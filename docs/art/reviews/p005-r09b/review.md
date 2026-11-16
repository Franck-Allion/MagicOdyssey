# P005-R09B — Premium Card Hover Readability & Inspection Polish Review

**Date:** 2026-11-16
**Platform:** Windows 11; Godot 4.7.2 stable; OpenGL Compatibility; NVIDIA GeForce GTX 1660 Ti
**Milestone:** Lot 1 — J1 Combat Interface
**Task:** P005-R09B — Card Hover Readability & Inspection Polish

---

## 1. Executive Summary

**VERDICT: APPROVE (P005-R09B Technical & Visual Polish).**

This milestone resolves the **MAJOR readability issue (R09A-001)** identified in the P005-R09A global audit, dramatically enhancing text legibility for inspected cards in the player's hand at **1280×720** while preserving the approved ART-002 card artwork, the Hearthstone-style overlapping fan, and the overall CombatScreen composition.

### Key Results
- **Inspection Geometry:** Elevated default reference inspection height from **440 px to 540 px** (physical card height at 720p increased from **293.33 px to 360.0 px**, a **+22.7%** dimensional increase).
- **Physical Text Scaling at 720p:**
  - **Long Titles ("Archon of the Sundered Sphere"):** Increased from **8.51 physical px to 11.93 physical px** (**+40.2% increase**), meeting the target ~12 physical px threshold.
  - **Rules Text:** Increased from **9.32–9.72 physical px to 11.93 physical px** (**+22.7% to +28.0% increase**), meeting the target ~12 physical px threshold.
  - **Short/Medium Titles:** Increased from **13.78 physical px to 16.91 physical px** (**+22.7% increase**), remaining exceptionally crisp and legible.
- **Adaptive Positioning & Containment:** Implemented `calculate_inspection_center` with adaptive vertical clamping (`inspect_center_y = -20.0 px` at 540 px height), maintaining a safe **26 reference px (17.33 physical px at 720p)** margin from the bottom of the screen with zero bottom clipping.
- **Side HUD Clearance:** Leftmost and rightmost cards maintain **>= 40 reference px** horizontal clearance to both the Player Hero HUD (`x=296`) and Utility HUD (`x=1624`).
- **Tactical Clearance:** Inspected card top reaches `y=514 px` in reference space, remaining comfortably below the battlefield center divider (`y=480 px`), leaving the entire opponent board completely unobstructed.
- **Technical Verification:**
  - **Native Headless Test Suite:** **2507/2507 PASS** (31 new targeted assertions; exit code 0).
  - **ART-002 Visual Regression Suite:** **3/3 scenes 100% bit-exact parity** (0 differing pixels; exit code 0).
  - **Windows Standalone Playtest:** Full shell execution in isolated temporary directory across default (1888×956), 1920×1080, and 1280×720 modes with mouse hover, End Turn focus/activation, and clean ESC exit 0.

*Boundary Note:* P005 remains pending final owner artistic sign-off. Gate G1 remains NOT_VALIDATED. P006–P010 and Hero Artifact gameplay systems are not implemented or approved by this milestone.

---

## 2. R09A Readability Issue (R09A-001)

The P005-R09A audit identified that while 1080p card inspection was legible, 1280×720 inspection suffered from severely undersized typography:
- Card inspection height of 440 reference px scaled to only **293.33 physical px** on a 720p display.
- Single-line title fitting for long names ("Archon of the Sundered Sphere", 30 characters) forced font scaling down to 42 pt in source space, rendering at **8.51 physical px** on screen.
- Standard card rules text at 48 pt rendered at **9.32–9.72 physical px**.
- Both text elements fell well below standard accessibility thresholds for comfortable reading without manual zoom or squinting.

---

## 3. Baseline Measurements (R09A Baseline)

Measurements taken at 440 px inspection height (`inspect_center_y = 20.0 px`):

