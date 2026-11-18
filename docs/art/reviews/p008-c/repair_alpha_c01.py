"""P008-C01: deterministic alpha-only candidate and audit. No game integration.

Default: preserve original, write candidate/metrics/composites. --install requires
an explicit recorded visual PASS and all numeric checks; copies exact PNG bytes.
"""
from collections import deque
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageOps

ROOT = Path(__file__).resolve().parents[4]
OUT = Path(__file__).resolve().parent / "c01"
SOURCE = ROOT / "assets/_source/lot1/tokens/mo_creature_token_frame_v02.png"
RUNTIME = ROOT / "assets/textures/tokens/mo_creature_token_frame_v02.png"
ORIGINAL_HASH = "10266d58e3aaa9505dd385de16aef2c842359681b60eb9b14197ad36d0680018"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def dilate(mask, radius):
    """Exact square binary dilation, using separable integer window sums."""
    size = radius * 2 + 1
    padded = np.pad(mask, ((0, 0), (radius, radius)))
    sums = np.pad(np.cumsum(padded, axis=1, dtype=np.int32), ((0, 0), (1, 0)))
    horizontal = sums[:, size:] - sums[:, :-size] > 0
    padded = np.pad(horizontal, ((radius, radius), (0, 0)))
    sums = np.pad(np.cumsum(padded, axis=0, dtype=np.int32), ((1, 0), (0, 0)))
    return sums[size:, :] - sums[:-size, :] > 0


def components(mask, alpha, near_solid):
    """Exact 8-connected positive low-alpha regions, without modifying alpha."""
    unseen = mask.copy()
    result = []
    height, width = mask.shape
    for y, x in np.argwhere(mask):
        if not unseen[y, x]:
            continue
        unseen[y, x] = False
        pending = deque([(int(y), int(x))])
        count, far, max_alpha = 0, 0, 0
        xmin = xmax = int(x)
        ymin = ymax = int(y)
        while pending:
            py, px = pending.popleft()
            count += 1
            far += int(not near_solid[py, px])
            max_alpha = max(max_alpha, int(alpha[py, px]))
            xmin, xmax = min(xmin, px), max(xmax, px)
            ymin, ymax = min(ymin, py), max(ymax, py)
            for ny in range(max(0, py - 1), min(height, py + 2)):
                for nx in range(max(0, px - 1), min(width, px + 2)):
                    if unseen[ny, nx]:
                        unseen[ny, nx] = False
                        pending.append((ny, nx))
        result.append({"pixels": count, "bbox_xyxy_inclusive": [xmin, ymin, xmax, ymax],
                       "max_alpha": max_alpha, "pixels_farther_than_8_from_alpha128": far})
    return sorted(result, key=lambda v: v["pixels"], reverse=True)


