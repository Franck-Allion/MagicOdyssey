# ART-002-T20 — Integrated Attack & Health Inlays Review

2026-11-13 · **PASS** (Technical Verification & Geometric Integration) · Artistic Status: **RECOMMENDATION: SUBMIT FOR OWNER FINAL SIGN-OFF**.

This review documents the integration of dedicated Attack and Health inlay assets into the existing master card frame bronze sockets (`mo_card_frame_master_v03.png`). This addresses the owner review finding from ART-002-T15/T16: complete cabochons overlaid on top of the card frame duplicated the sculpted bronze sockets, producing visible double rings and an artificial pasted-on medallion look.

The solution preserves the original master frame's ornamental bronze rings, bevels, cardinal points, highlights, and shadows by replacing only the internal dark cavity material with dedicated inlay textures seated seamlessly inside the bronze sockets.

---

## 1. Executive Summary & Deliverables

| Deliverable | Path | Status | Observations |
|---|---|:---:|---|
| **Inlays Closeup (1080p)** | `docs/art/reviews/art002/t20/attack_health_inlays_closeup_1080p.png` | **VERIFIED** | Macro zoom of Attack (graphite steel) and Health (crimson ruby) inlays set inside original bronze sockets. |
| **Mask Diagnostics (1080p)** | `docs/art/reviews/art002/t20/inlay_mask_diagnostics_1080p.png` | **VERIFIED** | 4-panel layer breakdown, 360-ray boundary measurement, zero bronze spill, and T04B safe disk protection. |
| **Before / After Comparison (1080p)** | `docs/art/reviews/art002/t20/before_after_cabochons_1080p.png` | **VERIFIED** | Side-by-side card and macro zoom comparing T16 cabochons (duplicate ring) vs T20 integrated inlays (unified collet). |
| **Inspection View (1080p)** | `docs/art/reviews/art002/t20/inspected_card_1080p.png` | **VERIFIED** | Clean production card inspection view (Emerald Epic Arcane Knight) with all 4 stats and badges active. |
| **Gameplay Hand (1080p)** | `docs/art/reviews/art002/t20/seven_card_hand_1080p.png` | **VERIFIED** | Seven-card mixed hand at 1080p scale (height 316 px): 5 creatures, 1 spell, 1 equipment with inactive sockets. |
| **Secondary Hand (720p)** | `docs/art/reviews/art002/t20/seven_card_hand_720p.png` | **VERIFIED** | Seven-card mixed hand at 720p play scale (height 210 px) verifying numeral legibility. |
| **Full Combat Interface (1080p)** | `docs/art/reviews/art002/t20/full_combat_1080p.png` | **VERIFIED** | Full in-game combat screen at 1920×1080 with Sundered Observatory background, HUD, grid, and hand. |
| **Automated Regression Suite** | `docs/art/reviews/art002/t20/inlay_regression.gd` | **PASS (34/34)** | Texture loading, transparent corners, aperture alpha, optical constants, centers, and rollback flags. |
| **Asset Preparation Tool** | `docs/art/reviews/art002/t20/prepare_assets.py` | **PASS** | Geometric circle fitting, centering shift, stray alpha zeroing, and 512×512 RT downsampling. |

---

## 2. Source and Runtime Asset Mappings

Source assets provided in `assets/_source/lot1/cards/icons/` were inspected and processed into optimized runtime textures under `assets/textures/cards/icons/`. Source files remain completely unmodified.

