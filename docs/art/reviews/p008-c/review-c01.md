# P008-C01 — Deterministic V02 alpha repair: PASS

Date: 2026-11-18. **ALPHA STEP: PASS. P008-C integration remains pending.** No owner artistic approval granted. This result supersedes the earlier request for a native export for this bounded alpha check; the earlier failed attempt is retained below as history.

## Corrected files and preservation

- Corrected source: `assets/_source/lot1/tokens/mo_creature_token_frame_v02.png`.
- Byte-identical runtime file: `assets/textures/tokens/mo_creature_token_frame_v02.png`. This stages the file only; **CreatureToken still references V01**.
- [Original byte-preserving backup](c01/original_v02.png), SHA-256 `10266d58e3aaa9505dd385de16aef2c842359681b60eb9b14197ad36d0680018`.
- Corrected source/runtime/candidate SHA-256: `c5b09a920793d6fef70181e300595efe1702dd3bd98b9a5f9d1e58dbb1f10aba`.

The input and output are lossless PNG RGBA, exactly 1536×1024. No ImageGen, rejected generated output, JPEG reconstruction, RGB flood fill, resampling, blur, sharpening or repainting was used on the asset. V01, presentation code, ART-002 textures, P005/P006/P007, domain, HUD and grid remain unchanged. P009/P010 remain TODO; G1 remains NOT_VALIDATED.

## Exact normalization and measurements

```text
A = 0 or 1  -> 0
A = 254/255 -> 255
A = 2..253  -> unchanged
Every RGB channel value -> unchanged
```

Exactly **28,686 alpha pixels** changed: 27,076 from 1 to 0; 1,610 from 254 to 255. Every change is ±1/255. **Zero RGB channel values changed** across 1,572,864 pixels. Save/reload reproduces the candidate pixel array exactly. The alpha≥128 silhouette and alpha≥2 support masks are identical; no alpha≥2 metalwork was removed, moved or filled. All antialiasing values 2–253 and metallic highlights are preserved exactly.

| Alpha | Original count | Corrected count |
|---|---:|---:|
| 0 | 949,335 | 976,411 |
| 1 | 27,076 | 0 |
| 2–253 | 594,843 | 594,843; each individual bin unchanged |
| 254 | 1,610 | 0 |
| 255 | 0 | 1,610 |

Full 256-bin histograms and all individual RGBA samples: [c01/metrics.json](c01/metrics.json). [Changed-pixel mask](c01/modified_alpha_pixels.png), [alpha before](c01/alpha_before.png), [alpha after](c01/alpha_after.png).

| Region | Source coordinates | Alpha before → after |
|---|---|---|
| Exterior corners | (0,0), (1535,0), (0,1023), (1535,1023) | 0 → 0 |
| Portrait center | (768,350) | 0 → 0 |
| Attack / Health centers | (220,802) / (1317,802) | 0 → 0 |
| Bronze highlight | (1259,46) | 254 → 255 |
| Midnight-blue enamel | (55,380) | 253 → 253 |
| Neutral Armor / Shield housings | (570,860) / (970,860) | 253 → 253 |

The deep portrait rectangle x=180..1349, y=180..569 is now entirely alpha zero (1,294 residues removed). Radius-90 disks at both cabochon centers are entirely alpha zero (Attack: 206 residues removed; Health: 42).

The housings remain approximately 99.2% opaque at the sampled points. This PASS follows the explicitly requested preservation of 2–253; it **does not certify uniformly alpha-255 material interiors** or introduce a global exception for other assets.

## Connected-region and visual validation

The script inspects remaining positive alpha **2–31**, using exact 8-connectivity: **27,159 pixels in 249 regions**. All lie within Chebyshev distance 12 source pixels of alpha≥128 material. Of these, 224 pixels in six regions are farther than eight pixels; none is farther than 12, 16 or 24. Their bounds and counts are recorded individually in the metrics.

The six flagged regions follow the upper portrait rim, upper exterior frame and side ornaments. Their source RGB and alpha were inspected in the [edge-region sheet](c01/flagged_edge_regions.png). The existing edge taper was retained. At the 720p footprint, 12 source pixels correspond to approximately 0.8 physical pixel. The remaining low-alpha mask is **not empty**; this validation does not pretend every contour pixel must be zero.

