# P005-R06C — Player HUD Final Harmony & Typography Polish

Date: 2026-11-15. Godot 4.7.2 stable; Windows 11; OpenGL Compatibility; NVIDIA GeForce GTX 1660 Ti.

**Recommendation: APPROVE (or KEEP_WITH_ADJUSTMENTS pending owner live feel review). Stop after R06C; P005-R07A remains untouched.**

---

## 1. Summary

P005-R06C completes the visual and typographic refinement of the integrated Player Hero HUD delivered in P005-R06B without altering approved source PNG assets, redesigning components, or introducing heavy shader pipelines.

Key achievements:
- **Bronze & Material Harmony:** Applied a restrained, presentation-level color modulation (`housing_modulate = Color(0.88, 0.86, 0.85, 1.0)`) exclusively to the player orb housing `TextureRect` instances. This tempers the overly bright, saturated golden highlights by ~6–7% and brings them into the same antique-bronze family as the portrait frame and backplate, while preserving material depth, specular highlights, sculpted metal detail, and blue gemstone accents. The dynamic liquid reservoir, glass reflections, and text labels are completely unmodulated.
- **Vertical Composition & Optical Balance:** Harmonized vertical spacing across the 272×700 px player HUD panel. Visual gaps between the portrait frame's bottom silhouette and the Health orb's top silhouette (**25.7 px**) and between the Health orb and Mana orb (**26.2 px**) are now balanced to within 0.5 px of optical symmetry (previously 19.7 px vs 28.2 px, an 8.5 px asymmetry). All three elements preserve their exact horizontal centerline at `x = 136.0 px`.
- **AAA Resource Typography:** Refined the label hierarchy inside the glass aperture. Main numerical values remain the prominent focal point (~38 px at 1080p reference, `text_bright` color, outline reduced from 5 px to 3 px). "HP" / "MANA" secondary captions are reduced from 26 px to 21 px with a delicate 2 px outline and muted `secondary` parchment color. The combined typographic group is optically centered at `y = 95.0 px` (the exact geometric center of the 190 px orb), leaving balanced 32 px breathing margins top and bottom inside the glass aperture.
- **Preserved Fallback & Screen Parity:** Procedural opponent orbs (`housing_texture == null`) retain their exact fallback typography. Outside the player HUD column (`x >= 320 px`), combat screen rendering is **100% bit-exact (0 differing pixels)** at both 1080p and 720p.
- **Full Test Suite & Standalone Verification:** Native headless assertions increased from 1532 to **1548 passed (0 failed)**. ART-002 golden comparisons remain **3/3 bit-exact**. Standalone Windows executable verified across default, 1080p, and 720p desktop modes with real OS pointer hover and ESC exit code 0.

---

## 2. Original R06B Findings

The P005-R06B review successfully verified technical integration of the three approved ART-003 assets (portrait frame, shared orb housing, and dark backplate), but identified three visual friction points:
1. **Material Contrast:** The shared orb housing artwork appeared noticeably brighter and more saturated golden-yellow than the deeper antique bronze of the portrait frame and backplate. Bright highlights and saturated gemstones drew excessive visual attention away from the hero portrait and tactical board.
2. **Vertical Compression:** The bounding box gap between portrait frame and Health orb was 10 px (silhouette gap 19.7 px), while the gap between Health and Mana was 28 px (silhouette gap 28.2 px), creating a compressed upper section and an uneven vertical rhythm.
3. **Typography Prominence & Centering:** Orb captions ("HP" / "MANA") were 26 px with heavy 4 px dark outlines in bright white, competing with the numeric value. The numeric value sat at `y = 100.7 px` (5.7 px below aperture center) while the caption was pushed against the upper glass rim, causing the combined group to feel visually top-heavy.

---

## 3. Exact Geometry Changes

All modifications remain within `CombatLayout/PlayerHeroZone` (`offset_left = 24.0, offset_top = 220.0, offset_right = 296.0, offset_bottom = 920.0`, panel size 272×700 px):