| Asset Role | Source File (Unmodified) | Runtime File (Optimized) | Canvas Size | Visual Disk Center | Visual Disk Radius | Color Identity |
|---|---|---|:---:|:---:|:---:|---|
| **Attack Inlay** | `mo_stat_inlay_attack_v01.png` | `mo_inlay_attack.png`<br>`mo_inlay_attack_v01.png` | $512 \times 512\text{ px}$ | $(256.0, 256.0)$ | $205.0\text{ px}$ | Cool graphite steel / titanium disk (Mean RGB: 53, 61, 68) |
| **Health Inlay** | `mo_stat_inlay_health_v01.png` | `mo_inlay_health.png`<br>`mo_inlay_health_v01.png` | $512 \times 512\text{ px}$ | $(256.0, 256.0)$ | $202.0\text{ px}$ | Rich crimson ruby / bloodstone disk (Mean RGB: 121, 11, 12) |
| **Attack Bronze Bezel** | `mo_card_frame_master_v03.png` | `mo_socket_bezel_attack.png` | $220 \times 220\text{ px}$ | $(110.0, 110.0)$ | Aperture $r \le 71.5\text{ px}$ | Master frame bronze ring, bevel, highlights, shadows & cardinal points |
| **Health Bronze Bezel** | `mo_card_frame_master_v03.png` | `mo_socket_bezel_health.png` | $220 \times 220\text{ px}$ | $(110.0, 110.0)$ | Aperture $r \le 71.5\text{ px}$ | Master frame bronze ring, bevel, highlights, shadows & cardinal points |

### Asset Preparation Highlights
1. **Centering & Offset Elimination:** In the source $1254 \times 1254\text{ px}$ files, the circle fit centers were shifted by $(-5.15, +4.98)\text{ px}$ (Attack) and $(-11.70, -0.09)\text{ px}$ (Health). The preparation script centered each disk exactly at $(627.0, 627.0)$ before Lanczos downsampling to $512 \times 512\text{ px}$, resulting in a perfectly centered disk at $(256.0, 256.0)$ with zero baked offset.
2. **Clean Transparency:** Sub-threshold stray alpha ($< 5$) was zeroed. All 4 texture corners in both source and runtime textures verify strictly at $[0, 0, 0, 0]$.
3. **No Unwanted Rings:** Inspection verified that neither inlay asset contains an outer bronze, gold, or metallic bezel. They are pure circular material inlays designed specifically to replace the socket interior.

---

## 3. Measured Frame Socket Geometry

Master frame `mo_card_frame_master_v03.png` was measured using 360-ray radial gradient analysis from reference centers:
- **Attack Socket Center:** $(162, 1279)$
- **Health Socket Center:** $(919, 1279)$

### Radial Zone Breakdown

| Zone | Radius ($R$) | Master Frame Characteristics | Inlay Integration Behavior |
|---|:---:|---|---|
| **Core Cavity** | $0.0 \le r \le 65.0\text{ px}$ | Flat dark charcoal/blue-gray floor ($\text{Lum} \approx 9 - 25$, Max RGB $< 30$) | 100% replaced by inlay material ($\text{Lum} \approx 50 - 65$). |
| **Safe Disk (T04B)** | $r \le 70.0\text{ px}$ | Conservative numeral safe zone; zero bronze metal | Centered white numeral with dark outline rendered cleanly. |
| **Aperture Boundary** | $71.5 \le r \le 74.5\text{ px}$ | Deep cast shadow / crevice at the foot of the bronze bevel | Smoothstep antialiased transition where bronze bevel begins. |
| **Bronze Inner Bevel** | $74.5 \le r \le 81.0\text{ px}$ | Hand-painted bronze slope rising from shadow to crest | Original master frame bronze bevel is 100% visible and on top. |
| **Bronze Crest** | $R \approx 83.9\text{ px}$ | Highest bronze highlight / ridge ring ($\text{Lum} \approx 160 - 205$) | 100% preserved; zero overlap or competing metallic bezel. |
| **Outer Bronze Rim** | $R \approx 97.2\text{ px}$ | Outer sculpted ridge of the socket ring | 100% preserved; sharp, coherent definition. |
| **Cardinal Ornaments** | $R \approx 104.0\text{ px}$ | Foliage transitions and prongs at cardinal axes (N, S, E, W) | 100% untouched; full structural integrity maintained. |

