"""Inspect source alpha, verify GPU mounting stability, compose review evidence.

Requires Pillow and numpy. Does not modify source assets or golden references.
"""
from pathlib import Path
import hashlib
import json

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

OUT = Path("docs/art/reviews/p005-r06b")
SOURCE = Path("assets/_source/lot1/hud/player")
results = {"alpha_exception": "Owner accepts 252-254 interior alpha ONLY for mo_hud_player_panel_v01.png", "assets": [], "captures": []}

for path in sorted(SOURCE.glob("*.png")):
    im = Image.open(path)
    alpha = np.array(im)[:, :, 3]
    results["assets"].append({"path": str(path), "dimensions": im.size, "mode": im.mode,
                              "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                              "alpha_min": int(alpha.min()), "alpha_max": int(alpha.max()),
                              "transparent_pixels": int((alpha == 0).sum()),
                              "opaque_pixels": int((alpha == 255).sum())})
    assert im.mode == "RGBA"
    if path.name == "mo_hud_player_panel_v01.png":
        core = alpha[180:1350, 320:700]
        assert core.min() == 252 and core.max() == 254
        # Exterior is transparent, with a few alpha=1 residual pixels in the source.
        assert alpha[:, :150].max() <= 1 and alpha[:, 875:].max() <= 1
        silhouette = Image.fromarray(np.where(alpha < 128, 0, 255).astype("uint8")).copy()
        ImageDraw.floodfill(silhouette, (0, 0), 128)
        holes = int((np.array(silhouette) == 0).sum())
        results["panel_enclosed_holes_at_half_alpha_threshold"] = holes
        assert holes == 0
    else:
        assert alpha[627, 627] == 0 and alpha.max() == 255

for height in [1080, 720]:
    before = Image.open(OUT / f"before_r05_{height}p.png").convert("RGBA")
    after = Image.open(OUT / f"combat_screen_{height}p.png").convert("RGBA")
    factor = height / 1080
    diff = np.any(np.array(before) != np.array(after), axis=2)
    outside = int(diff[:, round(320 * factor):].sum())
    assert outside == 0, "Unexpected change outside player HUD and old shadow"
    frames = [Image.open(OUT / f"transition_{height}p_{i:02}.png").convert("RGBA") for i in range(8)]
    arrays = [np.array(frame) for frame in frames]
    metal_changed = 0
    metal_samples = 0
    for top in [256, 474]:
        housing = Image.open(SOURCE / "mo_hud_player_health_orb_housing_v01.png").getchannel("A")
        housing = housing.resize((round(190 * factor), round(190 * factor)), Image.Resampling.BILINEAR)
        mask = np.array(housing.filter(ImageFilter.MinFilter(5))) == 255
        yy, xx = np.indices(mask.shape)
        radius = np.sqrt(((xx + 0.5) / mask.shape[1] - 0.5) ** 2 + ((yy + 0.5) / mask.shape[0] - 0.5) ** 2)
        mask &= radius > 0.37  # Exclude the numeric/caption region.
        x = round((65 - 16) * factor)
        y = round((220 + top - 210) * factor)
        crops = [arr[y:y + mask.shape[0], x:x + mask.shape[1], :] for arr in arrays]
        metal_samples += int(mask.sum())
        metal_changed += sum(int(np.any(crop != crops[0], axis=2)[mask].sum()) for crop in crops[1:])
    assert metal_samples > 0 and metal_changed == 0, "Metal housing must remain fixed"
    wave_a = np.array(Image.open(OUT / f"wave_{height}p_a.png"))
    wave_b = np.array(Image.open(OUT / f"wave_{height}p_b.png"))
    motion = int(np.any(wave_a != wave_b, axis=2).sum())
    assert motion > 0, "Settled liquid must keep moving"
    results["captures"].append({"height": height, "outside_player_hud_changed_pixels": outside,
                                "stable_metal_sample_pixels": metal_samples,
                                "metal_changed_pixels_across_8_frames": metal_changed,
                                "settled_liquid_changed_pixels": motion})
    width, crop_height = frames[0].size
    comparison = Image.new("RGB", (width * 2, crop_height + 32), (16, 20, 27))
    rect = (round(16 * factor), round(210 * factor), round(304 * factor), round(930 * factor))
    comparison.paste(before.crop(rect), (0, 32))
    comparison.paste(after.crop(rect), (width, 32))
    draw = ImageDraw.Draw(comparison)
    draw.text((8, 8), "Before R05", fill="white")
    draw.text((width + 8, 8), "After R06B", fill="white")
    comparison.save(OUT / f"before_after_{height}p.png")
    states = Image.new("RGB", (width * 3, crop_height + 32), (16, 20, 27))
    for index, (state, caption) in enumerate([(30, "Full"), (15, "Half HP / 3 of 5 Mana"), (0, "Empty")]):
        states.paste(Image.open(OUT / f"state_{height}p_hp{state}.png"), (width * index, 32))
        ImageDraw.Draw(states).text((width * index + 8, 8), caption, fill="white")
    states.save(OUT / f"states_{height}p.png")
    frames[0].save(OUT / f"damage_refill_{height}p.gif", save_all=True, append_images=frames[1:], duration=130, loop=0)

(OUT / "verification.json").write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")
print(json.dumps(results, indent=2))