| Element | R06B Position | R06C Position | Size | Center (X, Y) | Change Notes |
|---|---|---|---|---|---|
| **Backplate** | `(0, 0)` to `(272, 700)` | `(0, 0)` to `(272, 700)` | 272×700 px | (136.0, 350.0) | Unchanged uniform crop |
| **Portrait Frame** | `(36, 46)` to `(236, 246)` | `(36, 44)` to `(236, 244)` | 200×200 px | (136.0, 144.0) | Shifted up 2 px |
| **Portrait Illustration** | `(62, 74)` to `(210, 218)` | `(62, 72)` to `(210, 216)` | 148×144 px | (136.0, 144.0) | Shifted up 2 px (matches frame) |
| **Player Health Orb** | `(41, 256)` to `(231, 446)` | `(41, 260)` to `(231, 450)` | 190×190 px | (136.0, 355.0) | Shifted down 4 px |
| **Player Mana Orb** | `(41, 474)` to `(231, 664)` | `(41, 476)` to `(231, 666)` | 190×190 px | (136.0, 571.0) | Shifted down 2 px |

### Optical Silhouette Balance Metrics
- **Centerline:** All three elements share exact horizontal axis `x = 136.0 px` (tolerance = 0.0 px).
- **Top Margin:** Panel visual crest to portrait frame visual top: `44.0 + 3.5 = 47.5 px` (comfortably clears panel crest).
- **Gap 1 (Portrait Frame $\rightarrow$ Health Orb):** `260.0 - 234.3 = 25.7 px`.
- **Gap 2 (Health Orb $\rightarrow$ Mana Orb):** `476.0 - 449.8 = 26.2 px`.
- **Gap Symmetry:** Optical difference $|25.7 - 26.2| = \mathbf{0.5\text{ px}}$ (previously 8.5 px asymmetry).
- **Bottom Margin:** Mana orb visual bottom to panel bottom: `700.0 - 665.8 = 34.2 px`.

---

## 4. Typography Adjustments

Typography inside `LiquidResourceOrb` when `housing_texture != null` was redesigned as a cohesive, optically centered typographic unit:

| Property | R06B Baseline | R06C Refined | Rationale |
|---|---|---|---|
| **Values Font Size** | 39 px (`diameter * 0.205`) | **38 px** (`diameter * 0.20`) | Refined focal proportion |
| **Values Font Color** | `text_bright` (`#fff8e6`) | `text_bright` (`#fff8e6`) | Main visual focal point |
| **Values Outline** | 5 px (`background`) | **3 px** (`background`) | Crisp, eliminates muddy heavy border |
| **Values Box Bounds** | `y = 76.0..125.4 px` | `y = 83.6..133.0 px` | Centered in lower aperture |
| **Kind Font Size** | 26 px (`diameter * 0.135`) | **21 px** (`diameter * 0.11`) | Elegant secondary caption scale |
| **Kind Font Color** | `text_bright` (`#fff8e6`) | **`secondary`** (`#bdb5a5`) | Soft antique parchment; avoids competing with numbers |
| **Kind Outline** | 4 px (`background`) | **2 px** (`background`) | Delicate, legible, non-distracting |
| **Kind Box Bounds** | `y = 47.5..85.5 px` | `y = 57.0..83.6 px` | Pushed down from upper rim; unified group |
| **Group Optical Center** | `y = 85.0 px` (top-heavy) | **`y = 95.0 px`** (exact center) | Perfect alignment with 190 px orb aperture center |
| **Top / Bottom Margins** | 15 px top / 42 px bottom | **32 px top / 32 px bottom** | Symmetrical aperture breathing room |

Dynamic values test results:
- `30 / 30`: 38 px font size, full outline clearance.
- `18 / 30`: 38 px font size, full outline clearance.
- `0 / 30`: 38 px font size, full outline clearance.
- `100 / 100`: Automatically fitted to 24 px, leaves 8 px internal clearance.
- `1 / 1`: 38 px font size, full outline clearance.
- `10 / 10`: 38 px font size, full outline clearance.
- 720p scaling: Font size $\ge 16$ physical pixels across all values (38 px $\times 2/3 = 25.3$ px; 24 px $\times 2/3 = 16.0$ px).

---

## 5. Bronze Modulation Details

To resolve material hierarchy without altering the source PNG asset or adding a dedicated shader:
- Added `@export var housing_modulate: Color = Color.WHITE` to `LiquidResourceOrb`.
- Configured `housing_modulate = Color(0.88, 0.86, 0.85, 1.0)` on `PlayerHealthOrb` and `PlayerManaOrb`.
- Applied exclusively to `($Housing as TextureRect).modulate`.

