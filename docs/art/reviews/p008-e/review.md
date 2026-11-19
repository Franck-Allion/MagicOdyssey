# P008-E — Minimal CreatureToken V03 integration

2026-11-19. **V03 integrated; readability targets NOT MET. Owner artistic approval NOT granted.** P009/P010 remain TODO and G1 remains NOT_VALIDATED.

## 1. Source and alpha validation

Owner input: `assets/_source/lot1/tokens/mo_creature_token_frame_v03.png`. PNG RGBA, **1536×1024**, SHA-256 `11aad8771668bedba8056d9d824144b702905b2f82008b8f371348512f598c28`. Runtime `assets/textures/tokens/mo_creature_token_frame_v03.png` is byte-identical. Source artwork was not edited, regenerated or normalized. V01 and V02 source/runtime artwork remain unchanged.

[Source metrics](source_verification.json) include the complete alpha histogram and RGBA samples. All four exterior corners, portrait (768,400), Attack (233,800) and Health (1300,800) samples have alpha 0. Neutral Armor (580,840) and Shield (950,840) samples have alpha 253. The file contains fully opaque pixels, but most material is near-opaque; no claim of uniformly alpha-255 interiors is made.

Actual [dark](v03_dark_composite.png) and [light](v03_light_composite.png) alpha composites were inspected: no significant matte fringe or colored edge contamination was reproduced. The initial raw preview showed apparent red/yellow contour colors; that preview was not treated as proof of a defect after real compositing contradicted it. Warm-color pixel counts in the JSON are simple color predicates, not defect counts; those samples include legitimate bronze. No cleanup was applied. [Offline 720p footprint diagnostic](v03_native_size_diagnostic_720p.png) is explicitly a composite study, not a Godot screenshot. Genuine engine evidence follows below.

Lossless runtime import generates mipmaps with alpha-border fixing; CreatureToken retains linear mipmap filtering.

## 2. Measured calibration and production changes

Only the frame reference and authoritative layout change in production. The portrait polygon follows the V03 opening rather than retaining V02's curved outline. An initial diagonal upper-right clipping gap found in source-scale GPU inspection was corrected by extending the polygon beneath the existing bronze rim; final captures and executable use that correction.

Source alpha scanlines at y800 show clear Attack x113–353 and Health x1179–1418, supporting the chosen centers. Neutral plaque samples and visual boundaries guided independently fitted inserts rather than blindly transferring V02 bounds.

| Element | V02 / P008-D | V03 |
|---|---|---|
| Canvas / fitted token | 1536×1024 / 154×102.667 reference px | unchanged |
| Attack center | (220,802) | **(233,800)** |
| Current Health center | (1317,802) | **(1300,800)** |
| Primary inlay size | 296×296 | unchanged; material sits behind the new frame |
| Primary font ceiling / fit radius | 240 / 106 | **260 / 116** source px |
| Armor insert | (400,802), 336×116 | **(420,787), 322×116**, center (581,845) |
| Shield insert | (800,796), 336×128 | **(802,785), 312×120**, center (958,845) |
| Secondary font / width | 170 / 260 | unchanged; housing padding constrains height |
| Portrait fill target | (108,84), 1320×690 | **(112,116), 1304×620**, new 22-vertex clipping polygon |
| Status origin | (410,120) | **(410,150)** |
| Weapon / Protection fixture origins | (260,140) / (1140,140) | retained, inside V03 upper safe regions |

Stat order remains **ATTACK — ARMOR — SHIELD — HEALTH**. Positive defenses use original `PLATE_ARMOR`/`PLATE_SHIELD`; zero values draw neither numeral nor insert. Primary materials remain official `INLAY_ATTACK`/`INLAY_HEALTH`, with no duplicate original card bezels. Current Health stays separate from maximum Health. The existing moderate 0.80 horizontal scale for multiple primary digits is retained; no additional compression was used to force the targets.

Changed code: `creature_token.gd`, `creature_token_layout.gd`, and asset-specific expectations in `test_creature_token.gd`. Tests now expect the V03 file, measured centers, y845 secondary baseline and V03 housing band; assertion count and non-geometric behavior checks are retained. One initial stale V02 band expectation failed and was corrected to the new measured band. No view-model contract, lifecycle, P006 identity, P007 binding, P005 composition, CombatEngine or card definition changed.

## 3. Reversible comparison using identical data

`capture.gd -- --variant=A` renders a development-only V02 adapter derived from HEAD P008-D code/layout. `--variant=C` renders production V03. This is a review script, not a gameplay option. A production frame switch was not exposed to players. Historical artwork remains available for fallback.

Paired genuine Godot GPU screenshots, unretouched and native-size:

- Full 24 at [V02 1080p](A/v02_full_board_1080p.png) / [V03 1080p](C/v02_full_board_1080p.png), [V02 720p](A/v02_full_board_720p.png) / [V03 720p](C/v02_full_board_720p.png).
- Mixed four-stat board at [V02 720p](A/v02_mixed_board_720p.png) / [V03 720p](C/v02_mixed_board_720p.png); equivalent 1080p files are retained.
- [V03 double digits 720p](C/v02_double_digit_720p.png), [four stats](C/v02_four_stats_720p.png), [zero defenses](C/v02_zero_armor_shield_720p.png), [selection](C/v02_selected_token_720p.png), [five statuses](C/v02_status_overflow_720p.png).

The inherited filename prefix `v02_` describes the original capture harness naming, **not the frame in folder C**. Scenario screenshots in folder A use V02; those in C use V03. The inherited material-activation and printed-overlay diagnostics always exercise the production V03 component, even when saved in A; they are not comparative V02 screenshots. Neither scenario image was synthesized or resized for the comparison.

