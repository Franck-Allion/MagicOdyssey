"""Read-only analysis of original GPU captures; no screenshot retouching."""
from pathlib import Path
import hashlib,json,re,subprocess
import numpy as np
from PIL import Image

ROOT=Path(__file__).resolve().parents[4]
OUT=Path(__file__).resolve().parent

def text(path):
    b=path.read_bytes()
    return b.decode('utf-16' if b.startswith(b'\xff\xfe') else 'utf-8-sig')

def luminance(rgb):
    rgb=np.asarray(rgb)/255.0
    rgb=np.where(rgb<=0.04045,rgb/12.92,((rgb+0.055)/1.055)**2.4)
    return rgb @ np.array([.2126,.7152,.0722])

def run():
    assert not re.search('SCRIPT ERROR|Parse Error|ERROR:',text(OUT/'gpu.log'))
    result=json.loads((OUT/'gpu_results.json').read_text())
    assert result['checks']['failed']==0
    records=[]
    for meta in result['layout']:
        variant,height=meta['variant'],meta['height']
        position=next(p['position'] for p in json.loads((OUT/'background_positions.json').read_text()) if p['variant']==variant and p['height']==height)
        background=np.array(Image.open(OUT/f'background_{variant}_{height}p.png').convert('RGBA'))
        shift=np.floor(position).astype(int)-5
        for stat,cell in enumerate(meta['cells']):
            material=np.array(Image.open(OUT/f'probes/{variant}_{stat}_material_{height}p.png').convert('RGBA'))
            xy=np.array(meta['origin'])+np.array(cell[:2])*meta['scale']
            end=xy+np.array(cell[2:])*meta['scale']
            for value in [0,1,2,3,6,8,10,12,14,99]:
                path=OUT/f'probes/{variant}_{stat}_{value}_{height}p.png'
                a=np.array(Image.open(path).convert('RGBA'))
                ink=(a[:,:,3]>=128)&(a[:,:,0]>=150)&(a[:,:,1]>=150)&(a[:,:,2]>=140)
                y,x=np.nonzero(ink); assert len(x),path
                ey,ex=np.nonzero(a[:,:,3]>0)
                bbox=[int(x.min()),int(y.min()),int(x.max()-x.min()+1),int(y.max()-y.min()+1)]
                margin=float(min(x.min()-xy[0],y.min()-xy[1],end[0]-(x.max()+1),end[1]-(y.max()+1)))
                assert margin>=0,(path,margin)
                full_margin=float(min(ex.min()-xy[0],ey.min()-xy[1],end[0]-(ex.max()+1),end[1]-(ey.max()+1)))
                assert full_margin>=0,(path,full_margin)
                gaps=[]
                for other_index,other_cell in enumerate(meta['cells']):
                    if other_index==stat:continue
                    start=np.array(meta['origin'])+np.array(other_cell[:2])*meta['scale']
                    finish=start+np.array(other_cell[2:])*meta['scale']
                    dx=max(float(start[0]-(x.max()+1)),float(x.min()-finish[0]),0.0)
                    dy=max(float(start[1]-(y.max()+1)),float(y.min()-finish[1]),0.0)
                    gaps.append((dx*dx+dy*dy)**.5)
                bg=background[y+shift[1],x+shift[0],:3]
                coverage=a[y,x,3:4]/255.0
                composite=a[y,x,:3]*coverage+bg*(1-coverage)
                foreground_luma=luminance(composite)
                background_luma=luminance(bg)
                ratio=(np.maximum(foreground_luma,background_luma)+0.05)/(np.minimum(foreground_luma,background_luma)+0.05)
                # Positive ink outside the source material's visible alpha footprint.
                spill=int(np.count_nonzero(ink&(material[:,:,3]<128)))
                records.append({'variant':variant,'resolution':height,'stat':['Attack','Armor','Shield','Health'][stat],'value':value,
                                'bright_ink_bbox_xywh':bbox,'all_alpha_bbox_xywh':[int(ex.min()),int(ey.min()),int(ex.max()-ex.min()+1),int(ey.max()-ey.min()+1)],
                                'minimum_cell_margin_px':margin,'clipped_by_cell':False,'outside_material_alpha128_ink_pixels':spill,
                                'full_alpha_cell_margin_px':full_margin,'nearest_other_stat_cell_distance_px':min(gaps),
                                'contrast_ratio_min':float(ratio.min()),'contrast_ratio_median':float(np.median(ratio)),
                                'secondary_zero_note':'Probe only; hidden in scene' if stat in [1,2] and value==0 else None})
    assert len(records)==240
    (OUT/'measurements.json').write_text(json.dumps({'method':'GPU probes, alpha>=128 and RGB bright-ink thresholds 150/150/140; material alpha and same-phase actual no-ink scene backgrounds; contrast uses straight-alpha probe compositing over the actual background and sRGB relative luminance, not an accessibility certification. Ink and full-alpha/stroke bounds are both checked against cell bounds.','records':records},indent=2)+'\n')
    protected={}
    paths=subprocess.check_output(['git','ls-files','scripts','scenes','assets','resources','project.godot','export_presets.cfg'],cwd=ROOT).decode().splitlines()
    for rel in paths:
        data=(ROOT/rel).read_bytes(); head=subprocess.check_output(['git','show','HEAD:'+rel],cwd=ROOT)
        if not rel.endswith('.png'):
            data=data.replace(b'\r\n',b'\n'); head=head.replace(b'\r\n',b'\n')
        assert data==head,rel
        protected[rel]=hashlib.sha256(data).hexdigest()
    for variant in ['baseline','variant_a','variant_b','variant_c']:
        for height in [720,1080]:
            a=np.array(Image.open(OUT/f'{variant}_empty_{height}p.png'))
            b=np.array(Image.open(ROOT/f'docs/art/reviews/p006/board_idle_{height}p.png'))
            assert np.array_equal(a,b),(variant,height)
    (OUT/'preservation.json').write_text(json.dumps({'tracked_production_files_match_HEAD':protected,'empty_board_differing_pixels':0,'native_assertions_unmodified':True},indent=2)+'\n')
    screenshots=sorted(p.name for p in OUT.glob('*.png'))
    (OUT/'index.md').write_text('# P008-F01 GPU evidence index\n\nUnretouched Godot captures. A/B/C use identical data and footprint. Numbered status icons, +N and W/P are NON-PRODUCTION placeholders. Background files are genuine no-ink diagnostic renders for contrast analysis.\n\n'+''.join(f'- [{name}]({name})\n' for name in screenshots)+'\n[Glyph probes](probes/) · [Measurements](measurements.json) · [Review](review.md)\n')
    for v in ['a','b','c']:
        chosen=[r for r in records if r['variant']==v and r['resolution']==720]
        print(v,[(r['stat'],r['value'],r['bright_ink_bbox_xywh'][2:],round(r['contrast_ratio_min'],2),r['outside_material_alpha128_ink_pixels']) for r in chosen if r['value'] in [1,12]])
    print('PROTECTED_FILES',len(protected),'MEASUREMENTS',len(records),'GPU',result['checks'])

if __name__=='__main__':run()
