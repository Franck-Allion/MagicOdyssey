# ART-002-T02 — Master Card Frame v3 Visual Integration Review

**Date:** November 2026  
**Evaluation Scope:** Visual integration and verification of the rarity-neutral master card frame v3 (`mo_card_frame_master_v03.png`) in Godot 4.7.2 stable.  
**Evaluated Scene:** `res://scenes/ui/art002_card_integration_test.tscn`  
**Modified Script:** `res://scripts/presentation/art002_card_integration_test.gd`  
**Capture Script:** `res://docs/art/reviews/art002/capture.gd`  
**Engine & GPU Verified:** Godot 4.7.2.stable.official.ed1daf0bf, OpenGL API 3.3.0, NVIDIA GeForce GTX 1660 Ti  
**Recommendation:** **APPROVE_FRAME_FOR_PRODUCTION** (Frame asset validated; downstream presentation guidelines documented for P009).

---

## 1. Asset Specifications & Reproducibility

| Source Asset | Relative Path | Dimensions | Stored Mode & Bands | File Size | SHA-256 Checksum |
|---|---|---|---|---|---|
| **Master Frame v03 (New)** | `assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png` | 1086 × 1448 | RGBA `('R', 'G', 'B', 'A')` | 1,870,336 bytes | `937d2a3e3c099ec9830213c725025af250639032591ecc234f8e491068ced3e3` |
| **Master Frame v02 (Baseline)** | `assets/_source/lot1/cards/frames/mo_card_frame_master_v02.png` | 1086 × 1448 | RGB `('R', 'G', 'B')` | 2,237,662 bytes | `ce802a9e85b6f60aa500720ba6ed07087ed4c429224c54479d51b31e13d074d9` |
| **Test Illustration** | `assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png` | 1086 × 1448 | RGB `('R', 'G', 'B')` | 2,526,310 bytes | `71f87eb6bc0fb8d10da7286d47aacb1cae07236088afc04f2e6209d6738d50dc` |

Both previous v02 assets and all existing ART-002-T01 evidence were preserved unmodified for historical comparison.

---

## 2. Native RGBA & Pixel Transparency Verification

Pillow 12.1.1 inspected all pixels and metadata of `mo_card_frame_master_v03.png`. Unlike v02, which was a flat RGB image containing a painted checkerboard, **v03 contains a true 8-bit native alpha channel with 256 distinct levels (0–255)**.

### Alpha Distribution
- **Total Pixels:** 1,572,528
- **Fully Transparent (`alpha == 0`):** 648,383 pixels (41.23%) — covers the entire exterior silhouette and central aperture opening.
- **Antialiased Transitions (`1 <= alpha <= 239`):** 58,196 pixels (3.70%) — smooth gradient boundaries around card edges and aperture curves.
- **Opaque Structural Elements (`240 <= alpha <= 255`):** 865,949 pixels (55.07%) — dense, opaque borders, nameplate, rules panel, and socket interiors.

### Representative Pixel Coordinates & Sample Values

