# P005-R04 ? Player HUD and adaptive ten-card presentation

Date: 2026-11-15. Godot 4.7.2 stable; Windows; OpenGL Compatibility; NVIDIA GeForce GTX 1660 Ti.

**Recommendation: KEEP_WITH_ADJUSTMENTS. Owner artistic approval pending. Stop after R04; P006 remains untouched.**

## Result and scope

The owner's criticisms were an undersized, compressed hand, gaseous resource effects, and an oversized hero portrait. This revision changes the player presentation within the existing R03 composition. It supports display counts 0?10 without implementing draw, overflow, card playing, dragging, commands, or the future P009 interactive HandView.

Pre-existing uncommitted R03 edits and its review/capture files were retained. The four tactical rows, all 24 slot reservations, six-column alignment, battlefield hierarchy, accessors, opponent back layout, right utility column, turn banner, deck/graveyard and End Turn placement were preserved. The shared liquid shader improves the four existing orb instances without changing their API or opponent HUD geometry. No card artwork, ART-002 components, normative specifications or domain scripts were changed.

## Hand geometry and size comparison

All samples use the production master v03 at native 1086?1448 geometry, CardViewLayout, CardContentOverlay, CardStatOverlay for creatures, CardCategoryOverlay for noncreatures, and the existing five rarity materials. Creature, spell and equipment names/values are presentation samples; they are not official catalog definitions. Existing knight art is reused across the fixtures; no new licensed or third-party imagery is introduced.

[270 px](candidate_270.png), [300 px](candidate_300.png), [330 px](candidate_330.png) are full 1920?1080 GPU captures with the same ten cards. The [comparison sheet](hand_card_size_comparison.png) shows identical bottom 360-pixel crops in order **270, 300, 330**, top to bottom.

**Selected height: 270 px**, width 202.5 px. This is 22.7% taller than the 220 px R02 starting point in the brief and 9.8% taller than the 246 px uncommitted R03 fixture found on disk. At 720p, proportional scaling gives 180?135 px cards. The 300/330 candidates fit horizontally but intrude into the last tactical reservation row. Retaining the battlefield geometry favors 270; those larger candidates are comparison evidence, not accepted idle layouts.

`CombatPreviewCards.layout_pose` accepts count, available width, preferred height, maximum angle, vertical curvature compression and minimum overlap. For count n, half-count h=(n?1)/2:

- Maximum angle A=min(9 degrees, 1.6 degrees ? (n?1)).
- Center step=min(height ? 0.64, (width?height ? 0.95?24)/max(1,n?1)).
- Circular radius R=step ? max(h,1)/max(sin(A),0.001).
- Per-card angle a=(index?h)/max(h,1) ? A.
- Horizontal center=width/2+R sin(a); vertical drop=0.2 R (1?cos(a)).
- Common center height reserves the outer rotated corners, with bottom bound at local y=270 (reference screen y=1074).
- Native half-size pivot, uniform scale, signed angle and mirrored depth layers preserve symmetry. Layer depth=min(index,n?1?index), with stable sibling order breaking equal-depth ties.

The arc is intentionally vertically compressed to preserve the tactical row. The idle mathematical envelope stays in reference x=320?1600, y=774?1075; no card corner clips at either supported resolution. At ten cards, centers are roughly 113 px apart, preserving a substantial exposed strip rather than shrinking the faces. At one card, the card is exactly centered and unrotated. Two/three cards spread gently; middle counts grow smoothly; eight through ten progressively overlap at unchanged scale.

Native tests cover every count 0?10, actual generated child count, finite poses, mirrored positions/angles, ordering, aspect ratio, useful overlap, central symmetry, monotonic envelope growth, vertical continuity, supported-resolution containment, and raised-card geometry. GPU screenshots cover 1/3/5/7/10 at both resolutions.

| Count | 1080p | 720p |
|---|---|---|
| 1 | [Capture](hand_1_card.png) | [Capture](hand_1_card_720p.png) |
| 3 | [Capture](hand_3_cards.png) | [Capture](hand_3_cards_720p.png) |
| 5 | [Capture](hand_5_cards.png) | [Capture](hand_5_cards_720p.png) |
| 7 | [Capture](hand_7_cards.png) | [Capture](hand_7_cards_720p.png) |
| 10 | [Capture](hand_10_cards.png) | [Capture](hand_10_cards_720p.png) |

## Inspection contract

`set_inspected_card(index, blend)` interpolates from the resting pose to an upright 420 px card, lifts it, clamps its horizontal center and gives it z=100. Other cards retain their resting transforms. Blend is supplied by the presentation caller; this component adds no interaction or Tweens. Index ?1 restores the fan.