There are also 400 removed alpha-1 pixels farther than eight pixels from an original zero, primarily in the top exterior edge area. Their [location mask](c01/removed_alpha1_away_from_original_zero.png) was inspected rather than assuming every alpha-1 pixel was adjacent to zero. The alpha≥2 support remains identical and no new visible holes in metal were found. No uncertain boundary inference or further cleanup was applied.

Inspected actual offline composites: [dark battlefield](c01/after_battlefield.png), [light contrasting background](c01/after_light.png), [bright portrait](c01/after_bright_portrait.png), [dark portrait](c01/after_dark_portrait.png), and [official Attack/Health inlays](c01/after_official_inlays.png). The battlefield is existing V03 artwork darkened to 0.45 for diagnosis. Portraits use existing Arcane Knight artwork at diagnostic brightness 2.5 and 0.18. Original ART-002 material files are placed under the frame, without extra bronze bezels. Diagnostic resizing/brightness affects review images only, never the asset. Corresponding `before_*.png` files are retained. Maximum before/after difference in any composited channel: **1/255**, for each of the five backings.

The [native 720p comparison](c01/native_720p_comparison.png) is an actual 1280×720 canvas showing before/after tokens at **103×69 raster pixels**, approximating the unchanged 102.667×68.444 physical-pixel footprint. It was inspected at actual dimensions. No significant white halo, damaged edge, unexpected visible metal hole or inlay seam was observed. Source-scale enlargements were supplementary evidence.

These are explicitly **offline composites, not Godot GPU screenshots**. The reference portrait polygon and source-space inlay positions are used only in diagnostics. No integration, numeral readability, game filtering/mipmap or Windows runtime acceptance is implied.

## C01 execution and remaining scope

Reproducible [Python/Pillow/NumPy script](repair_alpha_c01.py): candidate preparation **exit 0**; `--install` after inspection **exit 0**. No package installation was needed. Installation requires all numeric checks and a [visual PASS record](c01/visual_review.json) matching the candidate hash. Source/runtime byte identity is recorded in [metrics.json](c01/metrics.json).

Final independent read-back verified the exact alpha formula, original backup hash, RGB identity, source/runtime identity and protected-file preservation. `git diff --check`: **exit 0**. Godot native/GPU/Windows tests: **NOT_RUN for C01**, because this task explicitly excludes integration. No prior assertion count is reported as a fresh result.

**Stop after P008-C01. Alpha repair PASS; P008-C integration and owner artistic acceptance remain pending.**

---

# Historical P008-C attempt — superseded for the alpha step

The following describes the original uncorrected asset and previous failed generation attempt. The original report is also preserved in [review-p008-c-initial.md](review-p008-c-initial.md). Its metrics and native-export recommendation are historical, not the C01 result above.

Date: 2026-11-18. **INCOMPLETE / ALPHA VERIFICATION FAILED.** No owner artistic acceptance granted.

## Outcome

The supplied V02 does not match the brief's RGB JPEG description. The actual existing input is a 1536×1024 RGBA PNG at `assets/_source/lot1/tokens/mo_creature_token_frame_v02.png`, SHA-256 `10266d58e3aaa9505dd385de16aef2c842359681b60eb9b14197ad36d0680018`. Its bytes were preserved. The supplied frame has the requested neutral secondary cavities, but its alpha does not meet the strict transparent-opening / opaque-material requirements.

One restoration was attempted with the built-in imagegen tool, requesting alpha-only repair and exact geometry/material preservation. It failed verification and was rejected. **A native transparent V02 PNG with corrected alpha is required to continue.** This is a failure of this restoration attempt, not a claim that mathematical alpha cleanup is impossible.

The brief explicitly says to stop if production-quality reconstruction cannot be obtained. Stages 2–6 were therefore not delivered. Preliminary local runtime/layout edits were fully undone; CreatureToken still uses V01. No V02 runtime texture remains. No ART-002 assets, P005 geometry, P006 slots, P007 APIs, test assertions, scenes or shaders were changed. P009/P010 remain TODO; G1 remains NOT_VALIDATED.

