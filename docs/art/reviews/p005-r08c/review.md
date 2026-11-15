# P005-R08C - Utility HUD Layout & Typography Polish

2026-11-15. Godot 4.7.2 stable, Windows, OpenGL Compatibility, NVIDIA GeForce GTX 1660 Ti.

## 1. Executive summary

**TECH PASS / ART REVIEW. Recommendation: APPROVE, subject to owner visual acceptance.** Recent Actions now has a centered semibold heading and quieter body; paired player miniatures have measured clearances from the panel metal; End Turn is a separate, smaller tactile object; the piles and button move upward to balance the tall panel. No approved PNG, utility backplate crop, shared component implementation, opponent pile layout or gameplay behavior changes.

The selected layout retains **87.5% of the deck scale and 83.6% of the face-up graveyard scale**, with a useful **112 px card height / 74.7 physical px at 720p**. This tradeoff is explicit. ART-003-T06B is not required for this proposed composition. Preserving the original miniature sizes with the same margins would require a separate wider source asset; that alternative is quantified below and has not been started.

Stop after R08C. P005 is not globally complete. No R09, art generation, PNG modification or domain binding.

## 2. Baseline problems and method

Baseline: `c6385ada8d7df4477f8772772354d5f907855d0f`. The owner's assessment supersedes the earlier agent recommendation: **R08B TECH PASS / ART KEEP_WITH_ADJUSTMENTS**. Its 2452 assertions and successful Windows export did not constitute artistic acceptance.

The live baseline was captured **before production edits** using `capture_p005_r08c.gd -- --baseline`, with both resolutions, source font/layout and animation frozen for deterministic comparison. Baseline problems observed: title smaller/lighter than body, miniatures squeezed toward bronze walls, button ornaments crossing the side metal, and an oversized quiet interval above the piles. Original R08B images and the fresh baseline were inspected.

## 3. Typography

- Heading: **16 -> 19 reference px**, Segoe UI family **weight 600**, warm ivory `text_bright`; centered in local x=40..232, y=64..96. The painted interior center is x=135.65; heading center x=136 differs by only 0.35 px.
- Body: **17 -> 16 px**, existing Segoe UI body font, muted `secondary`, left-aligned within x=44..228, y=112..256. Line spacing is 3 px.
- Up to three supplied entries remain presentation-only. A five-line visible budget with word ellipsis and clipping contains unsupported excessively long input without shrinking the type or spilling into the pile section. All requested valid fixtures fit in full: empty, one short action, three actions and one long action.
- Captions remain 15 px and counts 25 px. End Turn remains dynamic 21 px text with native input states.

[Typography stress sheet](recent_actions_typography.png): left to right empty, one action, three actions, long valid action. [720p sheet](recent_actions_typography_720p.png). Fixture text is supplied only by the capture script, without event subscription or engine mutation.

## 4. Before/after geometry

All positions below are local to the unchanged **272x684 ActionBarZone at screen (1624,372)**.

| Element | R08B | R08C |
|---|---|---|
| Utility backplate | (20,0), 232x684 | unchanged |
| RecentTitle | (40,64), 192x28, 16 px, left | (40,64), 192x32, 19 px semibold, center |
| RecentActions | (40,102), 192x128, 17 px | (44,112), 184x144, 16 px |
| Player DeckStackView | (30,296), 104x200 | (35,258), 104x178 |
| Player GraveyardView | (138,296), 104x200 | (133,258), 104x178 |
| Deck card height | 128 px | 112 px |
| Graveyard card height | 134 px | 112 px |
| EndTurnButton | (20,558), 232x58 | (40.38,520), 190x47.45455 |
| Opponent deck/graveyard | (30,0)/(138,0), 104x166 | unchanged |

The player Control envelopes overlap horizontally by 6 px, but their actual painted cards, caption ink and counts are separate. These noninteractive component envelopes are not treated as artwork boundaries. Card scale is uniform and remains 3:4. The source backplate keeps its original aspect and AtlasTexture crop `(64,12,664,1964)`.

## 5. Painted-bound measurements

[analysis.json](analysis.json) records all numeric results and unchanged source hashes; [analyze.py](analyze.py) reproduces them without rewriting images. Source alpha >8/255 defines painted silhouettes. Panel metal uses a conservative diagnostic `alpha>128, R>1.12G, G>1.12B`, sampled through the relevant vertical bands. This is a measured bronze-color proxy, not an artist-authored material mask or artistic approval.

