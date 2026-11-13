# ART-002-T15 — Graphite Steel Attack Cabochon Integration

2026-11-13 · **PASS** (Technical Verification & Integration) · Artistic Status: **RECOMMENDATION: APPROVE (FOR OWNER FINAL SIGN-OFF)**.

This review documents the targeted integration of the new graphite-steel Attack cabochon V2 (`mo_stat_cabochon_attack_v02.png`), resolving the color ambiguity between Attack (formerly warm bronze/amber) and Health (deep ruby red) identified in owner review of ART-002-T13.

---

## 1. Source and Runtime Asset Mapping

| Component | Source Asset | Source Size | Bounding Box ($\alpha \ge 10$) | Derived Runtime Texture | Texture Size | Format |
|---|---|---|---|---|---|---|
| **Attack V2 (Graphite Steel)** | `mo_stat_cabochon_attack_v02.png` | 1254 × 1254 px | (61, 32, 1182, 1198), $1121 \times 1166\text{ px}$ | `assets/textures/cards/icons/mo_cabochon_attack_v02.png`<br>`assets/textures/cards/icons/mo_cabochon_attack.png` | 512 × 512 px | RGBA8 |
| **Attack V1 (Warm Bronze)** | `mo_stat_cabochon_attack_v01.png` | 1254 × 1254 px | (75, 0, 1171, 1177), $1096 \times 1177\text{ px}$ | `assets/textures/cards/icons/mo_cabochon_attack_v01.png` | 512 × 512 px | RGBA8 |
| **Health V1 (Ruby Red)** | `mo_stat_cabochon_health_v01.png` | 1254 × 1254 px | (67, 39, 1182, 1202), $1115 \times 1163\text{ px}$ | `assets/textures/cards/icons/mo_cabochon_health_v01.png`<br>`assets/textures/cards/icons/mo_cabochon_health.png` | 512 × 512 px | RGBA8 |

- **Original Source Files:** Preserved completely untouched in `assets/_source/lot1/cards/icons/`.
- **Runtime Preparation:** Downsampled to 512×512 px with Lanczos filtering. Sub-threshold stray alpha below 5 was cleanly zeroed.
- **Rollback Capability:** V1 runtime texture `mo_cabochon_attack_v01.png` is preserved. `CardStatOverlay.attack_cabochon_version` allows instant switching between V2 (2, default) and V1 (1).

---

## 2. Files Modified

1. `scripts/presentation/card_stat_overlay.gd`:
   - Preloaded `CABOCHON_ATTACK_V02`, `CABOCHON_ATTACK_V01`, and `CABOCHON_ATTACK`.
   - Added version control flag: `static var attack_cabochon_version: int = 2`.
   - Updated `_draw()` to select the active Attack cabochon texture dynamically.
   - Strictly preserved all existing geometry (`ATTACK_CENTER`, `HEALTH_CENTER`, `CABOCHON_SIZE = Vector2(250, 250)`).
2. `assets/textures/cards/icons/mo_cabochon_attack_v02.png`:
   - New runtime texture generated from `mo_stat_cabochon_attack_v02.png`.
3. `assets/textures/cards/icons/mo_cabochon_attack.png`:
   - Updated production texture pointing to Attack V2.
4. `docs/art/reviews/art002/t15/graphite_attack_regression.gd`:
   - Automated regression test validating texture loading, transparency, geometry preservation, and version switching.
5. `docs/art/reviews/art002/t15/capture.gd`:
   - Dedicated review capture suite generating all 5 required Full HD 1080p review captures.

---

## 3. V1 vs V2 Geometric & Alpha Comparison

| Metric | Attack V1 (Warm Bronze) | Attack V2 (Graphite Steel) | Health V1 (Ruby Red) | Comparison Notes |
|---|---|---|---|---|
| **Canvas Dimensions** | 1254 × 1254 px | 1254 × 1254 px | 1254 × 1254 px | Identical source canvas dimensions. |
| **Visible Bbox ($\alpha \ge 10$)** | (75, 0, 1171, 1177) | (61, 32, 1182, 1198) | (67, 39, 1182, 1202) | Attack V2 matches Health V1 within 6 px width and 3 px height. |
| **Visible Width × Height** | $1096 \times 1177\text{ px}$ | $1121 \times 1166\text{ px}$ | $1115 \times 1163\text{ px}$ | Aspect ratio: V2 = 0.961, Health = 0.959. Virtually identical geometry. |
| **Silhouette Center** | $(623.0, 588.5)$ | $(621.5, 615.0)$ | $(624.5, 620.5)$ | Attack V2 center aligns with canvas center $(627, 627)$ within 12 px (0.9%). |
| **Corner Alpha** | `[1, 0, 0, 0]` | **`[0, 0, 0, 0]`** | `[1, 0, 0, 0]` | Attack V2 has 100% transparent corners; zero background halo. |

