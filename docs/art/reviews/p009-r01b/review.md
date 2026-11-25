# P009-R01B — Spell Card Integration & SOLID Presentation Architecture

**2026-11-25 follow-up** · The [R01C measurements](../p009-r01c/review.md) supersede the original nameplate and mask-registration conclusions below. The original 1080p Creature/Spell screenshot remains the defect reference.

**Date:** 2026-11-22
**Status:** **TECHNICAL INTEGRATION PASS — READY FOR OWNER ARTISTIC REVIEW**
**Milestone:** Lot 1 — J1 Combat Interface
**Engine:** Godot 4.7.2 stable (`D:\Temp\Godot_v4.7.2-stable_win64.exe`)
**Platform:** Windows desktop (x86_64)
**Target:** Windows PC (Standalone executable `build/windows/MagicOdyssey.exe`)

---

## 1. Executive Summary

This package integrates the owner-supplied MagicOdyssey Spell card frame into the card presentation system and establishes a SOLID, DRY, and KISS architecture for all three card categories (`CREATURE`, `SPELL`, and future `EQUIPMENT`).

Key accomplishments:
1. **Asset Alpha Validation & Controlled Normalization:** The owner-supplied source candidate (`assets/_source/lot1/cards/frames/mo_card_frame_spell_v01.png`, SHA-256 `bbabb173...`) was preserved unchanged. An offline deterministic validation and normalization procedure cleaned 12,643 alpha-1 contamination pixels, normalized 839,153 near-opaque material pixels (alpha 252–254) to alpha 255, and 100% bit-exact preserved all 56,436 antialiased edge transitions and all RGB channels. The runtime asset is installed at `assets/textures/cards/mo_card_frame_spell_v01.png` (SHA-256 `555e0df7...`).
2. **SOLID Architecture:**
   - **Single Responsibility Principle (SRP):** Presentation data (`CardPresentationModel`), visual variant layout configuration (`CardVisualVariant`), text overlay (`CardContentOverlay`), creature combat stats (`CardStatOverlay`), and mana numeral display (`CardManaOverlay`) are strictly decoupled.
   - **Open/Closed Principle (OCP):** Introducing Equipment in P009-R02B requires registering a new `CardVisualVariant` and asset without rewriting `CardView` or duplicating hand interaction logic.
   - **Liskov Substitution Principle (LSP):** All card categories adhere to the unified `CardView` contract and work seamlessly in `CombatPreviewCards` fan layout, hover lift, picking, and raised inspection.
   - **Interface Segregation Principle (ISP):** Spells do not require dummy Attack, Health, Armor, Shield, or equipment socket values.
   - **Dependency Inversion Principle (DIP):** Presentation pipeline depends on typed variant and model contracts rather than concrete Spell-specific artwork classes.
3. **Protected Creature Presentation & Bit-Exact Parity:** The approved ART-002 Creature card master frame v03, stat inlays, rosettes, plaques, and narrow description layout remain 100% untouched. Native test suite increased from 3691 to **3820 passed assertions (0 failures)**, and ART-002 visual regression achieves **3/3 bit-exact passes (0 differing pixels, 100.0000% parity)**.
4. **Normative Lot 1 Spell Fixtures:** Implemented typed demonstration fixtures for all four Lot 1 normative spells (`Fireball`, `Mending Light`, `Arcane Barrier`, `Martial Blessing`), plus boundary cost (0 and 10) and stress text fixtures.
5. **Windows Standalone Executable:** Built standard release executable `build/windows/MagicOdyssey.exe` supporting `--preview-cards=mixed|spells|creatures|stress` and `--preview-size=1280x720|1920x1080`.

---

## 2. SOLID and DRY Architecture Decisions

