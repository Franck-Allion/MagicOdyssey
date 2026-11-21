"""Source alpha and genuine raster analysis; never alters supplied artwork."""
from pathlib import Path
import hashlib
import json
import subprocess
import numpy as np
from PIL import Image, ImageDraw

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[4]


def bbox(mask):
    y, x = np.nonzero(mask)
    return [int(x.min()), int(y.min()), int(x.max()-x.min()+1), int(y.max()-y.min()+1)] if len(x) else None


def component(alpha, seed):
    image = Image.fromarray(np.where(alpha == 0, 0, 255).astype('uint8')).copy()
    ImageDraw.floodfill(image, seed, 128)
    return np.array(image) == 128


def exterior(alpha):
    image = Image.fromarray(np.where(alpha == 0, 0, 255).astype('uint8')).copy()
    w,h = image.size
    for seed in [(x,y) for x in range(w) for y in [0,h-1]] + [(x,y) for y in range(h) for x in [0,w-1]]:
        if image.getpixel(seed) == 0:
            ImageDraw.floodfill(image,seed,128)
    return np.array(image) == 128


def luminance(rgb):
    rgb = np.asarray(rgb)/255.0
    rgb = np.where(rgb <= .04045, rgb/12.92, ((rgb+.055)/1.055)**2.4)
    return rgb @ np.array([.2126, .7152, .0722])


def source():
    path = ROOT/'assets/_source/lot1/tokens/mo_creature_token_frame_v05_final.png'
    runtime = ROOT/'assets/textures/tokens/mo_creature_token_frame_v05_final.png'
    image = Image.open(path)
    a = np.array(image)
    assert image.mode == 'RGBA' and image.size == (1536, 1024)
    alpha = a[:, :, 3]
    old = np.array(Image.open(OUT.parent/'original_v05.png'))
    expected = old[:, :, 3].copy()
    expected[expected <= 1] = 0
    expected[expected >= 254] = 255
    apertures = {}
    for name, seed in [('exterior',(0,0)),('portrait',(768,350)),('Attack',(216,823)),('Health',(1320,823))]:
        mask = exterior(alpha) if name == 'exterior' else component(alpha, seed)
        apertures[name] = {'alpha_zero_bbox_xywh': bbox(mask), 'pixels': int(mask.sum())}
        Image.fromarray((mask*255).astype('uint8')).save(OUT/f'alpha_{name}.png')
    scanlines = {}
    for y in [488,598,653,750,780,800,821,851,900,920]:
        mask = alpha[y] == 0
        edges = np.flatnonzero(np.diff(np.pad(mask.astype(int),(1,1))))
        scanlines[y] = [[int(start),int(end-1)] for start,end in zip(edges[::2],edges[1::2]) if end-start > 10]
    unit = 1536/154
    cells = [[1,63,39,38.6667],[43,49,32,33],[79,49,32,33],[114,63,39,38.6667]]
    cells = [[v*unit for v in r] for r in cells]
    actual = [[66,673,300,300],[365,788,380,126],[780,782,380,138],[1170,673,300,300]]
    # Source polygon read directly from HEAD layout; geometric diagnostic only.
    import re
    text = (ROOT/'scripts/presentation/creature_token_layout.gd').read_text()
    polytext = text.split('const PORTRAIT_POLYGON:')[1].split('const STATUS_ORIGIN:')[0]
    polygon = [(float(x),float(y)) for x,y in re.findall(r'Vector2\((\d+), (\d+)\)',polytext)]
    pm = Image.new('L',image.size)
    ImageDraw.Draw(pm).polygon(polygon,fill=255)
    pm = np.array(pm)>0
    portrait = component(alpha,(768,350))
    data = {'mode': image.mode, 'size': list(image.size), 'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
            'runtime_byte_identical': path.read_bytes()==runtime.read_bytes(),
            'alpha_histogram': np.bincount(alpha.ravel(),minlength=256).tolist(),
            'rgb_equal_to_pre_normalization_reference': bool(np.array_equal(a[:,:,:3],old[:,:,:3])),
            'alpha_matches_exact_0_1_and_254_255_normalization': bool(np.array_equal(alpha,expected)),
            'apertures': apertures, 'transparent_scanlines_inclusive': scanlines,
            'variant_b_cells_source_xywh': cells,'HEAD_cells_source_xywh': actual,
            'portrait_unfilled_alpha0_pixels':int((portrait&~pm).sum()),
            'portrait_spill_attack_alpha0_pixels':int((component(alpha,(216,823))&pm).sum()),
            'portrait_spill_health_alpha0_pixels':int((component(alpha,(1320,823))&pm).sum()),
            'portrait_spill_exterior_alpha0_pixels':int((exterior(alpha)&pm).sum())}
    (OUT/'source.json').write_text(json.dumps(data,indent=2)+'\n')
    for color,name in [('#202530','dark'),('#eeeeee','bright')]:
        bg=Image.new('RGBA',image.size,color)
        bg.alpha_composite(image)
        bg.save(OUT/f'composite_{name}.png')
    print('SOURCE', {k:v for k,v in data.items() if k not in ['alpha_histogram','transparent_scanlines_inclusive']})


