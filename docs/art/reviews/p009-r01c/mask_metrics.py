"""Measure imported masks and Godot-rendered PNG pairs from the R01C capture script."""

import argparse
import colorsys
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[3]
SIZE = (1086, 1448)
RARITIES = ("common", "uncommon", "rare", "epic", "legendary")
# Traced on the bare Spell PNG at 4x, along the blue-to-dark-bezel boundary.
# These are reference contours independently of the smaller production SVG paths.
CRYSTALS = {
    "crown": [(543, 24), (565, 48), (543, 83), (523, 48)],
    "bridge": [(543, 833), (567, 861), (543, 896), (519, 861)],
    "footer": [(543, 1339), (568, 1372), (543, 1408), (519, 1372)],
}
# Bronze projection into the ribbon. Straight rail measurements use x=180..906.
PANEL = (180, 898, 906, 946)
BRIDGE_BEZEL = [(522, 897), (565, 897), (558, 903), (551, 910),
                (545, 922), (543, 925), (541, 924), (535, 914), (529, 906)]


def read(path):
    return np.array(Image.open(path).convert("RGBA"))


def polygon(points):
    # Integer source coordinates denote pixel edges. Sample at pixel centers.
    image = Image.new("L", (SIZE[0] * 2, SIZE[1] * 2))
    ImageDraw.Draw(image).polygon([(x * 2, y * 2) for x, y in points], fill=255)
    return np.array(image)[1::2, 1::2] > 0


def extent(mask):
    ys, xs = np.nonzero(mask)
    return [int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1] if len(xs) else None


def midpoint(box):
    return [round((box[0] + box[2]) / 2, 2), round((box[1] + box[3]) / 2, 2)] if box else None


def weight(mask, where):
    return round(float(mask[where].sum()) / 255, 2)


def mask_metrics(mask, regions):
    assert mask.shape == (SIZE[1], SIZE[0])
    support = mask > 0
    union = np.logical_or.reduce(list(regions.values()))
    result = {}
    for name, crystal in regions.items():
        crystal_box = extent(crystal)
        window = np.zeros_like(crystal)
        top = max(crystal_box[1] - 12, 1339) if name == "footer" else crystal_box[1] - 12
        window[top:crystal_box[3] + 12, crystal_box[0] - 12:crystal_box[2] + 12] = True
        mask_box = extent(support & window)
        coverage = weight(mask, crystal)
        result[name] = {
            "crystal_xyxy": crystal_box, "crystal_center": midpoint(crystal_box),
            "crystal_area": int(crystal.sum()), "mask_xyxy": mask_box,
            "mask_center": midpoint(mask_box), "covered_area": coverage,
            "weighted_coverage_percent": round(100 * coverage / crystal.sum(), 2),
            "coverage_outside_crystal_in_local_window": weight(mask, window & ~crystal),
        }
    lower_description = np.zeros_like(support)
    lower_description[1230:1339] = True
    return {
        "crystals": result,
        "off_crystal_weighted_pixels": weight(mask, ~union),
        "off_crystal_nonzero_pixels": int((support & ~union).sum()),
        "rules_reservation_nonzero_pixels": int(support[990:1230, 140:946].sum()),
        "lower_description_nonzero_pixels": int((support & lower_description).sum()),
        "lower_description_mask_xyxy": extent(support & lower_description),
    }


def source_glyph(path):
    image = read(path)
    # Include visible gold antialiasing, excluding faint dark outline samples.
    ink = (image[:, :, 0] > 100) & (image[:, :, 3] >= 32)
    box = extent(ink)
    left, top, right, bottom = box
    return {
        "ink_xyxy": box, "ink_center": midpoint(box),
        "rail_clearance_ltrb": [left - PANEL[0], top - PANEL[1], PANEL[2] - right, PANEL[3] - bottom],
        "painted_bridge_bezel_ink_pixels": int((ink & polygon(BRIDGE_BEZEL)).sum()),
    }


def visible_glyph(directory, case):
    name = case["case"]
    shown = read(directory / f"{name}_shown.png")
    hidden = read(directory / f"{name}_hidden.png")
    delta = np.max(np.abs(shown[:, :, :3].astype(np.int16) - hidden[:, :, :3]), axis=2)
    changed = delta >= 8
    box = extent(changed)
    assert box is not None, f"Missing drawn category ink for {name}"
    ys, xs = np.nonzero(changed)
    a, b, c, d, x, y = case["transform"]
    matrix = np.array([[a, c], [b, d]]) * case["viewport_scale"]
    translation = np.array([x, y]) * case["viewport_scale"]
    source = np.linalg.solve(matrix, np.stack((xs + 0.5, ys + 0.5)) - translation[:, None])
    x_min, y_min = source.min(axis=1)
    x_max, y_max = source.max(axis=1)
    assert x_min > 460 and x_max < 625 and y_min >= 898 and y_max < 946, (name, source.min(axis=1), source.max(axis=1))
    return {
        "case": name, "title": case["title"], "physical_xyxy": box,
        "physical_ink_height": box[3] - box[1],
        "physical_changed_pixels": int(changed.sum()),
        "projected_source_y_min_max": [round(y_min, 2), round(y_max, 2)],
    }