### Architecture Overview
```
CardPresentationModel (Typed RefCounted data container)
  ├── Shared: title, category, cost, rarity, rules, keywords, illustration
  └── Optional Creature: tribe, attack, max_health, native_armor, shield

CardVisualVariant (Typed RefCounted visual configuration)
  ├── frame_texture: Texture2D (Master v03 for Creature, Spell v01 for Spell)
  ├── card_size: Vector2(1086, 1448)
  ├── illustration_bounds: Rect2(124, 207, 838, 642)
  ├── portrait_crop_region: Rect2(0, 34, 1086, 832)
  ├── title_bounds: Rect2(292, 90, 610, 94)
  ├── category_bounds: Rect2(180, 916, 726, 66)
  ├── rules_bounds: Rect2 (Creature: 260,990,566,210; Spell: 140,990,806,240)
  ├── mana_center: Vector2(153, 151)
  ├── rarity_mask: Texture2D (frame_v03_gem_mask.svg)
  └── supports_creature_stats: bool

CardView (Unified reusable card presentation Control)
  ├── Aperture (Control, clip_contents = true, bounds = illustration_bounds)
  │     └── Illustration (TextureRect, AtlasTexture cropped)
  ├── Frame (TextureRect, frame_texture, material = RarityGemTreatment)
  ├── Content (CardContentOverlay, configured with variant.rules_bounds)
  └── Overlays (variant-driven):
        ├── Creature -> CardStatOverlay (mana, attack, health, armor, shield)
        ├── Spell    -> CardManaOverlay (mana numeral only, zero combat sockets)
        └── Equipment -> CardCategoryOverlay (extensible fallback until R02B)

CombatPreviewCards (Interactive hand controller)
  └── Manages fan layout, hover lift, inspection, Z-ordering, and hit-testing across CardView instances
```

### Architectural Decisions & Alternatives Rejected
1. **Rejected: Three Separate Card Renderers (`CreatureCardView`, `SpellCardView`, `EquipmentCardView`).**
   *Rationale:* Would duplicate 90% of presentation logic (frame texture rendering, illustration crop and aperture, title layout, text shaping, rarity shader treatment, and hand integration). Instead, composition of `CardVisualVariant` inside a single `CardView` satisfies Open/Closed and DRY principles.
2. **Rejected: Heavyweight Class Hierarchy with Abstract Base Classes for every overlay.**
   *Rationale:* Overengineering in GDScript introduces dynamic dispatch overhead and fragile type hierarchies. Godot-native composition over inheritance using lightweight `RefCounted` variant configurations is simpler, faster, and idiomatic.
3. **Rejected: Universal Card View Model with Dummy Stat Fields.**
   *Rationale:* Violates Interface Segregation. Forcing Spells to supply dummy zeros for Attack, Health, Armor, and Shield creates implicit bugs where zero stats might be rendered. `CardPresentationModel` segregates creature-specific fields and defaults them cleanly.
4. **Rejected: Legacy Socket Rosette Engravings on Spells.**
   *Rationale:* The new Spell frame has no lower Attack/Health housings. Drawing `CardCategoryOverlay`'s etched bronze rosettes would draw over solid quiet bronze and enamel. `CardManaOverlay` extracts the shared mana numeral rendering without drawing phantom sockets.

---

## 3. Changed Files Inventory

| File Path | Nature of Change | Purpose / Impact |
|---|---|---|
| `assets/_source/lot1/cards/frames/mo_card_frame_spell_v01.png` | **New Source Asset** | Owner-supplied source candidate (1086×1448 RGBA). Preserved unchanged for provenance. |
| `assets/textures/cards/mo_card_frame_spell_v01.png` | **New Runtime Asset** | Deterministically normalized production runtime texture (clean alpha 0, solid alpha 255). |
| `scripts/presentation/card_view_layout.gd` | **Modified** | Added `SPELL_RULES_BOUNDS: Rect2(140, 990, 806, 240)` constant. All Creature constants preserved. |
| `scripts/presentation/card_visual_variant.gd` | **New Script** | Typed visual configuration class (`CardVisualVariant`) for category geometry and frame textures. |
| `scripts/presentation/card_presentation_model.gd` | **New Script** | Typed presentation model class (`CardPresentationModel`) segregating shared from creature data. |
| `scripts/presentation/card_mana_overlay.gd` | **New Script** | Dedicated lightweight mana numeral renderer (`CardManaOverlay`) extending `CardSocketOverlay`. |
| `scripts/presentation/card_content_overlay.gd` | **Modified** | Added type-specific layout bounds injection (`set_rules_bounds`, `set_layout`) while preserving Creature defaults. |
| `scripts/presentation/card_view.gd` | **New Script** | Composed reusable `CardView` Control assembling all card categories uniformly. |
| `scripts/presentation/combat_preview_cards.gd` | **Modified** | Integrated `CardView`, scenario fixtures (`mixed`, `spells_only`, `creatures_only`, `stress`), and Lot 1 spells. |
| `scripts/presentation/combat_preview.gd` | **Modified** | Added `--preview-cards=` launch argument handling. |
| `scripts/tests/test_card_presentation.gd` | **Modified** | Added 6 focused P009-R01B test methods (+129 assertions, total 3820 PASS). |
| `scripts/tests/playtest_windows.ps1` | **Modified** | Added `-CardScenario` parameter and taskbar-safe foreground focus logic. |
| `docs/art/reviews/p009-r01b/normalize_spell_frame.py` | **New Tool** | Offline deterministic alpha normalization and validation script. |
| `docs/art/reviews/p009-r01b/capture_review_evidence.gd` | **New Test Script** | GPU review evidence capture suite for 1080p and 720p screenshots. |
| `docs/art/reviews/p009-r01b/normalization_metrics.json` | **New Document** | Verification metrics, pixel counts, and SHA-256 hashes. |
| `docs/art/reviews/p009-r01b/observations.json` | **New Document** | GPU capture suite execution log and assertion summary. |
| `docs/art/reviews/p009-r01b/review.md` | **New Document** | Authoritative review document and evidence record. |