| Metric | 1080p Reference Space | 720p Physical Display |
|---|---:|---:|
| Card Dimensions (3:4 ratio) | 330 × 440 px | 220 × 293.33 px |
| Card Top Boundary | y = 604 px | y = 402.67 px |
| Card Bottom Boundary | y = 1044 px (36 px margin) | y = 696.0 px (24 px margin) |
| Short Title Font Size ("Arcane Knight", 68 pt) | 20.66 px | 13.78 px |
| Medium Title Font Size ("Voidbound Talisman", 62 pt) | 18.84 px | 12.56 px |
| Long Title Font Size ("Archon of the Sundered Sphere", 42 pt) | 12.76 px | **8.51 px (MAJOR)** |
| Rules Text Font Size (46–48 pt) | 13.98–14.59 px | **9.32–9.72 px (MAJOR)** |

---

## 4. Candidate Inspection Size Comparison

In accordance with Section 5 of the specification, three candidate inspection sizes were rendered and evaluated on the actual GPU at 1280×720:

| Candidate | Ref Height | 720p Physical Card | 720p Long Title | 720p Rules Text | Viewport / Bottom Margin | Side HUD Clearance | Visual Assessment |
|---|:---:|:---:|:---:|:---:|:---:|:---:|---|
| **Candidate A (Baseline)** | 440 px | 220 × 293.3 px | 8.51 px | 9.32–9.72 px | Bottom margin: 24.0 px | 40.0 px | **REJECT:** Fails 720p readability targets; requires squinting/zoom. |
| **Candidate B** | 500 px | 250 × 333.3 px | 11.05 px | 11.05 px | Bottom margin: 17.3 px | 40.0 px | **REJECT:** Borderline readability; does not reliably reach 12 physical px. |
| **Candidate C (Selected)** | **540 px** | **270 × 360.0 px** | **11.93 px** | **11.93 px** | **Bottom margin: 17.3 px** | **40.0 px** | **ACCEPT:** Optimal balance of legibility, 3:4 aspect ratio, and containment. |

Evidence Captures:
- `baseline_hover_720p.png` (Candidate A)
- `candidate_500_720p.png` (Candidate B)
- `candidate_540_720p.png` (Candidate C)

---

## 5. Selected Inspection Height

**Candidate C (540 px reference height, 360.0 physical px at 720p)** was selected as the optimal solution.

### Rationale
1. **Target Readability:** It is the minimal uniform height that elevates both 48 pt rules text and 48 pt title text to ~12 physical px at 720p (`48 * (540 / 1448) * (2/3) = 11.93 physical px`).
2. **Standard Game Proportions:** At 540 reference px on a 1080p screen (and 360 physical px on a 720p screen), the inspected card occupies exactly **50.0% of the screen height**, adhering to established CCG presentation conventions (e.g., Hearthstone).
3. **Strict Aspect Ratio:** Retains the native `1086×1448` (3:4) aspect ratio with zero non-uniform distortion (`405 × 540 px`).
4. **Preserved Clearance:** Left and right extremes maintain 40 px safe margins to HUD columns without any risk of overlap.

---

## 6. Final Physical Font Measurements

Comparison of physical font dimensions rendered in the actual production scene:

| Inspected Text Element | Source Points | Baseline 1080p | Baseline 720p | Final R09B 1080p | Final R09B 720p | Net Improvement (720p) |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **Short Titles** ("Arcane Knight") | 68 pt | 20.66 px | 13.78 px | **25.36 px** | **16.91 px** | **+22.7%** |
| **Medium Titles** ("Voidbound Talisman") | 62 pt | 18.84 px | 12.56 px | **23.12 px** | **15.41 px** | **+22.7%** |
| **Long Titles** ("Archon of the Sundered Sphere") | 48 pt (was 42 pt) | 12.76 px | **8.51 px** | **17.90 px** | **11.93 px** | **+40.2%** |
| **Rules Text** (Short & Multi-line) | 48 pt | 14.59 px | **9.32–9.72 px** | **17.90 px** | **11.93 px** | **+22.7% to +28.0%** |
| **Category / Type Subtitle** | 48 pt | 14.59 px | 9.72 px | **17.90 px** | **11.93 px** | **+22.7%** |

---

## 7. Long-Title Behavior & Controlled Wrapping

