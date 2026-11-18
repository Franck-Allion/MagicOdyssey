"""Read-only asset audit; writes diagnostic composites, never edits artwork."""
from pathlib import Path
import hashlib
import json
import subprocess
import sys
import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[4]
OUT = Path(__file__).resolve().parent

def sha(data):
    return hashlib.sha256(data).hexdigest()

def run():
    paths = [ROOT / f"assets/_source/lot1/tokens/mo_creature_token_frame_v0{v}.png" for v in (1, 2)]
    images = [Image.open(p) for p in paths]
    arrays = [np.array(im) for im in images]
    v02 = arrays[1]
    alpha = v02[:, :, 3]
    assert images[1].format == "PNG" and images[1].mode == "RGBA" and images[1].size == (1536, 1024)
    samples = {name: v02[y, x].tolist() for name, x, y in [
        ("outside", 0, 0), ("portrait", 768, 350), ("attack", 220, 802),
        ("health", 1317, 802), ("armor", 570, 860), ("shield", 970, 860), ("enamel", 55, 380)]}
    for name in ("outside", "portrait", "attack", "health"):
        assert samples[name][3] == 0, (name, samples[name])
    assert np.count_nonzero((alpha > 0) & (alpha < 250)) > 0, "Antialiased alpha is present"
    # Deep aperture and central disks must be clear, not merely their centers.
    yy, xx = np.ogrid[:1024, :1536]
    regions = {"portrait_interior": (xx >= 180) & (xx < 1350) & (yy >= 180) & (yy < 570)}
    for name, cx in [("attack_interior", 220), ("health_interior", 1317)]:
        regions[name] = (xx - cx) ** 2 + (yy - 802) ** 2 < 90 ** 2
    region_metrics = {k: {"max_alpha": int(alpha[m].max()), "nonzero_pixels": int(np.count_nonzero(alpha[m]))} for k, m in regions.items()}
    # Record even failed strict-alpha checks so the failure is reviewable.
    strict_clear = all(stats["max_alpha"] == 0 for stats in region_metrics.values())
    Image.fromarray(alpha).save(OUT / "v02_alpha.png")
    # Same-coordinate contour comparison: green V01, magenta V02.
    overlay = np.zeros_like(v02)
    overlay[:, :, 0] = alpha
    overlay[:, :, 1] = arrays[0][:, :, 3]
    overlay[:, :, 2] = alpha
    overlay[:, :, 3] = 255
    Image.fromarray(overlay).save(OUT / "alpha_alignment_v01_v02.png")
    battlefield = Image.open(ROOT / "assets/_source/lot1/battlefield/wip/mo_battlefield_sundered_observatory_bg_wip_v03.png").convert("RGBA").resize(images[1].size)
    for name, backing in [("dark", Image.new("RGBA", images[1].size, (4, 4, 8, 255))),
                           ("bright", Image.new("RGBA", images[1].size, (250, 250, 242, 255))),
                           ("battlefield", battlefield)]:
        result = Image.alpha_composite(backing, images[1])
        result.save(OUT / f"v02_composite_{name}.png")
    comparison = Image.new("RGB", (1536, 1064), (24, 24, 30))
    d = ImageDraw.Draw(comparison)
    for i, im in enumerate(images):
        tile = Image.alpha_composite(Image.new("RGBA", im.size, (24, 24, 30, 255)), im).resize((768, 512))
        comparison.paste(tile, (i * 768, 40))
        d.text((i * 768 + 20, 15), f"V0{i + 1} / supplied artwork / 50% diagnostic", fill="white")
    comparison = comparison.crop((0, 0, 1536, 552))
    comparison.save(OUT / "v01_vs_v02_artwork.png")
    runtime = ROOT / "assets/textures/tokens/mo_creature_token_frame_v02.png"
    protected = json.loads((OUT.parent / "p008/preservation.json").read_text())["protected_files"]
    preservation = {}
    for rel, prior in protected.items():
        data = (ROOT / rel).read_bytes()
        baseline = subprocess.check_output(["git", "show", f"HEAD:{rel}"], cwd=ROOT)
        if not rel.endswith(".png"):
            data = data.replace(b"\r\n", b"\n")
            baseline = baseline.replace(b"\r\n", b"\n")
        preservation[rel] = {"unchanged_from_HEAD": data == baseline, "sha256": sha(data)}
        assert data == baseline, rel
    result = {"input_actual_format": "PNG RGBA, not the RGB JPEG described in the brief",
              "dimensions": list(images[1].size), "source_sha256": sha(paths[1].read_bytes()),
              "runtime_installed": runtime.exists(),
              "runtime_byte_identical": runtime.read_bytes() == paths[1].read_bytes() if runtime.exists() else None,
              "source_artwork_modified": False, "alpha_min": int(alpha.min()), "alpha_max": int(alpha.max()),
              "fully_transparent_pixels": int(np.count_nonzero(alpha == 0)),
              "fully_opaque_pixels": int(np.count_nonzero(alpha == 255)),
              "alpha_histogram": np.bincount(alpha.ravel(), minlength=256).tolist(),
              "samples": samples, "deep_transparent_regions": region_metrics,
              "strict_deep_aperture_transparency_pass": strict_clear,
              "warning": "Supplied material alpha is near-opaque (mostly 252/253), not 255; preserved, not certified fully opaque.",
              "protected_files": preservation}
    candidate_path = OUT / "rejected_generated_restore.png"
    if candidate_path.exists():
        candidate = np.array(Image.open(candidate_path))
        both_solid = (alpha > 245) & (candidate[:, :, 3] > 245)
        result["rejected_generated_candidate"] = {
            "sha256": sha(candidate_path.read_bytes()),
            "dimensions": list(Image.open(candidate_path).size),
            "fully_opaque_pixels": int(np.count_nonzero(candidate[:, :, 3] == 255)),
            "solid_silhouette_disagreements_at_alpha_128": int(np.count_nonzero((alpha > 127) != (candidate[:, :, 3] > 127))),
            "material_pixels_with_changed_RGB": int(np.count_nonzero(np.any(v02[:, :, :3] != candidate[:, :, :3], axis=2) & both_solid)),
            "compared_material_pixels": int(np.count_nonzero(both_solid)),
            "verdict": "REJECTED: geometry and RGB changed; material opacity still nonconforming"}
    (OUT / "asset_verification.json").write_text(json.dumps(result, indent=2) + "\n")
    print(f"ASSET_FORMAT_AND_PRESERVATION_PASS; STRICT_APERTURE_ALPHA_PASS={strict_clear}; FULLY_OPAQUE_PIXELS={result['fully_opaque_pixels']}")
    return 0 if strict_clear and result["fully_opaque_pixels"] > 0 else 1

if __name__ == "__main__":
    sys.exit(run())
