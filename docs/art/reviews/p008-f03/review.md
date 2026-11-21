# P008-F03 — V05 integration verification and tactical acceptance

2026-11-21. **TARGETED_CORRECTIONS_REQUIRED. P008-F03 is not technically complete against the requested Variant B contract. P008 owner artistic approval remains pending.**

V05 is already installed in the supplied HEAD `9448e6f`. This run independently verified that implementation, completed missing acceptance evidence, and found blocking geometry/readability defects. The existing commit title is not evidence of completion. No production code, native assertion, source/runtime artwork PNG, model API, slot, HUD, hand, or combat rule was changed in this verification. No V06 was generated and P009/P010 were not started.

## Decision and blocking findings

The supplied artwork passes its file/alpha prerequisite. Its cavities do **not** support the requested B reservations without crossing bronze or putting raised defense materials over the portrait. Production currently uses a lower, much thinner defense band and smaller primary glyphs. Merely declaring unused `VARIANT_B_*` constants does not integrate B.

| Finding | Evidence | Consequence |
|---|---|---|
| F03-01: defense geometry differs from B | B centers about y653; production centers y851. Actual dark neutral interiors are about y762–906. | Raised-center B layout is absent; moving only the text would place it in the portrait. |
| F03-02: primary readability materially regresses from B | Native 720p: B single/double **14/14 px**, V05 **12/10 px**. | V05 two-digit primary ink is about 29% shorter than B. Targets not reached. |
| F03-03: defense ink crosses material and bronze | At 720p Armor `12`: **16 bright pixels outside material alpha128, 8 on the bronze predicate**; Shield `12`: **11 and 8**. | A numeral fitting an abstract rectangle does not establish clean material containment. |
| F03-04: positive defense surface is too short | Neutral cavity segmentation is ~318×145 /317×145 source px; B reservations ~319×329. V05 defense ink is 10 px rather than 11 at 720p. | Enlarging only the numeral worsens border crossings. |

**Narrow correction proposal:** retain the outer V05 frame, jewel, slot positions and portrait treatment; revise only the four internal stat housings/apertures around the B content reservations below. Raise both neutral defense housings to the B centers and provide their required height; enlarge/reshape the two primary apertures to admit the actual B `12`, `14`, and `99` glyph masks plus outline. Keep bronze outside those masks and provide continuous original-material coverage beneath them. Recalibrate the portrait only where these internal housing boundaries change. This is a proposal for a localized supplied-art correction, not a generated replacement or an approved edit. No global alpha threshold or additional glyph compression is proposed.

If the artwork must remain byte-identical, an explicit change to the strict geometry/readability contract would be needed. This package does not silently make that tradeoff or shrink the numbers further. A renderer-only material adjustment may repair some contour spill, but cannot move the existing bronze defense housings from y851 to y653.

## Authoritative evidence and historical evidence warning

Use the new [verification index](verification/index.md), [240 fresh measurements](verification/measurements.json), [GPU results](verification/results.json), and [analysis output](verification/analysis.txt). These are actual Godot/OpenGL captures, at native resolution and the original token footprint. None are assembled or resized screenshots.

The files at the root of this folder were inherited from HEAD. In particular, `capture_f03.gd` uses `Control.draw_string` for its isolated probes instead of the production `CreatureToken.draw_number`; its `measurements.json` is **not valid evidence of production glyph bounds**. `scripts/tools/measure_v05_godot.gd` changes values without scheduling redraws and its saved repeated-value measurements are not accepted. `comp_config*.png` were Pillow mockups and are **not GPU comparisons**. These historical files are preserved, explicitly superseded for acceptance, and excluded from the new result counts.

## Source PNG and alpha

[Independent source measurements](verification/source.json), [dark composite](verification/composite_dark.png), [bright composite](verification/composite_bright.png), [cavity segmentation](verification/cavities.json).

- PNG **1536×1024 RGBA**; source/runtime SHA-256 `de92764000c40742fa865960646acde85ef19714102a0f73555a44c5c6ad1caf`; **byte-identical**.
- Compared with the inherited pre-normalization reference `original_v05.png`: all RGB values identical; alpha matches exactly 0/1→0, 254/255→255, 2–253 preserved. No alpha 1 or 254 remains. This verifies consistency with that available reference; provenance of the reference is inherited.
- Dark/bright source composites inspected: no obvious matte fringe, solid-metal hole or opaque portrait/primary contamination observed. This visual check is not a formal proof for every edge pixel.
- Connected fully transparent Attack aperture: `(92,694,249,259)`; Health `(1196,695,249,258)`; portrait `(94,98,1351,675)`, all XYWH in source pixels. The bounding boxes describe irregular openings, not safe rectangular writing areas.
- Dark neutral cavity masks: Armor `(425,762,318,145)`, Shield `(794,762,317,145)`. These use declared color/alpha thresholds and exclude bronze; bounds alone do not certify corner containment.

The original ART-002 textures and all V01–V04/V03 history remain untouched. The runtime was already installed correctly in HEAD; no redundant copy was needed.

## Geometry and rendering

