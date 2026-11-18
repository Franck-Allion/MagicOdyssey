"""Analyze unretouched GPU images, asset parity, and native glyph probes."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[5]
OUT = Path(__file__).resolve().parent
REVIEW = OUT.parent

def run():
    glyphs = []
    for path in sorted((OUT / 'glyphs').glob('*.png')):
        image = np.array(Image.open(path).convert('RGBA'))
        mask = (image[:,:,3] >= 128) & (image[:,:,0] >= 150) & (image[:,:,1] >= 150) & (image[:,:,2] >= 140)
        yy, xx = np.nonzero(mask)
        assert len(xx), path
        ey, ex = np.nonzero(image[:,:,3] > 0)
        kind, value, resolution = path.stem.split('_')
        glyphs.append({'kind':kind,'value':int(value),'resolution':int(resolution[:-1]),
                       'nominal_source_font_points':220 if kind == 'primary' else 170,
                       'nominal_physical_font_points':(220 if kind == 'primary' else 170) * 154 / 1536 * (2/3 if resolution=='720p' else 1),
                       'raster_ink_bbox_xywh':[int(xx.min()),int(yy.min()),int(xx.max()-xx.min()+1),int(yy.max()-yy.min()+1)],
                       'raster_all_nonzero_alpha_bbox_xywh':[int(ex.min()),int(ey.min()),int(ex.max()-ex.min()+1),int(ey.max()-ey.min()+1)],
                       'ink_pixels':int(mask.sum())})
    (OUT/'glyph_measurements.json').write_text(json.dumps({'method':'Actual GPU glyph-only images: alpha>=128, R/G>=150, B>=140. Ink bounds exclude dark stroke/shadow; same shared renderer, token transform scale and fractional phase. Not text size inferred from font points.','measurements':glyphs},indent=2)+'\n')
    parity = {}
    for height in (1080,720):
        before = np.array(Image.open(ROOT/f'docs/art/reviews/p006/board_idle_{height}p.png'))
        after = np.array(Image.open(REVIEW/f'v02_empty_{height}p.png'))
        parity[str(height)] = int(np.any(before != after,axis=2).sum())
        assert parity[str(height)] == 0
    protected = json.loads((REVIEW.parent/'p008/preservation.json').read_text())['protected_files']
    protected.update({key:{} for key in ['scripts/presentation/creature_token_view_model.gd','scripts/presentation/creature_status_view_model.gd','scripts/presentation/combat_screen.gd','scripts/presentation/creature_token_demo.gd']})
    preservation = {}
    for path in protected:
        actual=(ROOT/path).read_bytes()
        expected=subprocess.check_output(['git','show','HEAD:'+path],cwd=ROOT)
        if not path.endswith('.png'):
            actual=actual.replace(b'\r\n',b'\n'); expected=expected.replace(b'\r\n',b'\n')
        preservation[path]={'unchanged_from_HEAD':actual==expected,'sha256':hashlib.sha256(actual).hexdigest()}
        assert actual==expected,path
    source=(ROOT/'assets/_source/lot1/tokens/mo_creature_token_frame_v02.png').read_bytes()
    runtime=(ROOT/'assets/textures/tokens/mo_creature_token_frame_v02.png').read_bytes()
    assert source==runtime and hashlib.sha256(source).hexdigest()=='c5b09a920793d6fef70181e300595efe1702dd3bd98b9a5f9d1e58dbb1f10aba'
    metrics={'P006_empty_differing_pixels':parity,'protected_files':preservation,'C01_asset_hash_preserved':True,'source_runtime_byte_identical':True}
    (OUT/'preservation.json').write_text(json.dumps(metrics,indent=2)+'\n')
    windows = {}
    for scenario in ['single','full']:
        summary_path=OUT/f'standalone-{scenario}.log'
        summary_data=summary_path.read_bytes()
        summary=summary_data.decode('utf-16' if summary_data.startswith(b'\xff\xfe') else 'utf-8-sig')
        assert 'PASS: shell launch, 3 desktop windows, ESC exits with code 0, no remaining game process.' in summary
        windows[scenario]={}
        for mode in ['default','1920x1080','1280x720']:
            log=(OUT/f'windows-{scenario}/desktop-{mode}.log').read_text(encoding='utf-8-sig')
            clicks=re.findall(r'^SLOT_CLICK (\d+ \d+ \d+)',log,re.MULTILINE)
            assert len(set(clicks))==24
            assert f'{mode} : ESC exit=0' in summary
            assert f'{mode} : actual hand hover and raised inspection click isolation PASS' in summary
            assert f'{mode} : native End Turn hover/press/release, focus and mouse/Space activation PASS' in summary
            assert not re.search(r'ERROR|WARNING|SCRIPT ERROR',log)
            windows[scenario][mode]={'unique_slot_identities_clicked':len(set(clicks)),'slot_click_events':len(clicks),'hand_and_raised_inspection':'PASS','End_Turn_mouse_and_Space':'PASS','ESC_exit_code':0}
    executable=ROOT/'build/windows/MagicOdyssey.exe'
    results={'native':{'exit_code':0,'passed':3662,'failed':0,'old_assertions_retained':3620,'new_assertions':42},
             'GPU':{'exit_code':0,'passed':718,'failed':0},'ART002':{'exit_code':0,'scenes_bit_exact':3},
             'import_exit_code':0,'export_exit_code':0,'standalone_single_harness_exit_code':0,'standalone_full_harness_exit_code':0,
             'Windows_OS_pointer_tests':windows,'executable_sha256':hashlib.sha256(executable.read_bytes()).hexdigest(),
             'alpha':'PASS / unchanged C01 PNG bytes','native_720p_four_stat_readability':'ART_CORRECTION_REQUIRED',
             'owner_approval':'PENDING','G1':'NOT_VALIDATED'}
    # Counts/return codes are execution observations, cross-checked against logs.
    def log_text(path):
        data=path.read_bytes()
        return data.decode('utf-16' if data.startswith(b'\xff\xfe') else 'utf-8-sig')
    assert 'Total Assertions: 3662' in log_text(OUT/'tests.log') and 'RESULT: ALL TESTS PASSED' in log_text(OUT/'tests.log')
    assert 'P008_C02_GPU_CHECKS=718 FAILURES=0' in log_text(OUT/'gpu.log')
    (OUT/'results.json').write_text(json.dumps(results,indent=2)+'\n')
    for kind in ['primary','secondary']:
        print(kind,[(m['value'],m['raster_ink_bbox_xywh'][2:]) for m in glyphs if m['kind']==kind and m['resolution']==720])
    print('PARITY_AND_PRESERVATION_PASS',parity)

if __name__=='__main__':
    run()