To ensure that long card names remain legible without shrinking to illegible sizes or changing underlying card frames:
- `CardContentOverlay` evaluates single-line width fitting down to `TITLE_MINIMUM`.
- If a title would drop below **52 pt** on a single line and contains multiple words, the system checks whether wrapping across two lines fits within `TITLE_BOUNDS` (`610×94 px`).
- For "Archon of the Sundered Sphere", 2-line wrapping with `-6.0` line separation fits with **48 pt font size** (up from 42 pt).
- Single-line short/medium titles ("Arcane Knight", "Fireball", etc.) remain at **62–68 pt** on a single line.
- Full card titles are preserved intact with zero arbitrary abbreviations, zero text truncation, and zero ellipsis.

---

## 8. Rules-Text Behavior

- Card rules text consistently renders at **48 pt** in source coordinates across creatures, spells, and equipment.
- In 1280×720 display mode, rules text renders at **11.93 physical px** (comfortably readable).
- In 1920×1080 display mode, rules text renders at **17.90 physical px**.
- Text formatting (bold keywords, paragraph centering, word wrapping) remains cleanly centered within `RULES_BOUNDS`.

---

## 9. Left, Center, and Right Viewport Containment

Positioning is governed by `CombatPreviewCards.calculate_inspection_center()`:
- **Horizontal Clamping:**
  `clampf(rest_x, half_w + 16.0, width - half_w - 16.0)`
  - Leftmost card (`index = 0`): Center x = 218.5 px in hand zone $\rightarrow$ card left edge = `x = 336.0 px` in screen coordinates.
    Clearance to Player Hero HUD (`x = 296.0 px`): **40.0 px**.
  - Rightmost card (`index = 9`): Center x = 1061.5 px in hand zone $\rightarrow$ card right edge = `x = 1584.0 px` in screen coordinates.
    Clearance to Utility HUD (`x = 1624.0 px`): **40.0 px**.
- **Vertical Clamping:**
  `inspect_center_y = minf(20.0, 1080.0 - 26.0 - 804.0 - 270.0) = -20.0 px`.
  - Card Bottom: `804.0 - 20.0 + 270.0 = 1054.0 px`.
    Margin from screen bottom (`y = 1080 px`): **26.0 reference px** (**17.33 physical px at 720p**). Zero bottom clipping.
  - Card Top: `804.0 - 20.0 - 270.0 = 514.0 px`.
    Clearance below battlefield center divider (`y = 480 px`): **34.0 reference px**. Zero opponent board obstruction.

---

## 10. Hover Stability & Interaction

- **Hit-Box Parity:** `pick_card_at()` and `_apply_card_transforms()` share the identical `calculate_inspection_center()` method. Pointer picking accurately reflects the animated 540 px visual footprint with zero geometry drift.
- **Hysteresis:** Pointer movement within the upper raised body (`local_p.y < -20.0`) reliably maintains inspection of the active card.
- **Steering:** Moving the pointer into neighboring resting cards seamlessly transfers hover ownership without flickering.
- **Transitions:** Smoothstep easing over 0.18s provides fluid elevation and return to the resting fan.

---

## 11. Full-Screen Composition Impact

- When inspecting a card, the enlarged card commands appropriate visual focal weight without overwhelming the screen.
- The 40 px side margins preserve complete visibility of the player resource orbs and turn/action controls.
- The resting hand fan (`preferred_height = 270.0 px`) remains completely unchanged.
- Both 7-card standard play and 10-card visual stress layouts operate with identical containment guarantees.

---

## 12. 1080p Review Evidence

| Capture File | Description |
|---|---|
| `final_full_hand_1080p.png` | Complete CombatScreen at 1080p with 10 resting cards |
| `final_hover_left_1080p.png` | 1080p hover inspection of leftmost card (index 0: Arcane Knight) |
| `final_hover_center_1080p.png` | 1080p hover inspection of center card (index 4: Pyretic Inscription) |
| `final_hover_right_1080p.png` | 1080p hover inspection of rightmost card (index 9: Archon of the Sundered Sphere) |

---

## 13. 720p Review Evidence