def composites(before, after):
    field = Image.open(ROOT / "assets/_source/lot1/battlefield/wip/mo_battlefield_sundered_observatory_bg_wip_v03.png").convert("RGBA")
    field = ImageEnhance.Brightness(ImageOps.fit(field, before.size)).enhance(0.45)
    portrait = Image.open(ROOT / "assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png").convert("RGBA")
    portrait = ImageOps.fit(portrait, (1320, 690), centering=(0.5, 0))
    polygon = [(300,78),(1238,78),(1335,104),(1404,171),(1422,262),(1422,550),(1400,618),(1316,644),(1215,685),(1172,748),(1125,774),(410,774),(363,748),(320,685),(220,644),(136,618),(114,550),(114,262),(132,171),(201,104)]
    mask = Image.new("L", before.size)
    ImageDraw.Draw(mask).polygon(polygon, fill=255)
    backings = {"battlefield": field, "light": Image.new("RGBA", before.size, (246, 246, 238, 255))}
    for name, factor in [("bright_portrait", 2.5), ("dark_portrait", 0.18)]:
        backing = field.copy()
        layer = Image.new("RGBA", before.size)
        layer.paste(ImageEnhance.Brightness(portrait).enhance(factor), (108, 84))
        backing.paste(layer, (0, 0), mask)
        backings[name] = backing
    backing = backings["bright_portrait"].copy()
    for name, cx in [("attack", 220), ("health", 1317)]:
        inlay = Image.open(ROOT / f"assets/textures/cards/icons/mo_inlay_{name}.png").convert("RGBA").resize((296, 296), Image.Resampling.LANCZOS)
        backing.alpha_composite(inlay, (cx - 148, 802 - 148))
    backings["official_inlays"] = backing
    native = Image.new("RGB", (1280, 720), (28, 30, 37))
    draw = ImageDraw.Draw(native)
    draw.text((20, 14), "P008-C01 / OFFLINE composites / 1:1 native 720p footprint / not a Godot screenshot", fill="white")
    draw.text((20, 35), "Before: upper row. Candidate: lower row. Source 1536x1024 -> 102.667x68.444 physical px, raster 103x69.", fill="white")
    for col, (name, backing) in enumerate(backings.items()):
        for row, (version, image) in enumerate([("before", before), ("after", after)]):
            composite = Image.alpha_composite(backing, image)
            composite.save(OUT / f"{version}_{name}.png")
            # Diagnostic resizing affects only the composites, never source pixels.
            native.paste(composite.convert("RGB").resize((103, 69), Image.Resampling.LANCZOS), (40 + col * 245, 125 + row * 145))
        draw.text((40 + col * 245, 90), name, fill="white")
    draw.text((20, 395), "Primary rings show official Attack/Health material only in the last column. No numerals or game APIs are changed.", fill="white")
    native.save(OUT / "native_720p_comparison.png")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--install", action="store_true")
    args = parser.parse_args()
    OUT.mkdir(exist_ok=True)
    backup = OUT / "original_v02.png"
    if not backup.exists():
        assert digest(SOURCE) == ORIGINAL_HASH, "Unexpected input; never use generated candidate"
        shutil.copyfile(SOURCE, backup)
    assert digest(backup) == ORIGINAL_HASH
    original = Image.open(backup)
    assert original.format == "PNG" and original.mode == "RGBA" and original.size == (1536, 1024)
    before = np.array(original)
    after = before.copy()
    alpha = before[:, :, 3]
    corrected = after[:, :, 3]
    corrected[alpha <= 1] = 0
    corrected[alpha >= 254] = 255
    candidate = OUT / "candidate_v02.png"
    Image.fromarray(after).save(candidate, format="PNG", compress_level=9)
    reloaded = np.array(Image.open(candidate))
    assert np.array_equal(reloaded, after), "Lossless save round trip"
    yy, xx = np.ogrid[:1024, :1536]
    regions = {"portrait_deep": (xx >= 180) & (xx < 1350) & (yy >= 180) & (yy < 570)}
    for name, cx in [("attack_deep", 220), ("health_deep", 1317)]:
        regions[name] = (xx - cx) ** 2 + (yy - 802) ** 2 < 90 ** 2
    samples = [("corner_tl",0,0),("corner_tr",1535,0),("corner_bl",0,1023),("corner_br",1535,1023),
               ("portrait",768,350),("attack",220,802),("health",1317,802),
               ("armor",570,860),("shield",970,860),("enamel",55,380),("bronze",1259,46)]
    near = dilate(corrected >= 128, 8)
    low = (corrected >= 2) & (corrected <= 31)
    comps = components(low, corrected, near)
    far = low & ~near
    far_counts = {str(radius): int(np.count_nonzero(low & ~dilate(corrected >= 128, radius))) for radius in [8, 12, 16, 24]}
    removed_away_mask = (alpha == 1) & ~dilate(alpha == 0, 8)
    removed_away_from_zero = int(removed_away_mask.sum())
    Image.fromarray(np.uint8(removed_away_mask) * 255).save(OUT / "removed_alpha1_away_from_original_zero.png")
    # Inspect every component flagged by the distance diagnostic, without cleanup.
    flagged = [component for component in comps if component["pixels_farther_than_8_from_alpha128"]]
    contact = Image.new("RGB", (1600, max(1, len(flagged)) * 180), (25, 25, 30))
    contact_draw = ImageDraw.Draw(contact)
    for index, component in enumerate(flagged):
        x0, y0, x1, y1 = component["bbox_xyxy_inclusive"]
        box = (max(0,x0-8), max(0,y0-8), min(1536,x1+9), min(1024,y1+9))
        crop = original.crop(box)
        alpha_crop = Image.fromarray(corrected).crop(box)
        for col, tile in enumerate([crop.convert("RGB"), alpha_crop.convert("RGB")]):
            tile.thumbnail((760, 135), Image.Resampling.NEAREST)
            contact.paste(tile, (10 + col * 800, index * 180 + 35))
        contact_draw.text((10,index*180+10), f"Source RGB left / alpha right / bbox {box} / existing edge taper, no cleanup", fill="white")
    contact.save(OUT / "flagged_edge_regions.png")
    Image.fromarray(np.uint8(low) * 255).save(OUT / "remaining_alpha_2_31.png")
    Image.fromarray(np.uint8(far) * 255).save(OUT / "low_alpha_far_from_solid.png")
    changed = alpha != corrected
    Image.fromarray(np.uint8(changed) * 255).save(OUT / "modified_alpha_pixels.png")
    Image.fromarray(alpha).save(OUT / "alpha_before.png")
    Image.fromarray(corrected).save(OUT / "alpha_after.png")
    checks = {"RGB_bit_exact": bool(np.array_equal(before[:, :, :3], after[:, :, :3])),
              "alpha_2_through_253_unchanged": bool(np.array_equal(alpha[(alpha >= 2) & (alpha <= 253)], corrected[(alpha >= 2) & (alpha <= 253)])),
              "same_alpha128_silhouette": bool(np.array_equal(alpha >= 128, corrected >= 128)),
              "same_alpha2_support": bool(np.array_equal(alpha >= 2, corrected >= 2)),
              "all_deep_openings_zero": all(not np.any(corrected[m]) for m in regions.values()),
              "corners_zero": all(corrected[y,x] == 0 for _,x,y in samples[:4]),
              "fully_opaque_bronze_sample": bool(corrected[46,1259] == 255),
              "neutral_cavities_preserved": bool(corrected[860,570] == alpha[860,570] == 253 and corrected[860,970] == alpha[860,970] == 253)}
    metrics = {"task": "P008-C01", "transformation": "A<=1 -> 0; A>=254 -> 255; A=2..253 unchanged; RGB unchanged",
               "original_sha256": digest(backup), "candidate_sha256": digest(candidate),
               "format": "PNG RGBA", "dimensions": list(original.size), "checks": checks,
               "before_histogram": np.bincount(alpha.ravel(), minlength=256).tolist(),
               "after_histogram": np.bincount(corrected.ravel(), minlength=256).tolist(),
               "modified_alpha_pixels": int(changed.sum()), "alpha1_to0": int((alpha == 1).sum()),
               "alpha254_to255": int((alpha == 254).sum()), "modified_RGB_channel_values": int(np.count_nonzero(before[:,:,:3] != after[:,:,:3])),
               "samples": {name: {"xy":[x,y], "before_RGBA":before[y,x].tolist(), "after_RGBA":after[y,x].tolist()} for name,x,y in samples},
               "deep_regions": {name:{"before_max_alpha":int(alpha[m].max()),"after_max_alpha":int(corrected[m].max()),"before_nonzero":int(np.count_nonzero(alpha[m])),"after_nonzero":int(np.count_nonzero(corrected[m]))} for name,m in regions.items()},
               "low_alpha_definition": "remaining positive alpha 2..31; 8-connectivity; far = Chebyshev distance >8 from alpha>=128",
               "low_alpha_pixels": int(low.sum()), "low_alpha_region_count": len(comps), "low_alpha_far_pixels":int(far.sum()),
               "low_alpha_far_counts_by_radius": far_counts,
               "alpha1_removed_farther_than8_from_original_zero": removed_away_from_zero,
               "low_alpha_components": comps,
               "installed": False}
    composites(original, Image.fromarray(after))
    metrics["composite_max_channel_difference"] = {name: int(np.abs(np.array(Image.open(OUT / f"before_{name}.png")).astype(int) - np.array(Image.open(OUT / f"after_{name}.png")).astype(int)).max()) for name in ["battlefield", "light", "bright_portrait", "dark_portrait", "official_inlays"]}
    if args.install:
        visual = json.loads((OUT / "visual_review.json").read_text())
        assert visual["alpha_step"] == "PASS" and visual["candidate_sha256"] == digest(candidate)
        assert all(checks.values()), checks
        assert digest(SOURCE) in (ORIGINAL_HASH, digest(candidate)), "Source changed concurrently"
        shutil.copyfile(candidate, SOURCE)
        shutil.copyfile(SOURCE, RUNTIME)
        assert digest(SOURCE) == digest(RUNTIME) == digest(candidate)
        metrics["installed"] = True
        metrics["source_runtime_byte_identical"] = True
    (OUT / "metrics.json").write_text(json.dumps(metrics, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({k:metrics[k] for k in ["checks","modified_alpha_pixels","alpha1_to0","alpha254_to255","modified_RGB_channel_values","low_alpha_pixels","low_alpha_region_count","low_alpha_far_pixels","installed"]}, indent=2))
    return 0 if all(checks.values()) else 1


if __name__ == "__main__":
    raise SystemExit(main())
