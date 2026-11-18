# P008-C — Stage 1 stopped: native V02 alpha correction required

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