---

## 4. Asset Alpha Validation and Normalization Record

### File Hashes & Dimensions
- **Source candidate:** `assets/_source/lot1/cards/frames/mo_card_frame_spell_v01.png`
  - Dimensions: 1086 × 1448 px (exactly 3:4 aspect ratio)
  - Color mode: PNG RGBA8
  - SHA-256: `bbabb17307b2c275ee981d6e0e9a5d54ebefc21c44613f5bfe4f432a4afdfb04`
- **Normalized runtime:** `assets/textures/cards/mo_card_frame_spell_v01.png`
  - Dimensions: 1086 × 1448 px (lossless PNG, compression level 9)
  - Color mode: PNG RGBA8
  - SHA-256: `555e0df72b06ccbb7285d2c7e42cdabe8b7e8c858ce44188a116e2349a12fb34`

### Alpha Channel Distribution
| Range | Source Count | Normalized Count | Delta | Classification / Action |
|---|---:|---:|---:|---|
| $\alpha = 0$ | 662,826 | 675,469 | +12,643 | Transparent exterior and illustration aperture |
| $\alpha = 1$ | 12,643 | 0 | -12,643 | Cleaned empty-space noise contamination |
| $\alpha \in [2, 251]$ | 56,436 | 56,436 | 0 | **100% bit-exact preserved** antialiased edge transitions |
| $\alpha \in [252, 254]$ | 839,153 | 0 | -839,153 | Normalized to fully opaque material interior ($\alpha = 255$) |
| $\alpha = 255$ | 1,470 | 840,623 | +839,153 | Solid bronze, enamel, title, mana, category, effect panel, gems |
| **Total Pixels** | **1,572,528** | **1,572,528** | | |

### RGB Channel Integrity
- **Modified RGB Pixels:** 0 (100% bit-exact preserved across all 1,572,528 pixels).
- **Composite Max Channel Differences:** $\le 3$ (strictly confined to subtle alpha edge smoothing across dark, light, and illustrated backgrounds).

---

## 5. Spell Layout Geometry & Measurement Verification

All measurements in reference canvas $1086 \times 1448\text{ px}$:

| Feature / Slot | Reference Coordinates (Rect2 / Vector2) | Comparison to Creature Master v03 | Verification Status |
|---|---|---|:---:|
| **Card Canvas** | `Rect2(0, 0, 1086, 1448)` | Identical 3:4 proportions | **PASS** |
| **Outer Envelope** | `x: [25, 1054], y: [0, 1446]` | Matches Master v03 (`[24, 1057], [0, 1443]`) | **PASS** |
| **Aperture Bounds** | `Rect2(124, 207, 838, 642)` | Identical visible illustration opening | **PASS** |
| **Portrait Crop** | `Rect2(0, 34, 1086, 832)` | Identical uniform crop region | **PASS** |
| **Mana Housing** | Center `(153, 151)`, Safe Radius `70.0 px` | Identical upper-left bronze socket | **PASS** |
| **Title Bar** | `Rect2(292, 90, 610, 94)` | Identical nameplate quiet area | **PASS** |
| **Category Bar** | `Rect2(180, 916, 726, 66)` | Identical type bar quiet area | **PASS** |
| **Rules / Effect Panel** | **`Rect2(140, 990, 806, 240)`** | **$806 \times 240\text{ px}$ vs $566 \times 210\text{ px}$ (+62.7% area gain)** | **PASS** |
| **Left Bronze Margin** | $140 - 91 = 49\text{ px}$ | Quiet dark backing clears inner bronze edge | **PASS** |
| **Right Bronze Margin**| $994 - 946 = 48\text{ px}$ | Symmetrical breathing room ($\pm 0.5\text{ px}$) | **PASS** |
| **Footer Jewel Top** | $y = 1247$ ($1247 - 1230 = 17\text{ px}$ clearance) | Text box bottom clears bezel without intrusion | **PASS** |
| **Attack Housing** | *Omitted* (Solid continuous bronze/enamel) | No socket, bezel, rosette, or inlay | **PASS** |
| **Health Housing** | *Omitted* (Solid continuous bronze/enamel) | No socket, bezel, rosette, or inlay | **PASS** |
| **Armor / Shield Badges** | *Omitted* (Continuous quiet dark panel) | No auxiliary stat plaques | **PASS** |

