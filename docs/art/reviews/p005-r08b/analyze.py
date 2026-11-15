"""Read-only source and desktop evidence analysis. Does not rewrite any image."""
from pathlib import Path
import hashlib
import json
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[4]
OUT = Path(__file__).resolve().parent
records = json.loads((OUT / 'asset_preflight.json').read_text())
for item in records:
    source = ROOT / item['path']
    assert hashlib.sha256(source.read_bytes()).hexdigest() == item['sha256'], source
    a = np.array(Image.open(source).convert('RGBA')).astype(int)
    r, g, b, alpha = (a[:, :, i] for i in range(4))
    item['visible_red_fringe_pixels'] = int(((r > 180) & (g < 70) & (b < 70) & (alpha > 8)).sum())
    item['visible_green_fringe_pixels'] = int(((g > 100) & (g > r * 1.5) & (g > b * 1.5) & (alpha > 32)).sum())
    assert item['visible_red_fringe_pixels'] == 0
    if 'utility_panel' in source.name:
        interior = alpha[300:1600, 200:590]
    elif 'turn_phase' in source.name:
        interior = alpha[240:640, 220:1550]
    elif 'end_turn' in source.name:
        interior = alpha[140:390, 400:1690]
    elif 'card_back' in source.name:
        interior = alpha[160:1288, 160:926]
    else:
        interior = None
    if interior is not None:
        item['interior_alpha_range'] = [int(interior.min()), int(interior.max())]
        assert interior.min() >= 250, source
    item['png_unchanged'] = True

results = {'sources': records, 'desktop': {}}
for mode in ['default', '1920x1080', '1280x720']:
    normal = np.array(Image.open(OUT / f'desktop-{mode}.png'))
    height, width = normal.shape[:2]
    factor = min(width / 1920, height / 1080)
    ox, oy = (width - 1920 * factor) / 2, (height - 1080 * factor) / 2
    def crop(image, rect):
        x, y, w, h = rect
        x0, y0 = round(ox + x * factor), round(oy + y * factor)
        x1, y1 = round(ox + (x+w) * factor), round(oy + (y+h) * factor)
        return image[y0:y1, x0:x1]
    frames = [np.array(Image.open(OUT / f'desktop-{mode}-motion-{i}.png')) for i in range(8)]
    reservoirs = {}
    for name, rect in {'player_hp': (130,660,50,50), 'player_mana': (130,860,50,50),
                       'opponent_hp': (98,180,12,12), 'opponent_mana': (98,234,12,12)}.items():
        changes = [int(np.any(crop(a,rect) != crop(b,rect), axis=2).sum()) for a,b in zip(frames,frames[1:])]
        assert max(changes) > 0, (mode, name, changes)
        reservoirs[name] = changes
    button_rect = (1644,930,232,58)
    hover = np.array(Image.open(OUT / f'desktop-{mode}-button-hover.png'))
    pressed = np.array(Image.open(OUT / f'desktop-{mode}-button-pressed.png'))
    button_delta = int(np.any(crop(hover,button_rect) != crop(pressed,button_rect),axis=2).sum())
    assert button_delta > 0, mode
    hovered_hand = np.array(Image.open(OUT / f'desktop-{mode}-hover-center.png'))
    hand_delta = int(np.any(crop(normal,(320,500,1280,556)) != crop(hovered_hand,(320,500,1280,556)),axis=2).sum())
    assert hand_delta > 0
    log = (OUT / f'desktop-{mode}.log').read_text(encoding='utf-8-sig')
    assert 'UTILITY_PREVIEW_ACTIVATED' in log
    assert 'ERROR' not in log and 'WARNING' not in log
    results['desktop'][mode] = dict(client=[width,height],reservoir_changes=reservoirs,
                                    button_hover_pressed_changed_pixels=button_delta,
                                    center_hand_hover_changed_pixels=hand_delta)
(OUT / 'analysis.json').write_text(json.dumps(results,indent=2)+'\n')
print('PASS: source bytes, asset interiors, all four animated desktop reservoirs, native button and hand hover in three modes')
