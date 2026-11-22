# Current owner decision - 2026-11-22

**OWNER ART-APPROVED / WINDOWS TECHNICAL FOLLOW-UP PASS (2026-11-22).** The owner explicitly accepted the V05 frame and P008-F04 Bahnschrift typography after viewing the actual Windows executable, including native 720p readability as a deliberate Lot 1 compromise. No further V05 redesign is required before P009.

See [final owner sign-off](../p008/owner-sign-off-2026-11-22.md). This supersedes the internal-housing redesign recommendation and every pending-owner-approval statement in the historical review below. Measurements, residual material interference, reduced 99 height, icon dependencies and historical blocked automation remain unchanged.

The new [Windows follow-up](../p008/final-windows-2026-11-22/review.md) passed real OS-input checks at 1080p, 720p and default mode on 2026-11-22. These new results do not relabel the historical failed attempts. No second owner artistic review was required.

## Historical review - 2026-11-21 (preserved verbatim)

# P008-F04 — CreatureToken numeral clarity

2026-11-21. **IMPLEMENTED / WINDOWS VERIFICATION BLOCKED / OWNER TYPOGRAPHY REVIEW PENDING.** Selected candidate **C**, subject to completing Windows desktop verification. This is not final P008 artistic approval.

The owner explicitly accepted the current V05 geometry in this task. That decision supersedes the earlier proposal to change the internal housings. All existing stat coordinates, portrait cropping, frame artwork, slot positions and HUD composition are preserved. The refinement changes only token numeral typography. P009/P010 remain TODO; G1 remains NOT_VALIDATED.

## Selected treatment and native comparison

Token numerals now use **Bahnschrift at weight 700, natural width**, pure white fill, one black glyph outline, and no shadow. The outline is 10 source pixels: about 0.67 continuous screen pixels at 720p, producing an approximately **one-pixel raster boundary**. Secondary font ceiling is 190 source points; the existing primary ceiling and safe circle remain unchanged. Two-digit primary horizontal scale changes from **0.80 to 1.00**. Fitting still protects the existing numerical envelope; it introduces no custom per-digit offsets.

Inspect the actual native [six-variant comparison at 720p](comparison_720p.png) and [1080p](comparison_1080p.png). The [complete battlefield pair](full_board_pair_native_720p.png) contains two independently GPU-rendered 1280×720 screens placed adjacent in a 2560×720 viewport. Neither panel is resized. Read the file at 100% scale to compare its individual screens.

Before/after, matching data and battlefield positions:

| Scenario | Original A, 720p | Selected production, 720p |
|---|---|---|
| Single token | [Before](a_single_720p.png) | [After](production_single_720p.png) |
| Four positive stats | [Before](a_four_positive_720p.png) | [After](production_four_positive_720p.png) |
| Attack 12 / Health 14, Armor 10 / Shield 12 | [Before](a_two_digit_720p.png) | [After](production_two_digit_720p.png) |
| Two-digit defenses | [Before](a_secondary_digits_720p.png) | [After](production_secondary_digits_720p.png) |
| Stress 99 | [Before](a_stress_99_720p.png) | [After](production_stress_99_720p.png) |
| All 24 occupied, positive stats | [Before](a_full_board_720p.png) | [After](production_full_board_720p.png) |
| Mixed full board | [Before](a_mixed_stats_720p.png) | [After](production_mixed_stats_720p.png) |
| Zero defenses | [Before](a_zero_defense_720p.png) | [After](production_zero_defense_720p.png) |

All scenes also exist at native 1920×1080; see the [capture index](index.md). These are genuine Godot GPU images, not enlarged crops, retouched images or mockups. An original-HEAD renderer snapshot supplies A. Its two-digit captures match the corrected F03B V05 baseline **bit-exactly at both resolutions**. The installed production treatment matches candidate C bit-exactly in all tested static scenarios at both sizes. Hover/selection are checked functionally; pixel equality during a feedback Tween is not claimed.

## Baseline diagnosis and font analysis

