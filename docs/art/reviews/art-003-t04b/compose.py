"""Offline ART-003-T04B. Run from any directory; writes only beside this file.

Requires Pillow and numpy. Source PNGs are read-only. No Godot resources created.
"""
from __future__ import annotations

import hashlib
import json
from functools import lru_cache
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont, ImageOps

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[3]
HUD = ROOT / 'assets/_source/lot1/hud'
PATHS = {
    'panel': HUD / 'opponent/mo_hud_opponent_panel_v01.png',
    'frame': HUD / 'player/mo_hud_player_portrait_frame_v01.png',
    'housing': HUD / 'player/mo_hud_player_health_orb_housing_v01.png',
    'hero': ROOT / 'assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png',
    'context': ROOT / 'docs/art/reviews/p005-r06e/combat_screen_1080p.png',
    'background': ROOT / 'assets/_source/lot1/battlefield/wip/mo_battlefield_sundered_observatory_bg_wip_v03.png',
}
IMAGES = {k: Image.open(v).convert('RGBA') for k, v in PATHS.items()}
FONT = Path('C:/Windows/Fonts/segoeui.ttf')
BOLD = Path('C:/Windows/Fonts/segoeuib.ttf')
RESAMPLE = Image.Resampling.LANCZOS
VARIANTS = [(chr(65 + i), h, d) for i, (h, d) in enumerate(
    [(296, 90), (296, 100), (296, 105), (312, 90), (312, 100), (312, 105)])]


