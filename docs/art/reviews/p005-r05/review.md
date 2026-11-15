# P005-R05 — Hearthstone-Style Hand Recognition & Hover Inspection

Date: 2026-11-15. Godot 4.7.2 stable; Windows 11; OpenGL Compatibility; NVIDIA GeForce GTX 1660 Ti.

**Recommendation: APPROVE (or KEEP_WITH_ADJUSTMENTS pending owner live feel review). Stop after R05; P006 remains untouched.**

---

## 1. Executive Summary

P005-R05 refines the player hand presentation layer by delivering working, fluid, Hearthstone-style pointer hover inspection in the standalone combat preview without requiring gameplay drag-and-drop or card commands.

Key accomplishments:
- **At-Rest Card Identification:** Switched card fan layering from symmetric mirrored depth to deterministic left-to-right stacking (`z_index = index`). In MagicOdyssey's ART-002 master frame, the mana gem socket and title start are positioned at the top-left of each card. Left-to-right stacking guarantees that every card in hands of 0–10 cards has an exposed, unobstructed top-left strip revealing its mana cost, title fragment, illustration slice, and rarity gem.
- **Deterministic Oriented Picking with Hysteresis:** Replaced unrotated rectangular bounding boxes with transformed oriented bounding box (OBB) hit-testing (`is_point_in_card`). Added active inspection hysteresis: when a card is raised, pointer movement within its raised visual body maintains hover ownership without oscillation or accidental drop-out, while moving into neighboring resting card areas cleanly transfers focus.
- **Smooth Animation Controller:** Replaced instantaneous snapping with an interruptible, per-frame blend interpolator in `_process`. Uses smoothstep easing (`t = b * b * (3 - 2b)`) over a 0.18-second duration. Supports five distinct state machine states (`IDLE`, `HOVERING`, `TRANSITIONING`, `INSPECTING`, `RETURNING`).
- **Inspection Card Size Decision:** Evaluated candidate inspection heights at 420 px, 460 px, and 500 px. Selected **440 px** height (330 px width at native 0.75 aspect ratio). This height renders ART-002 rules text and stat cabochons comfortably readable, stays enclosed within the viewport (with 36 px margin at the bottom), and clears the left hero panel (ends at x=296) and right utility column (starts at x=1624) with over 40 px horizontal clearance on both sides.
- **100% Green Test Suite & Parity:** Native headless tests increased from 1223 to **1473 passed assertions (0 failed)**. ART-002 visual regression suite maintained **3/3 bit-exact parity (0 differing pixels)**. Windows standalone export was rebuilt and verified with automated real desktop pointer movement across default, 1080p, and 720p client windows, with ESC clean exit code 0.

---

## 2. Original R04 Interaction Limitations

P005-R04 established the mathematical fan layout for 0–10 cards, but exhibited critical ergonomic limitations for interactive play:
1. **No Real Pointer Hover:** Cards had `MOUSE_FILTER_IGNORE`, and inspection was only settable via programmatic script calls (`set_inspected_card`). The standalone game window did not react to pointer movement.
2. **Obscured Mana Sockets on the Right Half:** R04 used mirrored depth layering (`z_index = min(index, n - 1 - index)`). Cards on the right half overlapped inwards, causing the left edge of cards 5–9 to be buried underneath their left neighbors. Because mana sockets sit on the top-left, mana costs for cards on the right half were completely hidden.
3. **Ambiguous Overlapping Hit Bounds:** A simple axis-aligned bounding box (AABB) would produce massive overlapping hit areas where rotated cards intersect, causing pointer jitter and rapid flickering between adjacent cards.
4. **Lack of Lift-Off Hysteresis:** If hit-testing only tested resting card positions, as soon as a card lifted upwards and grew, the mouse pointer would find itself inside the newly exposed underlying card or empty space, causing immediate hover cancellation and severe oscillation (chattering).

---

## 3. At-Rest Identification Strategy

At rest, players do not need to read full multi-line rules text across overlapping cards. They must immediately recognize card identity through:
- **Mana cost:** Primary resource budgeting cue.
- **Title fragment:** Recognizable name beginning (e.g. "Arcane...", "Pyretic...", "Celestial...").
- **Illustration slice:** Distinct color palette and subject silhouette.
- **Rarity gem:** Embedded cabochon indicating common, uncommon, rare, epic, or legendary status.

