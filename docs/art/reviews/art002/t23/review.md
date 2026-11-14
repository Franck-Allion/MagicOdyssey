# ART-002-T23 — Integrated Armor & Shield Plaque Inlays Review

2026-11-14 · **PASS** (Technical Verification & Geometric Integration) · Artistic Status: **RECOMMENDATION: SUBMIT FOR OWNER FINAL SIGN-OFF**.

This review documents the integration of dedicated Armor and Shield plaque inlays into the existing bottom-center stat plate slots of the master card frame (`mo_card_frame_master_v03.png`). This extends the preferred inlay direction established in ART-002-T20 (Attack graphite steel and Health crimson ruby circular inlays) to Armor and Shield, replacing the legacy small floating mini-icons with material plaque inserts seated naturally inside the bronze plate slots.

The implementation preserves the existing master-frame bronze badge structure, card geometry, typography, and inactive-socket behavior, while providing clean optical scale, zero border overlap, centered numeral focus, and instant rollback capability.

---

## 1. Executive Summary & Deliverables

| Deliverable | Path | Status | Observations |
|---|---|:---:|---|
| **Plaques Closeup (1080p)** | `docs/art/reviews/art002/t23/armor_shield_plaques_closeup_1080p.png` | **VERIFIED** | Macro zoom of Armor (protective steel) and Shield (arcane blue ward) inlays seated inside bronze slots. |
| **Before / After Comparison (1080p)** | `docs/art/reviews/art002/t23/before_after_armor_shield_1080p.png` | **VERIFIED** | Side-by-side card and macro zoom comparing T11 floating mini-icons vs T23 integrated plaque inlays. |
| **Inspection View (1080p)** | `docs/art/reviews/art002/t23/inspected_card_1080p.png` | **VERIFIED** | Clean production card inspection view (Emerald Epic Arcane Knight) with all 4 stats and plaques active. |
| **Gameplay Hand (1080p)** | `docs/art/reviews/art002/t23/seven_card_hand_1080p.png` | **VERIFIED** | Seven-card mixed hand at 1080p scale (height 316 px): 5 creatures, 1 spell, 1 equipment with inactive sockets. |
| **Secondary Hand (720p)** | `docs/art/reviews/art002/t23/seven_card_hand_720p.png` | **VERIFIED** | Seven-card mixed hand at 720p play scale (height 210 px) verifying numeral legibility. |
| **Full Combat Interface (1080p)** | `docs/art/reviews/art002/t23/full_combat_1080p.png` | **VERIFIED** | Full in-game combat screen at 1920×1080 with Sundered Observatory background, HUD, grid, and hand. |
| **Mixed Stats Examples (1080p)** | `docs/art/reviews/art002/t23/mixed_stats_examples_1080p.png` | **VERIFIED** | 8-card matrix verifying single digits, double digits, zero protection hiding, and stress testing up to 99/99. |
| **Automated Regression Suite** | `docs/art/reviews/art002/t23/plaque_regression.gd` | **PASS (30/30)** | Texture loading, transparent corners, calibrated constants, usable area clearance, and rollback flags. |
| **Asset Preparation Tool** | `docs/art/reviews/art002/t23/prepare_assets.py` | **PASS** | Alpha threshold zeroing (<5), tight bounding-box cropping with safety padding, and Lanczos downsampling. |

---

## 2. Source and Runtime Asset Mappings

Source assets provided under `assets/_source/lot1/cards/icons/` were inspected, cleaned of sub-threshold alpha artifacts, and downsampled using Lanczos filtering into optimized runtime textures under `assets/textures/cards/icons/`. Source files remain completely unmodified.

| Asset Role | Source File (Unmodified) | Runtime File (Optimized) | Source Size | Runtime Size | Aspect Ratio | Color / Material Identity |
|---|---|---|:---:|:---:|:---:|---|
| **Armor Plaque** | `mo_stat_plate_armor_v01.png` | `mo_plate_armor.png`<br>`mo_plate_armor_v01.png` | $1774 \times 887\text{ px}$ | $512 \times 177\text{ px}$ | $2.892$ | Dense steel / dark metal protective cartouche (Mean RGB: 80.6, 76.4, 75.4) |
| **Shield Plaque** | `mo_stat_plate_shield_v01.png` | `mo_plate_shield.png`<br>`mo_plate_shield_v01.png` | $1774 \times 887\text{ px}$ | $512 \times 197\text{ px}$ | $2.599$ | Deep arcane azure ward cartouche (Mean RGB: 10.5, 54.2, 107.8) |

