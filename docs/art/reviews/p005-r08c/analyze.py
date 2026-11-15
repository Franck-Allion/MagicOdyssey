"""Read-only alpha-visible geometry, source-byte and desktop verification."""
from pathlib import Path
import hashlib
import json
import numpy as np
from PIL import Image
ROOT = Path(__file__).resolve().parents[4]
OUT = Path(__file__).resolve().parent
sources = json.loads((OUT.parent/'p005-r08b/asset_preflight.json').read_text())
for source in sources:
    assert hashlib.sha256((ROOT/source['path']).read_bytes()).hexdigest() == source['sha256'], source['path']

panel = np.array(Image.open(ROOT/'assets/_source/lot1/hud/utility/mo_hud_utility_panel_v01.png')).astype(float)
bronze = (panel[:,:,3]>128) & (panel[:,:,0]>1.12*panel[:,:,1]) & (panel[:,:,1]>1.12*panel[:,:,2])
scale = 684/1964
panel_x = 20+(232-664*scale)/2
lips = []
for y in range(258,570):
    xs = np.where(bronze[round(12+y/scale)])[0]
    left, right = xs[xs<395], xs[xs>395]
    lips.append([panel_x+(left.max()-64)*scale,panel_x+(right.min()-64)*scale])
inner_left, inner_right = max(x[0] for x in lips), min(x[1] for x in lips)

bounds = {Path(s['path']).name:s['bounds_alpha8'] for s in sources}
def mapped(bounds, origin, size, native):
    x,y = origin; w,h = size
    return [x+bounds[0]*w/native[0],y+bounds[1]*h/native[1],x+bounds[2]*w/native[0],y+bounds[3]*h/native[1]]
def union(rects):
    return [min(r[0] for r in rects),min(r[1] for r in rects),max(r[2] for r in rects),max(r[3] for r in rects)]
def measure(dx,gx,y,view_h,button_x,button_y,button_w):
    deck_h = min(view_h-66,(104-8)/0.75)
    deck_w = deck_h*0.75
    deck = union([mapped(bounds['mo_hud_opponent_card_back_v01.png'],(dx+(104-deck_w)/2-3+i*1.5,y+5-i),(deck_w,deck_h),(1086,1448)) for i in range(5)])
    grave_h = view_h-66
    grave_w = grave_h*0.75
    grave = mapped(bounds['mo_card_frame_master_v03.png'],(gx+(104-grave_w)/2,y+2),(grave_w,grave_h),(1086,1448))
    empty = mapped(bounds['mo_hud_graveyard_empty_v01.png'],(gx+(104-grave_w)/2,y+2),(grave_w,grave_h),(1086,1448))
    button_h = button_w*522/2090
    button = mapped(bounds['mo_hud_end_turn_normal_v01.png'],(button_x,button_y),(button_w,button_h),(2090,522))
    return dict(deck_bounds=deck,faceup_bounds=grave,empty_bounds=empty,button_bounds=button,
                deck_height=deck_h,graveyard_height=grave_h,
                left_card_margin=deck[0]-inner_left,right_card_margin=inner_right-grave[2],
                card_gap=grave[0]-deck[2],button_left_margin=button[0]-inner_left,button_right_margin=inner_right-button[2],
                counter_to_button_gap=button[1]-(y+view_h),button_to_panel_bottom=684-button[3])
