# P007 — Hero & Turn HUD Data Binding Review

**Date:** 2026-11-17
**Platform:** Windows 11; Godot 4.7.2 stable (official ed1daf0bf); OpenGL Compatibility; NVIDIA GeForce GTX 1660 Ti
**Milestone:** Lot 1 — J1 Combat Interface
**Task:** P007 — Hero & Turn HUD Data Binding
**Status:** IMPLEMENTATION COMPLETE / TECHNICAL PASS

---

## 1. Executive Summary

**VERDICT: APPROVE (P007 Technical Implementation & Data Binding).**

Milestone `P007` establishes the presentation-level data-binding architecture for MagicOdyssey's combat HUDs. It transforms the previously static and manually previewed HUD components into a strongly typed, deterministic presentation model capable of refreshing all player and opponent HUD elements independently or via atomic state snapshots.

### Key Deliverables
1. **Typed View-Models:** Implemented `HeroHudViewModel` and `CombatHudViewModel` (`scripts/presentation/`), providing structured, validated data containers for hero resources, deck/graveyard counts, turn sequence, phase status, and action logs.
2. **Authoritative Injection Contract:** Implemented `CombatScreen.apply_hud_view_model(model)` and granular helpers (`apply_hero_resources`, `apply_turn_state`, `apply_deck_counts`, `apply_graveyard_counts`, `apply_recent_actions`, `set_end_turn_enabled`).
3. **Decoupled Architecture:** Presentation data binding is 100% decoupled from `CombatEngine`. Zero gameplay rules or turn advancement logic are executed; the End Turn button cleanly emits the presentation intent signal `end_turn_requested`.
4. **Idempotence & Shader Safety:** Reapplying identical snapshots does not restart or jerk liquid resource shaders or recreate active nodes.
5. **Preservation of Baselines:**
   - `P005` approved CombatScreen visual composition and 540 px hover inspection remain completely untouched.
   - `P006` 24 interactive tactical slots remain fully operational, interactable, and selectable.
   - `ART-002` visual regression suite maintains **3/3 scenes 100% bit-exact parity** (0 differing pixels).
   - Headless test coverage expanded from 2996 to **3098 assertions PASS** (+102 new assertions).
   - Standalone Windows build verified across default, 1080p, and 720p modes with clean ESC exit 0.

*Boundary Notice:* P007 is a presentation milestone. Gate G1 remains `NOT_VALIDATED` pending completion of P008–P010.

---

## 2. Files Changed & Added

| File | Action | Purpose |
|---|:---:|---|
| `scripts/presentation/hero_hud_view_model.gd` | **NEW** | Strongly typed data container for a single hero's HUD state. |
| `scripts/presentation/combat_hud_view_model.gd` | **NEW** | Strongly typed snapshot container for complete combat HUD state. |
| `scripts/presentation/graveyard_view.gd` | **MODIFIED** | Added `set_card_count()` for count updates decoupled from top-card identity. |
| `scripts/presentation/combat_screen.gd` | **MODIFIED** | Added public data-binding APIs, signal `hud_view_model_applied`, signal `end_turn_requested`. |
| `scripts/tests/test_combat_hud.gd` | **NEW** | Dedicated automated test suite (102 assertions) covering P007 contracts. |
| `scripts/tests/test_runner.gd` | **MODIFIED** | Registered `TestCombatHud` into the deterministic native test runner. |
| `docs/art/reviews/p007/capture.gd` | **NEW** | GPU review capture harness generating 1080p and 720p demonstration evidence. |
| `docs/art/reviews/p007/review.md` | **NEW** | Authoritative review document and verification report. |
| `docs/progress/lot1-progress.md` | **MODIFIED** | Updated progress tracker with P007 technical pass. |

---

## 3. View-Model Architecture

### `HeroHudViewModel` (`scripts/presentation/hero_hud_view_model.gd`)
A lightweight, typed presentation class representing one hero's visible status:
- `hero_name: String`: Supported hero identity (default: `"Hero"`).
- `current_health: int`: Current HP value ($\ge 0$).
- `max_health: int`: Maximum HP capacity ($\ge 0$).
- `current_mana: int`: Current unspent mana available for actions ($\ge 0$).
- `max_mana: int`: Mana capacity for the current turn ($\ge 0$).
- `deck_count: int`: Number of cards in deck ($\ge 0$).
- `graveyard_count: int`: Number of cards in graveyard ($\ge 0$).
- `top_graveyard_card: GraveyardView.PreviewCard`: Optional reference to the top card miniature.
- `is_valid() -> bool`: Verifies non-empty name and non-negative values.
- `duplicate_model() -> HeroHudViewModel`: Deep decoupled cloning.