The panel is uniformly scaled by 684/1964. Painted width is **225.33 px**; inner metal lips at local **33.96..237.35** leave only **203.39 px** of usable width. Counts/captions are additionally inspected in actual GPU images.

| Conservative painted clearance | R08B | Option A | Selected Option B |
|---|---:|---:|---:|
| Deck to left inner metal lip | 1.02 px | 3.02 px | **11.52 px** |
| Face-up graveyard to right lip | -0.41 px | 1.59 px | **12.43 px** |
| Deck to face-up graveyard | 12.86 px | 8.86 px | **16.26 px** |
| Button to left inner lip | -11.52 px | 8.42 px | **8.42 px** |
| Button to right inner lip | -12.88 px | 8.42 px | **8.42 px** |

Negative values identify crossing of the conservative bronze-lip projection, rather than claiming every silhouette pixel intersects metal. Final cards have approximately **7.68 / 8.29 physical px side clearance and 10.84 px inter-card space at 720p**. The transparent empty placeholder has still more clearance. Tests use the nonempty face-up frame as the wider graveyard case.

## 6. A/B/C layout exploration

**Option A: preserve miniature size and move the views.** Player envelopes x=32/136, y=258, 104x200. Original 128/134 px miniature heights remain. Actual card-to-wall clearances stay only 3.02/1.59 px, with 8.86 px between cards. This is still crowded and is rejected. [1080p GPU study](option_A_1080p.png), [720p](option_A_720p.png).

**Option B: modest player-only size/spacing adjustment within the existing envelope.** Views x=35/133, y=258, 104x178 produce equal 112 px cards. This retains recognizability while giving the measured margins above; caption/count sizes stay unchanged. Selected after examining the real GPU studies and default/face-up states at both scales. [1080p GPU study](option_B_1080p.png), [720p](option_B_720p.png). Study fixtures have deck/graveyard count 100 and a face-up Arcane Knight. They are explicit preview states of the actual production scene, not reconstructed screenshots.

**Option C: retain full-size miniatures by widening the artistic backplate.** For the baseline painted deck width 94.04 px and face-up graveyard width 95.87 px, a 16 px inter-card gap plus 12 px side margins requires **229.92 px inner width / approximately 251.86 px painted width**. This is **+26.53 px / +11.8% painted width**. The 272 px column could hold that art, but the existing PNG cannot fill it at the current height while preserving its ratio: uniform enlargement would require approximately **764.53 px height**, exceeding the 684 px envelope by 80.53 px. Merely increasing the TextureRect width does not widen the image under KEEP_ASPECT_CENTERED. Stretching or clipping the crest is rejected.

## 7. Button silhouette and input

The initially suggested 205-215 px range was evaluated against the **203.39 px interior**, rather than assumed safe. At 210 px the button's approximately 206.18 px painted silhouette still crosses the inner lips. The final **190 px** canvas yields a **186.55 px** silhouette and equal **8.42 px** side gaps. This falls below the suggested range because the actual painted panel demands it; text remains 21 px.

The button keeps the source ratio **2090:522**, with source alpha bounds `(22,13)..(2074,507)`. Its painted center is **x=135.653**, aligned to the measured panel interior center **x=135.652**. The 0.38 px node offset comes from source padding and the panel's actual inner lips, not an arbitrary visual nudge. Text center differs by about 0.27 px, below one display pixel. Painted vertical bounds are **y=521.18..566.09**, leaving 117.91 px to the bottom envelope. Its ornaments no longer merge with the side metal.

[Button closeup](end_turn_closeup.png), [four states](end_turn_states.png), [720p states](end_turn_states_720p.png), [keyboard focus](end_turn_focus_720p.png). State rows are normal, hover, pressed, disabled. PremiumEndTurnButton implementation, shader and state timings are unchanged. Native mouse/Space activation, focus and disabled rejection are tested. No turn advances.

## 8. Vertical distribution