### Measured Radiometric Impact
- **Portrait Frame Mean RGB (opaque):** `[94.1, 72.1, 55.1]` (brightness 73.8).
- **Orb Housing Unmodulated Mean RGB:** `[143.2, 98.2, 61.3]` (brightness 100.9).
- **Orb Housing Modulated Mean RGB:** `[126.0, 84.5, 52.1]` (brightness 87.5).
- **Material Hierarchy:**
  - Backplate: darkest backing (`[26, 33, 42]`).
  - Portrait frame: medium antique bronze (brightness 73.8).
  - Orb housings: slightly elevated bronze accent (brightness 87.5).
  - Liquid reservoir: unmodulated, dynamic focal colors (HP red `#c23b3b`, Mana blue `#3e6fe0`).

---

## 6. Before/After Comparisons

Matched-size GPU captures comparing R06B and R06C:
- [Side-by-side 1080p HUD comparison](before_after_comparison_1080p.png)
- [Before 1080p HUD closeup (R06B)](player_hud_before_1080p.png)
- [After 1080p HUD closeup (R06C)](player_hud_after_1080p.png)
- [After 720p HUD closeup (R06C)](player_hud_after_720p.png)

---

## 7. 1080p Review

- [Full 1080p CombatScreen](combat_screen_1080p.png)
- [Values 30 HP / 1 Mana](values_1080p_hp30_mana1.png)
- [Values 18 HP / 5 Mana](values_1080p_hp18_mana5.png)
- [Values 0 HP / 0 Mana](values_1080p_hp0_mana0.png)
- [Values 100 HP / 10 Mana](values_1080p_hp100_mana10.png)

At 1080p:
- The bronze of the orb housings visually belongs to the portrait metalwork.
- Gaps between Portrait, Health, and Mana are optically indistinguishable.
- Numbers are immediately legible at a glance; secondary captions are quiet and refined.
- Zero change outside reference $x = 320\text{ px}$.

---

## 8. 720p Review

- [Full 720p CombatScreen](combat_screen_720p.png)
- [720p HUD closeup](player_hud_after_720p.png)
- [Values 720p 30 HP / 1 Mana](values_720p_hp30_mana1.png)
- [Values 720p 100 HP / 10 Mana](values_720p_hp100_mana10.png)

At 720p:
- Proportional scaling preserves identical optical balance.
- 24 px minimum 1080p font size scales to 16.0 physical pixels, satisfying legibility invariants.
- Captions remain clear without muddy outlines.

---

## 9. Native Test Results

Commands executed from repository root `D:/Dev/MagicOdyssey`:

| Command | Purpose | Result | Exit |
|---|---|:---:|:---:|
| `& $GodotExe --headless --path . --editor --import --quit` | Headless editor scan | Clean | 0 |
| `& $GodotExe --headless --path . --script res://scripts/tests/test_runner.gd` | Native headless test suite | **1548 / 1548 PASS** | 0 |
| `powershell scripts/tests/run_visual_regression.ps1` | ART-002 visual regression | **3 / 3 bit-exact (0 diff)** | 0 |
| `& $GodotExe --path . --script res://scripts/tests/capture_p005_r06c.gd` | GPU captures at 1080p & 720p | All captures PASS | 0 |
| `powershell scripts/build_windows.ps1` | Windows release export | Built `MagicOdyssey.exe` | 0 |
| `powershell scripts/tests/playtest_windows.ps1 -ReviewDir docs/art/reviews/p005-r06c -HandCount 10 -AnimateResources` | Desktop mouse playtest | 3/3 desktop windows PASS, ESC exit 0 | 0 |
| `git diff --check` | Formatting & whitespace integrity | Clean | 0 |

---

## 10. Windows Standalone Verification

- Executable path: `build/windows/MagicOdyssey.exe`
- Tested across default (1888×956), 1920×1080 borderless, and 1280×720 borderless desktop modes.
- Verified real pointer hover across the 10-card hand, animated resource sloshing, and clean exit on ESC with exit code 0.
- Zero leftover processes or warnings reported.

---

## 11. Known Limitations

1. **Opponent HUD:** The opponent area retains its procedural orbs and temporary layout pending `P005-R07A`/`B`.
2. **Utility HUD:** Deck/graveyard and turn controls remain in their preliminary layout pending `P005-R08A`/`B`.
3. **Gameplay Domain Binding:** HUD values are presentation samples; live engine event binding occurs in `P007`/`P033`.

---

## 12. Recommendation

**APPROVE**

P005-R06C successfully resolves the owner's feedback regarding bronze material harmony, vertical optical balance, and typography refinement. The player hero HUD is cohesive, balanced, and readable.

Stop after P005-R06C. Do not proceed to P005-R07A automatically.