The GPU demonstration advances through eight blend steps for the leftmost, central and rightmost ten-card samples, then checks all raised corners. [Left](hand_hover_0.png), [center](hand_hover_4.png), [right](hand_hover_9.png), [inspection preview](hand_hover_preview.png). The parent does not clip children. Inspection temporarily overlays the lower battlefield, as expected for a presentation inspection preview; the idle hand does not obscure slot contents. P009 must still provide actual pointer picking, hover timing and input ownership.

## Ten-card owner requirement and normative discrepancy

The owner now requires a ten-card maximum. **Only display capacity is consolidated here. Gameplay remains governed by the existing seven-card normative cap.** No overflow or draw behavior is implemented.

A later explicit gameplay consolidation must amend:

- `specs/01-lot1-vertical-slice/01-scope.md`, ?3.6, lines 133?134: seven-card maximum and discard beyond seven. ?3.4 line 105 specifies the independent six-card initial deal, which should remain six unless separately changed.
- `specs/02-combat-rules/07-cards-and-zones.md`, ?1 item 6, lines 27?30: Q39 seven-card capacity, Q38 overflow, Q40 newest-first reduction semantics.
- `specs/06-reference/02-decisions.md`, Q39 line 76: validated seven-card maximum; review Q38/Q40 alongside it without changing their generic semantics accidentally.
- `specs/01-lot1-vertical-slice/03-acceptance-tests.md`, L1-B27 line 39: replace seven-full/eighth-discard with ten-full/eleventh-discard. L1-B26 fatigue remains unchanged.
- `specs/01-lot1-vertical-slice/05-roadmap.md`, P024 line 97 and `docs/progress/lot1-progress.md`, P024: update the future hand-cap contract, after formal consolidation.

Future P024 must test a draw from 9 to 10, overflow at 10 with the eleventh card discarded using OVERFLOW_DISCARD, sequential multi-draw crossing the cap, and newest-first discarding if maximum capacity is reduced (Q40). Keep the six-card initial deal and progressive fatigue tests independent. No existing P024 implementation/test file was changed in R04.

## Liquid rendering and motion

The existing independently written Godot shader now uses a single coherent interface with a small secondary ripple, wall meniscus curvature, a thin highlight and denser pigment/depth shading. Broad interior sinusoidal lighting was removed; seven prominent bubbles became two tiny low-contrast bubbles. Static glass reflections are restrained and remain independent of surface motion. Health is deep ruby, Mana sapphire. The housing remains procedural bronze.

Exact values update immediately and stay authoritative. Fill retains the existing 0.28-second smoothstep. A bounded signed surface impulse is computed from the current visible fill and new destination. The visual slope follows `strength ? sin(14t) ? exp(?4.5t)` and stops after two seconds. Rapid updates replace the current target/response, identical targets do not restart it, refill is smooth, and no Tween or CPU texture generation is introduced. Immediate updates and animation-disabled mode clear residual surface tilt and snap to the exact target. Each orb keeps its independent mutable material and the original public API.

[100/60/25/0 percent gallery](liquid_orbs_states.png), [48-frame transition sheet](liquid_orbs_motion_frames.png), [animation GIF](liquid_orbs_animation.gif), [transition ratios](animation_samples.csv). Actual GPU images at fixed fill differ over time; animation-disabled images are bit-identical. Full/empty and outside-housing GPU probes pass.

A separate [settling strip](liquid_settling.png) and [measured samples](settling_samples.csv) capture the level reaching 60% followed by decaying signed surface motion. Six real GPU observations verify residual tilt below 0.0002 at the end. CSV times use the monotonic test clock; production gameplay never uses this clock. Raw 48-frame PNGs are saved under `%TEMP%/magicodyssey-p005-r04-frames`; GIF encoding only assembles these genuine frames. Standalone desktop motion captures also document running resource updates.

The Unity reference was not revisited: its previously documented analysis in the required R01 review was sufficient. No Unity files, textures or shader code were copied or modified; usage rights remain unconfirmed.

## Hero composition and visual inspection

Portrait: 160?160 at reference resolution, with an AtlasTexture crop `(260,40,500,500)` of the unchanged knight illustration, emphasizing head and shoulders without distortion. Player orbs: 190 px diameter. The hero panel ends at y=920 instead of extending to y=1056, eliminating its empty tail. [Player HUD closeup](player_hud_closeup.png).

The real [1080p GPU capture](combat_screen_1080p.png), [720p GPU capture](combat_screen_720p.png), size comparison, ten-card 720p capture, raised-card preview and motion sheet were visually opened and inspected. Desktop captures at both supported sizes were also inspected. Resources remain identifiable and the portrait is secondary. Ten-card titles/rules intentionally overlap: the inspection pose is needed to read a complete card. Rule text remains small at 720p; costs on the right half can be covered by inward layering. This is a visible limitation for owner review, not a claim that all rules are simultaneously readable.