| Region | Coordinate $(x, y)$ | Stored RGBA | Native Alpha | Stored Interpretation |
|---|---|---|---|---|
| Outer top-left | $(0, 0)$ | $(0, 0, 0, 0)$ | $0 / 255$ | Fully transparent exterior |
| Outer top-right | $(1085, 0)$ | $(0, 0, 0, 0)$ | $0 / 255$ | Fully transparent exterior |
| Outer bottom-left | $(0, 1447)$ | $(0, 0, 0, 0)$ | $0 / 255$ | Fully transparent exterior |
| Outer bottom-right | $(1085, 1447)$ | $(0, 0, 0, 0)$ | $0 / 255$ | Fully transparent exterior |
| Outer mid-left | $(10, 724)$ | $(0, 0, 0, 0)$ | $0 / 255$ | Fully transparent exterior |
| Aperture center | $(543, 400)$ | $(0, 0, 0, 0)$ | $0 / 255$ | Fully transparent illustration opening |
| Aperture lower | $(543, 600)$ | $(0, 0, 0, 0)$ | $0 / 255$ | Fully transparent illustration opening |
| Left frame border | $(80, 600)$ | $(75, 91, 120, 253)$ | $253 / 255$ | Opaque metallic bronze/steel border |
| Right frame border | $(1000, 600)$ | $(31, 45, 70, 253)$ | $253 / 255$ | Opaque metallic border |
| Top frame border | $(543, 50)$ | $(45, 60, 78, 253)$ | $253 / 255$ | Opaque crest trim |
| Bottom frame border | $(543, 1400)$ | $(86, 70, 58, 253)$ | $253 / 255$ | Opaque footer filigree |
| Nameplate center | $(543, 130)$ | $(48, 60, 84, 253)$ | $253 / 255$ | Opaque nameplate backing |
| Rules panel center | $(543, 1000)$ | $(34, 39, 51, 253)$ | $253 / 255$ | Opaque rules panel backing |
| Rules panel left | $(200, 1050)$ | $(22, 25, 34, 252)$ | $252 / 255$ | Opaque rules panel backing |
| Mana socket interior | $(154, 156)$ | $(45, 47, 60, 253)$ | $253 / 255$ | Opaque mana socket |
| Attack socket interior | $(157, 1276)$ | $(42, 43, 55, 252)$ | $252 / 255$ | Opaque ATK socket |
| Health socket interior | $(934, 1276)$ | $(38, 41, 52, 253)$ | $253 / 255$ | Opaque HP socket |
| Aperture left boundary AA | $(127, 400)$ | $(34, 22, 13, 135)$ | $135 / 255$ | Clean antialiased border transition |
| Aperture right boundary AA | $(956, 400)$ | $(46, 32, 21, 133)$ | $133 / 255$ | Clean antialiased border transition |
| Aperture top boundary AA | $(543, 203)$ | $(27, 23, 20, 185)$ | $185 / 255$ | Clean curved arch transition |
| Aperture bottom boundary AA | $(543, 798)$ | $(192, 174, 153, 148)$ | $148 / 255$ | Clean curved bottom transition |

### Checkerboard Inspection
An exhaustive scan across all visible pixels (`alpha > 50`) and transparent pixels (`alpha == 0`) confirmed that **zero painted checkerboard pixels remain in the asset**. The aperture and card exterior are cleanly transparent $(0, 0, 0, 0)$, and no halo or high-frequency pixel grid exists.

---

## 3. Removal of Temporary Chroma-Key Shader

In `scripts/presentation/art002_card_integration_test.gd`:
1. Deleted `PREVIEW_SHADER` canvas item fragment code.
2. Deleted `_frame_material: ShaderMaterial` declaration.
3. Deleted shader compilation and material instantiation from `_ready()`.
4. Removed `frame.material = _frame_material` assignment from `_card()`.
5. Pointed `const FRAME` to `res://assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png`.

Godot now renders the card frame using native alpha transparency through standard `CanvasItem` GPU alpha blending (`SRC_ALPHA, ONE_MINUS_SRC_ALPHA`).

---

## 4. Visual Comparison: v02 vs v03

| Feature | v02 (Temporary Chroma-Key Preview) | v03 (Native RGBA Master Candidate) | Verdict |
|---|---|---|:---:|
| **Transparency Pipeline** | RGB with painted checkerboard; runtime chroma-key shader keying near-white pixels. | Native 8-bit RGBA alpha channel (`alpha == 0` aperture & exterior). Standard Godot blending. | **RESOLVED** |
| **Aperture Edge Quality** | Jagged fringes, slight color fringe artifacts from keying threshold near boundary. | Smooth sub-pixel antialiased alpha gradient ($133..185 / 255$). Zero fringing. | **RESOLVED** |
| **Color Neutrality** | Bright violet footer gem (`[194, 68, 212]`) and purple cloth (`[132, 118, 119]`) clashed with Common/Uncommon/Rare/Legendary. | Neutralized to deep midnight-blue (`[84, 116, 156]`), steel, and bronze. Supports all 5 rarities cleanly. | **RESOLVED** |
| **Rules Panel Opacity** | Dependent on shader bounding box. | Native solid backing (`alpha = 252-253`). Perfect contrast for text. | **RESOLVED** |
| **Socket Opacity** | Dependent on shader bounding box. | Native solid backing (`alpha = 252-253`) for Mana, ATK, and HP sockets. | **RESOLVED** |

---

## 5. Composition Geometry & Illustration Fit

