"""ART-002-T20: Asset Preparation & Runtime Texture Generation.

Inspects source inlays and master frame v03.
Generates optimized, centered 512x512 runtime textures:
- mo_inlay_attack.png / mo_inlay_attack_v01.png
- mo_inlay_health.png / mo_inlay_health_v01.png
- mo_socket_bezel_attack.png
- mo_socket_bezel_health.png
"""
from pathlib import Path
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[5]
SRC_DIR = ROOT / "assets/_source/lot1/cards/icons"
FRAME_PATH = ROOT / "assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png"
OUT_DIR = ROOT / "assets/textures/cards/icons"
REVIEW_DIR = ROOT / "docs/art/reviews/art002/t20"

OUT_DIR.mkdir(parents=True, exist_ok=True)
REVIEW_DIR.mkdir(parents=True, exist_ok=True)

# 1. Circle fit function
def fit_circle(alpha: np.ndarray, threshold: int = 128):
    h, w = alpha.shape
    center_est = np.array([w / 2.0, h / 2.0])
    points = []
    for deg in range(360):
        rad = np.deg2rad(deg)
        dir_vec = np.array([np.cos(rad), np.sin(rad)])
        for r in np.arange(400.0, 550.0, 0.5):
            pos = center_est + r * dir_vec
            x, y = int(round(pos[0])), int(round(pos[1]))
            if x < 0 or x >= w or y < 0 or y >= h or alpha[y, x] < threshold:
                points.append(center_est + (r - 0.25) * dir_vec)
                break
    points = np.array(points)
    xs, ys = points.T
    A = np.column_stack([2 * xs, 2 * ys, np.ones(len(xs))])
    b = xs**2 + ys**2
    sol = np.linalg.lstsq(A, b, rcond=None)[0]
    cx, cy = sol[0], sol[1]
    r = np.sqrt(sol[2] + cx**2 + cy**2)
    return cx, cy, r

print("Processing Inlay Assets...")
for stat_name, src_file, out_base in [
    ("attack", "mo_stat_inlay_attack_v01.png", "mo_inlay_attack"),
    ("health", "mo_stat_inlay_health_v01.png", "mo_inlay_health"),
]:
    src_path = SRC_DIR / src_file
    img = Image.open(src_path)
    arr = np.array(img)
    alpha = arr[:, :, 3]
    w, h = img.size

    cx, cy, r = fit_circle(alpha)
    print(f"[{stat_name.upper()}] Source {w}x{h} circle fit: center=({cx:.2f}, {cy:.2f}), radius={r:.2f} px")

    # Shift so circle center aligns exactly with canvas center (627, 627)
    shift_x = int(round((w / 2.0) - cx))
    shift_y = int(round((h / 2.0) - cy))
    print(f"[{stat_name.upper()}] Centering shift: ({shift_x}, {shift_y})")

    centered = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    centered.paste(img, (shift_x, shift_y))
    c_arr = np.array(centered)

    # Clean stray sub-threshold alpha < 5
    c_arr[c_arr[:, :, 3] < 5] = 0

    # Downsample to 512x512 with Lanczos
    rt_img = Image.fromarray(c_arr).resize((512, 512), Image.Resampling.LANCZOS)
    rt_arr = np.array(rt_img)
    rt_arr[rt_arr[:, :, 3] < 5] = 0
    clean_rt = Image.fromarray(rt_arr)

    # Verify corners
    corners = [rt_arr[0, 0], rt_arr[0, 511], rt_arr[511, 0], rt_arr[511, 511]]
    for idx, c in enumerate(corners):
        assert c[3] == 0, f"Corner {idx} not transparent: {c}"

    # Save to runtime directory
    out_path_prod = OUT_DIR / f"{out_base}.png"
    out_path_v01 = OUT_DIR / f"{out_base}_v01.png"
    clean_rt.save(out_path_prod)
    clean_rt.save(out_path_v01)
    print(f"[{stat_name.upper()}] Saved {out_path_prod.name} and {out_path_v01.name} (512x512 RGBA)")

# 2. Extract bronze socket bezels from master frame
print("\nExtracting master frame bronze socket bezels...")
frame_img = Image.open(FRAME_PATH)
frame_arr = np.array(frame_img)

BEZEL_BOX_SIZE = 220 # 220x220 patch covering r=110 from center
for stat_name, (scx, scy), out_bezel_name in [
    ("attack", (162, 1279), "mo_socket_bezel_attack.png"),
    ("health", (919, 1279), "mo_socket_bezel_health.png"),
]:
    half = BEZEL_BOX_SIZE // 2
    f_patch = frame_arr[scy - half:scy + half, scx - half:scx + half].astype(float)
    y_idx, x_idx = np.ogrid[:BEZEL_BOX_SIZE, :BEZEL_BOX_SIZE]
    dist = np.sqrt((x_idx - half)**2 + (y_idx - half)**2)

    # Smooth aperture transition between r=71.5 and r=74.5 px:
    # 0 inside (dark cavity transparent), 1 outside (bronze frame 100% opaque)
    t = np.clip((dist - 71.5) / 3.0, 0.0, 1.0)
    smooth = t * t * (3.0 - 2.0 * t)

    # Feather outer border (beyond r=104 to 109) so it blends seamlessly into frame
    t_out = np.clip((109.0 - dist) / 5.0, 0.0, 1.0)
    smooth_out = t_out * t_out * (3.0 - 2.0 * t_out)

    bezel = f_patch.copy()
    bezel[:, :, 3] = f_patch[:, :, 3] * smooth * smooth_out

    b_arr = np.clip(bezel, 0, 255).astype(np.uint8)
    b_arr[b_arr[:, :, 3] < 3] = 0

    bezel_img = Image.fromarray(b_arr)
    bezel_out_path = OUT_DIR / out_bezel_name
    bezel_img.save(bezel_out_path)
    print(f"[{stat_name.upper()}] Saved {bezel_out_path.name} ({BEZEL_BOX_SIZE}x{BEZEL_BOX_SIZE} RGBA)")

print("\nAsset preparation completed successfully.")