### `CombatHudViewModel` (`scripts/presentation/combat_hud_view_model.gd`)
An atomic snapshot container for the entire combat interface:
- `player_hero: HeroHudViewModel`: Player hero state.
- `opponent_hero: HeroHudViewModel`: Opponent hero state.
- `turn_number: int`: Current combat turn number ($\ge 1$).
- `active_camp: BattlefieldSlot.Camp`: Active camp (`PLAYER` or `OPPONENT`).
- `phase: CombatHudViewModel.Phase`: Normative turn phase enum (`TURN_START`, `ACTION`, `ATTACK`, `CLEANUP`, `MATCH_OVER`).
- `end_turn_enabled: bool`: Visual availability of the End Turn action.
- `recent_actions: Array[String]`: Recent action log entries.
- `turn_display_override: String` / `phase_display_override: String`: Optional overrides for special missions.
- `get_formatted_turn() -> String`: Standard `"TURN %02d"` formatting.
- `get_formatted_phase() -> String`: Canonical phase display string (e.g. `"PLAYER  /  ACTION"`, `"END-OF-TURN ATTACK"`).
- `duplicate_model() -> CombatHudViewModel`: Deep decoupled snapshot cloning.

---

## 4. Public Injection Contract

`CombatScreen` exposes an authoritative, deterministic snapshot injection API:

```gdscript
## Injects a complete presentation snapshot into all combat HUD components.
## Returns true on success; returns false on null or invalid models with zero mutation.
func apply_hud_view_model(model: CombatHudViewModel, animate: bool = true) -> bool
```

### Granular Refreshes
For performance or incremental animation updates, granular helpers update specific components while keeping the internal model synchronized:
- `apply_hero_resources(camp, health, max_health, mana, max_mana, animate) -> bool`
- `apply_turn_state(turn_number, active_camp, phase, end_turn_enabled) -> bool`
- `apply_deck_counts(player_deck, opponent_deck) -> bool`
- `apply_graveyard_counts(player_grave, opponent_grave) -> bool`
- `apply_recent_actions(actions) -> bool`
- `set_end_turn_enabled(enabled) -> void`
- `get_hud_view_model() -> CombatHudViewModel`

---

## 5. Mapping Between Model Fields and Existing UI Controls

| View-Model Property | Target UI Control | Presentation Behavior |
|---|---|---|
| `player_hero.current_health`, `max_health` | `PlayerHeroZone/PlayerHealthOrb` | Updates crimson liquid level, wave slosh, and central `"HP / MAX"` label. |
| `player_hero.current_mana`, `max_mana` | `PlayerHeroZone/PlayerManaOrb` | Updates azure liquid level, wave slosh, and central `"MANA / MAX"` label. |
| `opponent_hero.current_health`, `max_health` | `OpponentHeroZone/OpponentHealthOrb`<br>`OpponentHeroZone/HealthValues` | Updates emerald liquid orb and external high-contrast `"HP / MAX"` label. |
| `opponent_hero.current_mana`, `max_mana` | `OpponentHeroZone/OpponentManaOrb`<br>`OpponentHeroZone/ManaValues` | Updates amber liquid orb and external high-contrast `"MANA / MAX"` label. |
| `player_hero.deck_count` | `ActionBarZone/DeckStack` | Multi-layered card back stack and numeric counter label. |
| `opponent_hero.deck_count` | `OpponentPiles/DeckStack` | Symmetrical card back stack and numeric counter label. |
| `player_hero.graveyard_count` | `ActionBarZone/GraveyardView` | Shows `Empty` if count = 0; renders top miniature if provided; updates counter. |
| `opponent_hero.graveyard_count` | `OpponentPiles/GraveyardView` | Shows `Empty` if count = 0; renders top miniature if provided; updates counter. |
| `turn_number`, `active_camp`, `phase` | `MatchStatus/Turn`<br>`MatchStatus/Phase` | Formatted turn banner (e.g. `"TURN 03"`) and phase string (`"PLAYER  /  ACTION"`). |
| `end_turn_enabled` | `ActionBarZone/EndTurnButton` | `disabled = false` (Normal/Hover); `disabled = true` (dimmed, desaturated shader). |
| `recent_actions` | `ActionBarZone/RecentActions` | Up to 3 recent lines joined by `\n`; shows placeholder if empty. |