def gpu_mask_metrics(directory, mask, regions):
    raw = read(directory / "bare.png")
    allowed = np.array(Image.fromarray(mask).filter(ImageFilter.MaxFilter(3))) > 0
    crystal_union = np.logical_or.reduce(list(regions.values()))
    output = {}
    for rarity in RARITIES:
        rendered = read(directory / (rarity + ".png"))
        changed = (raw[:, :, :3] != rendered[:, :, :3]).any(axis=2)
        off_mask = int((changed & ~allowed).sum())
        off_crystal = int((changed & ~crystal_union).sum())
        alpha_changes = int((raw[:, :, 3] != rendered[:, :, 3]).sum())
        assert off_mask == alpha_changes == 0, (rarity, off_mask, alpha_changes)
        assert off_crystal == 0, (rarity, off_crystal)
        gems = {}
        for name, region in regions.items():
            red, green, blue = rendered[:, :, :3][region].astype(float).T
            hues = np.array([colorsys.rgb_to_hsv(r, g, b) for r, g, b in zip(red / 255, green / 255, blue / 255)])
            saturation = hues[:, 1]
            usable = (saturation > 0.25) & (hues[:, 2] > 0.15)
            hue = float(np.median(hues[usable, 0] * 360)) if usable.any() else None
            coverage = float((changed & region).sum() / region.sum())
            assert coverage > 0.85, (rarity, name, coverage)
            if rarity == "common":
                assert np.median(saturation) < 0.13, (name, saturation)
            else:
                ranges = {"uncommon": (190, 260), "rare": (0, 20), "epic": (120, 175), "legendary": (30, 65)}
                assert hue is not None and (ranges[rarity][0] <= hue <= ranges[rarity][1] or rarity == "rare" and hue >= 335), (rarity, name, hue)
            gems[name] = {"changed_percent": round(100 * coverage, 2),
                          "median_chromatic_hue": round(hue, 2) if hue is not None else None,
                          "median_saturation": round(float(np.median(saturation)), 3)}
        output[rarity] = {"outside_mask_rgb_changes": off_mask, "outside_crystal_rgb_changes": off_crystal,
                          "alpha_changes": alpha_changes, "gems": gems}
    old_changed = (raw[:, :, :3] != read(directory / "rare_before.png")[:, :, :3]).any(axis=2)
    output["before_rare"] = {
        "changed_pixels_in_lower_description": int(old_changed[1230:1339, :].sum()),
        "changed_pixels_on_footer_crystal": int((old_changed & regions["footer"]).sum()),
    }
    assert output["before_rare"]["changed_pixels_in_lower_description"] > 2000
    assert output["before_rare"]["changed_pixels_on_footer_crystal"] == 0
    return output


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("analysis_dir", type=Path, help="Same directory as MO_R01C_ANALYSIS_DIR")
    directory = parser.parse_args().analysis_dir
    regions = {name: polygon(points) for name, points in CRYSTALS.items()}
    old_mask = read(directory / "old_mask.png")[:, :, 0]
    spell_mask = read(directory / "spell_mask.png")[:, :, 0]
    old = mask_metrics(old_mask, regions)
    new = mask_metrics(spell_mask, regions)
    assert all(v["weighted_coverage_percent"] > 85 for v in new["crystals"].values()), new
    assert new["rules_reservation_nonzero_pixels"] == new["lower_description_nonzero_pixels"] == 0
    assert new["off_crystal_weighted_pixels"] < 2, new
    before = source_glyph(directory / "glyph_before.png")
    after = source_glyph(directory / "glyph_after.png")
    assert before["rail_clearance_ltrb"][3] < 0
    assert min(after["rail_clearance_ltrb"]) >= 2, after
    assert abs(after["rail_clearance_ltrb"][0] - after["rail_clearance_ltrb"][2]) <= 2, after
    assert after["painted_bridge_bezel_ink_pixels"] == 0, after
    cases = json.loads((OUT / "observations.json").read_text(encoding="utf-8"))["glyph_cases"]
    source_art = ROOT / "assets/_source/lot1/cards/frames/mo_card_frame_spell_v01.png"
    runtime_art = ROOT / "assets/textures/cards/mo_card_frame_spell_v01.png"
    assets = {}
    for path in (source_art, runtime_art):
        assert Image.open(path).size == SIZE
        assets[str(path.relative_to(ROOT).as_posix())] = hashlib.sha256(path.read_bytes()).hexdigest()
    report = {
        "units": "source pixels unless marked physical. xyxy bounds have exclusive right and bottom.",
        "frame_png_sha256": assets,
        "source_size": SIZE,
        "mask_traced_crystal_contours": CRYSTALS,
        "before_mask": old, "after_mask": new,
        "gpu_mask": gpu_mask_metrics(directory, spell_mask, regions),
        "nameplate": {"straight_rail_safe_strip_xyxy": PANEL, "bridge_bezel_trace": BRIDGE_BEZEL,
                      "before": before, "after": after, "font": cases[0]},
        "gpu_rendered_nameplate": [visible_glyph(directory, case) for case in cases[1:]],
    }
    (OUT / "mask_metrics.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"PASS: mask-wide coverage, leakage, five-rarity RGB/alpha and {len(cases) - 1} hand/inspection glyph measurements.")


if __name__ == "__main__":
    main()
