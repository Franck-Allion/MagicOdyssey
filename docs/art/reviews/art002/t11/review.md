# ART-002-T11 — Stat Icon Scale & Container Optical Alignment

2026-11-13 · **PASS** (Technical Verification & Calibration) · Artistic Status: **RECOMMENDATION: APPROVE (FOR OWNER FINAL SIGN-OFF)**.

This review documents the scale recalibration, container registration, and optical alignment refinement of the V2 stat icons (Attack, Health, Armor, Shield) on master frame v03, resolving the two presentation issues identified during owner review of ART-002-T10:
1. Icons were oversized relative to their containers, approaching or touching the decorative borders.
2. Containers and their icon/number contents did not appear optically centered or balanced.

---

## 1. Icon Sizing & Visible Silhouette Padding

All four V2 runtime icons in `assets/textures/cards/icons/` remain completely untouched. Sizing was recalibrated in `scripts/presentation/card_stat_overlay.gd` based on exact visible alpha bounds (where $\alpha \ge 10$) measured in source texture space:

| Statistic | Original Size (T10) | Final Size (T11) | Visible Silhouette Bounds | Container Dimensions | Minimum Visible Padding (T10 vs T11) | Evaluation |
|---|---|---|---|---|---|---|
| **Attack** | 60 × 60 px | **48 × 48 px** | 21.0 × 47.4 px | Inner collet circle: Dia 58 px<br>Bronze bezel: Dia 68 px | Top/Bottom margin:<br>T10: **-0.65 px** (Touching bronze rim)<br>T11: **+5.28 px** (Inside inner circle, **+10.28 px** to bezel) | **Resolved** · Sword tip and pommel no longer penetrate the bronze collet rim. |
| **Health** | 68 × 68 px | **52 × 52 px** | 39.8 × 37.2 px | Inner collet circle: Dia 58 px<br>Bronze bezel: Dia 68 px | Horizontal margin:<br>T10: **2.97 px** (Cramped)<br>T11: **+9.09 px** (Generous breathing room) | **Resolved** · Faceted ruby heart now floats comfortably with balanced internal padding. |
| **Armor** | 68 × 68 px | **52 × 52 px** | 39.8 × 37.4 px | Badge plate: 198 × 100 px<br>Corner radius: 23 px | Vertical margin:<br>T10: **25.56 px** (Crowding corner curves)<br>T11: **+31.31 px** (Clean plate breathing room) | **Resolved** · Steel breastplate has ample clearance from top accent line and bottom border. |
| **Shield** | 64 × 64 px | **50 × 50 px** | 33.2 × 40.8 px | Badge plate: 198 × 100 px<br>Corner radius: 23 px | Vertical margin:<br>T10: **23.88 px**<br>T11: **+29.59 px** (Matches Armor vertical margin) | **Resolved** · Luminous kite ward visual scale matches Armor cuirass within 5%. |

---

## 2. Container Optical Alignment & Frame Registration

Investigation of the master frame v03 geometry (`assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png`) and the independent T04B 360-ray aperture fits revealed the root cause of the socket misalignment:
- In T04B, the painted circular socket apertures were independently measured:
  - Attack socket center: `(162, 1279)`
  - Health socket center: `(919, 1279)`
- The numerals were correctly aligned to these centers (`ATTACK_CENTER = (162, 1279)`, `HEALTH_CENTER = (919, 1279)`).
- However, the top emblem collets retained pre-T04B legacy coordinates (`157, 1187` and `934, 1187`).
- Consequently:
  - Attack emblem collet was shifted **5 px to the left** of the socket's vertical axis.
  - Health emblem collet was shifted **15 px to the right** of the socket's vertical axis, off the painted bronze apex and into the shadow!

### Recalibration
- `ATTACK_EMBLEM_CENTER` updated from `Vector2(157, 1187)` to **`Vector2(162, 1187)`**.
- `HEALTH_EMBLEM_CENTER` updated from `Vector2(934, 1187)` to **`Vector2(919, 1187)`**.
- Result: **0.0 px axis error**. The socket aperture, top collet emblem, and numeral now share the exact same vertical center line on both left and right sockets.