def glyphs():
    result = json.loads((OUT/'results.json').read_text())
    assert result['checks']['failed']==0
    assert not any(x in (OUT/'gpu.log').read_text(encoding='utf-8-sig') for x in ['SCRIPT ERROR','Parse Error','ERROR:'])
    assert '"failed": 0' in (OUT/'backgrounds.log').read_text(encoding='utf-8-sig')
    records=[]
    for meta in result['layout']:
        variant,h=meta['variant'],meta['height']
        background=np.array(Image.open(OUT/f'{variant}_background_{h}p.png').convert('RGBA'))
        frame=np.array(Image.open(OUT/f'probes/{variant}_frame_{h}p.png')) if variant!='b' else None
        # Bronze classification excludes dark neutral plaque interiors.
        bronze=(frame[:,:,3]>=128)&(frame[:,:,0].astype(float)>frame[:,:,1]*1.15)&(frame[:,:,0]>75) if frame is not None else np.zeros((120,180),bool)
        by,bx=np.nonzero(bronze)
        shift=np.floor(meta['scene_position']).astype(int)-5
        for stat,cell in enumerate(meta['cells']):
            material=np.array(Image.open(OUT/f'probes/{variant}_{stat}_material_{h}p.png'))
            xy=np.array(meta['origin'])+np.array(cell[:2])*meta['scale']
            end=xy+np.array(cell[2:])*meta['scale']
            for value in [0,1,2,3,6,8,10,12,14,99]:
                a=np.array(Image.open(OUT/f'probes/{variant}_{stat}_{value}_{h}p.png'))
                ink=(a[:,:,3]>=128)&(a[:,:,0]>=150)&(a[:,:,1]>=150)&(a[:,:,2]>=140)
                y,x=np.nonzero(ink)
                assert len(x)>0,(variant,h,stat,value)
                full=a[:,:,3]>0
                ey,ex=np.nonzero(full)
                bg=background[y+shift[1],x+shift[0],:3]
                coverage=a[y,x,3:4]/255
                fg=a[y,x,:3]*coverage+bg*(1-coverage)
                l1,l2=luminance(fg),luminance(bg)
                contrast=(np.maximum(l1,l2)+.05)/(np.minimum(l1,l2)+.05)
                distance=float(np.sqrt(((x[:,None]-bx)**2+(y[:,None]-by)**2).min())) if len(bx) else None
                records.append({'variant':variant,'resolution':h,'stat':['Attack','Armor','Shield','Health'][stat],'value':value,
                    'bright_ink_bbox_xywh':bbox(ink),'all_alpha_bbox_xywh':bbox(full),
                    'minimum_full_alpha_cell_margin_px':float(min(ex.min()-xy[0],ey.min()-xy[1],end[0]-ex.max()-1,end[1]-ey.max()-1)),
                    'outside_material_alpha128_ink_pixels':int((ink&(material[:,:,3]<128)).sum()),
                    'bronze_overlap_bright_pixels':int((ink&bronze).sum()),'nearest_bronze_pixel_center_px':distance,
                    'contrast_min':float(contrast.min()),'contrast_median':float(np.median(contrast)),
                    'secondary_zero':'hypothetical glyph probe; suppressed in real scene' if stat in [1,2] and value==0 else None})
    assert len(records)==240
    (OUT/'measurements.json').write_text(json.dumps({'method':'Actual production/benchmark draw_number, native first-slot scale and fractional phase. Bright alpha>=128 RGB>=150/150/140. Full-alpha includes stroke/shadow. Bronze is a declared warm-color predicate, not semantic segmentation. Contrast uses real no-ink GPU backgrounds with all defenses active. Distances are pixel-center distances.','records':records},indent=2)+'\n')
    for v in ['v03','b','v05']:
        print(v,[(r['stat'],r['value'],r['bright_ink_bbox_xywh'][2:],r['outside_material_alpha128_ink_pixels'],r['bronze_overlap_bright_pixels']) for r in records if r['variant']==v and r['resolution']==720 and r['value'] in [1,12,14,99]])
    print('GPU',result['checks'])


if __name__ == '__main__':
    source()
    if (OUT/'results.json').exists(): glyphs()
