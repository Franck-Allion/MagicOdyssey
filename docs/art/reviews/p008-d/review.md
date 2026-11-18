# P008-D — Tactical readability polish

2026-11-18. **TECH PASS / OWNER ART REVIEW. Variant C selected.** Readability improves; comfortable reading of every secondary statistic at native 720p is still not certified. P009/P010 TODO; G1 NOT_VALIDATED. No owner artistic approval is inferred.

## Changes

Production changes are confined to `creature_token.gd`, `creature_token_layout.gd` and the explicit review-fixture helper `creature_token_demo.gd`. Native coverage is appended to `test_creature_token.gd`. The frame source/runtime PNGs, official ART-002 materials, printed card renderer, primary socket centers, secondary housings, portrait clipping, model classes, lifecycle and slot/HUD APIs remain unchanged.

- Attack and **current** Health remain permanently visible, including zero. Maximum Health remains separate in the unchanged model.
- Token-only primary typography uses a 240-point ceiling, 106-source-pixel fitting disk, and 0.80 horizontal scale for multiple digits. Actual cached glyph bounds are fitted with six source pixels of stroke/rounding allowance. Single digits use scale 1.0. No per-value optical offsets, artificial stat ceiling, or card-renderer change.
- Secondary zeros return before drawing either insert or numeral. The neutral V02 cavity remains visible. Positive values retain the official material and 170-point numerals; housing padding limits further safe enlargement. Model values are never rewritten.
- Status strip moves from (410,610) to (410,120). Weapon/Protection diagnostic origins move to (260,140)/(1140,140), clear of the central face and primary/secondary stat band. Three icon slots and `+N` remain supported.
- Added `diagnostic_indicators_enabled`, default **false**. Missing-icon status letters/numbers and equipment W/P fallback letters require explicit opt-in. `CreatureTokenDemo` enables them only for the documented development/review fixtures. Injected status icons continue to render without this flag, and the overflow count remains available. View-model booleans/counts and all existing methods remain intact. Approved equipment/status icon artwork is still required; the flag preserves the diagnostic capability instead of passing letters off as permanent art.

The primary renderer delegates ink, outline, shadow and glyph centering to the existing shared renderer after fitting the token-only transformed bounds. Transform is reset before subsequent materials/indicators. Source font metadata: [font_fit.json](font_fit.json). Examples: single digits fit at 240 source points (16.04 computed physical points at 720p); `10` at 191 and `12/14` at 192 (12.77/12.83 physical points), versus C02's 162/163/162. Computed points are not visible raster height.

## Controlled comparison before selection

All three variants were rendered by real Godot/OpenGL at 1920×1080 and 1280×720. A/B review scripts derive from current HEAD C02 code and the unchanged shared renderer; they remain diagnostic-only. C is the production candidate. No PNG edits, new artwork, screenshot synthesis, retouching or enlargement was used to make the choice.

| Variant | Treatment | Native evidence and tradeoff |
|---|---|---|
| A | C02 baseline, visible secondary zeros, lower status strip | [two digits 720p](A/v02_double_digit_720p.png), [full board](A/v02_full_board_720p.png). Stable baseline; small primary doubles and unnecessary zero noise compete with the portrait/status band. |
| B | Hidden defensive zeros; top status/equipment diagnostics; baseline primary typography | [full board 720p](B/v02_full_board_720p.png), [five statuses](B/v02_status_overflow_720p.png). Cleaner portrait center and inactive plaques, but primary doubles stay 7 px high. Top strip remains diagnostic noise in crowded fixtures. |
| C — retained | B policy plus fitted/condensed primary typography | [two digits 720p](C/v02_double_digit_720p.png), [full board](C/v02_full_board_720p.png), [mixed board](C/v02_mixed_board_720p.png). Primary doubles increase to 9 px ink height; reduced horizontal scale is visible but numerals remain distinct. Secondary values are still small. |

Each folder contains native single, four stats, double digits, zero/positive defenses, five statuses with +2, equipment, full 24, mixed 24, selection, empty, bright/dark diagnostic portrait captures at both sizes. Corresponding 1080p examples: [A](A/v02_full_board_1080p.png), [B](B/v02_full_board_1080p.png), [C](C/v02_full_board_1080p.png). Native A/C double-digit and B/C full-board screenshots were viewed directly before selecting C; the full 1080p candidate was also inspected. Enlarged material diagnostics are supplementary only.

## Actual raster measurements

[All measurements](glyph_measurements.json) come from 108 real GPU glyph probes using the corresponding variant renderer, actual token scaling and first-slot fractional pixel phase. Bright-ink bounds use alpha≥128 and R/G≥150, B≥140. Full nonzero-alpha bounds including outline/shadow/antialiasing are recorded separately. Probes measure representative Attack/Armor positions; the same styles are applied to Health/Shield. Width can vary with raster phase in other columns.

| At native 720p | A/B bright ink | C bright ink |
|---|---|---|
| Primary `1` / `2` | 6×10 / 6×10 px | **7×11 / 7×11 px** |
| Primary `12` / `14` | 9×7 / 10×7 px | **9×9 / 9×9 px** |
| Secondary `1` / `2` | 2×7 / 4×7 px | unchanged |
| Secondary `12` / `14` | 9×7 / 8×7 px | unchanged |

At 1080p C primary `1/2` ink is 16/17 px high and `12/14` 13 px, versus baseline 15 and 11 px respectively. Positive secondary ink remains 11–12 px. Primary two-digit height therefore improves by two physical pixels at both resolutions without touching the cabochon artwork.

