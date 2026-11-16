"""Read-only visual audit measurements; no source or screenshot is rewritten."""
from pathlib import Path
import hashlib,json,re,math
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[4]
OUT=Path(__file__).resolve().parent
manifest=json.loads((OUT/'production_manifest.json').read_text())
for name,digest in manifest['sha256'].items():
    assert hashlib.sha256((ROOT/name).read_bytes()).hexdigest()==digest,name
obs=json.loads((OUT/'observations.json').read_text())
result={'baseline':manifest['baseline'],'production_hashes_unchanged':len(manifest['sha256']),'panels':{},'animation':{},'hover':{},'desktop':{}}

def alpha_bounds(path,crop=None):
    im=Image.open(path).convert('RGBA')
    if crop:
        x,y,w,h=map(int,crop);im=im.crop((x,y,x+w,y+h))
    a=np.array(im)[:,:,3];ys,xs=np.where(a>8)
    return [int(xs.min()),int(ys.min()),int(xs.max()+1),int(ys.max()+1)],im.size
for name,item in obs['artwork'].items():
    source=ROOT/item['source'].removeprefix('res://')
    bounds,native=alpha_bounds(source,item['crop'])
    x,y,w,h=item['rect'];scale=min(w/native[0],h/native[1]);ox=x+(w-native[0]*scale)/2;oy=y+(h-native[1]*scale)/2
    visible=[ox+bounds[0]*scale,oy+bounds[1]*scale,ox+bounds[2]*scale,oy+bounds[3]*scale]
    result['panels'][name]=dict(visible_bounds=visible,center=[(visible[0]+visible[2])/2,(visible[1]+visible[3])/2],source_bounds=bounds,uniform_scale=scale)

# Source geometry verified against the runtime region rectangles. Slot nodes have no runtime layout mutation.
scene=(ROOT/'scenes/combat/combat_screen.tscn').read_text()
nodes={}
for m in re.finditer(r'\[node name="([^"]+)"([^\]]*)\]([^\[]*)',scene):
    name,attrs,body=m.groups();pm=re.search(r'parent="([^"]+)"',attrs)
    if not pm:continue
    parent=pm.group(1);path=name if parent=='.' else parent+'/'+name
    vals={k:float(v) for k,v in re.findall(r'offset_(left|top|right|bottom) = (-?[0-9.]+)',body)}
    nodes[path]=(parent,vals)
def rect_for(path):
    parent,v=nodes[path]
    if path=='CombatLayout':return [0,0,1920,1080]
    px,py,_,_=rect_for(parent) if parent in nodes else [0,0,0,0]
    return [px+v.get('left',0),py+v.get('top',0),v.get('right',0)-v.get('left',0),v.get('bottom',0)-v.get('top',0)]
slots=[dict(path=p,rect=rect_for(p)) for p in nodes if '/SlotGuide_' in p]
assert len(slots)==24
for path,r in obs['regions'].items():
    assert np.allclose(rect_for(path),r),(path,rect_for(path),r)
left=min(s['rect'][0] for s in slots);right=max(s['rect'][0]+s['rect'][2] for s in slots)
rows=sorted(set(s['rect'][1] for s in slots))
result['slots']=dict(count=len(slots),rects=slots,column_grid_bounds=[left,right],column_grid_center=(left+right)/2,offset_from_screen_center=(left+right)/2-960,row_tops=rows,slot_size=slots[0]['rect'][2:],horizontal_gap=18,placeholder_size=[146,100])

frame_bounds,_=alpha_bounds(ROOT/'assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png')
back_bounds,_=alpha_bounds(ROOT/'assets/_source/lot1/hud/opponent/mo_hud_opponent_card_back_v01.png')
def transformed(bounds,center,angle,h):
    points=[];c=math.cos(angle);s=math.sin(angle)
    for x,y in [(bounds[0],bounds[1]),(bounds[2],bounds[1]),(bounds[2],bounds[3]),(bounds[0],bounds[3])]:
        dx=(x-543)*h/1448;dy=(y-724)*h/1448
        points.append((center[0]+dx*c-dy*s,center[1]+dx*s+dy*c))
    return [min(p[0] for p in points),min(p[1] for p in points),max(p[0] for p in points),max(p[1] for p in points)]
def union(rects):return [min(r[0] for r in rects),min(r[1] for r in rects),max(r[2] for r in rects),max(r[3] for r in rects)]
result['fan_source_geometry']={}
for count in [7,10]:
    half=(count-1)*.5;limit=math.radians(min(9,(count-1)*1.6));step=min(270*.64,(1280-270*.95-24)/(count-1));radius=step*max(half,1)/max(math.sin(limit),.001)
    outer_drop=radius*(1-math.cos(limit))*.2;outer_half=270*(math.cos(limit)+.75*math.sin(limit))*.5;cy=270-outer_half-outer_drop
    rects=[]
    for i in range(count):
        angle=(i-half)/max(half,1)*limit;drop=radius*(1-math.cos(angle))*.2
        rects.append(transformed(frame_bounds,(320+640+radius*math.sin(angle),804+cy+drop),angle,270))
    result['fan_source_geometry'][str(count)]=dict(painted_bounds=union(rects),axis=960,height=270)
