from pathlib import Path
import hashlib,json,subprocess
import numpy as np
from PIL import Image

ROOT=Path(__file__).resolve().parents[4]
OUT=Path(__file__).resolve().parent

def run():
    measurements=[]
    counts={}
    for variant in 'AC':
        paths=list((OUT/variant/'glyphs').glob('*.png'))
        assert len(paths)==36,(variant,len(paths))
        for path in sorted(paths):
            a=np.array(Image.open(path).convert('RGBA'))
            mask=(a[:,:,3]>=128)&(a[:,:,0]>=150)&(a[:,:,1]>=150)&(a[:,:,2]>=140)
            y,x=np.nonzero(mask); ey,ex=np.nonzero(a[:,:,3]>0)
            kind,value,resolution=path.stem.split('_')
            measurements.append({'variant':variant,'kind':kind,'value':int(value),'resolution':int(resolution[:-1]),'ink_bbox_xywh':[int(x.min()),int(y.min()),int(x.max()-x.min()+1),int(y.max()-y.min()+1)],'all_alpha_bbox_xywh':[int(ex.min()),int(ey.min()),int(ex.max()-ex.min()+1),int(ey.max()-ey.min()+1)]})
        counts[variant]=json.loads((OUT/variant/'observations.json').read_text())['checks']
        for height in (720,1080):
            a=np.array(Image.open(OUT/variant/f'v02_empty_{height}p.png'))
            b=np.array(Image.open(ROOT/f'docs/art/reviews/p006/board_idle_{height}p.png'))
            assert np.array_equal(a,b),('empty baseline differs',variant,height)
    (OUT/'glyph_measurements.json').write_text(json.dumps({'method':'Actual GPU glyph probes; bright ink alpha>=128 and R/G>=150,B>=140. All-alpha box separately includes antialiasing/outline/shadow.','measurements':measurements},indent=2)+'\n')
    old=json.loads((OUT.parent/'p008-c/c02/preservation.json').read_text())['protected_files']
    preservation={}
    for path in old:
        if path.endswith('creature_token_demo.gd'):continue
        actual=(ROOT/path).read_bytes(); baseline=subprocess.check_output(['git','show','HEAD:'+path],cwd=ROOT)
        if not path.endswith('.png'):
            actual=actual.replace(b'\r\n',b'\n'); baseline=baseline.replace(b'\r\n',b'\n')
        assert actual==baseline,path
        preservation[path]=hashlib.sha256(actual).hexdigest()
    source=(ROOT/'assets/_source/lot1/tokens/mo_creature_token_frame_v03.png').read_bytes()
    assert hashlib.sha256(source).hexdigest()=='11aad8771668bedba8056d9d824144b702905b2f82008b8f371348512f598c28'
    assert source==(ROOT/'assets/textures/tokens/mo_creature_token_frame_v03.png').read_bytes()
    for version in [1,2]:
        for directory in ['assets/_source/lot1/tokens','assets/textures/tokens']:
            path=f'{directory}/mo_creature_token_frame_v0{version}.png'
            data=(ROOT/path).read_bytes()
            assert data==subprocess.check_output(['git','show','HEAD:'+path],cwd=ROOT),path
            preservation[path]=hashlib.sha256(data).hexdigest()
    (OUT/'preservation.json').write_text(json.dumps({'V03_source_runtime_identical_and_source_unchanged':True,'protected_files_match_HEAD':preservation,'empty_board_differing_pixels':0,'GPU_checks':counts},indent=2)+'\n')
    for v in 'AC':
        print(v,[(m['kind'],m['value'],m['ink_bbox_xywh'][2:]) for m in measurements if m['variant']==v and m['resolution']==720 and m['value'] in [1,2,12,14]])

if __name__=='__main__':run()