---

## 3. Badge Composition & Optical Balance

The Armor badge (`Rect2(280, 1280, 198, 100)`) and Shield badge (`Rect2(608, 1280, 198, 100)`) are mathematically symmetric around card center $X = 543$ ($543 - 478 = 65\text{ px}$ and $608 - 543 = 65\text{ px}$, $280\text{ px}$ from outer card edges). Their outer rectangles were strictly preserved as mandated.

Internal badge element placement was centralized into typed constants and optically balanced:

| Element | T10 Local Position | T11 Calibrated Position | Internal Padding & Spacing (T11) |
|---|---|---|---|
| **Badge Icon Center** | `(48, 50)` | **`(50, 50)`** | Left margin: **30.1 px** (Comfortably clears 23 px corner radius and 3 px border). |
| **Badge Numeral Center** | `(137, 50)` (Hardcoded) | **`(140, 50)`** (`BADGE_NUMBER_LOCAL_CENTER`) | Right margin: **40.0 px** (Single-digit), **21.0 px** (Double-digit, zero collision). |
| **Inter-Element Clearance** | ~45 px | **52.1 px** (Single-digit), **33.1 px** (Double-digit) | Clear, comfortable separation between icon silhouette and numeral ink. |
| **Group Optical Center** | $X = 88.5\text{ px}$ (Left-heavy) | **$X = 94.1\text{ px}$** | Balanced within $4.9\text{ px}$ of the plate physical center ($X = 99.0\text{ px}$). |

---

## 4. Final Centralized Constants

Updated in `scripts/presentation/card_stat_overlay.gd`:

```gdscript
## Centralized optical alignment and scale constants for premium icons
const ATTACK_EMBLEM_CENTER: Vector2 = Vector2(162, 1187)
const HEALTH_EMBLEM_CENTER: Vector2 = Vector2(919, 1187)

## Calibrated V2 optical constants (ART-002-T11 refined sizing & alignment)
const ATTACK_ICON_OFFSET: Vector2 = Vector2(0, 0)
const ATTACK_ICON_SIZE: Vector2 = Vector2(48, 48)

const HEALTH_ICON_OFFSET: Vector2 = Vector2(0, -1)
const HEALTH_ICON_SIZE: Vector2 = Vector2(52, 52)

const BADGE_ICON_LOCAL_CENTER: Vector2 = Vector2(50, 50)
const BADGE_NUMBER_LOCAL_CENTER: Vector2 = Vector2(140, 50)

const ARMOR_ICON_OFFSET: Vector2 = Vector2(0, 0)
const ARMOR_ICON_SIZE: Vector2 = Vector2(52, 52)

const SHIELD_ICON_OFFSET: Vector2 = Vector2(0, 0)
const SHIELD_ICON_SIZE: Vector2 = Vector2(50, 50)
```

Preserved for comparison, diagnostics, and rollback:
- T10 sizing constants (`ATTACK_ICON_SIZE_T10`, etc.) and `static var use_t10_sizing: bool = false`.
- V1 sizing constants (`ATTACK_ICON_SIZE_V01`, etc.) and `static var icon_version: int = 2`.

---

## 5. Visual Evidence (1920×1080 Full HD)

Rendered with genuine Godot 4.7.2 GPU viewport rendering on an NVIDIA GeForce GTX 1660 Ti (OpenGL Compatibility backend).

