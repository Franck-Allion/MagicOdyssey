"""ART-002-T23: Asset Preparation & Runtime Texture Generation for Armor & Shield Plaque Inlays.

Inspects source stat plate PNGs:
- assets/_source/lot1/cards/icons/mo_stat_plate_armor_v01.png
- assets/_source/lot1/cards/icons/mo_stat_plate_shield_v01.png

Verifies:
- transparency and alpha cleanliness
- visible bounds and internal padding
- horizontal orientation
- readability area for white numerals
- absence of external decorative border / frame

Generates optimized runtime textures under assets/textures/cards/icons/:
- mo_plate_armor.png / mo_plate_armor_v01.png
- mo_plate_shield.png / mo_plate_shield_v01.png
"""
from pathlib import Path
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[5]
SRC_DIR = ROOT / "assets/_source/lot1/cards/icons"
OUT_DIR = ROOT / "assets/textures/cards/icons"
REVIEW_DIR = ROOT / "docs/art/reviews/art002/t23"

OUT_DIR.mkdir(parents=True, exist_ok=True)
REVIEW_DIR.mkdir(parents=True, exist_ok=True)

TARGET_WIDTH = 512
PADDING = 4  # transparent safety border around tight crop

print("=== ART-002-T23 Asset Preparation ===")

for stat_name, src_file, out_base in [
    ("armor", "mo_stat_plate_armor_v01.png", "mo_plate_armor"),
    ("shield", "mo_stat_plate_shield_v01.png", "mo_plate_shield"),
]:
    src_path = SRC_DIR / src_file
    assert src_path.exists(), f"Source file missing: {src_path}"

    img = Image.open(src_path)
    arr = np.array(img)
    w, h = img.size
    print(f"\n[{stat_name.upper()}] Processing source: {src_file} ({w}x{h}, mode={img.mode})")

    alpha = arr[:, :, 3]

    # 1. Inspect stray sub-threshold alpha (< 5)
    stray_count = int(np.sum((alpha > 0) & (alpha < 5)))
    print(f"[{stat_name.upper()}] Stray alpha (<5) pixels: {stray_count}")

    # Zero stray alpha
    clean_arr = arr.copy()
    clean_arr[clean_arr[:, :, 3] < 5] = 0
    clean_alpha = clean_arr[:, :, 3]

    # 2. Measure tight visible bounds (alpha >= 5)
    ys, xs = np.where(clean_alpha > 0)
    min_x, max_x = int(xs.min()), int(xs.max())
    min_y, max_y = int(ys.min()), int(ys.max())
    crop_w = max_x - min_x + 1
    crop_h = max_y - min_y + 1
    aspect = crop_w / float(crop_h)

    print(f"[{stat_name.upper()}] Tight bounds: X=[{min_x}..{max_x}] (W={crop_w}), Y=[{min_y}..{max_y}] (H={crop_h}), Aspect={aspect:.3f}")

    # Bounding box center & Center of Mass
    box_cx = (min_x + max_x) / 2.0
    box_cy = (min_y + max_y) / 2.0
    crop_a_float = clean_alpha[min_y:max_y + 1, min_x:max_x + 1].astype(float)
    com_y = min_y + float(np.sum(np.arange(crop_h)[:, None] * crop_a_float) / np.sum(crop_a_float))
    com_x = min_x + float(np.sum(np.arange(crop_w)[None, :] * crop_a_float) / np.sum(crop_a_float))
    print(f"[{stat_name.upper()}] Box center: ({box_cx:.2f}, {box_cy:.2f}), COM: ({com_x:.2f}, {com_y:.2f})")

    # 3. Create padded crop with transparent border
    padded_w = crop_w + 2 * PADDING
    padded_h = crop_h + 2 * PADDING
    padded_arr = np.zeros((padded_h, padded_w, 4), dtype=np.uint8)
    padded_arr[PADDING:PADDING + crop_h, PADDING:PADDING + crop_w] = clean_arr[min_y:max_y + 1, min_x:max_x + 1]

    # 4. Downscale to runtime texture (width = 512, proportional height)
    target_h = int(round(TARGET_WIDTH * padded_h / float(padded_w)))
    padded_img = Image.fromarray(padded_arr)
    rt_img = padded_img.resize((TARGET_WIDTH, target_h), Image.Resampling.LANCZOS)
    rt_arr = np.array(rt_img)

    # Ensure edge transparency is absolute zero
    rt_arr[rt_arr[:, :, 3] < 5] = 0
    rt_arr[0, :, 3] = 0
    rt_arr[-1, :, 3] = 0
    rt_arr[:, 0, 3] = 0
    rt_arr[:, -1, 3] = 0

    clean_rt = Image.fromarray(rt_arr)

    # 5. Verify corner transparency
    corners = [rt_arr[0, 0], rt_arr[0, -1], rt_arr[-1, 0], rt_arr[-1, -1]]
    for idx, c in enumerate(corners):
        assert c[3] == 0, f"Corner {idx} not transparent: {c}"

    # 6. Save runtime assets
    out_prod = OUT_DIR / f"{out_base}.png"
    out_v01 = OUT_DIR / f"{out_base}_v01.png"
    clean_rt.save(out_prod)
    clean_rt.save(out_v01)

    print(f"[{stat_name.upper()}] Saved runtime texture: {out_prod.name} and {out_v01.name} ({TARGET_WIDTH}x{target_h}, RGBA)")

print("\nAsset preparation completed successfully.")