def aperture(image: Image.Image) -> Image.Image:
    """Extract only the enclosed center-connected transparent component."""
    alpha = image.getchannel('A')
    binary = alpha.point(lambda p: 255 if p < 128 else 0)
    ImageDraw.floodfill(binary, (image.width // 2, image.height // 2), 100, thresh=0)
    component = binary.point(lambda p: 255 if p == 100 else 0)
    # Include the one-pixel antialias fringe, weighted by the actual source alpha.
    return ImageChops.multiply(component.filter(ImageFilter.MaxFilter(3)), ImageOps.invert(alpha))


MASKS = {k: aperture(IMAGES[k]) for k in ['frame', 'housing']}


def ink_mask(text: str, size: int, bold: bool = False, stroke: int = 1) -> Image.Image:
    font = ImageFont.truetype(str(BOLD if bold else FONT), size)
    box = font.getbbox(text, stroke_width=stroke)
    mask = Image.new('L', (box[2] - box[0], box[3] - box[1]))
    ImageDraw.Draw(mask).text((-box[0], -box[1]), text, font=font,
                              fill=255, stroke_width=stroke, stroke_fill=255)
    return mask


def text(image: Image.Image, xy: tuple[int, int], label: str, size: int = 20,
         color: str = '#eee4cf', bold: bool = False) -> None:
    ImageDraw.Draw(image).text(xy, label,
        font=ImageFont.truetype(str(BOLD if bold else FONT), size), fill=color)


def label(image: Image.Image, center: tuple[float, float], value: str, size: int,
          color: str, bold: bool, stroke: int = 1) -> tuple[int, int, int, int]:
    mask = ink_mask(value, size, bold, stroke)
    x, y = round(center[0] - mask.width / 2), round(center[1] - mask.height / 2)
    font = ImageFont.truetype(str(BOLD if bold else FONT), size)
    box = font.getbbox(value, stroke_width=stroke)
    ImageDraw.Draw(image).text((x - box[0], y - box[1]), value, font=font,
        fill=color, stroke_width=stroke, stroke_fill='#080d19')
    return x, y, x + mask.width, y + mask.height


def panel(h: int) -> Image.Image:
    # Uniform scale by target height. 312 crops only near-transparent side padding.
    source = IMAGES['panel']
    w = round(source.width * h / source.height)
    scaled = source.resize((w, h), RESAMPLE)
    result = Image.new('RGBA', (272, h))
    result.alpha_composite(scaled, ((272 - w) // 2, 0))
    return result


@lru_cache(maxsize=None)
def portrait(size: int = 88) -> Image.Image:
    result = Image.new('RGBA', IMAGES['frame'].size)
    # Same existing face crop as the current CombatScreen; no new character.
    hero = IMAGES['hero'].crop((260, 40, 760, 540)).resize(result.size, RESAMPLE)
    hero.putalpha(MASKS['frame'])
    result.alpha_composite(hero)
    result.alpha_composite(IMAGES['frame'])
    return result.resize((size, size), RESAMPLE)


@lru_cache(maxsize=None)
def reservoir(size: int, blue: bool) -> Image.Image:
    yy, xx = np.mgrid[0:1254, 0:1254]
    radius = np.sqrt(((xx - 570) / 620) ** 2 + ((yy - 430) / 620) ** 2)
    intensity = np.clip(1.0 - radius * .55, .2, 1.0)
    base = np.array([47, 100, 230] if blue else [191, 44, 58])
    rgb = np.clip(intensity[..., None] * base + 8, 0, 255).astype('uint8')
    result = Image.fromarray(rgb).convert('RGBA')
    result.putalpha(MASKS['housing'])
    result.alpha_composite(IMAGES['housing'])
    return result.resize((size, size), RESAMPLE)


def compose(name: str, h: int, d: int, worst: bool = False) -> tuple[Image.Image, dict]:
    result = panel(h)
    portrait_y = 38 + (h - 296) // 8
    result.alpha_composite(portrait(), (92, portrait_y))
    cy = 205 + (h - 296) * .75
    records = []
    for cx, blue, caption, value in [(81, False, 'HP', '100 / 100' if worst else '30 / 30'),
                                     (191, True, 'MANA', '10 / 10' if worst else '5 / 5')]:
        x, y = round(cx - d / 2), round(cy - d / 2)
        result.alpha_composite(reservoir(d, blue), (x, y))
        size = round(d * .19)
        while ink_mask(value, size, True).width > d * .56:
            size -= 1
        cap_size = max(9, round(d * .095))
        cap_box = label(result, (cx, cy - d * .16), caption, cap_size, '#c9c1b0', False)
        value_box = label(result, (cx, cy + d * .065), value, size, '#fff1d5', True)
        aperture_small = MASKS['housing'].resize((d, d), RESAMPLE)
        # Minimum Euclidean distance between actual text ink and aperture edge.
        # Brute-force distances to boundary only, small (<105 px) arrays.
        safe = np.asarray(aperture_small) >= 240
        eroded = np.asarray(Image.fromarray(safe.astype('uint8') * 255).filter(ImageFilter.MinFilter(3))) > 0
        boundary = np.argwhere(safe & ~eroded)
        ink = ink_mask(value, size, True)
        iy, ix = np.nonzero(np.asarray(ink) > 16)
        points = np.stack([iy + value_box[1] - y, ix + value_box[0] - x], axis=1)
        inside = all(0 <= py < d and 0 <= px < d and safe[py, px] for py, px in points)
        distance = float(np.sqrt(((points[:, None, :] - boundary[None, :, :]) ** 2).sum(axis=2)).min())
        records.append(dict(caption=caption, value=value, font=size, caption_font=cap_size,
            value_ink_box=value_box, caption_ink_box=cap_box, aperture_bbox=aperture_small.getbbox(),
            text_clearance_px=round(distance if inside else -distance, 2), housing_box=[x, y, x+d, y+d]))
    return result, dict(variant=name, panel=[272,h], orb=d, portrait=[88,88],
                        portrait_box=[92,portrait_y,180,portrait_y+88], orbs=records)


def geometry() -> list[dict]:
    """Diagnostic bronze segmentation, supplemented by visual inspection.

    RGB criterion is an approximation, not an authoritative artist metal mask.
    Gaps to lower ornament are conservative projected gaps, not collision claims.
    """
    records = []
    for name,h,d in VARIANTS:
        image = panel(h)
        a = np.asarray(image).astype(float)
        metal = (a[:,:,0] > a[:,:,1]*1.12) & (a[:,:,1] > a[:,:,2]*1.12) & (a[:,:,3] > 128)
        side = metal.copy()
        side[:,70:202] = False
        cy = 205+(h-296)*.75
        overlaps = []
        for cx in [81,191]:
            x,y = round(cx-d/2),round(cy-d/2)
            mask = np.zeros((h,272),dtype=bool)
            mask[y:y+d,x:x+d] = np.asarray(IMAGES['housing'].getchannel('A').resize((d,d),RESAMPLE)) > 128
            overlaps.append(int((mask & side).sum()))
        sep = np.argwhere(metal[100:160,100:172])
        sep_lo,sep_hi = int(sep[:,0].min())+100,int(sep[:,0].max())+100
        lower = np.argwhere(metal[int(h*.85):,100:172])
        lower_y = int(lower[:,0].min())+int(h*.85)
        portrait_y = 38 + (h-296)//8
        pf = np.zeros((h,272),dtype=bool)
        pf[portrait_y:portrait_y+88,92:180] = np.asarray(IMAGES['frame'].getchannel('A').resize((88,88),RESAMPLE)) > 128
        visible = image.getchannel('A').point(lambda p:255 if p>8 else 0).getbbox()
        actual_orb_top = round(cy-d/2)
        records.append(dict(variant=name,visible_panel_bbox=visible,side_border_overlap_pixels=overlaps,
            separator_y=[sep_lo,sep_hi],orb_separator_gap=actual_orb_top-sep_hi,
            central_lower_ornament_y=lower_y,orb_lower_ornament_vertical_gap=lower_y-(actual_orb_top+d),
            portrait_metal_overlap_pixels=int((pf & metal).sum()),orb_box_gap=110-d,
            nominal_player_gap=344-(24+h),
            visible_player_gap=round(344+15/1536*700-(24+visible[3]),2)))
    return records


def save(image: Image.Image, name: str) -> None:
    image.convert('RGB').save(OUT / name)


def fallback_panel() -> Image.Image:
    alt = panel(296)
    alt.alpha_composite(portrait(),(92,38))
    for y,blue,cap,val in [(140,False,'HP','100 / 100'),(194,True,'MANA','10 / 10')]:
        alt.alpha_composite(reservoir(44,blue),(58,y))
        text(alt,(110,y),cap,16,color='#c9c1b0')
        text(alt,(110,y+17),val,23,bold=True)
    return alt


def sheet(worst: bool = False) -> Image.Image:
    image = Image.new('RGBA', (1920,1080), '#111b28')
    text(image,(32,24),'ART-003-T04B  /  OFFLINE COMPOSITION STUDY',28,bold=True)
    text(image,(32,68),'Native scale: 1 reference px at 1080p; 2/3 physical px at 720p. Open original at 100%. All six use identical scale.',20)
    for i,(name,h,d) in enumerate(VARIANTS):
        x = 36 + i*310
        text(image,(x,116),f'{name}   272 x {h}   /   orb {d}',18,bold=True)
        hud,_=compose(name,h,d,worst)
        image.alpha_composite(hud,(x,160))
        if not worst:
            hud,_=compose(name,h,d,True)
            image.alpha_composite(hud,(x,620))
    row_note = ('TOP: 1080p worst cases.   BOTTOM: 720p worst cases.' if worst else
                'TOP: HP 30 / 30, MANA 5 / 5.   BOTTOM: HP 100 / 100, MANA 10 / 10.')
    text(image,(32,514),row_note,20)
    text(image,(32,1008),'Ornate housing + small aperture: geometric fitting alone does not establish readable values. Owner approval pending.',20)
    if worst:
        text(image,(32,570),'Worst-case values: HP 100 / 100 and MANA 10 / 10',24,bold=True)
        # Include true physical 720p scale on the same canvas, never enlarged.
        text(image,(32,610),'BELOW: 720p physical scale (2/3). TOP: 1080p physical scale (1:1).',18)
        for i,(name,h,d) in enumerate(VARIANTS):
            hud,_=compose(name,h,d,True)
            image.alpha_composite(hud.resize((181,round(h*2/3)),RESAMPLE),(36+i*310,670))
    return image


def main() -> None:
    hashes = {k:hashlib.sha256(p.read_bytes()).hexdigest() for k,p in PATHS.items()}
    records=[]
    for name,h,d in VARIANTS:
        for worst in [False,True]:
            _, record=compose(name,h,d,worst)
            record['worst_case']=worst
            records.append(record)
    comparison=sheet()
    save(comparison,'opponent_hud_comparison_1080p.png')
    save(comparison.resize((1280,720),RESAMPLE),'opponent_hud_comparison_720p.png')
    save(sheet(True),'opponent_hud_worst_case_values.png')
    # No primary passes: required best-candidate files show the supported alternative.
    alt = fallback_panel()
    best=Image.new('RGBA',(1920,1080),'#111b28')
    best.alpha_composite(alt,(24,24))
    text(best,(340,40),'Recommended alternative: external values / PROPOSAL ONLY',28,bold=True)
    text(best,(340,92),'272 x 296 panel; 44 px color cues; 88 px portrait frame.',22)
    text(best,(340,140),'No primary variant satisfies the complete 720p readability requirement.',22)
    text(best,(340,188),'See review.md and the fallback study. No production integration.',22)
    save(best,'opponent_hud_best_candidate_1080p.png')
    save(best.resize((1280,720),RESAMPLE),'opponent_hud_best_candidate_720p.png')
    # Preserve every player pixel from the recorded current screenshot.
    context=IMAGES['context'].copy()
    # Clear the obsolete opponent block using the exact source battlefield crop.
    background=ImageOps.fit(IMAGES['background'],context.size,method=RESAMPLE)
    context.paste(background.crop((310,20,690,200)),(310,20))
    context.alpha_composite(alt,(24,24))
    ImageDraw.Draw(context).rectangle((700,190,1880,250),fill='#0c1422')
    text(context,(720,204),'OFFLINE COMPOSITION STUDY - composited over R06E capture - NOT integrated',24,bold=True)
    save(context,'opponent_hud_screen_context.png')
    save(context.resize((1280,720),RESAMPLE),'opponent_hud_screen_context_720p.png')
    assert np.array_equal(np.asarray(context)[344:1044,24:296],np.asarray(IMAGES['context'])[344:1044,24:296])
    # Supported fallback: same source panel, small housing as color cue, external readable text.
    fallback=Image.new('RGBA',(1920,1080),'#111b28')
    text(fallback,(340,32),'PROPOSAL ONLY: values beside 44 px housings',26,bold=True)
    text(fallback,(340,80),'Same 272 x 296 panel and 88 px portrait. No new art.',22)
    fallback.alpha_composite(alt,(24,24))
    fallback.alpha_composite(alt.resize((181,197),RESAMPLE),(24,420))
    text(fallback,(340,426),'Left: true 720p physical size, 15.3 px value font; review at 100%.',22)
    text(fallback,(340,474),'The orbs become color cues; captions and values have independent space.',22)
    save(fallback,'opponent_hud_fallback_proposal.png')
    assets={k:dict(path=str(p.relative_to(ROOT)),dimensions=IMAGES[k].size,sha256=hashes[k],
        alpha_bbox=IMAGES[k].getchannel('A').getbbox(),visible_bbox=IMAGES[k].getchannel('A').point(lambda a:255 if a>8 else 0).getbbox())
        for k,p in PATHS.items()}
    measurements=dict(assets=assets,font=str(FONT),bold_font=str(BOLD),variants=records,
        aperture_source_bbox={k:m.getbbox() for k,m in MASKS.items()},player_context_bit_exact=True)
    (OUT/'measurements.json').write_text(json.dumps(measurements,indent=2),encoding='utf-8')
    (OUT/'geometry.json').write_text(json.dumps(geometry(),indent=2),encoding='utf-8')
    assert hashes == {k:hashlib.sha256(p.read_bytes()).hexdigest() for k,p in PATHS.items()}
    print('PASS: 6 variants x 2 value sets; 1080p/720p; source hashes unchanged; player context bit-exact.')


if __name__ == '__main__':
    main()