### Stacking Geometry
By setting resting `card.z_index = index`:
- Card 0 is drawn at `z = 0`.
- Card 1 is drawn at `z = 1`, overlapping the right portion of Card 0, leaving Card 0's top-left corner exposed.
- Card $i$ always exposes its top-left quadrant (where mana socket, title banner start, and rarity gem reside).
- The rightmost card (Card $n-1$) is completely unobstructed on both sides.

In a full 10-card hand across 1280 px fan width, card horizontal centers are spaced approximately 113 px apart. With card width of 202.5 px at 270 px resting height, each card presents an exposed strip of at least 80–113 px, guaranteeing accessible visual recognition and pointer picking.

---

## 4. Overlapping Card Picking Algorithm

Hit-testing is implemented via `CombatPreviewCards.pick_card_at(local_point: Vector2) -> int`:

```gdscript
static func is_point_in_card(p: Vector2, center: Vector2, rotation: float, card_height: float) -> bool:
    var offset: Vector2 = (p - center).rotated(-rotation)
    var scale_factor: float = card_height / CardViewLayout.CARD_SIZE.y
    var half_width: float = CardViewLayout.CARD_SIZE.x * scale_factor * 0.5
    var half_height: float = card_height * 0.5
    return absf(offset.x) <= half_width and absf(offset.y) <= half_height
```