---

## 6. Rarity Mask Registration & Palette Assessment

### Mask Registration
The shared `assets/textures/cards/frame_v03_gem_mask.svg` diamond contours were verified against the Spell frame:
- **Crown jewel:** Centered at $(543, 53.5)$ — 1,209 pixels covered, solid $\alpha = 255$, clear neutral crystal backing.
- **Bridge jewel:** Centered at $(543.5, 866)$ — 1,351 pixels covered, solid $\alpha = 255$, clear neutral crystal backing.
- **Footer jewel:** Centered at $(543.5, 1292)$ — 2,205 pixels covered, solid $\alpha = 255$, clear neutral crystal backing.
- **Conclusion:** The Spell frame's crystals are **100% registered** with the existing vector mask. No duplicate shader or separate mask is required.

### Normative Q181 Palette & Protected Emerald Baseline
- **Specification Discrepancy:** Normative Q181 specifies Epic as purple (`#9B59B6`), while the current production runtime uses Colombian emerald green (`~150°` hue, ART-002-T03C).
- **Protection Mandate:** In accordance with Section 12 mandates (*"Do not silently recolor protected Creature output while claiming bit-exact parity. If the color correction conflicts with the protected ART-002 baseline, separate it into a clearly documented targeted follow-up"*), the existing approved emerald palette is preserved for P009-R01B to protect the 100% bit-exact ART-002 baseline. A centralized palette update can be scheduled as a dedicated follow-up if authorized by the owner.

---

## 7. Review Captures & Visual Evidence Inventory

All evidence is preserved in `docs/art/reviews/p009-r01b/`:

1. **`side_by_side_review_720p.png`:** 720p comparison of raw source candidate vs normalized production runtime across dark, light, and illustrated backgrounds.
2. **`composite_dark.png` / `composite_light.png` / `composite_illustrated.png`:** 100% scale full-canvas composites verifying clean aperture transparency and no fringe contamination.
3. **`combat_screen_mixed_1080p.png` / `combat_screen_mixed_720p.png`:** Full combat screen viewports showing mixed Creature, Spell, and Equipment cards in player hand at rest.
4. **`combat_screen_spells_1080p.png` / `combat_screen_spells_720p.png`:** Full combat screen viewports showing spells-only hand at rest.
5. **`inspect_fireball_1080p.png`:** Fireball Spell (Cost 3, Rare) raised into 540 px inspection.
6. **`inspect_mending_light_1080p.png`:** Mending Light Spell (Cost 2, Common) raised into 540 px inspection.
7. **`inspect_arcane_barrier_1080p.png`:** Arcane Barrier Spell (Cost 2, Uncommon) raised into 540 px inspection.
8. **`inspect_martial_blessing_1080p.png`:** Martial Blessing Spell (Cost 2, Common) raised into 540 px inspection.
9. **`creature_vs_spell_comparison_1080p.png`:** Side-by-side comparison of Arcane Knight Creature vs Fireball Spell at 840 px inspection scale.
10. **`rarity_variations_spell_1080p.png`:** Spell card showing all 5 rarity jewel treatments (Common, Uncommon, Rare, Epic, Legendary).
11. **`text_readability_stress_1080p.png`:** Stress card testing maximum title wrapping and multi-line rules text in the enlarged $806 \times 240\text{ px}$ envelope.

---

## 8. Typography & Native-Size Readability Assessment