In addition to bounds tests, ten source-scale GPU primary glyph/outline masks (`0,1,2,3,6,8,10,12,14,99`) were compared with V02 metal alpha: **zero intersections** of glyph alpha≥16 with frame alpha≥128 at the Attack aperture. [Results](aperture_results.json), [reproducible capture](aperture_check.gd). The Attack opening has a small noncircular intrusion near radius 105; this pixel-level check supplements the nominal 106 fitting disk rather than treating it as proof of an entirely clear circular opening. Health's nearest alpha≥128 material is at radius 110. Source art is untouched.

## Zero state, hierarchy and remaining limits

[Zero defenses](C/v02_zero_armor_shield_720p.png) now leave two empty neutral cavities. [Positive defenses](C/v02_positive_armor_shield_720p.png) show official Armor/Shield materials and numbers. Primary 0 remains visible. Native checks explicitly verify no numeral dispatch at secondary zero and that the model retains zero; GPU material probes verify zero/positive activation. No active Shield material appears at zero.

The native 24-token board is visibly calmer when most secondary values are zero; larger primary doubles improve scanning. No token/frame enlargement, adjacent-slot overlap, HUD collision or hand obstruction was observed. All 24 full/mixed slots remain clickable at both sizes. P005 composition is preserved exactly when the board is empty.

**Remaining limitation:** positive defenses still have only 7 px of bright numeral height at 720p; a secondary `1` is only two bright pixels wide. Compression also changes the proportions of primary doubles. These tradeoffs require owner review; comfortable four-stat reading is not claimed merely because bounds pass.

Status/equipment diagnostic glyphs remain too small and too generic to be production indicators. Moving them upward preserves the creature face and the stat band, but cannot make a 9×8-pixel diagnostic cell expressive. The top fixture strip may still appear crowded, especially with W/P plus five statuses. It is explicitly development-only via the new opt-in. Approved status icons and equipment artwork are needed; no new symbols or gameplay priority/expiration rules were invented. The real `+N` counter and injected-icon path remain functional.

## Validation and preserved behavior

Godot 4.7.2 stable ed1daf0bf; Windows; OpenGL Compatibility; NVIDIA GTX 1660 Ti / driver 551.86.

| Check | Actual result | Exit |
|---|---|---:|
| Headless import | PASS | 0 |
| Full native tests, including existing P005–P008 suites | **3681 passed / 0 failed**; 3662 previous retained +19 | 0 |
| Variant A GPU | 717 checks, 0 failures | 0 |
| Variant B GPU | 717 checks, 0 failures | 0 |
| Variant C GPU | 717 checks, 0 failures | 0 |
| Source-scale glyph/metal checks | Ten masks, zero intersections | 0 |
| ART-002 regression | **3/3 bit-exact**, zero differing pixels | 0 |
| Empty-board parity | Zero pixels differ from P006 at both sizes for A/B/C | 0 |
| Normal release Windows export | Embedded executable built | 0 |
| Isolated full-board Windows harness | Default + exact 1080p + exact 720p; all interactions PASS | 0 |
| `git diff --check` | PASS | 0 |

The existing P007 off-tree anchor warning persists in native tests; no new script errors. No assertion was weakened. Model snapshot, current/max Health, dynamic updates, statuses/+N, equipment state, lifecycle and P007 binding remain covered by the original suites. Added checks cover development opt-in, hidden zero/model preservation, safe transformed glyph bounds and two-digit fit.

[Native log](tests.log), [A GPU](A/gpu.log), [B GPU](B/gpu.log), [C GPU](C/gpu.log), [ART-002](art002.log), [Windows log](standalone.log), [export](export.log), [results](results.json), [protected-file/empty parity manifest](preservation.json). The V02 source/runtime bytes still match C01 SHA-256 `c5b09a920793d6fef70181e300595efe1702dd3bd98b9a5f9d1e58dbb1f10aba`. Shared card overlays, ART-002 textures, HUD models, CombatScreen, slot component and portrait APIs match HEAD. Graph discovery had no usable GDScript symbols and final coverage metadata was unavailable/truncated; bounded direct source reads/diffs and actual tests were used instead.

## Real Windows input

The embedded EXE was copied alone into a new isolated directory. Three full-board launches passed at default 1888×956, exact 1920×1080 and exact 1280×720. Every run used actual OS pointer moves/clicks over all 24 slot identities, selection switching/toggle, hand hover, raised-card click isolation, End Turn mouse/focus/Space interaction, and ESC exit **0**. No remaining game process or game-log error/warning. These are presentation events, not CombatEngine turn advancement. GPU capture-script pointer tests are injected and are not substituted for this OS evidence.

Inspected [Windows selected 720p](windows-full/desktop-1280x720-selected-player-attack.png) and [Windows selected 1080p](windows-full/desktop-1920x1080-selected-player-attack.png). The latter retains Windows titlebar tooltips at the upper right; these are OS capture artifacts, not game UI, and were not retouched. Executable: `D:\Dev\MagicOdyssey\build\windows\MagicOdyssey.exe`. To inspect the fixture:

```powershell
& .\build\windows\MagicOdyssey.exe -- --preview-tokens=full_board --preview-size=1280x720
```

## Owner decision and stop

Recommend C for owner review as a measured tactical improvement over C02. Approve the zero-suppression policy, condensed primary proportions and upper indicator placement only after reviewing native captures. Positive-secondary readability and approved icon content remain open artistic decisions. **No artistic acceptance granted.** P009/P010 TODO; G1 NOT_VALIDATED. Stop after P008-D.
