# ART-002-T13 — Attack and Health Integrated Cabochons Integration

2026-11-13 · **PASS** (Technical Verification & Integration) · Artistic Status: **RECOMMENDATION: APPROVE (FOR OWNER FINAL SIGN-OFF)**.

This review documents the replacement of the separate Attack and Health mini-icons with dedicated integrated premium cabochons (`mo_stat_cabochon_attack_v01.png` and `mo_stat_cabochon_health_v01.png`), providing a unified, AAA dark-fantasy presentation where material, color, and subtle internal motifs convey the stat semantics without socket rim clutter.

---

## 1. Source Asset Mapping & Runtime Textures

The two new source assets deposited in `assets/_source/lot1/cards/icons/` were inspected and optimized for runtime rendering:

| Statistic | Source File | Source Size | Bounding Box ($\alpha \ge 200$) | Visual Center | Derived Runtime Texture | Cleaned Size | Format |
|---|---|---|---|---|---|---|---|
| **Attack** | `mo_stat_cabochon_attack_v01.png` | 1254 × 1254 px | (77, 71, 1168, 1174), $1092 \times 1104\text{ px}$ | (622.5, 622.5) | `assets/textures/cards/icons/mo_cabochon_attack.png`<br>`assets/textures/cards/icons/mo_cabochon_attack_v01.png` | 512 × 512 px | RGBA8 |
| **Health** | `mo_stat_cabochon_health_v01.png` | 1254 × 1254 px | (68, 40, 1180, 1199), $1113 \times 1160\text{ px}$ | (624.0, 619.5) | `assets/textures/cards/icons/mo_cabochon_health.png`<br>`assets/textures/cards/icons/mo_cabochon_health_v01.png` | 512 × 512 px | RGBA8 |

### Runtime Texture Preparation & Halo Cleaning
- **Alpha Thresholding:** Sub-threshold stray alpha below 5 was cleanly zeroed, producing 100% transparent corners (`alpha = 0.000`) and eliminating box halos.
- **Downsampling:** Resampled to power-of-two 512×512 px textures using Lanczos interpolation, preserving micro-relief, metallic bevels, and subtle internal weapon/heart motifs without aliasing artifacts.
- **Source Preservation:** The original source PNGs in `assets/_source/lot1/cards/icons/` remain completely untouched.

---

## 2. Attack & Health Integration Approach

In `scripts/presentation/card_stat_overlay.gd`:
- **Integrated Cabochons as Containers:** The dedicated cabochon textures are drawn centered at the independent T04B socket apertures (`ATTACK_CENTER = (162, 1279)` and `HEALTH_CENTER = (919, 1279)`).
- **Numerals Drawn Directly on Top:** The high-contrast white numerals (`TacticalNumber` font) are rendered directly over the cabochons, retaining the strict circular safe disk constraint (`SOCKET_SAFE_RADIUS = 70.0`).
- **Elimination of Separate Mini-Icons:** The procedural upper-rim collets (`_socket_emblem`) and separate mini-sword/mini-heart symbols have been removed from the default production rendering pipeline.
- **Semantic Encoding:** Meaning is now conveyed organically through:
  - Attack: Warm bronze and dark amber metallic cabochon with subtle crossed-weapon internal relief on the lower left.
  - Health: Deep faceted ruby red gemstone cabochon with bronze bezel on the lower right.
  - Numeral values remain the primary, instantly readable focal point.
- **Preservation of Armor and Shield:** The footer Armor and Shield badge plates (`Rect2(280, 1280, 198, 100)` and `Rect2(608, 1280, 198, 100)`), their calibrated local centers `(50, 50)` and `(140, 50)`, and their approved V2 icons are 100% preserved.

---

## 3. Rollback & Backwards Compatibility

Prior separate mini-icon rendering code and optical constants have been **fully preserved**:
- `CardStatOverlay.use_separate_icons: bool` allows toggling between Integrated Cabochons (`false`, default) and Historical Separate Icons (`true`).
- When `use_separate_icons = true`, the renderer dynamically draws the T11/T10/T08 collets and mini-icons.
- All historical test suites (`t08/icon_regression.gd`, `t10/icon_regression.gd`, `t11/icon_regression.gd`) continue to pass with zero failures.

---

## 4. Optical Alignment & Sizing Notes

| Parameter | Calibrated Value | Rationale |
|---|---|---|
| `CABOCHON_SIZE` | `Vector2(250, 250)` | At 250×250 px, the cabochon's inner gem diameter ($143.5\text{ px}$, $R = 71.8\text{ px}$) matches the numeral safe disk ($R = 70.0\text{ px}$) within 1.8 px, while the outer bronze bezel ($R \approx 100\text{ px}$) seats over the master frame's painted bronze bezel ($R \approx 105\text{ px}$). |
| `ATTACK_CABOCHON_OFFSET` | `Vector2(0, 0)` | In 250 px space, the visible gem center is within 0.89 px of the aperture center. |
| `HEALTH_CABOCHON_OFFSET` | `Vector2(0, 0)` | In 250 px space, the visible gem center is within 1.49 px of the aperture center. |
| Numeral Centering | Preserved T04B Centers | `ATTACK_CENTER = (162, 1279)`, `HEALTH_CENTER = (919, 1279)`. Numerals remain centered inside the cabochons with 0 px offset. |

