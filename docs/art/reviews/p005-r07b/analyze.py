"""Read-only analysis of approved assets and actual GPU/desktop evidence."""
from pathlib import Path
import hashlib
import json
import numpy as np
from PIL import Image

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[3]
EXPECTED = {
    'opponent/mo_hud_opponent_card_back_v01.png': 'ce5d3e2873b4db7747121cda2e4b5abd4a11dc09804679603f4c18385617f681',
    'opponent/mo_hud_opponent_panel_v01.png': 'cab582589724f2df0986efbaca4b2b2118fdf70d951684bc13afb216a39202d4',
    'player/mo_hud_player_portrait_frame_v01.png': 'ba4e8a35cd786cfb2fd1125755dc17ce7d4a0062644ebbb75e10f5db6788ca91',
    'player/mo_hud_player_health_orb_housing_v01.png': 'ce58a60fd27e90988828292c02b2a8b6a7eb76d62fa1f140d20b3d2c9546ab0b',
}

def region(image, rect, factor=1.0):
    x,y,w,h = rect
    return np.asarray(image)[int(y*factor):int((y+h)*factor),int(x*factor):int((x+w)*factor)]

def changes(a,b):
    return int(np.any(a != b,axis=2).sum())

assets = []
for name,expected in EXPECTED.items():
    path = ROOT/'assets/_source/lot1/hud'/name
    actual = hashlib.sha256(path.read_bytes()).hexdigest()
    assert actual == expected, f'Source PNG changed: {name}'
    image = Image.open(path)
    alpha = image.getchannel('A')
    values = np.asarray(alpha)
    visible = Image.fromarray((values > 8).astype('uint8')*255).getbbox()
    assets.append(dict(path=str(path.relative_to(ROOT)),size=image.size,mode=image.mode,
        alpha_bbox=alpha.getbbox(),visible_alpha_gt8_bbox=visible,center_alpha=int(values[image.height//2,image.width//2]),
        transparent_pixels=int((values==0).sum()),sha256=actual))

parity = []
for height in [1080,720]:
    factor = height/1080
    before = Image.open(OUT/f'before_{height}p.png')
    after = Image.open(OUT/f'combat_screen_{height}p.png')
    for name,rect in [('player_hud',(24,344,272,700)),('battlefield',(320,220,1280,560)),
                      ('player_hand_with_hover_space',(320,344,1280,736)),('utilities',(1624,220,272,836))]:
        a,b = region(before,rect,factor),region(after,rect,factor)
        count = changes(a,b)
        maximum = int(np.abs(a.astype(int)-b.astype(int)).max())
        parity.append(dict(height=height,region=name,differing_pixels=count,max_channel_delta=maximum))
        # Text atlas rasterization can shift a boundary sample by 1/255 when
        # additional UI fonts are loaded. Report it, while keeping player parity strict.
        if name == 'battlefield':
            assert maximum <= 1 and count <= 16, f'Unexpected battlefield visual difference: {height}'
        else:
            assert count == 0, f'Unexpected production difference: {height} {name}'

desktop = []
for mode in ['default','1920x1080','1280x720']:
    frames = [Image.open(path) for path in sorted(OUT.glob(f'desktop-{mode}-motion-*.png'))]
    if not frames:
        continue
    width,height = frames[0].size
    factor = min(width/1920,height/1080)
    ox,oy = (width-1920*factor)/2,(height-1080*factor)/2
    for name,rect in [('opponent_hp',(82,164,44,44)),('opponent_mana',(82,218,44,44)),
                      ('player_hp',(70,596,180,180)),('player_mana',(70,796,180,180))]:
        x,y,w,h = rect
        crops = [np.asarray(im)[round(oy+y*factor):round(oy+(y+h)*factor),round(ox+x*factor):round(ox+(x+w)*factor)] for im in frames]
        counts = [changes(crops[i-1],crops[i]) for i in range(1,len(crops))]
        desktop.append(dict(mode=mode,orb=name,consecutive_changed_pixels=counts))
        assert sum(counts)>0, f'No desktop motion: {mode} {name}'

data = dict(assets=assets,unchanged_regions=parity,desktop_animation=desktop)
(OUT/'analysis.json').write_text(json.dumps(data,indent=2),encoding='utf-8')
print(json.dumps(data,indent=2))
print('PASS: approved sources unchanged, player/utility regions bit-exact, battlefield deltas quantified, available desktop motion verified.')