## Measured input defects

- PNG format, RGBA channels and exact dimensions: PASS.
- 949,335 pixels have alpha 0. The portrait and both cabochon center samples are transparent.
- Strict deep-interior transparency: FAIL. A portrait rectangle x=180..1349, y=180..569 contains 1,294 pixels with alpha 1/255. Radius-90 disks around Attack (220,802) and Health (1317,802) contain respectively 206 and 42 pixels with alpha 1/255. These are well inside the openings, separate from their antialiased boundaries.
- Opaque materials: FAIL against the explicit fully opaque requirement. Alpha maximum is 254; **no pixel reaches 255**. Bronze/enamel and both neutral-cavity samples are typically alpha 253. This is a small visual difference but is not reported as fully opaque.
- Geometry comparison: the V01 and V02 alpha contours differ around primary circular openings and the portrait's lower boundary. The V01 alpha was not blindly transferred.

The low-alpha residue is subtle. Direct inspection of the [dark](v02_composite_dark.png), [bright](v02_composite_bright.png) and [battlefield](v02_composite_battlefield.png) composites did not reveal an obvious white matte fringe at displayed source scale. That observation does not override the failed numeric alpha requirements or establish native-720p readability. Bright metal highlights were retained. No threshold-based white removal or repainting was applied.

The bright and dark backings are synthetic uniform diagnostic colors, not production portraits. The battlefield composite uses the project's V03 battlefield artwork resized for source-scale examination; it is **not a screenshot of the game or evidence of unchanged battlefield composition**.

## Rejected restoration

[Rejected candidate](rejected_generated_restore.png): PNG RGBA, 1536×1024. Visual inspection shows changed metal detail. Automated comparison to the supplied V02 finds:

- 8,364 solid-silhouette disagreements at alpha threshold 128.
- Changed RGB in 538,627 of 541,877 compared material pixels (both inputs alpha >245).
- Zero fully opaque pixels; alpha defect unresolved.

It is review evidence only and is never loaded by the game. The [exact prompt](restoration_prompt.txt) records the built-in tool request. No generated replacement was installed or represented as approved artwork.

## Evidence and verification

- [V01 versus supplied V02](v01_vs_v02_artwork.png): labeled 50% source-art diagnostic.
- [V02 alpha channel](v02_alpha.png): actual supplied alpha values.
- [Same-coordinate alpha alignment](alpha_alignment_v01_v02.png): green=V01, magenta=V02; near-white=overlap. This uses supplied alpha rather than a transferred mask.
- [Machine-readable audit](asset_verification.json): alpha histogram, measured regions, hashes, rejected-candidate metrics, and unchanged protected-file comparisons against current HEAD.
- `python docs/art/reviews/p008-c/inspect_assets.py`: **exit 1**, strict alpha verification failed as documented. Diagnostic files are written before returning failure. All protected-file comparisons passed.
- A preliminary Godot headless editor import ran successfully, **exit 0**, before the failed detailed alpha check. This establishes importability only. Temporary runtime texture/import files and preliminary integration changes were removed after rejection.
- `git diff --check`: **exit 0** after final documentation updates.
- Complete native suite, ART-002 GPU regression, P005/P006/P007 GPU regressions, P008 model suite, native 720p readability, 24 populated-slot interactions, hand/End Turn checks, 1080p/720p GPU screenshots, Windows export and isolated executable playtests: **NOT_RUN for P008-C**, because Stage 1 failed. The historical 3,620 assertions remain the P008-B baseline; they are not a fresh P008-C result.

## Artistic recommendation and continuation

Do not approve or install either candidate as a completed P008-C asset. Obtain a native V02 RGBA export with alpha-0 interiors/exterior, alpha-255 material interiors and smooth antialiasing confined to edges, preserving original V02 RGB detail and contours. Re-run this preflight, then proceed to runtime import, measured plaque/numeral calibration and the complete requested GPU/native/Windows matrix. Four-stat native-720p readability remains unreviewed in P008-C; the prior P008-B limitation remains open.