`TacticalNumber` is a `SystemFont` in the global theme, not an imported font file. Its family stack resolves on this computer to **Palatino Linotype Bold**; Cinzel and Trajan Pro are not the resolved face. The original numeral renderer draws a 4-source-pixel dark theme-colored outline plus an outlined directional shadow offset by 2 source pixels. At the 720p token scale these correspond to about **0.27 /0.13 physical px** before rasterization. They do not supply a consistent opaque black perimeter. Thin serif details and the primary 0.80 width transform make small doubles visually busy over the materials.

The final token font resolves to Bahnschrift. Although its reported style name is `Regular`, the measured variation coordinates are **wght=700, wdth=100**, so this is the supported bold variable instance at natural width, not simulated compression. [Font properties and actual resolution](fonts.json), [font inspection log](font-inspection.log).

No font binaries were copied, embedded or redistributed. The new resource uses the installed Windows font through `SystemFont`, with Segoe UI and Arial fallbacks. Microsoft documents [application use of installed Windows fonts](https://learn.microsoft.com/en-us/typography/fonts/font-faq), and [Bahnschrift's variable design and Windows availability](https://learn.microsoft.com/en-us/typography/font-list/bahnschrift). This introduces a system-font dependency rather than a redistributable font package. Exact visuals on systems resolving a fallback remain unverified; the existing theme already uses system fonts.

The original and selected fonts use grayscale antialiasing, light hinting, automatic subpixel positioning, automatic/viewport oversampling, no MSDF and no font mipmaps. No global import or theme property was changed. Godot exposes these controls on [SystemFont](https://docs.godotengine.org/en/stable/classes/class_systemfont.html); the [4.7 text rendering API](https://docs.godotengine.org/en/4.7/classes/class_textserver.html) supplies the glyph and true glyph-outline calls used here.

## Controlled candidates

Every candidate uses the same V05 PNG, portrait, official ART-002 textures, values, footprint and battlefield positions. Each was GPU-rendered at 1080p and 720p with single/four-stat/two-digit/99/full/mixed scenarios. No candidate changes housing geometry.

| Candidate | Treatment | Native visual assessment |
|---|---|---|
| A | Original Palatino, ivory fill, 4-source dark outline + shadow, 0.80 primary double width | Preserved baseline; serif details compete with textured surfaces. |
| B | Palatino, white, black outline 10, no shadow | Cleaner separation, but retains narrow serif doubles and most secondary material interference. |
| **C** | **Bahnschrift 700, white, black outline 10, no shadow, natural width, secondary ceiling 190** | **Selected: more uniform strokes, clearer 6/8 and separated doubles without a heavy halo.** |
| C14 | C with outline 14 | Little extra native benefit; tightens primary fitting, reduces the small 99 counters and uses more black. |
| N | C without outline | Loses the dark separation over bright metallic/azure detail. Fitting permits slightly larger white silhouettes because no stroke space is required. |
| D | C with font mipmaps enabled | Visibly softer at this scale; most fill pixels become partially covered and the black contour loses opaque coverage. Rejected. |

The different outlines are real controlled renderer settings; safe fitting responds to the stroke's required space. Their primary glyph sizes are therefore not artificially forced identical when that would break the original safe circle. The A/B/C/etc. names are review-only labels and are not exposed as a gameplay choice.

The visual recommendation comes from reviewing the native images separately from the numerical results. No independent human recognition test or final owner acceptance is claimed. C improves perceived clarity without enlarging the token or obscuring more portrait area. In particular, its 6 has a visible internal opening where the baseline primary 6 can lose that enclosed opening at the sampled raster phase; 8 retains two openings. The 1/7 and 3/8 glyphs retain distinct stems, diagonals and counter structure. These are visual observations supported by the per-value probes, not measured recognition times.

## Quantitative raster evidence

[528 per-variant/stat/value/resolution records](measurements.json), [raw production-path probes](probes/), [analysis output](analysis.txt), [GPU results](results.json).

Measured values are `0,1,2,3,6,7,8,10,12,14,99`, all four statistics, both resolutions, six candidates. The probe invokes the actual production fitter and the shared glyph renderer. Fill-only and outline-only probes retain the same font, points, fit padding and placement; they hide a layer through transparent color rather than changing the fit. Full-alpha probes include the real stroke and antialiasing. Secondary-zero probes are hypothetical: real scenes suppress both zero numeral and active material. The invalid historical F03 measurements were not reused.

Bright fill uses alpha≥128 and RGB≥150/150/140, consistent with F03B. Every record includes white bounds, full-alpha bounds, width, outline bounds/distances, alpha-edge coverage, enclosed counter areas, two-digit separation diagnostics, material spill, bronze interference and contrast. The bronze mask uses the disclosed warm-color predicate, not perfect semantic segmentation. Contrast uses actual active-material no-ink GPU backgrounds, straight-alpha compositing and sRGB luminance. A separate edge metric samples the actual white/composited-outline separation. These diagnostics do not constitute accessibility certification.

Representative native 720p measurements:

| White ink XYWH size | Original A | Selected C |
|---|---|---|
| Attack 6 | 8×12 px | 7×12 px |
| Attack 12 | 11×10 px | 11×10 px |
| Attack 99 | 11×10 px | **11×8 px** |
| Armor 12 | 13×10 px | 10×9 px |
| Shield 12 | 13×10 px | 10×9 px |
| Health 12 | 11×10 px | 11×10 px |

The selected single primary glyphs vary between **12 and 14 px**, two-digit primaries between **8 and 10 px**, and positive secondaries between **9 and 10 px** at 720p. **The 14/11-pixel benchmark targets are not met across the tested values.** This task improves shape and separation rather than claiming larger ink. The 99 fitting tradeoff is explicit: retaining natural width inside the existing circle reduces its white height, but both counters remain open at the sampled native phase. It requires owner comparison, not a claim that every digit is objectively superior.

For C `12`, the alpha≥128 outline pixels outside the bright fill have a 95th-percentile nearest-fill distance of **1 px** for all four stats at 720p. Some diagonal/antialiased samples are farther away; the full record retains them. This is a pixel-center raster distance, not an inference from font point size. No outline is stacked on another outline, and no token numeral shadow remains.

For C Armor `12` at 720p, local fill-versus-material contrast is about **2.46 minimum /9.25 median**; its actual white-to-near-outline median is about **11.37**. Shield `12` is about **2.90 /12.66**, with white-to-outline median **16.29**. Metallic highlights still vary the underlying local contrast. A black edge improves separation but does not turn the entire material into a uniform background.

Over the 720p mandatory probes, excluding suppressed secondary zeros, original bright ink has **85 bronze-mask overlaps /140 material-alpha spill pixels**; C has **2 /35**. At 1080p those counts are A **126 /175**, C **24 /20**. No tested C case introduces a new or larger white-ink bronze/material interference count relative to A. Including the stroke, alpha≥128 bronze overlaps decrease from **98 to 61 at 720p**, and **211 to 34 at 1080p**, with no per-case increase. These are aggregate pixel diagnostics over repeated probes, not counts of production defects or unique affected creatures. Residual interference is inherited and reduced, not claimed eliminated.

The optional mipmap case D increases the average fraction of nonzero fill samples below alpha224 from about **0.135 in C to 0.808 at 720p**. This explains its softer edge coverage in these actual captures; partial-alpha fraction alone is not a universal blur metric.

## Implementation and protected contracts

- `resources/themes/creature_token_numerals.tres` centralizes the token-only font, white fill, black outline, shadow policy, width scale and secondary point ceiling.
- `scripts/presentation/numeral_style.gd` defines the typed optional style resource.
- `CardSocketOverlay.draw_number_with_style` contains the existing shared glyph loop. `draw_number` keeps its signature and invokes that loop with no style, preserving the original ART-002 defaults. There is one production numeral-rendering implementation, not a copied token renderer.
- `CreatureToken` supplies its style to that renderer and includes the new stroke allowance in its existing primary fit. It restores the draw transform after each primary numeral. No source coordinate in `CreatureTokenLayout` changed.
- The Windows test harness now verifies foreground ownership before input and can raise/focus only its own verified test window. This follows an observed failed foreground attempt; it prevents unrelated foreground windows from receiving the rest of the test sequence.

V05 source/runtime bytes, outer silhouette, portrait polygon/crop, primary centers, secondary material rectangles, ART-002 textures, global theme, CardView, P005 scene, P006 slots, model/lifecycle APIs and P007 bindings remain protected. No combat engine or card rule changes. Zero defenses retain zero in the model and still draw neither active material nor numeral.

## Verification and Windows status

| Executed check | Actual result | Exit |
|---|---|---:|
| Final headless editor import | PASS | 0 |
| Full native suite | **3691/3691**, assertions unchanged | 0 |
| Six-candidate GPU scenarios/probes/input | **3588 checks, 0 failures** | 0 |
| Native comparison GPU scenes | **3 checks, 0 failures** | 0 |
| Installed default production GPU scenarios/input | **324 checks, 0 failures** | 0 |
| Raster analysis | **528 records** | 0 |
| ART-002 visual regression | **3/3 bit-exact; 0 differing pixels** | 0 |
| Protected source and static-render parity | **222 existing production files unchanged**; 14 empty-board/resolution pairs bit-exact with P006; [manifest](preservation.json) | 0 |
| Standard Windows export | PASS | 0 |
| Real Windows before/after/input acceptance | **BLOCKED by foreground ownership; not a pass** | Baseline attempts 1 |
| `git diff --check` | PASS | 0 |

Logs: [import](import.log), [native](tests.log), [comparison/probes](gpu.log), [comparison scenes](comparison.log), [installed production](production.log), [ART-002](art002.log), [export](export.log), [font inspection](font-inspection.log), [first Windows failure](windows-before-first-attempt.txt), [guarded Windows failure](windows-before.txt), [final result manifest](validation.json).

The native suite retains its pre-existing P007 off-tree anchor warning. No native assertion was changed or weakened. GPU input checks inject SubViewport events and do **not** establish OS pointer verification. All 24 occupied slots pass hover and selection in those GPU checks. No new script error was accepted as a passing result.

The initial baseline Windows attempt did not acquire foreground and failed ESC; its capture did not show MagicOdyssey and was removed from acceptance evidence. A guarded retry refused further input because foreground ownership was still unavailable. Neither attempt is counted as a successful standalone test. The updated selected executable has been built, but its actual desktop pointer/hand/End Turn/ESC verification and normal-desktop-scale sharpness judgment remain pending. Historical F03B Windows results are not substituted for this changed typography.

The original embedded executable was saved byte-identically as `build/windows/MagicOdyssey-P008-F03B-baseline.exe`, SHA-256 `e35819360fd935b43fb811a61c635667627f7873002b4f8f82af13e6befcd112`, matching the F03B validation manifest. The new selected build is `build/windows/MagicOdyssey.exe`. Owner comparison commands, from the repository root:

```powershell
& .\build\windows\MagicOdyssey-P008-F03B-baseline.exe -- --preview-tokens=full_board --preview-size=1280x720
& .\build\windows\MagicOdyssey.exe -- --preview-tokens=full_board --preview-size=1280x720
```

Run one at a time, view at normal desktop scale, and use ESC to close. The GPU comparison images already provide the matched before/after data without requiring a font switch in normal gameplay.

## Reproduction and acceptance boundary

Run `inspect_fonts.gd`, `capture.gd`, `comparison.gd`, `final.gd` through Godot 4.7.2 with the project path and a GPU display server. Then run `python docs/art/reviews/p008-f04/analyze.py`. Render scripts must run sequentially. Run `scripts/tests/run_visual_regression.ps1` without updating goldens. The standard exporter is `scripts/build_windows.ps1`; required desktop input command is `scripts/tests/playtest_windows.ps1 -TokenScenario full_board -BattlefieldSlots -UtilityHud -ReviewDir docs/art/reviews/p008-f04/windows-full`, plus the `single` variant in a separate directory. These real desktop tests require the test window to retain foreground.

Graph project `D-Dev-MagicOdyssey`, generation `2026-11-21T17:24:42Z`: targeted symbol search, both-direction trace and exact shared-renderer snippet were consulted. Coverage metadata reported unavailable/changed metadata for the bounded paths. Direct source reads, HEAD comparisons and runtime checks support the findings; no exhaustive graph claim is made.

Remaining limitations: real Windows verification blocked by desktop focus; owner typography acceptance pending; primary 99 is smaller; some secondary material/bronze interference remains; alternative Windows font fallback and other operating systems are not visually verified. No new artwork, no new production icons, no P009/P010 implementation. **P008-F04 is not fully signed off while Windows verification is outstanding. P008 artistic approval remains pending; G1 NOT_VALIDATED. Stop after P008-F04.**