baseline = measure(30,138,296,200,20,558,232)
option_a = measure(32,136,258,200,40.38,520,190)
option_b = measure(35,133,258,178,40.38,520,190)
assert min(option_b['left_card_margin'],option_b['right_card_margin']) >= 11
assert option_b['card_gap'] >= 16
assert min(option_b['button_left_margin'],option_b['button_right_margin']) >= 8
painted_width = (719-72)*scale
required_inner = baseline['deck_bounds'][2]-baseline['deck_bounds'][0]+baseline['faceup_bounds'][2]-baseline['faceup_bounds'][0]+16+24
required_painted = required_inner+(painted_width-(inner_right-inner_left))
result = dict(source_hashes_unchanged=True,source_manifest=sources,metal_detection='RGB bronze ratio with alpha >128; conservative horizontal silhouette projections, not an artist-authored mask',panel_inner=[inner_left,inner_right],panel_inner_width=inner_right-inner_left,panel_painted_width=painted_width,baseline=baseline,option_a=option_a,option_b=option_b,option_c=dict(required_inner_width=required_inner,required_painted_width=required_painted,increase=required_painted-painted_width,uniform_fit_height=684*required_painted/painted_width,art_refinement_required_for_full_size=True,required_for_selected_option_b=False))

# Actual source-image hash equality and full GPU preservation are separate checks.
result['gpu_parity'] = {}
for height in [1080,720]:
    before=np.array(Image.open(OUT/f'before_{height}p.png'))
    after=np.array(Image.open(OUT/f'combat_screen_{height}p.png'))
    sx=round(1624*height/1080); sy=round(372*height/1080)
    changed_left=int(np.any(before[:,:sx]!=after[:,:sx],axis=2).sum())
    changed_header=int(np.any(before[:sy,sx:]!=after[:sy,sx:],axis=2).sum())
    assert changed_left == changed_header == 0
    result['gpu_parity'][str(height)]=dict(left_changed=changed_left,header_changed=changed_header)

if '--desktop' in __import__('sys').argv:
    result['desktop']={}
    for mode in ['default','1920x1080','1280x720']:
        normal=np.array(Image.open(OUT/f'desktop-{mode}.png'))
        height,width=normal.shape[:2]
        f=min(width/1920,height/1080); ox=(width-1920*f)/2; oy=(height-1080*f)/2
        def crop(a,rect):
            x,y,w,h=rect
            return a[round(oy+y*f):round(oy+(y+h)*f),round(ox+x*f):round(ox+(x+w)*f)]
        frames=[np.array(Image.open(OUT/f'desktop-{mode}-motion-{i}.png')) for i in range(8)]
        reservoirs={}
        for name,rect in {'player_hp':(130,660,50,50),'player_mana':(130,860,50,50),'opponent_hp':(98,180,12,12),'opponent_mana':(98,234,12,12)}.items():
            changes=[int(np.any(crop(a,rect)!=crop(b,rect),axis=2).sum()) for a,b in zip(frames,frames[1:])]
            assert max(changes)>0,(mode,name)
            reservoirs[name]=changes
        hover=np.array(Image.open(OUT/f'desktop-{mode}-button-hover.png'))
        pressed=np.array(Image.open(OUT/f'desktop-{mode}-button-pressed.png'))
        button_delta=int(np.any(crop(hover,(1664,892,192,49))!=crop(pressed,(1664,892,192,49)),axis=2).sum())
        assert button_delta>0
        hand=np.array(Image.open(OUT/f'desktop-{mode}-hover-center.png'))
        hand_delta=int(np.any(crop(normal,(320,500,1280,556))!=crop(hand,(320,500,1280,556)),axis=2).sum())
        assert hand_delta>0
        log=(OUT/f'desktop-{mode}.log').read_text(encoding='utf-8-sig')
        assert log.count('UTILITY_PREVIEW_ACTIVATED')==2 and 'UTILITY_PREVIEW_FOCUSED' in log
        assert 'ERROR' not in log and 'WARNING' not in log
        result['desktop'][mode]=dict(client=[width,height],reservoir_changes=reservoirs,button_changed=button_delta,hand_changed=hand_delta,native_focus=True,mouse_and_space_activations=2)
(OUT/'analysis.json').write_text(json.dumps(result,indent=2)+'\n')
print('PASS: source bytes unchanged, measured silhouette margins/gap, button clearance and GPU parity'+(', three desktop modes' if 'desktop' in result else ''))
print(json.dumps({k:result[k] for k in ['panel_inner_width','panel_painted_width','option_b','option_c']},indent=2))