Slot **162×112 reference px**, token **154×102.667**, continuous 720p footprint **102.667×68.444 physical px**. All 24 original positions are preserved.

Exact B scale is **1536/154**, as in P008-F01. Values below retain the prototype's `38.6667` height convention; rounded center labels in the brief are approximate.

| Stat | B rectangle, reference XYWH | B source rectangle XYWH | Current production source placement |
|---|---|---|---|
| Attack | 1,63,39,38.6667 | 9.974,628.364,388.987,385.663 | center 216,823; material 300×300; safe radius 122 |
| Armor | 43,49,32,33 | 428.883,488.727,319.169,329.143 | 365,788,380,126; center 555,851 |
| Shield | 79,49,32,33 | 787.948,488.727,319.169,329.143 | 780,782,380,138; center 970,851 |
| Current Health | 114,63,39,38.6667 | 1137.039,628.364,388.987,385.663 | center 1320,823; material 300×300; safe radius 122 |

B source centers are `(204.468,821.195)`, `(588.468,653.299)`, `(947.532,653.299)`, `(1331.532,821.195)`. The primary clear openings are only ~249×259 source px versus B's ~389×386 reservation. A 720p B primary `12` has ~19×14 px ink, which cannot be treated as safely contained by V05's roughly 17 px diameter aperture.

Production preserves official `INLAY_ATTACK`, `INLAY_HEALTH`, `PLATE_ARMOR`, `PLATE_SHIELD` and the shared stroke/shadow renderer. No duplicate bezel was added. Its inherited primary fitting retains 0.80 horizontal scale for double digits, whereas B uses uncompressed glyphs. This run adds no compression. Effective Attack/current Health are supplied independently of printed/base Attack/maximum Health. Secondary zero values retain their model values and draw neither numeral nor active material; the neutral painted housing remains visible.

## Same-data comparisons and native ink

V03 is reconstructed from the actual `c91cf83` renderer/layout, with its class name removed and review probe hooks added. V05 delegates to current production. B delegates to the original F01 functional renderer. All use the same resolved models, Arcane Knight portrait, five repeating stat tuples, statuses/equipment flags, footprint and slot coordinates. Native V03 is not accidentally replaced by current V05 when the baseline is rendered.

| Bright ink height | V03 720p /1080p | B 720p /1080p | V05 720p /1080p |
|---|---|---|---|
| Primary single | 11 /17–18 px | **14 /20–21 px** | **12 /19 px** |
| Primary double | 9 /15 px | **14 /21 px** | **10 /15 px** |
| Secondary positive | 7 /11–12 px | **11 /16–17 px** | **10 /14–15 px** |

Measured all four stats, ten values `0,1,2,3,6,8,10,12,14,99`, both resolutions, first-slot fractional raster phase: **240 records**. Secondary-zero probes are hypothetical; real scene zeros are suppressed. Bright ink uses alpha≥128 and RGB≥150/150/140. Separate all-alpha bounds include outline, shadow and antialiasing. Font point size is never used as the visible ink measurement.

Each record includes width/height, all-alpha bounds, material-alpha spill, full-alpha cell margin, contrast and nearest bronze distance. Bronze uses a disclosed warm-color predicate, not perfect semantic edge segmentation. At V05 Armor/Shield `12`, bronze distance is **0 px**. Their full-alpha material-rectangle margins are negative (Armor **−1.13 px**, Shield **−0.73 px** at 720p). Local Armor `12` contrast is about **1.72 minimum /9.33 median**; Shield about **3.27 /11.87**. These textured, per-pixel diagnostics are not accessibility certification. B itself retains the documented primary-material contour spill; its diagnostic surfaces are not approved final artwork.

Native full-board comparisons: [V03 720p](verification/v03_full_board_720p.png), [B 720p](verification/b_full_board_720p.png), [V05 720p](verification/v05_full_board_720p.png); [V03 1080p](verification/v03_full_board_1080p.png), [B 1080p](verification/b_full_board_1080p.png), [V05 1080p](verification/v05_full_board_1080p.png).

Single/focused scenes: [single 720p](verification/v05_single_720p.png), [four positive](verification/v05_four_positive_720p.png), [two digits](verification/v05_two_digit_720p.png), [99](verification/v05_stress_99_720p.png), [zero defenses](verification/v05_zero_defense_720p.png), [status overflow](verification/v05_status_overflow_720p.png), [equipment flags](verification/v05_equipment_720p.png), [mixed board](verification/v05_mixed_stats_720p.png), [hover](verification/v05_hover_720p.png), [selection](verification/v05_selected_720p.png). Corresponding 1080p images are indexed.

## Portraits, indicators and full-board judgment

Actual [bright](verification/v05_bright_720p.png) / [dark](verification/v05_dark_720p.png) GPU portrait fixtures use in-memory exposure changes, with no source edits. There is only **one suitable creature illustration** in the current assets: Arcane Knight. Multiple creature compositions remain untested; no new portrait was generated.

