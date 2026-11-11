# ART-001-T02 — Observatory v3 Artwork Integration Review

**Date:** November 2026  
**Evaluation Scope:** Visual integration of revised battlefield artwork (v03) against the 24-slot tactical grid and combat UI fixtures.  
**Evaluated Scene:** `res://scenes/ui/art001_integration_test.tscn`  
**Script:** `res://scripts/presentation/art001_integration_test.gd`  
**Recommendation:** **APPROVE_ARTWORK** (Subject to final human artistic sign-off on generated screenshots).

---

## 1. Asset Specifications & Reproducibility

- **Source Asset:** `res://assets/_source/lot1/battlefield/wip/mo_battlefield_sundered_observatory_bg_wip_v03.png`
- **Source Dimensions:** 1672 × 941 (Aspect Ratio: 1.7768:1 — virtually identical to 16:9 / 1.7777:1).
- **Source SHA256:** `9149C53F8E76CA77935CC84FB14C285239F54620D642F9CB78AC23C1B8BF5FF0`
- **Comparison Baseline (v02):** `assets/_source/lot1/battlefield/wip/mo_battlefield_sundered_observatory_bg_wip_v02.png` (1376 × 768, SHA256 `508FF955...`).
- **Rendering Parameters:**
  - Viewport Scaling: `TextureRect.STRETCH_KEEP_ASPECT_COVERED` with `TextureRect.EXPAND_IGNORE_SIZE` on a 1920 × 1080 canvas.
  - Scale Factor: $1080 / 941 \approx 1.1477$.
  - Cropping: Negligible ($\le 1$ pixel horizontally), zero vertical crop, zero perspective distortion.
  - Tactical Scrim: Preserved existing configuration (`ColorRect` at $x=260, y=245$, size $1400 \times 548$, `board_darkening = 0.30` navy).
- **Grid Preservation:** The exact normative tactical grid is maintained identically to v2:
  - 6 Columns ($x = 478 + 185 \times c$, slot width 164px, gap 21px).
  - 4 Rows ($y = 263.0, 389.0, 535.0, 661.0$, slot height 120px).
  - Total grid footprint: $x = 478..1567$, $y = 263..781$.

---

## 2. Visual Acceptance Checklist & Side-by-Side Comparison

| Acceptance Criterion | v02 Evaluation (Baseline) | v03 Evaluation (Revised) | Status |
|---|---|---|:---:|
| **1. Opponent Rows on Stone Floor** | **FAIL**: Floor ellipse started at $y \approx 610$. Both opponent rows ($y=263, 389$) floated over walls, arches, and instruments. | **PASS**: Floor ellipse begins at $y \approx 210-230$. Both opponent rows sit naturally and firmly on the arena stone floor. | **RESOLVED** |
| **2. 24 Slots Aligned & Readable** | **PASS**: Grid slots aligned, but lacked an environmental grounding on the top half. | **PASS**: All 24 slots remain perfectly aligned, with clean borders and translucent backgrounds. | **PASS** |
| **3. No Token or Stat Overlap** | **PASS**: ATK and HP clearly separated at bottom-left and bottom-right of crests. | **PASS**: Clean positioning maintained; no overlap between tokens, numbers, or badges. | **PASS** |
| **4. Floor Engravings vs Slot Outlines** | **FAIR**: Bright, glowing cyan/blue star pattern competed with blue player slot outlines. | **PASS**: Engravings redesigned as subtle, darker cyan geometric/astrological compass lines carved into slate stone tiles. | **RESOLVED** |
| **5. Opponent Hero Panel Readability** | **PASS**: Hero panel readable against the celestial opening. | **PASS**: Hero panel framed cleanly against dark stone balustrade and starfield; text contrast is sharp. | **PASS** |
| **6. Full 7-Card Hand Visibility** | **PASS**: 35px clearance above hand ($y=816..1056$). Hand covered platform rim. | **PASS**: All 7 cards remain 100% visible; bottom stone steps provide a natural visual footer. | **PASS** |
| **7. No Clipped UI at 1280×720** | **PASS**: Responsive scaling maintained. Small badges dense. | **PASS**: Responsive scaling verified; no clipping of hero HUDs, inspector, hand, or action button. | **PASS** |
| **8. Atmospheric Environment Quality** | **PASS**: Observatory theme recognizable, but bottom-right corner had an artifact star. | **PASS**: Observatory arches, moon, torches, globes, and armillary spheres preserved with richer depth. Bottom-right artifact removed. | **RESOLVED** |