Piles move up 38 px; reducing their height 22 px moves the counter baseline up 60 px. The button moves up 38 px and is reduced proportionally, increasing the lower quiet margin and freeing it from the frame. The heading keeps its relationship to the crest; body starts 16 px below the heading rectangle. The maximum log rectangle stops at y=256, before piles begin at y=258; requested valid fixture ink finishes earlier. Counter envelope ends at y=436, leaving approximately **85.18 px to the button silhouette**. These spaces accommodate populated logs while the empty state remains quiet.

No box, separator, ornamental title bar, gemstone, duplicated border, extra texture or opaque overlay was added to fill space. The single approved tall backplate remains the compositional anchor.

## 9. Actual 1080p evidence

- [Fresh baseline utility](utility_before_1080p.png).
- [Refined utility](utility_after_1080p.png).
- [Matched-scale comparison](before_after_1080p.png), baseline left / refined right.
- [Production CombatScreen](combat_screen_1080p.png).
- [Deck/graveyard closeup, 100/100 face-up fixture](deck_graveyard_closeup.png).

## 10. Actual 720p evidence and visual assessment

- [Refined utility](utility_after_720p.png).
- [Matched-scale comparison](before_after_720p.png), baseline left / refined right.
- [Production CombatScreen](combat_screen_720p.png).
- [100/100 stress screen](stress_counts_720p.png).
- [Empty graveyard](graveyard_720p_0.png), [one](graveyard_720p_1.png), [several](graveyard_720p_12.png), [100](graveyard_720p_100.png).

Inspected actual full-screen GPU output, both matched comparisons, heading/body stress sheets, pile/face-up closeups and button states. The heading is now clearly separate from the body. Both painted cards and labels have visible space around them; counts remain aligned and readable. The miniature illustration, official back and empty skull/rune remain recognizable at 720p, with necessarily limited fine detail. The button is a separate object inside the panel. Battlefield and hand remain dominant. All production images are real Godot GPU captures; closeups and sheets only copy actual GPU pixels at their original physical scale. No offline mock screenshot, artwork regeneration or screenshot retouching.

GPU and independent Python comparisons prove **zero changed pixels** at both resolutions outside ActionBarZone: both hero HUDs, battlefield, player/opponent hands, opponent piles, MatchStatus and surrounding background are bit-exact. All three shared component implementations and approved source/import files are byte-for-byte unchanged in Git.

## 11. Tests and commands

Commands run from `D:/Dev/MagicOdyssey`; `$GodotExe = D:/Temp/Godot_v4.7.2-stable_win64_console.exe`.

| Command | Actual result | Exit |
|---|---|---:|
| `& $GodotExe --path . --script res://scripts/tests/capture_p005_r08c.gd -- --baseline` | Real before-edit GPU capture at both sizes | 0 |
| `& $GodotExe --path . --script res://scripts/tests/capture_p005_r08c.gd -- --study` | Real controlled A/B studies at both sizes | 0 |
| `& $GodotExe --headless --path . --editor --import --quit` | Clean headless import | 0 |
| `& $GodotExe --headless --path . --script res://scripts/tests/test_runner.gd` | **2476/2476 PASS, 0 failed** | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/run_visual_regression.ps1` | ART-002 **3/3 bit-exact**, no golden changes | 0 |
| `& $GodotExe --path . --script res://scripts/tests/capture_p005_r08c.gd` | 1080p/720p, outside-region parity, typography/count/graveyard stress and real native button input PASS | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build_windows.ps1` | Embedded Windows EXE rebuilt | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/playtest_windows.ps1 -ReviewDir docs/art/reviews/p005-r08c -HandCount 10 -AnimateResources -UtilityHud -UtilityButtonY 915.73` | Isolated desktop in three modes, native mouse/focus/Space, hover/animation/ESC PASS | 0 |
| `python docs/art/reviews/p005-r08c/analyze.py --desktop` | Source hashes, painted-bound margins, GPU parity and desktop motion/input evidence PASS | 0 |
| `git diff --check` and `git diff --cached --check` | Clean whitespace | 0 |

The **2452 baseline assertions are retained**, plus 24 new assertions for heading font/color/alignment, body line budget, player-only size changes, useful card scale, opponent geometry, button aspect and spacing. Existing CombatScreen, DeckStackView thresholds/texture identity, GraveyardView transitions/last-entering snapshot, noncreature presentation, hidden-information and player hover regressions still pass. The GPU script verifies native hover/down/up/Space/disabled input, focus, fit of actual wrapped text and unchanged TURN 01. Clean logs accompany the review. No tests were weakened.