---

## 5. Review Captures (1920×1080 Full HD & 1280×720 Secondary)

All screenshots were generated with genuine Godot 4.7.2 GPU viewport rendering on an NVIDIA GeForce GTX 1660 Ti (OpenGL Compatibility backend).

| Screenshot Deliverable | Resolution | Purpose & Key Observations |
|---|---|---|
| [attack_health_cabochons_closeup_1080p.png](attack_health_cabochons_closeup_1080p.png) | 1920 × 1080 | **2.3× macro close-up** of Attack and Health sockets. Demonstrates the rich amber/bronze and ruby red cabochon textures, subtle internal motifs, and high numeral contrast. |
| [inspected_card_1080p.png](inspected_card_1080p.png) | 1920 × 1080 | **Production inspection view** of Rampart Guard (ATK 4, HP 5, Armor 2, Shield 4, Emerald Epic gem). Proves clean, uncluttered presentation without upper-rim collet noise. |
| [seven_card_hand_1080p.png](seven_card_hand_1080p.png) | 1920 × 1080 | **Seven-card linear hand study** at in-game 1080p scale (card height 316 px). Demonstrates instant color distinction (amber vs ruby) across full hand. |
| [full_combat_interface_1080p.png](full_combat_interface_1080p.png) | 1920 × 1080 | **Full combat scene** with Sundered Observatory background, HUD, 4×6 grid, and 7-card hand at 1080p. Validates overall gameplay aesthetic and visual integration. |
| [before_after_attack_health_1080p.png](before_after_attack_health_1080p.png) | 1920 × 1080 | **Direct side-by-side card comparison** between T11 Separate Mini-Icons (left) and T13 Integrated Cabochons (right) at identical scale. Highlights the cleaner, more premium look. |
| [seven_card_hand_720p.png](seven_card_hand_720p.png) | 1280 × 720 | **Secondary compatibility check** at 720p play scale (card height 210 physical pixels). Proves numerals and color distinction remain clear without becoming muddy. |

---

## 6. Technical Verification Transcript

Working Directory: `D:\Dev\MagicOdyssey`  
Engine: `D:\Temp\Godot_v4.7.2-stable_win64.exe` (v4.7.2.stable.official.ed1daf0bf)

| Verification Step | Command / Invocation | Exit Code | Result | Observations |
|---|---|---:|---|---|
| Godot Asset Import | `--headless --editor --path . --import --quit` | `0` | **PASS** | Imported cabochon textures cleanly. |
| Native Test Harness | `scripts\tests\run_tests.ps1` | `0` | **PASS** | 14/14 core test assertions pass. |
| ART-002 Scene Init | `scenes/ui/art002_card_integration_test.tscn` | `0` | **PASS** | Scene tree and shaders compile and initialize cleanly. |
| T04B/T06 Numerical Regression | `docs/art/reviews/art002/t06/stat_regression.gd` | `0` | **PASS** | All 144 socket combinations pass (0 failures, max ink error 1.055 px). |
| T13 Cabochon Regression Suite | `docs/art/reviews/art002/t13/cabochon_regression.gd` | `0` | **PASS** | Textures, transparency, 250×250 sizing, numeral safe disks, and toggles pass. |
| T11 Backward Compatibility | `docs/art/reviews/art002/t11/icon_regression.gd` | `0` | **PASS** | Passes without modification. |
| T10 Backward Compatibility | `docs/art/reviews/art002/t10/icon_regression.gd` | `0` | **PASS** | Passes without modification. |
| T08 Backward Compatibility | `docs/art/reviews/art002/t08/icon_regression.gd` | `0` | **PASS** | Passes without modification. |
| Review Capture Suite | `docs/art/reviews/art002/t13/capture.gd` | `0` | **PASS** | All 6 review captures rendered and saved with exit code 0. |
| Whitespace & Git Diff | `git diff --check` | `0` | **PASS** | Zero trailing whitespace or format violations. |

---

## 7. Remaining Visual Limitations

1. **Subtle Internal Motif Visibility on Small Scales:** The subtle internal motifs (crossed weapons in Attack, heart contours in Health) are designed as restrained low-contrast relief to avoid competing with the white numeral. At 1080p close-up and inspection scales, they add rich tactile depth. At 720p hand scale, the motifs recede and the semantic distinction is carried primarily by color (amber vs ruby) and socket position. This is by design to ensure numeral legibility.
2. **Organic Frame Edge Blend:** Because master frame v03 has subtle hand-painted asymmetry, the outer bronze bezel of the cabochons blends with a slightly different overlap on left ($X = 162$) versus right ($X = 919$). The soft transparent drop shadow included in the runtime texture cleanly absorbs this variation.

---

## 8. Conclusion & Recommendation

**RECOMMENDATION: APPROVE (FOR OWNER FINAL SIGN-OFF)**.

The integrated cabochons deliver a markedly more unified, AAA dark-fantasy presentation. Removing the separate upper-rim mini-icons eliminates socket visual clutter, while the white numerals remain completely centered, legible, and prominent over the rich amber and ruby gemstone textures. All previous presentation and combat behaviors are preserved.