---

## 4. Texture Transparency & Halo Verification

- **Corner Pixels:** `[0, 0, 0, 0]` verified across all four texture corners in both source and 512×512 runtime texture.
- **Edge Transition:** Soft alpha falloff ($r = 450\dots 500\text{ px}$) preserves a subtle grounding shadow without any rectangular clipping or fringe artifacts.
- **Premultiplied Zeroing:** Transparent pixels have RGB explicitly zeroed to prevent color bleeding during bilinear/mipmapped filtering.

---

## 5. Optical Alignment Findings

- **Aperture Centering:** Rendered at `ATTACK_CENTER = Vector2(162, 1279)` with `CABOCHON_SIZE = Vector2(250, 250)`.
- **Zero Optical Offset:** `ATTACK_CABOCHON_OFFSET = Vector2(0, 0)` is strictly preserved; the visible gem center sits within 1.0 px of the aperture center.
- **T04B Safe Disk Fitting:** The inner dark gem core diameter ($r \le 72\text{ px}$) perfectly accommodates the white stat numeral within the $70.0\text{ px}$ circular safe disk, preventing any numeral ink overlap onto the metallic bezel.

---

## 6. Color Differentiation & Material Assessment

| Statistic | Material Language | Mean RGB over Opaque | Mean Luminance | Core Luminance | Visual Association |
|---|---|---|---|---|---|
| **Attack V2 (New)** | Cold Forged Graphite Steel | **(63.4, 68.7, 75.4)** | **67.9** | **44 – 55** | Cold forged steel; physical impact; weapon strike. |
| **Attack V1 (Old)** | Warm Bronze / Amber | (129.7, 78.2, 49.5) | 90.3 | 60 – 75 | Warm amber; previously clashed with ruby red. |
| **Health V1 (Unchanged)** | Deep Faceted Ruby Gemstone | **(139.9, 41.4, 24.1)** | **68.9** | **35 – 50** | Living blood vitality; crimson organic life force. |

### Key Chromatic Findings
1. **Stark Chromatic Delta:**
   - Attack V2 Red channel: $R = 63.4$
   - Health V1 Red channel: $R = 139.9$
   - $\Delta R = 76.5\text{ px}$ ($> 120\%$ difference). Attack is now a cool, dark metallic slate, while Health is an intense crimson ruby.
2. **Material Differentiation:**
   - Attack communicates physical weapon impact through cold, forged-steel tones.
   - Health communicates vitality through luminous faceted ruby crystal.
3. **No Cyan/Blue Conflict with Shield:**
   - Attack V2 has $R = 63$, $G = 69$, $B = 75$ (neutral graphite steel with a subtle cold cast). It contains no saturated cyan/azure coloration, maintaining complete separation from the luminous arcane blue of the Shield badge ($R = 149$, $G = 177$, $B = 191$).
4. **Frame Harmony:**
   - The dark graphite steel tone harmonizes naturally with the antique-bronze master card frame v03, evoking medieval forged iron fittings set in bronze.

---

## 7. Actual 1920×1080 Readability Assessment

All review screenshots were rendered using genuine Godot 4.7.2 GPU viewport rendering on an NVIDIA GeForce GTX 1660 Ti (OpenGL Compatibility backend).

