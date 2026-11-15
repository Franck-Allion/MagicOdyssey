# P005-R06D — Player HUD Micro-Polish for Orb Fit and Breathing Room

Date: 2026-11-15. Godot 4.7.2 stable; Windows 11; OpenGL Compatibility; NVIDIA GeForce GTX 1660 Ti.

**Recommendation: APPROVE (or KEEP_WITH_ADJUSTMENTS pending owner live feel review). Stop after R06D; do not proceed automatically to any subsequent task.**

---

## 1. Summary

P005-R06D delivers a surgical micro-polish pass on the Player Hero HUD, addressing the final non-AAA visual issues identified in P005-R06C without altering approved source PNG assets, redesigning components, or touching opponent HUD or hand layouts.

Key achievements:
- **Orb Typography Safe-Area Fitting:** Resolved the boundary crowding on Health orb's "30 / 30" label. By implementing a content-aware safe-area available width formula (`available = diameter * 0.58`) and scaling base font size from 38 px down to **31 px** (auto-fitting "30 / 30" to **30 px**), string width decreased from 121.0 px to **96.0 px**. Inside the 119.5 px visible glass aperture (diameter 180 px), this guarantees **11.8 px of clear liquid margin** on both sides. The left "3" no longer crowds or overlaps the inner bronze circular bezel.
- **Caption Hierarchy Refinement:** Reduced the visual weight of secondary "HP" / "MANA" captions: font size adjusted from 21 px to **15 px** (`diameter * 0.085`), with a delicate 1 px outline and muted `secondary` parchment tone. Captions remain crisply readable while sitting in an elegant, subordinate hierarchy above the focal numerical value.
- **Subtle Orb Scale & Generous Bottom Breathing Room:** Reduced orb diameter subtly by 5.3% (from 190 px to **180 px**). Repositioned `PlayerHealthOrb` at `y = 252..432 px` and `PlayerManaOrb` at `y = 452..632 px`. The bottom of the Mana orb now has **68.2 px of margin** to the bottom of the 700 px panel (and ends at y = 631.8 px, well before the panel's bottom metal border at y = 638 px). The cramped feeling at the bottom of the panel is completely eliminated.
- **Optical Spacing Symmetry:** Silhouette gaps between portrait frame and Health orb (**19.7 px**) and between Health orb and Mana orb (**20.2 px**) are balanced to within **0.5 px** of optical symmetry. Horizontal centerline remains strictly aligned at `x = 136.0 px`.
- **Screen Parity & Full Test Suite:** Rendering outside the player HUD column ($x \ge 320\text{ px}$) remains **100% bit-exact (0 differing pixels)**. Native headless assertions increased from 1548 to **1553 passed (0 failed)**. ART-002 visual regression remains **3/3 bit-exact**. Windows release executable verified in isolated desktop playtest across default, 1080p, and 720p modes with ESC exit code 0.

---

## 2. Exact Layout Changes

All modifications remain strictly within `CombatLayout/PlayerHeroZone` (`offset_left = 24.0, offset_top = 220.0, offset_right = 296.0, offset_bottom = 920.0`, panel size 272×700 px):

| Element | R06C Position | R06D Position | Size | Center (X, Y) | Change Notes |
|---|---|---|---|---|---|
| **Backplate** | `(0, 0)` to `(272, 700)` | `(0, 0)` to `(272, 700)` | 272×700 px | (136.0, 350.0) | Unchanged uniform crop |
| **Portrait Frame** | `(36, 44)` to `(236, 244)` | `(36, 42)` to `(236, 242)` | 200×200 px | (136.0, 142.0) | Shifted up 2 px for top breathing |
| **Portrait Illustration** | `(62, 72)` to `(210, 216)` | `(62, 70)` to `(210, 214)` | 148×144 px | (136.0, 142.0) | Shifted up 2 px (matches frame) |
| **Player Health Orb** | `(41, 260)` to `(231, 450)` | `(46, 252)` to `(226, 432)` | **180×180 px** | (136.0, 342.0) | -10 px diameter, centered at x=136 |
| **Player Mana Orb** | `(41, 476)` to `(231, 666)` | `(46, 452)` to `(226, 632)` | **180×180 px** | (136.0, 542.0) | -10 px diameter, lifted 24 px upward |

### Spacing & Breathing Room Metrics
- **Centerline Alignment:** All three elements share exact horizontal axis `x = 136.0 px` (tolerance = 0.0 px).
- **Top Margin:** Panel visual crest to portrait frame visual top: `42.0 + 3.5 = 45.5 px` (comfortably clears panel crest).
- **Gap 1 (Portrait Frame $\rightarrow$ Health Orb):** `252.0 - 232.3 = 19.7 px`.
- **Gap 2 (Health Orb $\rightarrow$ Mana Orb):** `452.0 - 431.8 = 20.2 px`.
- **Gap Symmetry:** Optical difference $|19.7 - 20.2| = \mathbf{0.5\text{ px}}$.
- **Bottom Margin:** Mana orb visual bottom to panel bottom: `700.0 - 631.8 = \mathbf{68.2\text{ px}}$ (previously 34.2 px, a 100% increase in bottom breathing room!).
- **Bottom Metal Border Clearance:** Mana orb ends at $y = 631.8\text{ px}$, safely above the panel's bottom metal border which begins at $y = 638.0\text{ px}$.

---

## 3. Typography Changes

Typography inside `LiquidResourceOrb` when `housing_texture != null`:

| Property | R06C Baseline | R06D Refined | Rationale |
|---|---|---|---|
| **Values Base Font Size** | 38 px (`diameter * 0.20`) | **31 px** (`diameter * 0.17`) | Sits inside safe circular chord |
| **Values Auto-fit Target** | "30 / 30" $\rightarrow$ 38 px (121 px wide) | **"30 / 30" $\rightarrow$ 30 px (96 px wide)** | Eliminates crowding against inner glass rim |
| **Values Outline Size** | 3 px | **2 px** | Clean, crisp, AAA legibility |
| **Kind Font Size** | 21 px (`diameter * 0.11`) | **15 px** (`diameter * 0.085`) | Refined secondary caption scale |
| **Kind Outline Size** | 2 px | **1 px** | Delicate, non-competing border |
| **Kind Font Color** | `secondary` (`#bdb5a5`) | `secondary` (`#bdb5a5`) | Muted antique parchment tone |
| **Kind Box Bounds** | `y = 57.0..83.6 px` | `y = 54.0..77.4 px` | Balanced gap above numeric value |
| **Values Box Bounds** | `y = 83.6..133.0 px` | `y = 79.2..126.0 px` | Optically centered in lower aperture |
| **Safe-Area Margin** | < 2.5 px on left/right | **$\ge 11.8\text{ px}$ on left/right** | Generous liquid breathing space |

### Dynamic Values Evaluation at 180 px Diameter
- `30 / 30`: 30 px font size, 96.0 px width, 11.8 px clear margin on each side inside 119.5 px aperture.
- `18 / 30`: 30 px font size, 96.0 px width, 11.8 px clear margin on each side.
- `0 / 30`: 31 px font size, 81.0 px width, 19.3 px clear margin on each side.
- `1 / 1`: 31 px font size, 64.0 px width, 27.8 px clear margin on each side.
- `5 / 5`: 31 px font size, 64.0 px width, 27.8 px clear margin on each side.
- `10 / 10`: 30 px font size, 96.0 px width, 11.8 px clear margin on each side.
- `100 / 100`: Automatically scales to 24 px font size (104.0 px width), fits safely inside 114 px chord at $dy = 18\text{ px}$, and scales to exactly 16.0 physical pixels at 720p.

---

## 4. Before/After Comparison

Matched-size GPU captures comparing R06C and R06D:
- [Side-by-side 1080p HUD comparison](before_after_comparison_1080p.png)
- [Before 1080p HUD closeup (R06C)](player_hud_before_1080p.png)
- [After 1080p HUD closeup (R06D)](player_hud_after_1080p.png)
- [After 720p HUD closeup (R06D)](player_hud_after_720p.png)

Dedicated orb closeups:
- [HP 30 / 30 closeup](closeup_hp_30_30.png)
- [HP 100 / 100 closeup](closeup_hp_100_100.png)
- [Mana 1 / 1 closeup](closeup_mana_1_1.png)
- [Mana 10 / 10 closeup](closeup_mana_10_10.png)

---

## 5. Orb Fit and Spacing Validation

1. **Inner Circular Boundary Clearance:** The left "3" and right "0" of "30 / 30" sit comfortably within the glass aperture with over 11.8 px of unobstructed liquid space between the glyph outlines and the inner bronze bezel.
2. **Bottom Panel Clearance:** The Mana orb has 68.2 px of bottom breathing room, ending at $y = 631.8\text{ px}$, safely contained within the dark field of the panel.
3. **Typographic Group Balance:** The 15 px caption ("HP" / "MANA") and 30 px numerical value behave as a single harmonious typographic unit, optically centered in the aperture.
4. **Opponent Orb Invariance:** Procedural opponent orbs (`housing_texture == null`) retain their exact fallback typography.
5. **Screen Parity:** Outside reference $x = 320\text{ px}$, pixel differences are **zero at both 1080p and 720p**.

---

## 6. Test Results

Commands executed from repository root `D:/Dev/MagicOdyssey`:

| Command | Purpose | Result | Exit |
|---|---|:---:|:---:|
| `& $GodotExe --headless --path . --editor --import --quit` | Headless editor scan | Clean | 0 |
| `& $GodotExe --headless --path . --script res://scripts/tests/test_runner.gd` | Native headless test suite | **1553 / 1553 PASS** | 0 |
| `powershell scripts/tests/run_visual_regression.ps1` | ART-002 visual regression | **3 / 3 bit-exact (0 diff)** | 0 |
| `& $GodotExe --path . --script res://scripts/tests/capture_p005_r06d.gd` | GPU captures at 1080p & 720p | All captures PASS | 0 |
| `powershell scripts/build_windows.ps1` | Windows release export | Built `MagicOdyssey.exe` | 0 |
| `powershell scripts/tests/playtest_windows.ps1 -ReviewDir docs/art/reviews/p005-r06d -HandCount 10 -AnimateResources` | Desktop mouse playtest | 3/3 desktop windows PASS, ESC exit 0 | 0 |
| `git diff --check` | Formatting & whitespace integrity | Clean | 0 |

---

## 7. Recommendation

**APPROVE**

P005-R06D completely fixes the text crowding on "30 / 30", refines the secondary caption hierarchy, and restores generous bottom breathing room around the Mana orb. The Player Hero HUD is visually spacious, balanced, and AAA-polished.

Stop after P005-R06D. Do not proceed to any other task automatically.