## Validation and executable

Commands ran from `D:/Dev/MagicOdyssey`; `$GodotExe` is `D:/Temp/Godot_v4.7.2-stable_win64_console.exe`.

| Actual command | Result | Exit |
|---|---|---:|
| `& $GodotExe --headless --path . --editor --import` | Import/class registration clean; [log](import.txt) | 0 |
| `& $GodotExe --headless --path . --script res://scripts/tests/test_runner.gd` | **1223 passed, 0 failed**, includes CombatScreen and all original LiquidResourceOrb tests; [log](tests.txt) | 0 |
| `& $GodotExe --path . --script res://scripts/tests/capture_p005_r04.gd` | Target-resolution GPU images, corner bounds, inspection, timed loss/refill/settling, rapid updates, frozen rendering and reservoir probes PASS; [log](gpu.txt) | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/run_visual_regression.ps1` | ART-002 **3/3 bit-exact**, zero differing pixels; [log](art002.txt) | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build_windows.ps1` | Standalone embedded executable regenerated; [log](export.txt) | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/playtest_windows.ps1 -ReviewDir docs/art/reviews/p005-r04/standalone7 -HandCount 7 -AnimateResources` | Three isolated EXE launches; native 1080p/720p client sizes; ESC 0; no remaining game process; [log](desktop7.txt) | 0 |
| Same desktop command with `standalone10 -HandCount 10 -AnimateResources` | Three isolated EXE launches, ten real faces, both exact sizes, ESC 0; [log](desktop10.txt) | 0 |
| `git diff --check` | No whitespace errors | 0 |

The desktop helper copies only the embedded EXE to a new temporary directory and launches it via the Windows shell, outside the project/editor. Actual desktop client captures and eight timed motion captures per window are under [seven-card evidence](standalone7/) and [ten-card evidence](standalone10/). Both normal window startup (1888?956 on this desktop) and explicit 1920?1080 / 1280?720 were exercised. The export preset and build workflow are unchanged.

Double-click **`D:/Dev/MagicOdyssey/build/windows/MagicOdyssey.exe`** to launch directly into CombatScreen; ESC quits. For ten cards with resource animation:

```powershell
& .\build\windows\MagicOdyssey.exe -- --preview-size=1920x1080 --preview-hand=10 --preview-animate
```

The hand-count and animation flags are isolated presentation-review fixtures, not combat bindings.

The graph project `D-Dev-MagicOdyssey` was checked at generation `2026-11-15T09:01:47Z`. Targeted symbol search returned no relevant GDScript functions; coverage reported changed metadata/untracked scene/shader metadata. Direct source reads were used as the verification evidence; no exhaustive graph claim is made. One repeated desktop ESC check failed while another Godot GPU capture window was concurrently running; the test helper cleaned up that process. Final desktop verification was rerun without a competing GPU window. Initial native validation caught two obsolete R03 expectations (portrait larger than orbs and hero-panel bottom alignment); these were replaced with the new R04 composition requirements, retaining the right-column alignment and other assertions.

## Changed files and remaining review

- `scripts/presentation/combat_preview_cards.gd`: adaptive layout, real varied faces and inspection contract.
- `scenes/combat/combat_screen.tscn`: compact player portrait crop, orbs and panel.
- `resources/shaders/liquid_resource_orb.gdshader`, `scripts/presentation/liquid_resource_orb.gd`: dense liquid and damped visual slope.
- `scripts/presentation/combat_preview.gd`: standalone review flags.
- `scripts/tests/test_combat_screen.gd`, `capture_p005_r04.gd` and UID, `playtest_windows.ps1`: geometry, GPU and desktop verification.
- `docs/progress/lot1-progress.md` and this review directory: evidence and progress.

**KEEP_WITH_ADJUSTMENTS:** retain the adaptive display and denser liquid, then obtain owner review of the conservative fan curvature, 720p readability and portrait/resource balance. The constrained 270 px size and shallow arc preserve the tactical board; a more dramatic premium fan would require an explicitly authorized layout tradeoff. Bespoke orb housing, more varied approved illustrations and future P009 inspection/input remain outstanding. No automatic AAA artistic approval is granted.

NOT_RUN: clean target VM, another GPU/backend, other DPI settings, low-end performance benchmark, live gameplay bindings, and a board filled with 24 production tokens (P006/P008 are not implemented). Geometry assertions preserve the existing tactical reservations; they do not substitute for that future crowded-board review.

Recommended next task: owner artistic review of R04, followed by a narrowly scoped correction if requested. Do not advance automatically to P006 or consolidate the gameplay hand cap here.