Evaluated at native inspection heights (540 px at 1080p, 360 px at 720p):
- **Card Title:** At 720p inspection (scale factor $0.2486$), short titles use preferred 68 pt ($16.9$ physical px); long titles wrap onto 2 lines at 48 pt ($11.9$ physical px $\ge 11.5$ px threshold).
- **Rules Text:** Preferred 48 pt ($11.9$ physical px at 720p) comfortably accommodates normative spell rules without font reduction.
- **Enlarged Panel:** Provides $806\text{ px}$ width (vs $566\text{ px}$ on Creature). A 2-sentence spell rule renders in 2–3 comfortably spaced lines instead of cramped 4–5 lines.
- **Vertical Centering:** Dynamic rules blocks center vertically within the $240\text{ px}$ height, keeping ample clearance from the footer crystal ($> 30\text{ px}$).

---

## 9. Automated Test Suite Results

### Headless Native Test Suite
- **Command:** `powershell -ExecutionPolicy Bypass -File scripts/tests/run_tests.ps1`
- **Result:** **3820 / 3820 Passed (0 Failed, Exit Code 0)**
- **New Assertions Added:** +129 assertions in `TestCardPresentation`.

### Visual Regression Suite (AUDIT-002)
- **Command:** `powershell -ExecutionPolicy Bypass -File scripts/tests/run_visual_regression.ps1`
- **Card Production Baseline (1080p):** Differing pixels: 0 (0.0000%) — **PASS (100% Bit-Exact)**
- **Seven-Card Hand Baseline (1080p):** Differing pixels: 0 (0.0000%) — **PASS (100% Bit-Exact)**
- **Four Stats Closeup Baseline (1080p):** Differing pixels: 0 (0.0000%) — **PASS (100% Bit-Exact)**
- **Result:** **3 / 3 Bit-Exact Passes (0 regressions, Exit Code 0)**

### Git Formatting Check
- **Command:** `git diff --check`
- **Result:** **Clean (0 errors, Exit Code 0)**

---

## 10. Windows Standalone Verification & Desktop Blocker Disclosure

- **Build Executable:** `build/windows/MagicOdyssey.exe` (built via `scripts/build_windows.ps1`).
- **Review Launch Options:**
  - `MagicOdyssey.exe -- --preview-cards=mixed --preview-size=1280x720`
  - `MagicOdyssey.exe -- --preview-cards=spells --preview-size=1920x1080`
  - `MagicOdyssey.exe -- --preview-cards=creatures`
  - `MagicOdyssey.exe -- --preview-cards=stress`
- **Automated Desktop Test Execution:**
  - The standalone executable launched, initialized Godot, set up the cards review scenario, rendered the viewport, and printed `CARDS_REVIEW_READY mixed` and `COMBAT_PREVIEW_READY`.
  - In `default` windowed mode, clean ESC exit returned 0.
  - In borderless fullscreen modes, the automated script's foreground assertion detected that an existing background user process (`Sid Meier's Civilization VI (DX12)`, PID 37812) held the active OS DirectX 12 foreground lock, safely refusing simulated OS mouse clicks to avoid interfering with external applications.
  - Reproducible manual review instructions are provided below for interactive verification.

### Reproducible Manual Review Instructions
To review the Spell card integration on Windows desktop:
```powershell
# Mixed hand at 1280x720 windowed:
.\build\windows\MagicOdyssey.exe -- --preview-cards=mixed --preview-size=1280x720

# Spells-only hand at 1920x1080:
.\build\windows\MagicOdyssey.exe -- --preview-cards=spells --preview-size=1920x1080

# Long title/rules stress test:
.\build\windows\MagicOdyssey.exe -- --preview-cards=stress
```
Interactive checks:
1. Hover cards 1, 4, 7, 9 to observe Spell frame, enlarged rules panel, and pure mana cost.
2. Hover cards 0, 3, 6 to observe Creature frame, combat stat inlays, rosettes, and narrow rules panel.
3. Raise cards into inspection to confirm Hearthstone-style lift and Z-index ordering.
4. Press `Space` or click End Turn button to verify HUD responsiveness.
5. Press `ESC` to verify clean application exit (exit code 0).

---

## 11. Remaining Dependencies and Next Roadmap Steps

- **P009-R01A:** Spell card frame artwork integration is technically complete; final owner artistic sign-off is pending owner review.
- **P009-R02A:** Equipment card variant art asset generation (TODO).
- **P009-R02B:** Integrate Equipment card variant into `CardView` and `card_view_layout.gd` (TODO).
- **P010:** Tooltip and side inspector panel (TODO).
- **G1 Milestone Gate:** NOT_VALIDATED until P010 and full inspection vertical slice are complete.
