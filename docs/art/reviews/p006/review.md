# P006 — Interactive tactical battlefield slots

Date: 2026-11-17. Platform: Windows, Godot 4.7.2 stable ed1daf0bf, OpenGL Compatibility, NVIDIA GeForce GTX 1660 Ti / driver 551.86.

## 1. Executive summary

**TECH PASS / ART REVIEW. Recommendation: APPROVE for owner review.**

All 24 approved slot guides now expose typed identities, hover/click signals, persistent single selection, passive highlighting and interaction control. This is presentation only. No combat commands, legal-action calculations, summoning, movement, attacks, resource costs or turn changes were introduced.

The prerequisite is closed: [P005-R09C owner sign-off addendum](../p005-r09c/review.md#19-owner-sign-off-addendum-p005-close) documents the owner's explicit approval on 2026-11-16. P005 remains `TECH PASS / ART OWNER-APPROVED`; P005-R09 remains `OWNER-APPROVED / COMPLETE`. Existing local edits to the P005 review and roadmap were preserved.

2996 native assertions pass (2507 previous assertions retained, 489 added). 256 GPU checks pass. ART-002 passes 3/3 with zero differing pixels. Both P006 idle images match the approved P005 GPU references exactly. The isolated Windows executable passed actual OS pointer tests in all 24 slots at default, 1080p and 720p, plus hand, utility and ESC checks. P006 artistic acceptance remains pending the owner. P007–P010 remain TODO; G1 remains NOT_VALIDATED.

## 2. Files changed

| File | Purpose |
|---|---|
| `scripts/presentation/battlefield_slot.gd` (+ Godot UID) | Reusable Panel component, identity, input, visual feedback, token anchor |
| `scenes/combat/combat_screen.tscn` | Attach component and coordinates to the original 24 guides; no geometry/style edits |
| `scripts/presentation/combat_screen.gd` | Single validated slot registry, typed API and signal relay, single selection |
| `scripts/presentation/combat_preview_cards.gd` | Match GUI hit testing to the existing card picker, including the raised inspection footprint |
| `scripts/presentation/combat_preview.gd` | Explicit `--preview-slots` telemetry fixture; existing quit policy retained |
| `scripts/tests/test_battlefield_slots.gd` (+ Godot UID) | 489 additional native assertions |
| `scripts/tests/test_runner.gd` | Register the new suite without changing existing suites |
| `scripts/tests/playtest_windows.ps1` | Optional `-BattlefieldSlots` OS pointer checks; activate window through empty divider |
| `docs/art/reviews/p006/` | GPU capture script, images, observations and verification evidence |
| `docs/progress/lot1-progress.md` | Actual P006 technical/art status |

The Windows binary was rebuilt at `build/windows/MagicOdyssey.exe` (Git-ignored). No source PNG, shader, theme token, HUD resource, domain script or other milestone implementation was changed.

## 3. Slot architecture

The original `SlotGuide_01` … `SlotGuide_06` Panel nodes remain under their four original rows. Their original size (162×112 reference px), 180 px column step, row offsets, labels, divider and approved `tactical_reservation` StyleBox remain intact. No grid replacement, duplicate slot nodes or additional global input interceptor was introduced.

`BattlefieldSlot` derives from Panel. Only its own surface handles GUI input. Disabled slots consume GUI input while ignoring hover/click actions. `CombatScreen` builds one `Dictionary[Vector3i, BattlefieldSlot]` in visual row order. Initialization checks six components per row, valid and unique coordinates, matching node names and visual order. Missing rows, missing component scripts, invalid/duplicate coordinates or incorrect ordering produce explicit `P006:` errors and leave the registry empty. Identity setters lock after registration/readiness.

The code graph was consulted at Tier 2. Recorded generations included `2026-11-16T22:14:44Z` and subsequent watcher updates. Coverage reported changed filesystem metadata, so current source was read directly rather than treating the index as current proof. No shared tactical position implementation was found in the inspected scripts; this presentation type deliberately reserves a later adapter boundary.

## 4. Identity representation

`BattlefieldSlot.Camp { PLAYER = 0, OPPONENT = 1 }`, `Row { ATTACK = 0, DEFENSE = 1 }`; columns are 1…6. `get_slot_identity()` returns `Vector3i(camp, column, row)`. Opponent columns increase left to right, exactly like player columns. Invalid lookup coordinates return null; invalid selection/highlight operations return false.

Coordinates are presentation addresses, never a rule calculation. Hero Artifacts and Creature Equipment introduce no board positions.

## 5. Signal and API contract

The component and screen expose `slot_hovered(camp: Camp, column: int, row: Row)`, `slot_unhovered(...)` and `slot_selected(...)`. `slot_selected` means one accepted left-button press, including the second press of an OS double-click. Button releases, right and middle clicks do not select. Repeated hover-enter/leave notifications do not emit duplicate state transitions.

The screen additionally exposes `slot_selection_changed(slot: BattlefieldSlot)`, with null on clearing. Selection is resolved before the click signal is relayed. Programmatic selection emits the change signal only when the selected slot actually changes; it does not fabricate a click.

| CombatScreen API | Behavior |
|---|---|
| `get_slot(camp, column, row)` | Original component or null |
| `get_slots()` | Typed copy of all 24 components in visual order |
| `get_selected_slot()` | Selected component or null |
| `select_slot(camp, column, row)` | Select enabled slot; bool success; repeated call is idempotent |
| `clear_slot_selection()` | Clear selection; repeated clear is silent |
| `set_slot_highlight(camp, column, row, value)` | Passive highlight; bool success |
| `clear_slot_highlights()` | Clear all passive highlights |
| `set_slot_interaction_enabled(value)` | Enable/disable the whole board |

Per-slot `set_interactable(value)` supports selective disabling. Disabling the selected slot clears screen selection and hover. Re-enabling a slot underneath the stationary pointer restores hover. Component `set_selected` is a rendering setter for the screen's selection model; consumers should use the screen API to preserve single selection.

Clicking another slot switches selection; clicking the selected slot toggles it off. Escape remains the preview entry point's existing clean quit operation. Selection clearing through a future centralized cancel stack is deferred; no global Escape interception was added to CombatScreen.

## 6. Visual states

The approved idle Panel is always drawn unchanged. A native StyleBox overlay uses the existing `accent_bright` bronze/gold and `accent_dim` tokens, 12 px corners, a 2 px border inside the existing surface, and at most 10% translucent inner illumination. There is no shadow expansion, particle, opaque rectangle, asset generation or shader change. Transitions take 100 ms, with the previous tween cancelled on state changes.

| State | Overlay strength | Priority |
|---|---:|---:|
| IDLE | 0; no additional drawing | 4 |
| HIGHLIGHTED | 0.32 | 3 |
| HOVERED | 0.55 | 2 |
| SELECTED | 1.00; stable after pointer leaves | 1 |

Selection therefore stays distinct from hover, and clearing restores the appropriate underlying hover/highlight/idle state. Passive highlight expresses no gameplay legality. Disabled slots do not dim or modify approved idle artwork; explicit passive highlights may remain visible.

## 7. Complete 24-slot mapping

All paths below are relative to `CombatLayout/BattlefieldZone/`. Reference centers are in the 1920×1080 composition. Multiply both coordinates by 2/3 for the exact 720p composition.

| Camp | Column | Row | Original node | Reference center |
|---|---:|---|---|---|
| OPPONENT | 1 | DEFENSE | `OpponentBoardArea/OpponentDefenseRow/SlotGuide_01` | (561, 282) |
| OPPONENT | 2 | DEFENSE | `OpponentBoardArea/OpponentDefenseRow/SlotGuide_02` | (741, 282) |
| OPPONENT | 3 | DEFENSE | `OpponentBoardArea/OpponentDefenseRow/SlotGuide_03` | (921, 282) |
| OPPONENT | 4 | DEFENSE | `OpponentBoardArea/OpponentDefenseRow/SlotGuide_04` | (1101, 282) |
| OPPONENT | 5 | DEFENSE | `OpponentBoardArea/OpponentDefenseRow/SlotGuide_05` | (1281, 282) |
| OPPONENT | 6 | DEFENSE | `OpponentBoardArea/OpponentDefenseRow/SlotGuide_06` | (1461, 282) |
| OPPONENT | 1 | ATTACK | `OpponentBoardArea/OpponentAttackRow/SlotGuide_01` | (561, 418) |
| OPPONENT | 2 | ATTACK | `OpponentBoardArea/OpponentAttackRow/SlotGuide_02` | (741, 418) |
| OPPONENT | 3 | ATTACK | `OpponentBoardArea/OpponentAttackRow/SlotGuide_03` | (921, 418) |
| OPPONENT | 4 | ATTACK | `OpponentBoardArea/OpponentAttackRow/SlotGuide_04` | (1101, 418) |
| OPPONENT | 5 | ATTACK | `OpponentBoardArea/OpponentAttackRow/SlotGuide_05` | (1281, 418) |
| OPPONENT | 6 | ATTACK | `OpponentBoardArea/OpponentAttackRow/SlotGuide_06` | (1461, 418) |
| PLAYER | 1 | ATTACK | `PlayerBoardArea/PlayerAttackRow/SlotGuide_01` | (561, 582) |
| PLAYER | 2 | ATTACK | `PlayerBoardArea/PlayerAttackRow/SlotGuide_02` | (741, 582) |
| PLAYER | 3 | ATTACK | `PlayerBoardArea/PlayerAttackRow/SlotGuide_03` | (921, 582) |
| PLAYER | 4 | ATTACK | `PlayerBoardArea/PlayerAttackRow/SlotGuide_04` | (1101, 582) |
| PLAYER | 5 | ATTACK | `PlayerBoardArea/PlayerAttackRow/SlotGuide_05` | (1281, 582) |
| PLAYER | 6 | ATTACK | `PlayerBoardArea/PlayerAttackRow/SlotGuide_06` | (1461, 582) |
| PLAYER | 1 | DEFENSE | `PlayerBoardArea/PlayerDefenseRow/SlotGuide_01` | (561, 718) |
| PLAYER | 2 | DEFENSE | `PlayerBoardArea/PlayerDefenseRow/SlotGuide_02` | (741, 718) |
| PLAYER | 3 | DEFENSE | `PlayerBoardArea/PlayerDefenseRow/SlotGuide_03` | (921, 718) |
| PLAYER | 4 | DEFENSE | `PlayerBoardArea/PlayerDefenseRow/SlotGuide_04` | (1101, 718) |
| PLAYER | 5 | DEFENSE | `PlayerBoardArea/PlayerDefenseRow/SlotGuide_05` | (1281, 718) |
| PLAYER | 6 | DEFENSE | `PlayerBoardArea/PlayerDefenseRow/SlotGuide_06` | (1461, 718) |

## 8. Native tests and executed commands

All Godot invocations below used `D:\Temp\Godot_v4.7.2-stable_win64.exe`, launched by PowerShell `Start-Process -WindowStyle Hidden -PassThru`, followed by `WaitForExit()` and the actual process `ExitCode`. This avoids the GUI executable returning before completion. These are the executed argument lists; logs are included alongside the review.

| Check / arguments after Godot executable | Actual result | Evidence |
|---|---|---|
| `--headless --path D:\Dev\MagicOdyssey --editor --import --log-file D:\Temp\p006-import-engine.log` | Exit 0 | `import.log` |
| `--headless --path D:\Dev\MagicOdyssey --script res://scripts/tests/test_runner.gd --log-file D:\Temp\p006-tests.log` | Exit 0; 2996/2996 assertions | `native-tests.log` |
| `--path D:\Dev\MagicOdyssey --script res://docs/audits/AUDIT-002/capture_baseline.gd --log-file D:\Temp\p006-art002.log` | Exit 0; 3/3 scenes, zero differing pixels | `art002.log` |
| `--path D:\Dev\MagicOdyssey --script res://docs/art/reviews/p006/capture.gd --log-file D:\Temp\p006-gpu.log` | Exit 0; 256/256 GPU checks | `gpu.log`, `observations.json` |
| `--headless --path D:\Dev\MagicOdyssey --export-release "Windows Desktop" --log-file D:\Temp\p006-export.log` | Exit 0 | `export.log` |
| `& scripts/tests/playtest_windows.ps1 -ReviewDir docs/art/reviews/p006 -HandCount 7 -UtilityHud -UtilityButtonY 915.73 -BattlefieldSlots` | Exit 0; all three Windows modes | `desktop-summary.log`, `desktop-results.json` |
| `git diff --check` | Exit 0 | Executed after review/tracker updates |

Native coverage includes all 24 unique identities and valid resolutions, invalid camp/column/row rejection, immutable registration, preserved geometry and idle style, defensive iteration, signal identities and transition counts, hover enter/leave, left/right/middle/release/double-click handling, single selection, switching/toggle/clear/idempotence, disabled behavior, re-enable, passive highlighting and restoration, token anchor and absence of placeholders, and identity/selection stability at both scales. All prior hand, 540 px typography, HUD and utility tests remain registered and unchanged.

Development checks initially caught a test type-cache import dependency, incorrect off-tree transform measurement, and two overly specific GPU expectations (the picked hand descendant and fixture mana assumed as 5 rather than its initial 1). These were corrected; final logs above contain the passing checks. No existing assertion or production fixture value was weakened to resolve them.

## 9. Actual pointer evidence

Two distinct input paths are recorded:

1. `capture.gd` uses `SubViewport.push_input` mouse motion and button events through the real GUI picker. It does not emit slot signals. This validates all 24 positions at both resolutions, exact hover transition and click counts, disabled behavior and stationary re-enable, a future token child using PASS, an overlay that consumes input, hand inspection click isolation, HUD/utility/divider/gap isolation, End Turn activation, unchanged preview health/mana/turn, and full pixel restoration after interactions. These are **engine-injected events, not desktop pointer proof**.
2. `playtest_windows.ps1 -BattlefieldSlots` uses Windows `SetCursorPos`, `mouse_event` and `keybd_event` on an isolated standalone process. Preview-only listeners report events actually received by the application. Every one of the 24 identities was hovered and clicked in each mode; row columns 1 and 6 have individual desktop captures. Each mode recorded 28 accepted slot clicks across 24 unique identities: 24 initial selections, one toggle off, two selection/switch checks, and a final toggle off. Additional hand/inspection and utility clicks produced no slot signal. All seven hand indices were observed. End Turn received exactly one mouse and one Space activation per mode.

The first desktop attempt failed because Windows had not activated the application for pointer input. The harness now activates it with a real click in the empty center divider before checking slots. The complete rerun passed and is the recorded final run. Hover enter/leave totals can differ by one when window entry/activation sends its initial transition before fixture listeners connect; the native/engine tests enforce exactly one transition per explicit interaction.

## 10. 1080p review

The clean GPU captures and actual standalone selected/inspection captures were opened and inspected. The bronze hover is restrained, selection is clearly brighter and persists, interiors remain visible, and outlines stay within their original rounded surfaces. No adjacent-slot or HUD collision was introduced. The complete idle comparison against P005 is **0 differing pixels**.

| View | Real GPU capture |
|---|---|
| Idle | [board_idle_1080p.png](board_idle_1080p.png) |
| Player attack hover | [board_hover_player_attack_1080p.png](board_hover_player_attack_1080p.png) |
| Player attack selected | [board_selected_player_attack_1080p.png](board_selected_player_attack_1080p.png) |
| Opponent defense hover | [board_hover_opponent_defense_1080p.png](board_hover_opponent_defense_1080p.png) |
| Opponent defense selected | [board_selected_opponent_defense_1080p.png](board_selected_opponent_defense_1080p.png) |
| Labeled diagnostic | [board_multi_state_diagnostic_1080p.png](board_multi_state_diagnostic_1080p.png) |
| Full combat | [full_combat_after_p006_1080p.png](full_combat_after_p006_1080p.png) |

## 11. 720p review

Selection remains readable at the native 1280×720 size; hover is visibly quieter. The cards, 540 px reference inspection (360 physical px), side HUD clearances and utility controls retain the P005 composition. All row extremes responded to actual desktop pointer input. The idle comparison against P005 is **0 differing pixels**.

| View | Real GPU capture |
|---|---|
| Idle | [board_idle_720p.png](board_idle_720p.png) |
| Player attack hover | [board_hover_player_attack_720p.png](board_hover_player_attack_720p.png) |
| Player attack selected | [board_selected_player_attack_720p.png](board_selected_player_attack_720p.png) |
| Opponent defense hover | [board_hover_opponent_defense_720p.png](board_hover_opponent_defense_720p.png) |
| Opponent defense selected | [board_selected_opponent_defense_720p.png](board_selected_opponent_defense_720p.png) |
| Labeled diagnostic | [board_multi_state_diagnostic_720p.png](board_multi_state_diagnostic_720p.png) |
| Full combat | [full_combat_after_p006_720p.png](full_combat_after_p006_720p.png) |

All images above come from actual Godot GPU rendering. Hover/selection images use engine-injected pointer input; the diagnostic caption explicitly identifies API-forced highlight C2 and selection C4, with injected hover C6. `desktop-1920x1080-*` and `desktop-1280x720-*` images record actual OS pointer input, including hover/selected views and all eight row extremes. `regression_hand_inspection_*` records the additional engine pointer check. No screenshot was synthesized or retouched.

## 12. P005 regression checks

The scene diff adds only one script resource and four identity/script assignments per slot. Background, labels, spacing, center divider, hero HUDs, liquid resources, utility art, hand location and inspection geometry are unchanged. Source artwork and shaders are untouched. Exact idle GPU parity covers the complete image at both target sizes, not only the board. ART-002's three reference scenes remain bit-exact.

The only hand code change is `_has_point`, delegating GUI surface ownership to its existing card picker. This is required by the new interactive surfaces: the enlarged hand card extends into the board, so its visible footprint must intercept input instead of exposing a slot behind it. It changes no card rendering or geometry. Both engine and actual OS pointer tests confirm that clicking the enlarged card does not select an underlying slot. Existing End Turn mouse and keyboard interaction remains operational and does not mutate a combat turn.

## 13. Windows standalone validation

`build/windows/MagicOdyssey.exe` is an embedded-PCK export using the existing `Windows Desktop` / `all_resources` preset. Only the executable was copied to `C:\Users\franc\AppData\Local\Temp\MagicOdyssey-standalone-2e3b6031240c4cd3a4e1a0efbafd76b9\` and shell-launched independently of the editor and project resources.

Binary: **143,940,240 bytes**. SHA-256: `e324b9242f5decddc8a7a45364f1f78a81fb923ed9b05007333774736647c57b`.

| Client size | All 24 hover/click identities | Selection switch/toggle | Hand and click isolation | End Turn mouse/Space | Real ESC |
|---|---|---|---|---|---|
| Default 1888×956 | PASS | PASS | PASS | PASS | Exit 0 |
| 1920×1080 | PASS | PASS | PASS | PASS | Exit 0 |
| 1280×720 | PASS | PASS | PASS | PASS | Exit 0 |

No application warning/script error appeared in the final standalone logs. No game process remained after the checks. `--preview-slots` logs signals and freezes liquid animation for deterministic review only; normal launches retain the existing animation. No final creature visuals or gameplay fixture was added to the default scene.

To run the delivered preview, double-click `D:\Dev\MagicOdyssey\build\windows\MagicOdyssey.exe`. Hover a case, click to select, click another to switch or click the selected one to clear. Escape quits.

## 14. Known limitations and NOT_RUN

P006 artistic acceptance is **PENDING OWNER**, including whether the quiet hover strength is preferred. No playable combat engine is claimed. Legal targeting, cancel-stack integration, domain position types, final occupied token artwork/statistics and presenter binding remain outside P006. Programmatic highlights are passive and do not automatically expire or determine legal actions.

P006 was exercised on this Windows/OpenGL/GPU configuration. Separate clean-PC/VM, other renderers, accessibility/performance benchmarks and final full-board creature-density acceptance are NOT_RUN. Some desktop evidence includes small Windows title-button tooltip overlays in the upper-right corner; the clean primary GPU captures do not include them. No image was edited to remove desktop overlays.

## 15. P007/P008 integration considerations

P007 can consume screen signals and call typed presentation APIs through a future view-model/presenter. P032/P033 should adapt the eventual domain coordinates to `BattlefieldSlot.Camp` and `Row`; the slot component should not import engine commands or calculate valid actions.

Each slot exposes a full-rect `TokenAnchor`. Its children can express a future occupied presentation without changing identity or registry entries. A crest should leave the outer 4 px clear so slot outlines remain visible; visual-only token descendants should use IGNORE, and interactive descendants that delegate selection should use PASS. The GPU fixture tested the latter routing and was removed before production screenshots. An input-owning overlay should consume input instead. Authoritative occupancy/capacity remains a future engine responsibility. Hero Artifacts and attached Creature Equipment do not become tactical slots.

## 16. Final recommendation

**APPROVE — technical recommendation for owner review.** P006 implementation and requested local technical validation are complete. The newly introduced hover/selection treatment has not been artistically approved by the owner. Keep P006 as `TECH PASS / ART REVIEW` until that decision. Stop after P006; do not begin P007, P008 or gameplay integration. G1 remains NOT_VALIDATED.