### Minimum Metal Detection
- Attack Socket minimum detected warm bronze metal: **$71.75\text{ px}$** (at angle $272^\circ$).
- Health Socket minimum detected warm bronze metal: **$71.75\text{ px}$** (at angle $269^\circ$).
- Both sockets have zero bronze pixels inside $r \le 71.5\text{ px}$.

---

## 4. Layering and Masking Architecture

To satisfy the core requirement that the inlays appear *underneath* the original bronze socket ornamentation, card composition follows a strictly non-destructive 4-layer order:

```
┌─────────────────────────────────────────────────────────────────┐
│ Layer 4: White Stat Numerals & Badges (TacticalNumber, Center)  │
├─────────────────────────────────────────────────────────────────┤
│ Layer 3: Master-Frame Bronze Socket Ornamentation (Aperture)   │
│          • Retains bronze ring, bevel, highlights, shadows      │
│          • Dark floor keyed out (transparent at r <= 71.5 px)   │
│          • Original cardinal points 100% untouched              │
├─────────────────────────────────────────────────────────────────┤
│ Layer 2: Stat Inlay Material (190×190 px, R = 76 px)           │
│          • Attack: mo_inlay_attack.png (Graphite Steel)         │
│          • Health: mo_inlay_health.png (Crimson Ruby)           │
│          • Seated underneath Layer 3 bronze bevel               │
├─────────────────────────────────────────────────────────────────┤
│ Layer 1: Card Artwork & Master Frame v03 Body                   │
└─────────────────────────────────────────────────────────────────┘
```