| Capture File | Description |
|---|---|
| `baseline_hover_720p.png` | Candidate A (440 px baseline) for direct comparative review |
| `candidate_500_720p.png` | Candidate B (500 px) intermediate candidate |
| `candidate_540_720p.png` | Candidate C (540 px) selected solution |
| `final_full_hand_720p.png` | Complete CombatScreen at 720p with 10 resting cards |
| `final_hover_left_720p.png` | 720p hover inspection of leftmost card (index 0: Arcane Knight) |
| `final_hover_center_720p.png` | 720p hover inspection of center card (index 4: Pyretic Inscription) |
| `final_hover_right_720p.png` | 720p hover inspection of rightmost card (index 9: Archon of the Sundered Sphere) |
| `final_hover_long_title_720p.png` | 720p closeup inspection showing wrapped 48 pt title |
| `final_hover_rules_720p.png` | 720p closeup inspection showing multi-line rules text readability |
| `final_hover_spell_720p.png` | 720p inspection of Spell preview card (index 1: Arcane Study) |
| `final_hover_equipment_720p.png` | 720p inspection of Equipment preview card (index 2: Runic Relic) |
| `before_after_readability_720p.png` | Direct side-by-side comparative crop (Baseline 440 px vs R09B 540 px) |

---

## 14. Test Results and Actual Exit Codes

| Verification Suite | Target | Actual Result | Exit Code |
|---|---|---|:---:|
| `test_runner.gd` | Native Headless Test Suite | **2507/2507 PASS** (0 failures) | 0 |
| `run_visual_regression.ps1` | ART-002 Visual Regression Suite | **3/3 Bit-Exact Parity** (0 differing pixels) | 0 |
| `capture.gd` | GPU Comparison & Evidence Suite | 16/16 PNGs saved cleanly | 0 |
| `build_windows.ps1` | Standalone Windows Build | `MagicOdyssey.exe` built successfully | 0 |
| `playtest_windows.ps1` | Isolated Standalone Desktop Playtest | 3 window modes verified; mouse hover & ESC 0 | 0 |
| `git diff --check` | Whitespace & Formatting | Clean, 0 whitespace warnings | 0 |

---

## 15. Windows Standalone Verification

The standalone executable (`build/windows/MagicOdyssey.exe`) was copied to an isolated temporary directory and launched independently of Godot and the repository across all three target modes:
- **Default Mode (1888×956):** Rendered cleanly; mouse hover elevation, End Turn focus/activation, and ESC exit 0 verified.
- **1080p Mode (1920×1080):** Native 1:1 pixel rendering; mouse hover across leftmost, center, rightmost cards verified; zero clipping; ESC exit 0.
- **720p Mode (1280×720):** Native 2/3 scale rendering; mouse hover inspection verified; card text comfortably legible; zero clipping; ESC exit 0.
- **Resource Animation:** Four fluid resource reservoirs animated smoothly during desktop execution.

Desktop captures recorded in `docs/art/reviews/p005-r09b/`:
- `desktop-default.png`, `desktop-default-hover-left.png`, `desktop-default-hover-center.png`, `desktop-default-hover-right.png`
- `desktop-1920x1080.png`, `desktop-1920x1080-hover-left.png`, `desktop-1920x1080-hover-center.png`, `desktop-1920x1080-hover-right.png`
- `desktop-1280x720.png`, `desktop-1280x720-hover-left.png`, `desktop-1280x720-hover-center.png`, `desktop-1280x720-hover-right.png`

---

## 16. Known Limitations

1. **Crowded Board Token Presentation:** Token density on the tactical battlefield remains deferred to P008 (Fantasy Crest `CreatureToken`).
2. **Dedicated Spell/Equipment Frame Variants:** Dedicated non-creature visual card frames without creature stat sockets are planned under `P009-R01A/B` and `P009-R02A/B` (PLAN-002).
3. **Hero Artifact Exploration HUD:** Active Artifact HUD indicators and exploration inventory views are deferred to Phase 2 (Tower Exploration).

---

## 17. Recommendation

**RECOMMENDATION: APPROVE.**

The technical implementation and visual polish of P005-R09B have conclusively resolved R09A-001. Cards inspected at 1280×720 are now comfortably readable, with text scaling meeting or exceeding ~12 physical px targets, flawless viewport containment, zero HUD collisions, and 100% bit-exact preservation of approved ART-002 assets.

**Final visual acceptance of P005 remains strictly reserved for project owner sign-off.**