### Asset Preparation Highlights
1. **Clean Alpha Thresholding:** The raw source files contained faint compression residue with $\alpha \in [1, 4]$ across the outer canvas ($25{,}887$ pixels in Armor, $18{,}877$ in Shield). Sub-threshold alpha $< 5$ was zeroed, resulting in $100\%$ transparent outer canvas with strictly $[0, 0, 0, 0]$ corner verification.
2. **Visual Bounds & Centering:** Where $\alpha \ge 5$, the visible plaque bounds measure $1320 \times 452\text{ px}$ (Armor) and $1567 \times 597\text{ px}$ (Shield). Both plaques are naturally centered within $0.5\text{ px}$ of horizontal center and $1.5\text{ px}$ of vertical center.
3. **Padded High-Quality Downsampling:** A $4\text{ px}$ transparent safety margin was applied around the tight crop prior to Lanczos downsampling to $512\text{ px}$ width, ensuring that mipmap generation and bilinear texture filtering have clean zero-alpha outer boundaries without edge clamping.
4. **Anisotropic Mipmaps Enabled:** Both runtime texture `.import` files were configured with `mipmaps/generate=true` and `process/fix_alpha_border=true`, matching the approved T21 rendering pipeline.

---

## 3. Existing Geometry and Usable Inner Area

The master card frame geometry (`mo_card_frame_master_v03.png`, $1086 \times 1448\text{ px}$) provides dedicated auxiliary stat display slots at the bottom center:
- **Armor Slot Bounds:** $\text{Rect2}(280, 1280, 198, 100)$, Center: $(379, 1330)$
- **Shield Slot Bounds:** $\text{Rect2}(608, 1280, 198, 100)$, Center: $(707, 1330)$

### Slot Usable Area Measurement

| Feature | Dimension | Specification | Notes |
|---|:---:|---|---|
| **Outer Bounds** | $198 \times 100\text{ px}$ | $\text{Rect2}(280, 1280, 198, 100)$ / $\text{Rect2}(608, 1280, 198, 100)$ | Preserved exactly from T04/T06 baseline. |
| **Bronze Outer Border** | $3.0\text{ px}$ | `accent_dim` ($\text{Color}(0.471, 0.388, 0.247)$) | Solid sculpted bronze boundary of the plate slot. |
| **Corner Radius** | $23.0\text{ px}$ | `corner_radius_all(23)` | Rounded outer corners of the bronze frame. |
| **Drop Shadow** | $6.0\text{ px}$ | `shadow_color = Color(0, 0, 0, 0.7)` | Cast shadow underneath the bronze badge. |
| **Inner Usable Area** | $192 \times 94\text{ px}$ | $[3, 195] \times [3, 97]$ relative to slot origin | Cavity interior inside the $3\text{ px}$ bronze border. |
| **Inner Corner Radius** | $20.0\text{ px}$ | $23.0 - 3.0 = 20.0\text{ px}$ | Geometric inner corner arc. |
| **Top Highlight Line** | $2.0\text{ px}$ | $y = +3\text{ px}$ from top edge, $x \in [24, 174]$ | Warm metallic glint (`accent` token). |

---

## 4. Layering and Presentation Architecture

In accordance with the physical collet setting architecture ratified in ART-002-T20, the plaque badges follow a strictly ordered 4-layer composition:

```
┌─────────────────────────────────────────────────────────────────┐
│ Layer 4: White Stat Numerals (TacticalNumber 76 pt, Center)     │
│          • Centered at BADGE_PLAQUE_NUMBER_LOCAL_CENTER (99, 50)│
│          • Max width 83 px, 3 px dark outline, bright ivory     │
├─────────────────────────────────────────────────────────────────┤
│ Layer 3: Master-Frame Bronze Highlights & Border                │
│          • StyleBoxFlat 3 px bronze border (accent_dim)         │
│          • Top inner metallic highlight line (accent, y=+3 px)  │
├─────────────────────────────────────────────────────────────────┤
│ Layer 2: Plaque Inlay Material (180 px unified width)           │
│          • Armor: mo_plate_armor.png (180×62 px, Steel)         │
│          • Shield: mo_plate_shield.png (180×69 px, Arcane Ward) │
│          • Seated cleanly inside inner cavity; zero spill       │
├─────────────────────────────────────────────────────────────────┤
│ Layer 1: Slot Base & Drop Shadow (StyleBoxFlat)                 │
│          • Dark floor Color(12, 16, 24, 1.0)                    │
│          • 6 px ambient drop shadow                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. Scale and Optical Alignment Decisions

### A. Plaque Sizing Calibration
The inner cavity measures $192 \times 94\text{ px}$. To create an authentic inlaid appearance rather than an edge-to-edge decal, the plaque must preserve breathing room from the inner bronze border:
- **Unified Width:** Both plaques are calibrated to **$180.0\text{ px}$ width**, establishing identical horizontal baseline span across both footer slots.
- **Armor Plaque Dimensions:** $180 \times 62\text{ px}$ (aspect ratio $2.892$).
  - Horizontal margin: $(192 - 180) / 2 = \mathbf{6.0\text{ px}}$ on left and right.
  - Vertical margin: $(94 - 62) / 2 = \mathbf{16.0\text{ px}}$ on top and bottom.
  - Pixel spill beyond inner border: **$0\text{ px}$** ($100\%$ contained).
- **Shield Plaque Dimensions:** $180 \times 69\text{ px}$ (aspect ratio $2.599$).
  - Horizontal margin: $(192 - 180) / 2 = \mathbf{6.0\text{ px}}$ on left and right.
  - Vertical margin: $(94 - 69) / 2 = \mathbf{12.5\text{ px}}$ on top and bottom.
  - Pixel spill beyond inner border: **$0\text{ px}$** ($100\%$ contained).

### B. Visual Mass Balance
At $180\text{ px}$ width:
- Armor active pixels: $10{,}091\text{ px}$.
- Shield active pixels: $11{,}010\text{ px}$.
The two plaques are balanced within $9\%$ total visual mass. Armor reads as dense, compact protective metal; Shield reads as an elegant, slightly taller arcane ward.

### C. Numeral Placement & Legibility
In the legacy T11 layout, the numeral was offset to local $(140, 50)$ to accommodate the $52\text{ px}$ floating icon on the left. With the integrated plaque becoming the internal face, the numeral is repositioned to **$\text{local }(99, 50)$** (the exact slot center):
- **Font & Size:** `TacticalNumber` at $76\text{ pt}$, maximum width $83.0\text{ px}$.
- **Glyph Bounds:** At $76\text{ pt}$, single digits span $35\text{ px} \times 54\text{ px}$; double digits up to $99$ span $74\text{ px} \times 54\text{ px}$. All values fit within the $83\text{ px}$ cap without downscaling.
- **Contrast:** High-contrast ivory text (`text_bright`, RGB $255, 248, 230$) with a $3\text{ px}$ deep shadow outline (`background`, RGB $12, 16, 24$) renders with complete clarity over both dark steel and deep azure backgrounds.
- **Subordination:** Primary Attack and Health numerals use $126\text{ pt}$ font inside $R = 70\text{ px}$ circular collets. Secondary Armor and Shield numerals use $76\text{ pt}$ inside rectangular slots, maintaining unambiguous visual hierarchy.

---

## 6. Rollback and Backward Compatibility

To ensure zero risk to approved production workflows and allow instantaneous visual comparison, the legacy presentation logic is preserved in full:
- **`CardStatOverlay.use_plaque_inlays` (default `true`):** Controls whether plaque inlays are rendered. When set to `false`, `_badge()` immediately falls back to the T11 floating-icon logic.
- **`CardStatOverlay.use_separate_icons`:** Preserved for backward compatibility. Setting `use_separate_icons = true` or `presentation_mode = 2` automatically routes to legacy mini-icons.
- **Historical Constants Preserved:** `BADGE_ICON_LOCAL_CENTER = Vector2(50, 50)`, `BADGE_NUMBER_LOCAL_CENTER = Vector2(140, 50)`, `ARMOR_ICON_SIZE = Vector2(52, 52)`, and `SHIELD_ICON_SIZE = Vector2(50, 50)` remain untouched in code for deterministic rollback.

---

## 7. Visual Assessment at 1920×1080 (16:9)

Visual evaluation was conducted on real GPU renders across all 6 required review captures:

1. **`armor_shield_plaques_closeup_1080p.png`:**
   - Both plaque inlays seat naturally inside their bronze collets with clean breathing room.
   - Armor reads clearly as dark protective steel; Shield reads clearly as deep azure energy.
   - Zero pixel spill or clipping against the $3\text{ px}$ bronze border.
   - White numerals '2' and '1' are crisp and centered.

2. **`before_after_armor_shield_1080p.png`:**
   - Directly demonstrates the visual upgrade: eliminates the crowded left-icon / right-number asymmetry.
   - Replaces flat dark plastic cavities with rich material inlays matching Attack/Health.
   - Centered numeral placement significantly improves glanceability.

3. **`inspected_card_1080p.png`:**
   - Full-scale inspection of Emerald Epic Arcane Knight.
   - Attack ($4$, graphite), Health ($5$, ruby), Armor ($2$, steel), and Shield ($1$, azure) form a harmonious 4-stat defense and offense presentation.
   - Emerald rarity crystals and typography remain $100\%$ unaffected.

4. **`seven_card_hand_1080p.png`:**
   - At $316\text{ px}$ card height, Armor and Shield numerals are immediately readable.
   - Creatures with no protection (Scout) cleanly hide both slots.
   - Creatures with Armor only (Rampart Guard) or Shield only (Rune Crafter) render single plaques cleanly without unbalancing the footer.
   - Spell (Fireball) and Equipment (Bastion Armor) retain inactive-socket quatrefoil engravings and category ornaments.

5. **`full_combat_1080p.png`:**
   - Full combat view at $1920 \times 1080$ against Sundered Observatory background.
   - Plaque inlays do not compete with board elements or primary combat stats; secondary status remains appropriately restrained.

6. **`mixed_stats_examples_1080p.png`:**
   - Single digits ($1, 2, 3$), double digits ($10, 12, 14$), dual protections, and extreme stress tests ($99/99$) all center cleanly and respect the $83\text{ px}$ width budget.
   - Zero-value protection hiding functions perfectly.

### Secondary Notes at 1280×720 (`seven_card_hand_720p.png`)
- At $210\text{ px}$ card height, plaque inlays maintain their distinct steel vs azure hue identities.
- TacticalNumber numerals remain legible for rapid scanning without sub-pixel moiré or blur.

---

## 8. Technical Validation Results

| Check | Command | Exit Code | Observations |
|---|---|:---:|---|
| **Headless Editor Import** | `& $GodotExe --headless --editor --path . --import --quit` | **0** | Clean asset import; `.import` files generated with anisotropic mipmaps. |
| **Headless Test Runner** | `& $GodotExe --headless --path . --script res://scripts/tests/test_runner.gd` | **0** | $14 / 14$ harness self-test assertions pass cleanly. |
| **Card Integration Scene** | `& $GodotExe --headless --path . res://scenes/ui/art002_card_integration_test.tscn --quit-after 5` | **0** | Scene instantiates and executes with zero errors or warnings. |
| **T23 Plaque Regression Suite** | `& $GodotExe --headless --path . --script res://docs/art/reviews/art002/t23/plaque_regression.gd` | **0** | $30 / 30$ assertions pass (textures, transparency, constants, usable area clearance, rollback). |
| **GPU Screenshot Generation** | `& $GodotExe --path . --script res://docs/art/reviews/art002/t23/capture.gd` | **0** | All 7 high-resolution review images generated cleanly with zero errors. |
| **Git Diff Check** | `git diff --check` | **0** | Clean whitespace, zero trailing spaces, zero formatting errors. |

---

## 9. Remaining Limitations & Future Work

1. **Procedural Bronze Border:** The auxiliary badge outer border remains rendered via `StyleBoxFlat` ($3\text{ px}$ bronze line with $23\text{ px}$ corner radius). While visually cohesive with the frame, future art lots could explore extracting a pre-baked sculpted master-frame bronze bezel patch (similar to `mo_socket_bezel_attack.png`) if hand-sculpted relief is desired for the rectangular slots.
2. **Dynamic Live Modifiers:** Current implementation renders printed native Armor and transient Shield overlay. Dynamic buff/debuff color shifts (e.g. green for boosted, red for reduced) belong in the live combat modifier presentation layer and do not overwrite the base inlay material.

---

## 10. Final Recommendation

**RECOMMENDATION: SUBMIT FOR OWNER FINAL SIGN-OFF**

- **Technical Status:** PASS ($30 / 30$ regression tests pass; zero leaks; clean import; exit code $0$).
- **Visual Status:** Complete Full HD evidence package delivered at $1920 \times 1080$ and $1280 \times 720$.
- **Recommendation:** Submit artifacts to repository owner for artistic sign-off.