The current source polygon covers every fully transparent portrait-aperture pixel and intersects zero fully transparent Attack, Health or boundary-connected exterior pixels in the measured source masks. Aspect-fill cropping uses one scale without distortion. Native screenshots show a recognizable Knight face with no obvious unfilled wedges or image spill. Alpha2–253 transition pixels are not exhaustively classified by the alpha0 mask test.

All 24 token rectangles fit their original slots in GPU checks, with no observed frame overlap, clipping or HUD/hand collision at either resolution. The supplied V05 is visually quieter than heavily ornamented earlier frames and preserves the face. However, its lower band compresses all four statistics into one line and positive defenses cross bronze; the tactical hierarchy is weaker than B. This is visual judgment supported by the measured glyphs, not a user recognition study.

Three status slots, +N overflow, attachment booleans and icon injection remain unchanged. Fresh V03/V05 comparisons keep diagnostic letters disabled. The inherited B renderer deliberately includes its labeled historical placeholder convention. Windows `--preview-tokens` demonstrations explicitly enable diagnostic W/P/status letters. These are review fixtures, not production icon artwork. Approved status/equipment icons remain an art dependency; flags without injected art are not claimed to have final production iconography. P010 was not implemented.

## Regression and Windows evidence

| Check executed on this checkout | Result | Actual process exit |
|---|---|---:|
| Headless editor import | PASS | 0 |
| Full native test suite | **3691/3691**, no assertion edits this run | 0 |
| Three-renderer GPU comparisons/probes/input | **1276 checks, 0 failures** | 0 |
| Active no-ink GPU backgrounds | **6 checks, 0 failures** | 0 |
| Raster/source analysis | 240 records; acceptance defects recorded | 0 |
| ART-002 visual regression | **3/3 bit-exact, zero differing pixels** | 0 |
| Production preservation | **225 tracked production files match HEAD** | 0 |
| P005–P008 empty-board regression | All six V03/B/V05 resolution pairs match P006, **0 differing pixels** | 0 |
| Standard Windows release export | PASS, embedded executable | 0 |
| Full-board Windows OS input | default/1080p/720p PASS | 0 |
| Single-token Windows OS input | default/1080p/720p PASS | 0 |
| `git diff --check` | PASS | 0 |

The supplied HEAD has 3691 assertions, versus the brief's older 3681 baseline. The additional ten and prior geometry recalibrations predate this run; no assertion was removed or weakened here. The pre-existing P007 off-tree anchor warning remains in the native log. A passing regression count is not a readability pass.

Logs: [import](verification/import-current.txt), [native](verification/tests-current.txt), [GPU](verification/gpu.log), [backgrounds](verification/backgrounds.log), [ART-002](verification/art002-current.txt), [export](verification/export-current.txt), [full-board Windows](verification/windows-full-input.log), [single-token Windows](verification/windows-single-input.log), [preservation](verification/preservation.json), [final result manifest](verification/validation.json).

The fresh executable is `build/windows/MagicOdyssey.exe`; each Windows test copies only this embedded executable to a unique temporary directory and shell-launches it. Full-board tests use real Windows pointer motion/clicks over **all 24 identities**, selection switching/toggling, player card hover, raised-card click isolation, End Turn mouse/Space activation, and ESC exit 0. All checks run independently at default mode (1888×956 client on this desktop), exact 1920×1080 and exact 1280×720. GPU SubViewport events are separately labeled and never substituted for OS input. [Windows 720p selected board](verification/windows-full-input/desktop-1280x720-selected-player-attack.png), [raised card isolation](verification/windows-full-input/desktop-1280x720-raised-hand-no-slot-leak.png).

## Reproduction, limitations and completion boundary

Use Godot 4.7.2 stable, Windows/OpenGL Compatibility, NVIDIA GTX 1660 Ti. Run `verification/capture.gd`, then `verification/backgrounds.gd`, then `python docs/art/reviews/p008-f03/verification/analyze.py`. The second GPU script is mandatory: it supplies active-defense no-ink backgrounds rather than a zero-defense background. Run `scripts/tests/run_visual_regression.ps1` without updating goldens, `scripts/build_windows.ps1`, and `scripts/tests/playtest_windows.ps1 -BattlefieldSlots -UtilityHud -TokenScenario full_board` / `single` with separate review directories. Native invocation: `Godot --headless --path . --script res://scripts/tests/test_runner.gd`.

Graph project `D-Dev-MagicOdyssey`, generation `2026-11-20T19:02:30Z`, returned no relevant GDScript symbols and reported unavailable coverage/changed metadata for the bounded candidate paths. Direct source reads, historical-source extraction and runtime verification were used; no exhaustive graph claim is made.

NOT_RUN: revised-art integration, target-achieving production B layout, broader creature portrait compositions, final approved status/equipment art, and owner artistic acceptance. These are unresolved requirements/dependencies, not successful tests. No final-art approval is implied by the passing regression and Windows checks. **Do not close P008-F03, P008 or G1 on this evidence.** P005 remains owner-approved; P006/P007 retain their statuses; P009/P010 remain TODO; G1 NOT_VALIDATED. Stop after this P008-F03 package.