---

## 3. Detailed Side-by-Side Analysis (v02 vs v03)

### A. Camera Elevation and Arena Placement
In v02, the low camera angle placed the arena platform floor almost entirely in the bottom third of the viewport ($y \ge 610$). Because the combat design requires four tactical rows above the player's hand ($y=263..781$), the opponent rows appeared completely detached from the floor, floating like a HUD across the room's architecture.

In v03, the artist adopted an elevated, three-quarter tactical viewpoint. The stone platform now occupies the vast majority of the screen height ($y \approx 210$ down to $y \approx 1000$). The balustrade is pushed back into the upper mid-ground. As a result, **all four tactical rows (`O / DEFENSE`, `O / ATTACK`, `P / ATTACK`, `P / DEFENSE`) now reside entirely inside the circular arena floor**. The battlefield feels like a real, physical gladiatorial platform rather than a disconnected overlay.

### B. Linework and Visual Hierarchy
The central floor graphics in v02 were luminous and neon-like, creating a high-frequency hotspot directly beneath the player's front and back rows. In v03, the center features understated, darker cyan concentric celestial circles and compass crosshairs embedded in stone pavers. This keeps the center of the arena quiet, letting empty slot borders, active unit crests, and floating status badges stand out clearly.

### C. Resolution and Ergonomics
- **1920×1080 (Native Reference):** In both Preset B (typical combat) and Preset C (full 24-slot board), slot borders, crest portraits, stat labels (28 reference pixels), and HUD panels maintain pristine contrast and readability.
- **1280×720 (Responsive Floor):** Verified via `full_board_720p.png`. The entire interface fits comfortably within the 16:9 viewport. Stat numbers scale down cleanly to $\approx 18.7$ physical pixels and remain easily legible.

---

## 4. Generated Evidence (Godot OpenGL Renders)

All captures were generated using the project's native capture script (`docs/art/reviews/art001/capture.gd`) running a graphical `SubViewport`:

| Evidence File | Resolution | Preset | Description |
|---|:---:|:---:|---|
| [background_only_1080p.png](background_only_1080p.png) | 1920 × 1080 | A (0) | Raw v03 background without scrim or UI overlay. |
| [typical_combat_1080p.png](typical_combat_1080p.png) | 1920 × 1080 | B (1) | Typical 4-unit board, 5-card hand, 20 empty slots. |
| [full_board_1080p.png](full_board_1080p.png) | 1920 × 1080 | C (2) | Maximum stress test: 24 active crest tokens, 8 badges, 7 cards. |
| [full_board_720p.png](full_board_720p.png) | 1280 × 720 | C (2) | Maximum stress test at minimum responsive resolution. |

---

## 5. Technical Verification Results

All tests executed against Godot 4.7.2 stable (`D:\Temp\Godot_v4.7.2-stable_win64.exe`):

| Test Command | Purpose | Result / Console Output | Exit Code |
|---|---|---|:---:|
| `& $Godot --headless --editor --path . --quit` | Project import & resource scanner | Filesystem scan complete; `v03.png.import` created cleanly | **0** |
| `powershell -File scripts\tests\run_tests.ps1` | Native test harness regression suite | `Total Assertions: 14; Passed: 14; Failed: 0; ALL TESTS PASSED` | **0** |
| `& $Godot --headless --path . res://scenes/ui/art001_integration_test.tscn --quit-after 2` | Headless integration scene launch | Scene instantiates and executes without warnings or errors | **0** |
| `git diff --check` | Formatting, whitespace, and line ending hygiene | Clean; zero whitespace or line ending issues | **0** |

---

## 6. Recommendation

**APPROVE_ARTWORK**.

The revised v03 background successfully resolves the compositional defect documented in T01:
1. Both opponent rows now sit naturally upon the stone platform floor.
2. The elevated perspective provides authentic grounding for the 24 tactical slots.
3. Central floor engravings are refined and non-distracting.
4. The atmospheric theme, broken celestial dome, and fantasy props remain visually premium and distinctive.

*Note on Production Handoff:* This approval clears the artwork for integration in Lot 1 presentation scenes (P005+). Minor UI badge sizing at 720p remains an intended UI layout task for J1/J7 and is independent of the background asset.