## 12. Windows standalone verification

Rebuilt **`D:/Dev/MagicOdyssey/build/windows/MagicOdyssey.exe`** with embedded PCK. The existing workflow copies only that executable to a new temporary directory and launches it through Windows shell independently of repository/editor resources. The scene readiness marker follows actual rendering.

| Mode | Actual client | Native input | ESC exit |
|---|---:|---|---:|
| Default window | 1888x956 | hover/pressed/focus/mouse/Space PASS | 0 |
| 1080p | 1920x1080 | hover/pressed/focus/mouse/Space PASS | 0 |
| 720p | 1280x720 | hover/pressed/focus/mouse/Space PASS | 0 |

Each mode records exactly one mouse activation and one Space activation; focus is reported by native `focus_entered`. The explicit `--preview-utility` diagnostic adds logging only. Pointer tests still exercise left/center/right player cards, scrubbing and return to rest. Eight timed desktop frames per mode prove motion within all four individual reservoirs; analysis.json records pixel-change counts. Opponent cards remain hidden. All three processes exit cleanly with real ESC, code 0, with no remaining game process and no Godot errors/warnings.

[720p standalone](desktop-1280x720.png), [720p button with focus](desktop-1280x720-button-released.png), [1080p standalone](desktop-1920x1080.png), [1080p card hover](desktop-1920x1080-hover-center.png). Windows Reduce/Close tooltips appear in some 1080p desktop images; clean GPU screenshots separately show the opponent area. These desktop artifacts are not retouched.

## 13. Remaining limits and changed files

Production changes: **combat_screen.tscn and combat_screen.gd**, limited to the utility node geometry/type/color. The preview entry adds one diagnostic focus signal only. Validation changes: existing utility tests, new capture script/UID, read-only analysis, optional button-Y desktop parameter and native focus/Space checks. Documentation: this review, evidence and progress tracker. No changes to DeckStackView, GraveyardView, PremiumEndTurnButton, their thresholds/APIs/shaders, hands, heroes, tactical geometry, domain or card mechanics. No approved art/import bytes changed.

The selected miniatures are moderately smaller; exact original scale and full miniature rules readability are not claimed. This is still preview data, not real combat/event history. Inputs longer than the five-line log budget are bounded with ellipsis; no scrolling was added. Other renderers/platforms, clean-PC/VM deployment, alternate DPI setups and performance benchmarks are **NOT_VERIFIED**. Automated checks do not grant owner artistic acceptance.

## 14. ART-003-T06B decision and optional art brief

**Not required for selected Option B.** It meets the measured spacing targets with useful 112 px cards, unchanged panel aspect and zero artwork overlap. Final acceptance of the scale tradeoff remains with the owner.

If the owner requires the full R08B 128/134 px miniature sizes with these margins, then **ART-003-T06B REQUIRED - Utility Backplate Width Refinement**: current column 272 px, current painted panel 225.33 px, current inner width 203.39 px; minimum needed approximately **252 px painted / 230 px interior**, preferably **255-260 px painted**, or about **+27 to +35 px (+12-15%)**. Reserve at least 12 reference px between cards and inner metal and at least 16 px between card silhouettes. Keep height 684, transparent exterior and full crest/foot silhouette.

Optional future art-generation prompt (report only; **not executed**):

> Produce a standalone text-free RGBA utility HUD backplate for MagicOdyssey, matching the approved T06 antique-bronze and midnight-blue material identity. Refine width only: at 684 reference pixels of painted height, target 255-260 pixels painted width and at least 230 pixels of straight dark interior. Preserve restrained metal thickness, top crest, lower foot, transparent outer canvas, near-opaque dark interior and quiet visual weight. No compartments, gems, separators, baked labels, counts, button or card art. Do not stretch the existing approved PNG. Deliver a new version for separate owner review under the ART-003-T06B process; retain v01 unchanged.

No new asset or ART-003-T06B task was started.

## 15. Recommendation

**APPROVE for owner visual review. TECH PASS / ART REVIEW.** All requested independent polish and regression checks are complete. P005 remains incomplete; stop after **P005-R08C**. Do not proceed to ART-003-T06B or P005-R09 automatically.