The mixed fixture repeats eight identical value combinations across 24 slots for both frames, including Attack 1/6/12/14, Health 1/8/12/14, Armor 1/2/10/12 and Shield 1/3/10/12. `extra_cases.gd` explicitly regenerates these paired mixed boards. Single, positive/zero defenses, full/mixed board, equipment, overflow, empty and bright/dark diagnostic portraits are also captured at both sizes.

Native comparison shows less decorative noise and clearer neighboring frame separation in V03. Portrait fill remains large; the same existing illustration is reused, not 24 different artworks. No overlapping frames, HUD/hand collisions or slot-size increase was observed. Hover/selection still uses P006 feedback. Status and equipment diagnostics remain dense and tiny; approved icon artwork is still needed, with development-only letters controlled by the unchanged P008-D flag.

## 4. Actual native 720p glyph measurements

[Per-value raster boxes](glyph_measurements.json) measure real GPU glyph-only renders at the production scale and first-slot fractional phase. Ink criterion: alpha≥128, R/G≥150, B≥140. All-alpha bounds including antialiasing/outline/shadow are separately stored. Representative Attack/Armor positions are measured; Health/Shield share their rendering style and baseline. [Font-fit metadata](font_fit.json) records computed points separately from visible ink.

| Statistic at 720p | V02 bright ink | V03 bright ink | Target outcome |
|---|---|---|---|
| Primary `1` | 7×11 px | 5×11 px | below ~12 px height |
| Primary `6` | see full JSON | 11 px height | below ~12 px |
| Primary `12` / `14` | 9×9 px | **11×9 px** | wider, **not taller**; below ~12 px |
| Secondary `1` | 2×7 px | 3×7 px | below 9–10 px |
| Secondary `12` / `14` | 9×7 / 8×7 px | unchanged | below 9–10 px |

At 1080p, V03 primary `1` ink is 18 px high and `12/14` 15 px; secondary ink is approximately 12 px. At 720p, source font ceiling 260 does not imply 17-pixel visible text: fitting, font ink proportions, raster phase and downscaling determine the observed result. Primary `10/12/14` fit at 210/214/212 source points; secondary stays at 170.

**The requested 720p height targets are not met.** A simpler frame and wider two-digit ink do not establish comfortable at-a-glance four-stat recognition. Increasing font until it crosses the plaque rim, enlarging the tactical footprint or imposing more extreme glyph distortion was not used to manufacture a passing result. V03 is retained as the technically integrated candidate, but **do not grant artistic acceptance or claim the readability objective is solved**.

## 5. Regressions and executable

Godot 4.7.2 stable ed1daf0bf; Windows; OpenGL Compatibility; NVIDIA GTX 1660 Ti / driver 551.86.

| Check | Final result | Exit |
|---|---|---:|
| Headless import | PASS, V03 lossless/mipmap import | 0 |
| Complete native P005–P008 suites | **3681 passed / 0 failed**, same total as P008-D | 0 |
| V02 development GPU checks | **717 passed / 0 failed** | 0 |
| Final V03 GPU checks | **717 passed / 0 failed** | 0 |
| Additional paired mixed-value captures | PASS at both sizes | 0 |
| ART-002 bit-exact regression | **3/3**, zero differing pixels | 0 |
| Empty-board parity vs P006 | Zero differing pixels at both sizes, both frames | 0 |
| Normal embedded Windows release export | PASS | 0 |
| Final corrected-build OS-pointer harness | Three runs PASS: all 24 populated slots at exact 1080p/720p and default | 0 |
| `git diff --check` | PASS | 0 |

Logs: [native](tests.log), [V02 GPU](A/gpu.log), [V03 GPU](C/gpu.log), [ART-002](art002.log), [export](export.log), [final Windows](windows-final.log). The pre-existing P007 off-tree anchor warning persists in native tests; no new script error. Native assertions were recalibrated for the changed asset, not removed. Model/lifecycle, status/equipment state, P007 snapshots and printed-card checks remain in the full suite.

[Preservation manifest](preservation.json) verifies unchanged protected presentation/card files and V03 source/runtime identity. V01/V02 artwork is additionally compared byte-for-byte to HEAD. Graph coverage was unavailable/truncated, so evidence relies on exact source reads/diffs and executed tests rather than a claim of complete graph coverage.

The first Windows run passed before the portrait-corner correction; it is retained under `windows-full/` as development evidence only. Final acceptance uses the corrected build under `windows-final/`. These are actual Windows pointer tests, distinct from injected SubViewport events in the GPU harness.

Executable: `D:\Dev\MagicOdyssey\build\windows\MagicOdyssey.exe`. Populated preview:

```powershell
& .\build\windows\MagicOdyssey.exe -- --preview-tokens=full_board --preview-size=1280x720
```

## 6. Remaining owner decisions

Review V03's reduced ornamentation, portrait composition and separation at native size. **Do not approve tactical readability on cleanliness alone**: primary doubles remain 9 px high and positive defenses 7 px. Owner direction is still needed on how to gain real information space within the preserved battlefield layout. Diagnostic status/equipment art remains unfinished. No automatic owner approval, no P009/P010 work, G1 NOT_VALIDATED. Stop after P008-E.

Final Windows evidence: [selected 720p](windows-final/desktop-1280x720-selected-player-attack.png), [selected 1080p](windows-final/desktop-1920x1080-selected-player-attack.png). All three runs verified switching/toggle, real hand hover/raised-card isolation, End Turn mouse/Space and ESC exit 0; no remaining game process. These are presentation interactions, not CombatEngine turn advancement. Transient Windows titlebar tooltips in desktop captures are retained without retouching. [Execution summary](results.json).