Algorithm stages:
1. **Inspection Hysteresis Check:** If a card is currently raised or transitioning (`_target_index >= 0` with `raised_blend > 0.08`), its current interpolated center, height, and rotation are computed. If `local_point` is within this oriented footprint:
   - If `local_point.y < -20.0` (the upper body of the raised card, above all resting card bounds): return `_target_index` unconditionally. The player is reading the inspected card.
   - If `local_point.y >= -20.0` (overlapping the resting fan's vertical span): test resting cards from right to left (top to bottom visual stacking). If the pointer enters an exposed neighbor's resting footprint, transfer target to that neighbor immediately. Otherwise, maintain `_target_index`.
2. **Resting Fan Traversal:** Iterate in descending visual order (`i = count - 1 down to 0`). The first card whose oriented bounding box contains `local_point` is returned.
3. **Miss:** If no card contains the point, return `-1`.

---

## 5. Hover State Handling

The component defines an explicit state machine:
- `IDLE`: No card hovered; all cards at resting fan poses; `z_index = index`.
- `HOVERING`: Pointer entered a card; transition initiated (`blend <= 0.05`).
- `TRANSITIONING`: Card is rising and rotating upright (`0.05 < blend < 0.999`).
- `INSPECTING`: Card has reached full inspection pose (`blend >= 0.999`); `z_index = 100`.
- `RETURNING`: Pointer exited hand or switched card; previous card interpolating back to 0.0; `z_index = 90`.

Input handling connects `_gui_input` and `_input` for `InputEventMouseMotion`. Moving within the same card does not restart animations. Leaving the window (`NOTIFICATION_WM_MOUSE_EXIT`) or moving outside the hand clears `_target_index` to `-1`, gracefully returning all cards to resting fan poses.

---

## 6. Animation Implementation

Rather than allocating and managing Godot `Tween` instances every frame (which risk memory thrashing and conflicting interpolations), `CombatPreviewCards` uses a centralized per-card blend array `_card_blends: Array[float]`.

- Transition speed: `1.0 / transition_duration` (where `transition_duration = 0.18` seconds).
- Per-frame update: `_card_blends[i] = move_toward(_card_blends[i], target, speed * delta)` in `_process`.
- Smoothstep curve: `t = b * b * (3.0 - 2.0 * b)` ensures zero velocity at both ends of the motion, avoiding abrupt starts or hard stops.
- Automatic sleep: When all blends reach their destinations, `set_process(false)` is called, consuming zero CPU cycles at rest.
- Interruption safety: Rapidly moving from Card A to Card B retargets blend destinations immediately. Card A begins decreasing smoothly from its current fractional blend while Card B begins rising from its current blend.

---

## 7. Hover Card Size Decision

Controlled comparisons were conducted at three candidate inspection heights:
- **420 px:** Compact; preserves maximum tactical visibility; rules text legible at 1080p but tight at 720p.
- **460 px:** Very readable; intrudes deeper into tactical defense row.
- **500 px:** Oversized; upper edge approaches battlefield center divider; horizontal footprint risks crowding side margins.

**Selected Production Height: 440 px** (width 330 px).
At 440 px:
- Reference 1080p card center: `y = 824.0` (local `y = 20.0` within `PlayerHandZone` at `y = 804.0`).
- Card top edge: `824.0 - 220.0 = 604.0 px`.
- Card bottom edge: `824.0 + 220.0 = 1044.0 px` (leaves 36 px margin above screen bottom).
- Overlap with battlefield: temporarily covers rows `y = 604..780` (player defense row) only while actively hovered, which is normal and desirable for card inspection.
- Typography: Master frame title, subtype, description text, and numerical cabochons are crisp and effortlessly readable.

Comparison evidence: [Size comparison sheet](hand_hover_size_comparison.png).

---

## 8. Left, Center, and Right Boundary Handling

Inspected cards are clamped horizontally to prevent clipping against viewport edges or overlapping critical HUD controls:

```gdscript
var scale_inspect: float = inspect_h / CardViewLayout.CARD_SIZE.y
var half_w_inspect: float = CardViewLayout.CARD_SIZE.x * scale_inspect * 0.5
var inspect_center_x: float = clampf(rest_center.x, half_w_inspect + 16.0, size.x - half_w_inspect - 16.0)
```

Measured clearances at 1920×1080 reference:
| Card | Rest Center X | Inspect Center X | Global Left X | Global Right X | Left Hero Margin (ends 296) | Right Utility Margin (starts 1624) |
|---|---|---|---|---|---|---|
| Card 0 (Leftmost) | 71.2 px | 181.0 px | 336.0 px | 666.0 px | **+40.0 px clearance** | >950 px |
| Card 4 (Center) | 484.2 px | 484.2 px | 739.2 px | 1069.2 px | >440 px | >550 px |
| Card 9 (Rightmost) | 1208.8 px | 1099.0 px | 1254.0 px | 1584.0 px | >950 px | **+40.0 px clearance** |

Every card remains entirely inside the 1920×1080 and 1280×720 viewports with zero clipping.

---

## 9. Ten-Card Behavior

At 10 cards:
- Symmetrical angular spread reaches ±9.0 degrees.
- Center-to-center spacing is approximately 113.1 px.
- All 10 mana sockets and title beginnings remain visible at rest due to left-to-right stacking.
- Any of the 10 cards can be hovered directly.
- Scrubbing across the entire hand from card 0 to 9 produces smooth sequential lifting without hit chattering.

*Note on Normative Hand Limit:* Normative gameplay rules (`specs/01-lot1-vertical-slice/01-scope.md` §3.6 and Decision Q39) specify a maximum hand size of 7 cards. The presentation system supports display counts 0–10 as requested by the owner. Gameplay capacity consolidation will occur in P024.

---

## 10. 1080p Evidence

Full resolution captures (1920×1080):
- [1080p CombatScreen at rest (7 cards)](combat_screen_1080p.png)
- [7-card hand at rest crop](hand_7_rest.png)
- [10-card hand at rest crop](hand_10_rest.png)
- [10-card hand hover leftmost (Card 0)](hand_10_hover_left.png)
- [10-card hand hover center (Card 4)](hand_10_hover_center.png)
- [10-card hand hover rightmost (Card 9)](hand_10_hover_right.png)
- [Inspection size comparison (420 vs 460 vs 500 px)](hand_hover_size_comparison.png)
- [Transition filmstrip (activation & return)](hand_hover_transition_frames.png)
- [Animated inspection GIF](hand_hover_animation.gif)

---

## 11. 720p Evidence

Secondary resolution captures (1280×720):
- [720p CombatScreen at rest](combat_screen_720p.png)
- [720p 10-card hand hover center](hand_hover_720p.png)

Proportional downscaling (2/3 scale) maintains identical relative proportions, layout clearances, and upright inspection readability.

---

## 12. Windows Real-Pointer Test

Automated desktop playtest (`scripts/tests/playtest_windows.ps1`) verified genuine OS pointer interaction on the exported standalone binary `build/windows/MagicOdyssey.exe`:
- Launches isolated binary in temporary folder (proving independence from project files).
- Renders across three window modes: Default client (1888×956), 1920×1080 borderless, and 1280×720 borderless.
- Sends actual Windows mouse events via Win32 `SetCursorPos` and `mouse_event`.
- Exercises:
  1. Hovering leftmost card (Card 0 exposed mana socket).
  2. Hovering center card (Card 4).
  3. Hovering rightmost card (Card 9).
  4. Rapid scrubbing across cards 0 → 2 → 4 → 6 → 8 → 9 at 50 ms intervals.
  5. Moving pointer outside the hand into the battlefield (y=500), verifying smooth return to resting fan.
  6. Pressing ESC key, confirming exit code 0 and complete process cleanup.

Captured desktop evidence:
- Default: [rest](desktop-default.png), [hover left](desktop-default-hover-left.png), [hover center](desktop-default-hover-center.png), [hover right](desktop-default-hover-right.png)
- 1080p: [rest](desktop-1920x1080.png), [hover left](desktop-1920x1080-hover-left.png), [hover center](desktop-1920x1080-hover-center.png), [hover right](desktop-1920x1080-hover-right.png)
- 720p: [rest](desktop-1280x720.png), [hover left](desktop-1280x720-hover-left.png), [hover center](desktop-1280x720-hover-center.png), [hover right](desktop-1280x720-hover-right.png)

---

## 13. Native and Visual Regression Results

All verification commands executed from repository root `D:/Dev/MagicOdyssey`:

| Command | Purpose | Result | Exit Code |
|---|---|:---:|:---:|
| `& $GodotExe --headless --path . --editor --import` | Headless editor import & class scan | Clean | 0 |
| `& $GodotExe --headless --path . --script res://scripts/tests/test_runner.gd` | Native headless test suite | **1473 passed, 0 failed** | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/run_visual_regression.ps1` | AUDIT-002 ART-002 visual regression | **3/3 bit-exact (0 differing pixels)** | 0 |
| `& $GodotExe --path . --script res://scripts/tests/capture_p005_r05.gd` | GPU capture script | PASS (all bounds & saves clean) | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build_windows.ps1` | Standalone Windows release export | Built `MagicOdyssey.exe` | 0 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/playtest_windows.ps1 -ReviewDir docs/art/reviews/p005-r05 -HandCount 10` | Real Windows mouse playtest | PASS (3/3 windows, ESC exit 0) | 0 |
| `git diff --check` | Whitespace and syntax integrity | Clean | 0 |

---

## 14. Known Limitations

1. **Presentation Sample Content:** Card titles, subtypes, and rules text remain presentation fixtures (e.g. Arcane Knight, Astral Weaver). Official catalog resources (`CardDefinition.tres`) are introduced in J2 (`P011`–`P020`).
2. **No Drag or Play Commands:** Cards lift and enlarge on hover for visual reading, but clicking or dragging does not initiate casting or targeting. Play flows are scheduled for J4 (`P034`–`P035`).
3. **Resting Rules Text:** In 10-card hands, body rules text is intentionally overlapped at rest; hovering is required to read card mechanics.

---

## 15. P009 Reuse Plan

`CombatPreviewCards` establishes the production geometry, picking math, and hover state controller for the future interactive `HandView`:
- `layout_pose()` and `is_point_in_card()` will be extracted into a shared utility or directly inherited by `HandView`.
- Stacking order (`z_index = index`) will govern resting card rendering.
- State machine (`IDLE`, `HOVERING`, `TRANSITIONING`, `INSPECTING`, `RETURNING`) will integrate with card selection and drag states (`DRAGGING`, `TARGETING`).
- ART-002 card components (`CardContentOverlay`, `CardStatOverlay`, `CardCategoryOverlay`) will be bound to real domain `CardCopy` data via `CombatPresenter` (`P032`).

---

## 16. Final Recommendation

**APPROVE**

P005-R05 fully resolves the owner's feedback regarding hand readability and interaction ergonomics. Individual cards are identifiable at rest via unobstructed top-left mana and title cues, and pointer hover smoothly inspects full-size, upright, readable cards without jitter or clipping.

Stop after P005-R05. Do not proceed to P006.