### Why Layer 3 Over Layer 2 Eliminates Double Rings
1. **Physical Collet Setting:** In traditional jewelry or metalcraft, a stone or enamel inlay is set *inside* a carved metal collet; the metal bevel slopes inward over the edge of the stone. By placing Layer 3 (the master frame's bronze bevel) over Layer 2 (the inlay material), the hand-painted bronze edge naturally overlaps the outer edge of the inlay disc.
2. **Zero Bronze Spill:** Because the bronze bevel is in front, no inlay pixel can ever spill over the bronze ring or onto the frame foliage.
3. **Zero Masking Seams or Gaps:** Hand-painted sockets are not mathematically ideal circles (inner bronze edge varies between $71.75\text{ px}$ and $81.0\text{ px}$). Because the inlay extends to $R = 76\text{ px}$ underneath the bevel, any angular variation in the painted edge is naturally covered by bronze without leaving unpainted gaps.
4. **Complete Preservation of Cardinal Points:** Cardinal ornaments at the outer rim ($R \ge 97\text{ px}$) are completely untouched and free of overlapping cabochon bezels or drop shadows.

---

## 5. Before vs After Comparison

| Visual Aspect | T16 Cabochon Baseline (Before) | T20 Integrated Inlay (After) | Status |
|---|---|---|:---:|
| **Socket Construction** | Independent cabochon medallion stamped over socket | Inset material disc installed inside master bronze socket | **RESOLVED** |
| **Outer Metallic Rings** | **2 concentric rings** (outer bronze + inner graphite bezel) | **1 single unified ring** (original sculpted bronze frame) | **ELIMINATED** |
| **Bezel Appearance** | Overlapping, competing metallic rims with pasted-on look | Coherent, physically plausible inset collet setting | **CRAFTSMAN LOOK** |
| **Bronze Highlights & Shadows** | Partially obscured by cabochon's dark drop shadow | 100% preserved; master frame highlights & bevel intact | **PRESERVED** |
| **Cardinal Points** | Encroached by $230\text{ px}$ cabochon boundary | 100% untouched and visible | **PRESERVED** |
| **Color Identity** | Cold graphite vs warm bronze | Cold graphite steel (ATK) vs warm crimson ruby (HP) | **STRONG CONTRAST** |
| **Numeral Readability** | White numerals on dark core | White numerals on dark textured inlay core ($>8:1$ contrast) | **EXCELLENT** |
| **Coherence with Mana** | Mana was dark painted socket; Attack/Health were medals | All 3 sockets share identical master frame bronze bezels | **COHERENT** |

---

## 6. Numerical Rendering & System Preservation

1. **Numeral Coordinates & Safe Disks (T04B):**
   - Attack Numeral Center: strictly $(162, 1279)$.
   - Health Numeral Center: strictly $(919, 1279)$ (and Mana at $(153, 151)$).
   - Safe Disk Radius: strictly $70.0\text{ px}$.
   - All auto-fitting algorithms, kerning, and white numeral styling with dark outlines remain 100% untouched.
2. **Spell and Equipment Cards (T06):**
   - Spells and Equipment do not use `CardStatOverlay`; they use `CardCategoryOverlay`.
   - Their Attack and Health sockets remain untouched inactive dark sockets with category engravings.
3. **Armor and Shield Badges (T08/T10):**
   - Armor badge (left of Health socket) and Shield badge (right of Attack socket) preserve their exact positions, dimensions, and typography.
4. **Rarity Gems (T03C):**
   - Epic rarity verified with emerald green treatment (`card_rarity_gems.gdshader`).
5. **Instant Rollback Capability:**
   - Setting `CardStatOverlay.presentation_mode = 1` or `CardStatOverlay.use_inlays = false` instantly restores the T16 calibrated cabochons.
   - Setting `CardStatOverlay.presentation_mode = 2` or `CardStatOverlay.use_separate_icons = true` restores the T11 separate mini-icons over socket.
   - Setting `CardStatOverlay.presentation_mode = 3` or `CardStatOverlay.use_procedural_icons = true` restores procedural silhouettes.

---

## 7. Technical Validation Results

Working Directory: `D:\Dev\MagicOdyssey`  
Engine: `D:\Temp\Godot_v4.7.2-stable_win64.exe` (v4.7.2.stable.official.ed1daf0bf)

| Verification Check | Invocation | Exit Code | Result | Observations |
|---|---|:---:|:---:|---|
| **Headless Editor Asset Import** | `--headless --path . --import` | `0` | **PASS** | Generated `.import` files cleanly for all new runtime textures. |
| **Native Test Harness** | `scripts\tests\run_tests.ps1` | `0` | **PASS** | 14/14 core test assertions pass. |
| **T20 Inlay Regression Suite** | `docs/art/reviews/art002/t20/inlay_regression.gd` | `0` | **PASS** | 34/34 assertions pass (0 failures). |
| **T16 Registration Regression Suite** | `docs/art/reviews/art002/t16/registration_regression.gd` | `0` | **PASS** | Backward compatibility confirmed (0 failures). |
| **GPU Review Capture Suite** | `docs/art/reviews/art002/t20/capture.gd` | `0` | **PASS** | All 6 1080p scenes + 720p secondary capture rendered and saved (`result=0`). |
| **Git Diff Whitespace Check** | `git diff --check` | `0` | **PASS** | Zero trailing whitespace or conflict markers. |

---

## 8. Known Limitations

1. **Static Inlay Lighting:** The inlay textures have baked top-left ambient lighting matching the master card frame's global light direction ($135^\circ$ top-left key light). If real-time normal maps or dynamic card tilt lighting are introduced in future lots, the inlays will need corresponding normal/roughness textures.
2. **Fixed Hand Scale:** At 720p hand scale (card height 210 px), the inlays measure $\approx 27\text{ px}$ in diameter. While numerals remain legible due to high-contrast white text with black outline, the subtle internal stone texture resolves into solid color at that scale.

---

## 9. Recommendation

**RECOMMENDATION: APPROVE** (Submit for Owner Review).

The T20 implementation fulfills all technical and artistic requirements of ART-002-T20:
- Eliminates duplicate metallic rings completely.
- Preserves the master frame's sculpted bronze rings, bevels, highlights, and cardinal points.
- Delivers a physically plausible, inset craftsman collet setting.
- Maintains strong Attack (graphite steel) and Health (crimson ruby) color distinction.
- Preserves all existing numeral centers, safe disks, and backward-compatible rollback modes.