backs=[transformed(back_bounds,(960+(i-2.5)*72,30+72+abs(i-2.5)*3),math.radians((i-2.5)*3.5),144) for i in range(6)]
result['opponent_hand_painted']=dict(bounds=union(backs),center_x=(union(backs)[0]+union(backs)[2])/2)

for height in [1080,720]:
    result['hover'][str(height)]=obs[f'hover_{height}p']
    frames=[np.array(Image.open(OUT/f'resource_animation_{height}p_{i:02d}.png')) for i in range(6)]
    reservoirs={}
    for orb in range(4):
        crops=[np.array(Image.open(OUT/f'orb_{height}p_{orb}_{i:02d}.png')) for i in range(6)]
        deltas=[dict(changed_pixels=int(np.any(a!=b,axis=2).sum()),max_channel_difference=int(np.abs(a.astype(int)-b.astype(int)).max())) for a,b in zip(crops,crops[1:])]
        assert max(d['changed_pixels'] for d in deltas)>0,(height,orb)
        reservoirs[str(orb)]=deltas
    result['animation'][str(height)]=dict(times_ms=obs[f'animation_times_{height}p'],reservoirs=reservoirs,scope='motion evidence; PNG I/O and audit overlays make this unsuitable as a frame-rate benchmark')
    # Default GPU view is compared with the accepted R08C production capture for evidence, not modified.
    a=np.array(Image.open(OUT/f'combat_default_{height}p.png'));b=np.array(Image.open(OUT.parent/f'p005-r08c/combat_screen_{height}p.png'))
    result.setdefault('default_r08c_comparison',{})[str(height)]=int(np.any(a!=b,axis=2).sum())

result['artifact_candidates']={
 'A':dict(rect=[296,344,24,436],physical_720=[16,290.67],assessment='Rejected: 24px gutter cannot hold a useful icon/hit target'),
 'B':dict(rect=[320,780,1280,24],physical_720=[853.33,16],assessment='Rejected: only 24px high and crossed by the real hover envelope'),
 'C':dict(rect=[1640,198,240,48],physical_720=[160,32],assessment='Spatially viable with reservations: use clear PLAYER/HERO affiliation and a future overlay input owner; the transparent top of MatchStatus is logically underneath'),
 'capacity':'No starting or maximum capacity inferred. Compact summary or visible subset plus +N; artwork, interaction and progression DEFERRED.'}

if '--desktop' in __import__('sys').argv:
    for mode in ['default','1920x1080','1280x720']:
        initial=np.array(Image.open(OUT/f'desktop-{mode}.png'));height,width=initial.shape[:2];f=min(width/1920,height/1080);ox=(width-1920*f)/2;oy=(height-1080*f)/2
        def crop(a,r):
            x,y,w,h=r;return a[round(oy+y*f):round(oy+(y+h)*f),round(ox+x*f):round(ox+(x+w)*f)]
        frames=[np.array(Image.open(OUT/f'desktop-{mode}-motion-{i}.png')) for i in range(8)]
        changes={}
        for name,r in {'player_hp':(130,660,50,50),'player_mana':(130,860,50,50),'opponent_hp':(98,180,12,12),'opponent_mana':(98,234,12,12)}.items():
            delta=[int(np.any(crop(a,r)!=crop(b,r),axis=2).sum()) for a,b in zip(frames,frames[1:])];assert max(delta)>0,(mode,name);changes[name]=delta
        hover=np.array(Image.open(OUT/f'desktop-{mode}-button-hover.png'));down=np.array(Image.open(OUT/f'desktop-{mode}-button-pressed.png'))
        button_delta=int(np.any(crop(hover,(1664,892,192,49))!=crop(down,(1664,892,192,49)),axis=2).sum());assert button_delta>0
        hand=np.array(Image.open(OUT/f'desktop-{mode}-hover-center.png'));hand_delta=int(np.any(crop(initial,(320,500,1280,556))!=crop(hand,(320,500,1280,556)),axis=2).sum());assert hand_delta>0
        log=(OUT/f'desktop-{mode}.log').read_text(encoding='utf-8-sig');assert log.count('UTILITY_PREVIEW_ACTIVATED')==2 and 'UTILITY_PREVIEW_FOCUSED' in log;assert 'ERROR' not in log and 'WARNING' not in log
        result['desktop'][mode]=dict(client=[width,height],reservoir_changed_pixels=changes,button_hover_pressed_changed_pixels=button_delta,center_hover_changed_pixels=hand_delta,mouse_and_space_activations=2,native_focus=True)
(OUT/'analysis.json').write_text(json.dumps(result,indent=2)+'\n')
print('PASS: production byte hashes unchanged, 24 slots measured, all four reservoirs move at both sizes, screenshots analyzed'+('; isolated desktop checks verified' if result['desktop'] else ''))
print(json.dumps({'panels':result['panels'],'grid':{k:v for k,v in result['slots'].items() if k!='rects'},'opponent_hand':result['opponent_hand_painted'],'default_parity':result['default_r08c_comparison']},indent=2))
