"""Measure untouched GPU captures of the actual shared production renderer."""
from pathlib import Path
import json
import numpy as np
from PIL import Image

OUT = Path(__file__).resolve().parent
VARIANTS = ['a','b','c','c14','n','d']
VALUES = [0,1,2,3,6,7,8,10,12,14,99]


def bbox(mask):
    y,x = np.nonzero(mask)
    return [int(x.min()),int(y.min()),int(x.max()-x.min()+1),int(y.max()-y.min()+1)] if len(x) else None


def luminance(rgb):
    rgb=np.asarray(rgb)/255
    rgb=np.where(rgb<=.04045,rgb/12.92,((rgb+.055)/1.055)**2.4)
    return rgb @ np.array([.2126,.7152,.0722])


def distances(mask, target):
    y,x=np.nonzero(mask)
    ty,tx=np.nonzero(target)
    if not len(x) or not len(tx): return []
    return np.sqrt(((x[:,None]-tx)**2+(y[:,None]-ty)**2).min(axis=1))


def holes(mask):
    # Connected components of background enclosed by the bright-ink silhouette.
    seen=np.zeros_like(mask)
    areas=[]
    height,width=mask.shape
    for y,x in zip(*np.nonzero(~mask)):
        if seen[y,x]: continue
        stack=[(int(y),int(x))]
        seen[y,x]=True
        boundary=False
        size=0
        while stack:
            yy,xx=stack.pop()
            size+=1
            if yy in [0,height-1] or xx in [0,width-1]: boundary=True
            for ny,nx in [(yy-1,xx),(yy+1,xx),(yy,xx-1),(yy,xx+1)]:
                if 0<=ny<height and 0<=nx<width and not mask[ny,nx] and not seen[ny,nx]:
                    seen[ny,nx]=True
                    stack.append((ny,nx))
        if not boundary: areas.append(size)
    return areas