| Screenshot Deliverable | Resolution | Purpose & Key Observations |
|---|---|---|
| [before_after_icons_1080p.png](before_after_icons_1080p.png) | 1920 × 1080 | **Direct side-by-side icon crop comparison** between T10 (Before) and T11 (After). Clearly demonstrates resolution of border encroachment and establishment of generous breathing room. |
| [before_after_containers_1080p.png](before_after_containers_1080p.png) | 1920 × 1080 | **Full-card comparison** of container alignment. Demonstrates correction of the -5 px Attack and +15 px Health collet axis misalignments, plus balanced badge contents. |
| [final_inspected_card_1080p.png](final_inspected_card_1080p.png) | 1920 × 1080 | **Production inspection view** of Rampart Guard (ATK 4, HP 5, Armor 2, Shield 4, Epic Emerald gem). Clean presentation with no debug overlays. |
| [final_seven_card_hand_1080p.png](final_seven_card_hand_1080p.png) | 1920 × 1080 | **Seven-card linear hand study** at in-game 1080p scale (card height 316 px). Demonstrates crisp icon silhouettes with no border clutter. |
| [final_combat_1080p.png](final_combat_1080p.png) | 1920 × 1080 | **Full combat scene** with Sundered Observatory background, HUD, 4×6 grid, and 7-card hand at 1080p. Validates overall gameplay aesthetic and visual balance. |
| [optical_alignment_diagnostics_1080p.png](optical_alignment_diagnostics_1080p.png) | 1920 × 1080 | **Technical diagnostic view** with measured axis overlays (red), symmetry guides (cyan), bounding boxes (gold), and comprehensive measurement panel. (Diagnostic guides appear in this capture only). |

---

## 6. Technical Verification Transcript

Working Directory: `D:\Dev\MagicOdyssey`  
Engine: `D:\Temp\Godot_v4.7.2-stable_win64.exe` (v4.7.2.stable.official.ed1daf0bf)

| Verification Step | Command / Invocation | Exit Code | Result | Observations |
|---|---|---:|---|---|
| Godot Asset Import | `--headless --editor --path . --import --quit` | `0` | **PASS** | Reimported assets cleanly. |
| Native Test Harness | `scripts\tests\run_tests.ps1` | `0` | **PASS** | 14/14 core test assertions pass. |
| ART-002 Scene Init | `scenes/ui/art002_card_integration_test.tscn` | `0` | **PASS** | Scene tree and shaders compile and initialize cleanly. |
| T04B/T06 Numerical Regression | `docs/art/reviews/art002/t06/stat_regression.gd` | `0` | **PASS** | All 144 socket combinations pass (0 failures, max ink error 1.055 px). |
| T11 Icon & Alignment Regression | `docs/art/reviews/art002/t11/icon_regression.gd` | `0` | **PASS** | Aligned axes, refined sizes, padding bounds, and zero-protection states verified. |
| T10 Backward Compatibility | `docs/art/reviews/art002/t10/icon_regression.gd` | `0` | **PASS** | Passes without errors. |
| T08 Backward Compatibility | `docs/art/reviews/art002/t08/icon_regression.gd` | `0` | **PASS** | Passes without errors. |
| Review Capture Suite | `docs/art/reviews/art002/t11/capture.gd` | `0` | **PASS** | All 6 review captures rendered and saved with exit code 0. |
| Whitespace & Git Diff | `git diff --check` | `0` | **PASS** | Zero trailing whitespace or format violations. |

---

## 7. Remaining Visual Limitations

1. **Painted Frame Organic Asymmetry:** The master frame v03 artwork is hand-painted; its physical outer borders sit at $X = 162\text{ px}$ for Attack and $X = 167\text{ px}$ for Health from their respective card outer edges ($5\text{ px}$ organic asymmetry). The overlay centers precisely match the true painted socket apertures rather than forcing an artificial mathematical symmetry that would clash with the artwork.
2. **Double-Digit Badge Margin:** When a badge displays extreme double-digit values (e.g. Shield 10 or Armor 99), the right margin narrows from $40.0\text{ px}$ to $21.0\text{ px}$. This maintains complete clearance from the $3\text{ px}$ bronze border ($18\text{ px}$ net interior clearance) and preserves $33.1\text{ px}$ of separation from the icon.

---

## 8. Conclusion & Recommendation

**RECOMMENDATION: APPROVE (FOR OWNER FINAL SIGN-OFF)**.

The recalibrated sizes provide generous, consistent breathing room inside all containers ($+5.3\text{ px}$ for Attack, $+9.1\text{ px}$ for Health, $+31.3\text{ px}$ for Armor, $+29.6\text{ px}$ for Shield), while the container registration corrects the legacy axis misalignment to $0.0\text{ px}$ error against the painted frame apertures. All approved presentation and combat behaviors are preserved.