The test composition geometry was preserved identically:
- **Card Base Dimensions:** $1086 \times 1448$ px.
- **Illustration Aperture Control:** `position = Vector2(124, 207)`, `size = Vector2(838, 642)` with `clip_contents = true`.
- **Illustration Region:** Top $1086 \times 900$ region with `TextureRect.STRETCH_KEEP_ASPECT_COVERED`.
- **Alignment:** Arcane Knight helmet, armored shoulder, chest plate, and glowing spell hand are well positioned within the opening. The opaque curved frame borders overlap the rectangular clipping boundary cleanly with zero bleed into nameplate or rules text.

---

## 6. Visual Quality Across Test Modes

### Mode 0 — Single Card (1080p Inspection)
- **Rendered Size:** $570 \times 760$ px ($52.5\%$ master scale) at $(460, 225)$.
- **Typography & Ergonomics:**
  - Card Title ("Arcane Knight"): $35.7$ px — crisp, prominent.
  - Mana ("4"): $57.7$ px — commanding in socket.
  - Type & Tribe ("Creature · Human"): $25.7$ px — clean gold accent.
  - Rules Text: $28.3$ px — comfortably legible with high contrast against the dark rules panel.
  - Base Stats (ATK "4" / HP "5"): $56.7$ px — distinct, authoritative.
  - Captions ("ATK" / "HP"): $16.8$ px — neat secondary label.
- **Visual Feel:** Premium dark fantasy aesthetic with metallic bronze filigree, deep slate steel panels, and midnight-blue jewel elements.

### Mode 1 — Seven-Card Hand (1080p and 720p)
- **1080p Viewport ($1920 \times 1080$):**
  - Card Dimensions: $237 \times 316$ px; 16 px gap; $82.5$ px horizontal margins.
  - Hand spans $x = 82.5$ to $1837.5$, $y = 586$ to $902$. Fits entirely within viewport without clipping or overlap.
  - Mana ($24$ px) and ATK/HP ($23.6$ px) are instantly recognizable across the entire hand.
  - Titles ($14.8$ px) are readable.
  - Rules text ($11.8$ px) is readable with focused inspection.
- **720p Viewport ($1280 \times 720$):**
  - Card Dimensions: $158 \times 210.7$ px; $10.7$ px gap; $55$ px horizontal margins.
  - Hand fits completely with zero silhouette clipping.
  - Mana ($16$ px) and ATK/HP ($15.7$ px) remain clear tactical scan targets.
  - Titles ($9.9$ px) are distinguishable for known cards.
  - Rules text ($7.9$ px) is small and not comfortably readable at speed.
  - **Normative Alignment:** This is fully consistent with Decisions Q133/Q134. In digital card games, hand cards serve as tactical overview tokens; full rules text is read via hover-lift / inspection panel.

### Mode 2 — Five Rarities (1080p)
- **Rendered Cards:** 5 cards at $319.5 \times 426$ px, positioned across $x = 104$ to $1823.5$.
- **Rarity Verification:**
  - Common: Crisp White (`#F3F4F6`).
  - Uncommon: Sapphire Blue (`#3B82F6`).
  - Rare: Ruby Red (`#EF4444`).
  - Epic: Amethyst Violet (`#A855F7`).
  - Legendary: Radiant Amber Gold (`#F59E0B`).
- **Neutrality:** The neutralized bronze and midnight-blue foundation in v03 does not fight with any rarity color. Each rarity ribbon and label reads clearly without chromatic dissonance.

---

## 7. Real Screenshot Evidence

All screenshots were captured from the real Godot renderer on the NVIDIA GTX 1660 Ti via `capture.gd`:

| Image File | Viewport | Mode | Description |
|---|:---:|:---:|---|
| [single_card_1080p.png](single_card_1080p.png) | 1920 × 1080 | Mode 0 | Full-size inspection fixture; native alpha; Arcane Knight. |
| [hand_7_cards_1080p.png](hand_7_cards_1080p.png) | 1920 × 1080 | Mode 1 | Seven-card linear hand at 1080p; full silhouettes; 16 px gaps. |
| [hand_7_cards_720p.png](hand_7_cards_720p.png) | 1280 × 720 | Mode 1 | Seven-card linear hand at minimum responsive resolution 720p. |
| [rarity_samples_1080p.png](rarity_samples_1080p.png) | 1920 × 1080 | Mode 2 | All five rarity identities over the neutral master frame. |

---

## 8. Technical Verification Commands & Results

All verification steps executed cleanly against Godot 4.7.2 stable:

```powershell
$Godot = 'D:\Temp\Godot_v4.7.2-stable_win64.exe'

# 1. Headless editor import
Start-Process -FilePath $Godot -ArgumentList "--headless --editor --path D:\Dev\MagicOdyssey --import" -Wait

# 2. Native headless test runner
Start-Process -FilePath $Godot -ArgumentList "--headless --path D:\Dev\MagicOdyssey --script res://scripts/tests/test_runner.gd" -Wait

# 3. Headless ART-002 scene launch
Start-Process -FilePath $Godot -ArgumentList "--headless --path D:\Dev\MagicOdyssey res://scenes/ui/art002_card_integration_test.tscn --quit-after 5" -Wait

# 4. Graphical SubViewport captures
$runs = @(
    @('single_card_1080p.png', '1920', '1080', '0'),
    @('hand_7_cards_1080p.png', '1920', '1080', '1'),
    @('hand_7_cards_720p.png',   '1280', '720',  '1'),
    @('rarity_samples_1080p.png', '1920', '1080', '2')
)
foreach ($r in $runs) {
    Start-Process -FilePath $Godot -ArgumentList "--path D:\Dev\MagicOdyssey --script res://docs/art/reviews/art002/capture.gd -- D:/Dev/MagicOdyssey/docs/art/reviews/art002/v03/$($r[0]) $($r[1]) $($r[2]) --mode=$($r[3])" -Wait
}

# 5. Git diff check
git diff --check
```

### Execution Log Summary

| Verification Step | Target / Command | Result Output | Exit Code |
|---|---|---|:---:|
| Headless Editor Import | `Godot --import` | `mo_card_frame_master_v03.png.import` generated cleanly | **0** |
| Test Harness Regression | `res://scripts/tests/test_runner.gd` | `Total Assertions: 14; Passed: 14; Failed: 0; ALL TESTS PASSED` | **0** |
| Headless Scene Launch | `res://scenes/ui/art002_card_integration_test.tscn` | 5 frames elapsed, no errors or warnings | **0** |
| Graphical Capture: Single 1080p | Mode 0 (1920 × 1080) | `ART002_CAPTURE size=(1920, 1080) ... result=0` | **0** |
| Graphical Capture: Hand 1080p | Mode 1 (1920 × 1080) | `ART002_CAPTURE size=(1920, 1080) ... result=0` | **0** |
| Graphical Capture: Hand 720p | Mode 1 (1280 × 720) | `ART002_CAPTURE size=(1280, 720) ... result=0` | **0** |
| Graphical Capture: Rarities 1080p | Mode 2 (1920 × 1080) | `ART002_CAPTURE size=(1920, 1080) ... result=0` | **0** |
| Whitespace & Conflict Check | `git diff --check` | Clean, zero issues | **0** |

---

## 9. Remaining Production Limitations & Downstream Guidelines for P009

The master frame asset `mo_card_frame_master_v03.png` is technically sound and approved for production use. The following guidelines should be referenced during P009 (`CardView` & `HandView`):

1. **Aperture Top Arc Geometry:**
   - The arched opening at the top of the aperture reaches $y = 204$ along the centerline ($x = 543$).
   - The test fixture used an aperture at $(124, 207)$ with height $642$. In production `CardView`, configuring the portrait viewport at $(124, 204)$ with size $(838, 646)$ provides complete coverage up to the apex of the curved metal arch.
2. **Hand-Scale Readability & Inspection System:**
   - At 720p hand scale, rules text renders at $\approx 7.9$ physical pixels. While mana and stat sockets remain immediately distinguishable, full card rules must be inspected via the hover-lift / inspection panel (normative decisions Q133/Q134).
3. **Card-Level Rarity Treatments:**
   - The neutral bronze/midnight-blue base frame effectively supports external rarity tinting, ribbons, or shader-driven border highlights in production without requiring separate baked frame textures per rarity.

---

## 10. Conclusion & Final Recommendation

**Recommendation:** **APPROVE_FRAME_FOR_PRODUCTION**

The new v03 card frame successfully resolves all issues flagged in ART-002-T01:
- True native RGBA transparency eliminates the temporary chroma-key shader.
- Edges and aperture boundaries are smoothly antialiased without artifacts.
- Reworked neutral midnight-blue/steel/bronze palette provides a legitimate rarity-neutral master for the entire card catalog.