---

## 6. Snapshot Consistency & Idempotence

- **Idempotence:** Reapplying an identical view-model snapshot produces zero visual glitching. `LiquidResourceOrb` checks `is_equal_approx(target, _target_ratio)` and skips restarting slosh waves if the fill ratio is unchanged.
- **Fail-Closed Validation:** Passing `null` or a model with negative values returns `false` immediately without modifying any visual control.
- **Deep Decoupling:** Injected models are cloned on ingestion and retrieval (`duplicate_model()`). External mutations to model instances cannot affect displayed UI.

---

## 7. Health and Mana Update Behavior

- **Liquid Orbs:** Both hero Health and Mana orbs react to data injection with fluid simulation over `0.28s`.
- **Numeric Labels:** Number values update immediately without waiting for the fluid animation to settle.
- **Clamping:** Values are clamped to `[0, max_value]`. Max values are clamped to $\ge 0$.
- **Fill Ratio:** $F = \frac{\text{current}}{\max}$ if $\max > 0$, else $0.0$.
- **External Opponent Labels:** Opponent HUD labels (`HealthValues`, `ManaValues`) update via signal subscription on the orbs (`resource_values_changed`), ensuring 100% synchronization.

---

## 8. Deck and Graveyard Binding

- **Deck Counts:** Supports 0 (empty layer), 1–5 (2 layers), 6–15 (3 layers), and $>15$ (5 layers). Evaluated across 0, 1, normal 34-card decks, and 3-digit counts (100).
- **Graveyard Counters:**
  - When `graveyard_count == 0`: Displays the approved empty graveyard texture (`mo_hud_graveyard_empty_v01.png`) with count label `0`.
  - When `graveyard_count > 0` with top card: Displays the miniature card preview (`LastEnteringCard`) with rarity-tinted frame and artwork aperture.
  - When `graveyard_count > 0` without top card: Preserves any previously accepted top card, or displays the base empty frame with the updated counter label.

---

## 9. Turn, Camp and Phase Presentation

The `MatchStatus` panel reflects combat state through normative labels:
- **Turn Number:** Formatted as `"TURN %02d"` (e.g., `"TURN 01"`, `"TURN 05"`, `"TURN 99"`).
- **Active Camp & Phase:**
  - `Phase.TURN_START`: `"PLAYER  /  START"` or `"OPPONENT  /  START"`
  - `Phase.ACTION`: `"PLAYER  /  ACTION"` or `"OPPONENT  /  ACTION"`
  - `Phase.ATTACK`: `"END-OF-TURN ATTACK"`
  - `Phase.CLEANUP`: `"PLAYER  /  CLEANUP"` or `"OPPONENT  /  CLEANUP"`
  - `Phase.MATCH_OVER`: `"MATCH OVER"`
- Custom mission overrides (`turn_display_override`, `phase_display_override`) are supported without losing typed phase identity.

---

## 10. End Turn Button State Handling

- **Visual Feedback:** When `end_turn_enabled = false`, `PremiumEndTurnButton` transitions to `VisualState.DISABLED`, applying `0.52` brightness and `0.10` saturation via `utility_button_state.gdshader`.
- **Presentation Intent Signal:** Pressing the button emits `end_turn_requested` from `CombatScreen`. It executes zero combat commands and performs zero turn advancement calculations.

---

## 11. Recent Action Log

- **Capacity:** Displays up to 3 most recent actions.
- **Formatting:** Joined with `\n` using the quiet secondary typography token (`Color(0.80, 0.76, 0.70)`).
- **Empty State:** Automatically displays `"Awaiting first action..."` when the action list is empty.

---

## 12. GPU Review Evidence Captures (1080p & 720p)

All screenshots committed in `docs/art/reviews/p007/`:

| Scenario | 1080p Screenshot | 720p Screenshot | Description |
|---|---|---|---|
| **A. Default HUD** | `hud_default_1080p.png` | `hud_default_720p.png` | Turn 1, Player Action Phase, full 30 HP, 1/1 Mana, 34-card decks. |
| **B. Resource Changed** | `hud_resource_changed_1080p.png` | `hud_resource_changed_720p.png` | Player 22/30 HP, 0/4 Mana; Opponent 18/30 HP, 2/4 Mana; action log entry. |
| **C. Turn Transition** | `hud_turn_transition_1080p.png` | `hud_turn_transition_720p.png` | Turn 3, Opponent Action Phase, End Turn button disabled. |
| **D. Counters & Log** | `hud_counters_updated_1080p.png` | `hud_counters_updated_720p.png` | Decks 24/22, Graveyards 5/4 with top miniatures, 3 populated action entries. |
| **E. Extreme Values** | `hud_extreme_values_1080p.png` | `hud_extreme_values_720p.png` | Turn 99, 0/30 HP (lethal), 10/10 Mana, 100-card deck, Match Over. |
| **F. Disabled Button** | `hud_disabled_end_turn_1080p.png` | `hud_disabled_end_turn_720p.png` | Attack phase with desaturated disabled End Turn button. |
| **G. Full Screen** | `full_combat_after_p007_1080p.png` | `full_combat_after_p007_720p.png` | Canonical full CombatScreen state with active slots and 7-card hand fan. |

### Timed Resource Animation Evidence
- `p007_resource_anim_t00.png` (t = 0.0s)
- `p007_resource_anim_t04.png` (t = 0.4s)
- `p007_resource_anim_t08.png` (t = 0.8s)
- `p007_resource_anim_t12.png` (t = 1.2s)

---

## 13. Native Test Results

Native headless test runner output:

```
==================================================
MagicOdyssey — Native Headless Test Runner
Engine: 4.7.2-stable (official)
==================================================
[RUN] TestHarnessSelf
[RUN] TestCardPresentation
[RUN] TestCombatScreen
[RUN] TestBattlefieldSlots
[RUN] TestUtilityHud
[RUN] TestLiquidResourceOrb
[RUN] TestCombatHud
--------------------------------------------------
Test Execution Summary:
  Total Assertions: 3098
  Passed:           3098
  Failed:           0
==================================================
RESULT: ALL TESTS PASSED
```

- Total Assertions: **3098 / 3098 PASS** (+102 new P007 assertions).
- Exit Code: **0**.

---

## 14. Windows Standalone Verification

Executable rebuilt at `build/windows/MagicOdyssey.exe` and tested via `playtest_windows.ps1` in an isolated temporary sandbox (`%TEMP%\MagicOdyssey-standalone-*`):
- **Default Desktop (1888×956):** Rendered cleanly; mouse hover, End Turn focus/activation, and ESC exit 0 verified.
- **1080p Mode (1920×1080):** 1:1 pixel rendering; mouse hover, button activation, and ESC exit 0 verified.
- **720p Mode (1280×720):** Responsive 2/3 scale rendering; sharp text, mouse hover, button activation, and ESC exit 0 verified.
- Result: **PASS: shell launch, 3 desktop windows, ESC exits with code 0, no remaining game process.**

---

## 15. P005 and P006 Regression Assessment

- **P005 Composition:** Symmetrical 5-region composition, player hero HUD, opponent hero HUD, card fan, 540 px inspection, and utility controls remain 100% intact.
- **P006 Slots:** All 24 battlefield slots retain their unique identities, coordinates, hover/select signals, and token anchors.
- **Visual Regression:** `run_visual_regression.ps1` reports **3/3 scenes 100% Bit-Exact Parity** (0 differing pixels).
- **Whitespaces:** `git diff --check` passes with zero warnings.

---

## 16. Known Limitations

1. **CombatEngine Binding:** Actual live combat engine subscription belongs to `P033` (Playable Interactive Combat Loop). P007 provides the presentation model and injection API; it does not connect to gameplay events.
2. **Token Densities:** CreatureToken visual components on the board remain deferred to `P008`.
3. **Card Layout Variants:** Spell and Equipment dedicated non-creature frames remain deferred to `P009-R01A/B` and `P009-R02A/B`.

---

## 17. P008 Integration Readiness

With P007 complete:
- The combat HUD can display any combination of hero resources, turn state, and action logs during creature combat.
- The 24 tactical slots (`P006`) provide clean token anchors with `MOUSE_FILTER_IGNORE`.
- The presentation layer is ready to receive `P008` Fantasy Crest tokens on the board.

---

## 18. Final Recommendation

**RECOMMENDATION: APPROVE.**

`P007` fulfills all architectural, data-binding, and visual requirements specified for the milestone. It is technically complete, fully tested, and verified on real Windows desktop hardware.

Progression to `P008` (Fantasy Crest `CreatureToken`) is recommended.