def run():
    results=json.loads((OUT/'results.json').read_text())
    assert results['checks']['failed']==0
    assert not any(s in (OUT/'gpu.log').read_text(encoding='utf-8-sig') for s in ['SCRIPT ERROR','Parse Error','ERROR:'])
    records=[]
    for meta in results['layout']:
        v,h=meta['variant'],meta['height']
        background=np.array(Image.open(OUT/f'{v}_background_{h}p.png').convert('RGBA'))
        shift=np.floor(meta['scene_position']).astype(int)-5
        frame=np.array(Image.open(OUT/f'probes/{v}_frame_{h}p.png'))
        bronze=(frame[:,:,3]>=128)&(frame[:,:,0].astype(float)>frame[:,:,1]*1.15)&(frame[:,:,0]>75)
        for stat,cell in enumerate(meta['cells']):
            material=np.array(Image.open(OUT/f'probes/{v}_{stat}_material_{h}p.png'))
            for value in VALUES:
                full,fill,outline=[np.array(Image.open(OUT/f'probes/{v}_{stat}_{value}_{layer}_{h}p.png')) for layer in ['full','fill','outline']]
                ink=(fill[:,:,3]>=128)&(fill[:,:,0]>=150)&(fill[:,:,1]>=150)&(fill[:,:,2]>=140)
                all_alpha=full[:,:,3]>0
                y,x=np.nonzero(ink)
                assert len(x),(v,h,stat,value)
                background_rgb=background[y+shift[1],x+shift[0],:3]
                coverage=fill[y,x,3:4]/255
                fg=fill[y,x,:3]*coverage+background_rgb*(1-coverage)
                l1,l2=luminance(fg),luminance(background_rgb)
                ratio=(np.maximum(l1,l2)+.05)/(np.minimum(l1,l2)+.05)
                stroke=(outline[:,:,3]>=128)&~ink
                distance=distances(stroke,ink)
                sy,sx=np.nonzero(stroke)
                edge_ratios=[]
                if len(sx):
                    distances_sq=(x[:,None]-sx)**2+(y[:,None]-sy)**2
                    nearest=distances_sq.argmin(axis=1)
                    near=distances_sq.min(axis=1)<=4
                    if near.any():
                        ny,nx=sy[nearest[near]],sx[nearest[near]]
                        wa=full[y[near],x[near],3:4]/255
                        white=full[y[near],x[near],:3]*wa+background_rgb[near]*(1-wa)
                        oa=full[ny,nx,3:4]/255
                        stroke_rgb=full[ny,nx,:3]*oa+background[ny+shift[1],nx+shift[0],:3]*(1-oa)
                        wl,ol=luminance(white),luminance(stroke_rgb)
                        edge_ratios=(np.maximum(wl,ol)+.05)/(np.minimum(wl,ol)+.05)
                box=bbox(ink)
                assert box is not None
                crop=ink[box[1]:box[1]+box[3],box[0]:box[0]+box[2]]
                column_ink=crop.sum(axis=0)
                # Internal empty columns separate two glyphs (not a semantic kerning score).
                gap=int((column_ink==0).sum()) if value>=10 else None
                bfull=bbox(all_alpha)
                assert bfull is not None
                px=np.array(meta['origin'])+np.array(cell[:2])*meta['scale']
                end=px+np.array(cell[2:])*meta['scale']
                records.append({'variant':v,'resolution':h,'stat':['Attack','Armor','Shield','Health'][stat],'value':value,
                    'white_ink_bbox_xywh':box,'full_alpha_bbox_xywh':bfull,
                    'outline_alpha128_bbox_xywh':bbox(outline[:,:,3]>=128),
                    'outline_outside_fill_distance_median_px':float(np.median(distance)) if len(distance) else 0,
                    'outline_outside_fill_distance_p95_px':float(np.percentile(distance,95)) if len(distance) else 0,
                    'outline_outside_fill_distance_max_px':float(max(distance)) if len(distance) else 0,
                    'outline_core_pixels_outside_fill':int(stroke.sum()),
                    'partial_alpha_fill_fraction':float(((fill[:,:,3]>0)&(fill[:,:,3]<224)).sum()/max(1,(fill[:,:,3]>0).sum())),
                    'opaque_fill_pixels':int((fill[:,:,3]>=224).sum()),
                    'enclosed_counter_areas_px':holes(crop),'two_digit_empty_column_count':gap,
                    'outside_material_alpha128_white_pixels':int((ink&(material[:,:,3]<128)).sum()),
                    'bronze_overlap_white_pixels':int((ink&bronze).sum()),
                    'bronze_overlap_full_alpha128_pixels':int(((full[:,:,3]>=128)&bronze).sum()),
                    'full_alpha_material_rectangle_margin_px':float(min(bfull[0]-px[0],bfull[1]-px[1],end[0]-bfull[0]-bfull[2],end[1]-bfull[1]-bfull[3])),
                    'contrast_min':float(ratio.min()),'contrast_median':float(np.median(ratio)),
                    'white_to_near_outline_contrast_min':float(min(edge_ratios)) if len(edge_ratios) else None,
                    'white_to_near_outline_contrast_median':float(np.median(edge_ratios)) if len(edge_ratios) else None,
                    'secondary_zero_note':'hypothetical probe only; numeral/material suppressed in scenes' if stat in [1,2] and value==0 else None})
    assert len(records)==len(VARIANTS)*2*4*len(VALUES)
    data={'method':'Actual production/HEAD renderer and fitter. Per-layer probes retain the same font, fit and stroke padding. Fill alpha>=128 and RGB>=150/150/140. Stroke thickness measures nearest bright-fill pixel-center distances for alpha>=128 outline pixels outside fill; raster distance, not vector width. Full alpha includes AA and stroke. Contrast uses actual active-material no-ink GPU background and straight-alpha compositing; no accessibility certification. Counter count/partial-alpha fraction are diagnostics, not perceptual scores. Bronze uses the disclosed warm-color predicate.','records':records}
    (OUT/'measurements.json').write_text(json.dumps(data,indent=2)+'\n')
    for v in VARIANTS:
        chosen=[r for r in records if r['variant']==v and r['resolution']==720]
        print(v,[(r['stat'],r['value'],r['white_ink_bbox_xywh'][2:],r['full_alpha_bbox_xywh'][2:],r['outline_outside_fill_distance_p95_px'],r['enclosed_counter_areas_px'],r['outside_material_alpha128_white_pixels'],r['bronze_overlap_white_pixels']) for r in chosen if r['value'] in [6,8,12,99]])


if __name__=='__main__': run()