| Screenshot Deliverable | Resolution | Purpose & Key Observations |
|---|---|---|
| [attack_v1_vs_v2_1080p.png](attack_v1_vs_v2_1080p.png) | 1920 × 1080 | **Direct side-by-side card comparison** at identical scale. Demonstrates the replacement of the warm amber tone with cold graphite steel, completely resolving color clash with Health. |
| [attack_health_comparison_1080p.png](attack_health_comparison_1080p.png) | 1920 × 1080 | **Macro close-up (2.3× zoom)** of Attack V2 alongside unchanged Health V1. Proves strong color temperature differentiation (cold dark slate vs hot ruby crimson) with high numeral contrast (~5.5:1 ratio). |
| [inspected_card_1080p.png](inspected_card_1080p.png) | 1920 × 1080 | **Inspection view** of Rampart Guard showing all four stat representations active (Graphite Attack, Ruby Health, Steel Armor, Blue Shield). All four stats are immediately distinguishable with zero chromatic clash. |
| [seven_card_hand_1080p.png](seven_card_hand_1080p.png) | 1920 × 1080 | **Seven-card linear hand study** at in-game 1080p play scale (card height 316 px). Demonstrates rapid in-hand scanning: Attack (left) and Health (right) are instantly distinct at gameplay resolution. |
| [full_combat_interface_1080p.png](full_combat_interface_1080p.png) | 1920 × 1080 | **Full combat presentation** with Sundered Observatory background, HUD, 4×6 grid, and 7-card hand at 1080p. Validates overall gameplay aesthetic and visual integration. |

---

## 8. Technical Verification Transcript

Working Directory: `D:\Dev\MagicOdyssey`  
Engine: `D:\Temp\Godot_v4.7.2-stable_win64.exe` (v4.7.2.stable.official.ed1daf0bf)

| Verification Step | Command / Invocation | Exit Code | Result | Observations |
|---|---|---:|---|---|
| Godot Asset Import | `--headless --editor --path . --import --quit` | `0` | **PASS** | Imported Attack V2 textures cleanly. |
| Native Test Harness | `scripts\tests\run_tests.ps1` | `0` | **PASS** | 14/14 core test assertions pass. |
| ART-002 Scene Init | `scenes/ui/art002_card_integration_test.tscn` | `0` | **PASS** | Scene tree and shaders compile and initialize cleanly. |
| T04B/T06 Numerical Regression | `docs/art/reviews/art002/t06/stat_regression.gd` | `0` | **PASS** | All 144 socket combinations pass (0 failures, max ink error 1.055 px). |
| T15 Graphite Regression Suite | `docs/art/reviews/art002/t15/graphite_attack_regression.gd` | `0` | **PASS** | Texture loading, transparency, geometry preservation, and version switching pass. |
| T13 Cabochon Regression Suite | `docs/art/reviews/art002/t13/cabochon_regression.gd` | `0` | **PASS** | Passes without modification. |
| T11 Backward Compatibility | `docs/art/reviews/art002/t11/icon_regression.gd` | `0` | **PASS** | Passes without modification. |
| T10 Backward Compatibility | `docs/art/reviews/art002/t10/icon_regression.gd` | `0` | **PASS** | Passes without modification. |
| T08 Backward Compatibility | `docs/art/reviews/art002/t08/icon_regression.gd` | `0` | **PASS** | Passes without modification. |
| Review Capture Suite | `docs/art/reviews/art002/t15/capture.gd` | `0` | **PASS** | All 5 review captures rendered and saved with exit code 0. |
| Whitespace & Git Diff | `git diff --check` | `0` | **PASS** | Zero trailing whitespace or format violations. |

---

## 9. Remaining Visual Limitations

1. **Subtle Internal Crossed-Weapon Motif:** In Attack V2, the crossed-weapon motif is rendered as a restrained, dark steel relief. It is clearly visible in enlarged inspection and macro views, adding rich material depth, but recedes into dark graphite at hand scale to prioritize high-contrast numeral readability.
2. **Organic Frame Edge Blend:** As observed in T13, the master frame v03 has slight hand-painted asymmetry ($X = 162\text{ px}$ vs $X = 167\text{ px}$ from frame edges). The cabochon's soft alpha drop shadow smoothly absorbs this variation without visual seam.

---

## 10. Conclusion & Recommendation

**RECOMMENDATION: APPROVE (FOR OWNER FINAL SIGN-OFF)**.

The graphite-steel Attack cabochon V2 decisively solves the color ambiguity with Health. The cold forged-steel palette ($R = 63$) contrasts sharply with ruby crimson ($R = 140$), white numerals maintain excellent contrast (~5.5:1 ratio), and all existing frame geometry, T04B numeral centering, and approved systems remain strictly preserved.
