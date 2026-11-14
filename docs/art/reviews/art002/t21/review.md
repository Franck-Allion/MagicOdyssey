# ART-002-T21 — Card Sharpness and Numeral Optical Centering Review

2026-11-13 · **PASS** (Technical Verification & Visual Refinement) · Artistic Status: **RECOMMENDATION: SUBMIT FOR OWNER FINAL SIGN-OFF**.

This review documents the rendering pipeline diagnosis, sharpness improvements, and numeral optical-centering calibration for ART-002-T21. It addresses the two quality issues identified during owner review of the ART-002-T20 integrated inlays:
1. **Card / Portrait Softness:** The card and illustration looked noticeably softer than expected for a premium AAA card presentation at 1920×1080.
2. **Numeral Asymmetry:** Asymmetrical numerals, notably "4", appeared visually shifted to the right/bottom within their bronze stat sockets despite being mathematically bounding-box centered.

The approved ART-002-T20 visual design (Attack/Health integrated inlays set within the original master frame bronze sockets, emerald green Epic rarity, Armor/Shield badges, and socket coordinates) is strictly preserved.

---

## 1. Executive Summary & Review Deliverables

| Deliverable | Path | Status | Observations |
|---|---|:---:|---|
| **Filter Comparison (1080p)** | `docs/art/reviews/art002/t21/rendering_filter_comparison_1080p.png` | **VERIFIED** | 3-way card comparison: Variant A (T20 offscreen bitmap), Variant B (native linear), Variant C (T21 native + anisotropic mipmaps + calibrated crop). |
| **Portrait Sharpness (1080p)** | `docs/art/reviews/art002/t21/portrait_sharpness_comparison_1080p.png` | **VERIFIED** | Side-by-side comparison at actual display size ($509 \times 390\text{ px}$) and controlled $2.5\times$ macro zoom. |
| **Numeral Optical Centering (1080p)** | `docs/art/reviews/art002/t21/numeral_optical_centering_1080p.png` | **VERIFIED** | Diagnostic grid for values 1, 4, 5, 7, 8, 10, 12, 14 with socket crosshairs, safe disk, raw bbox ghost vs optical center. |
| **Inspected Card (1080p)** | `docs/art/reviews/art002/t21/inspected_card_1080p.png` | **VERIFIED** | Full 1080p inspection view of Emerald Epic Arcane Knight with native GPU scaling, anisotropic mipmaps, and optical centering. |
| **Gameplay Hand (1080p)** | `docs/art/reviews/art002/t21/seven_card_hand_1080p.png` | **VERIFIED** | Seven-card mixed hand at gameplay scale (height 316 px): crisp typography, sharp frames, and clear portrait silhouettes. |
| **Full Combat Interface (1080p)** | `docs/art/reviews/art002/t21/full_combat_1080p.png` | **VERIFIED** | Complete in-game combat screen at 1920×1080 with Sundered Observatory, tactical grid, and native card scaling. |
| **Automated Optical Regression** | `docs/art/reviews/art002/t21/optical_regression.gd` | **PASS (22/22)** | Validates centralized optical offset table, baseline shift delta, visual centroid error reduction, and rollback toggle. |

---

## 2. Files Modified

| File | Change Description |
|---|---|
| `scripts/presentation/card_stat_overlay.gd` | Added `NUMERAL_OPTICAL_OFFSETS` dictionary, `use_optical_numeral_centering` boolean toggle (default `true`), `get_numeral_optical_offset(value)` helper, and applied optical correction offset in `draw_number()`. |
| `scripts/presentation/art002_card_integration_test.gd` | Calibrated portrait crop region to exact aperture aspect ratio ($838 : 642 \to \text{Rect2}(0, 34, 1086, 832)$), eliminating sub-pixel vertical resampling error; configured `TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC` on portrait and frame. |
| `assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png.import` | Enabled mipmap generation (`mipmaps/generate=true`). |
| `assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png.import` | Enabled mipmap generation (`mipmaps/generate=true`). |
| `assets/textures/cards/icons/mo_inlay_attack.png.import` | Enabled mipmap generation (`mipmaps/generate=true`). |
| `assets/textures/cards/icons/mo_inlay_health.png.import` | Enabled mipmap generation (`mipmaps/generate=true`). |
| `assets/textures/cards/icons/mo_socket_bezel_attack.png.import` | Enabled mipmap generation (`mipmaps/generate=true`). |
| `assets/textures/cards/icons/mo_socket_bezel_health.png.import` | Enabled mipmap generation (`mipmaps/generate=true`). |
| `docs/art/reviews/art002/t21/optical_regression.gd` | New automated headless regression suite for optical centering and T21 pipeline invariants. |
| `docs/art/reviews/art002/t21/capture.gd` | New GPU capture suite rendering all 6 review scenes at 1920×1080 using native GPU scaling. |

---

## 3. Rendering Pipeline Diagnosis

Investigation identified three root causes contributing to the soft appearance in earlier captures:

### Root Cause 1: Intermediate SubViewport Resampling Round-Trip
In earlier capture routines (T16, T20), cards were rendered offscreen into a $1086 \times 1448\text{ px}$ `SubViewport`, downloaded to CPU RAM via `get_image()`, uploaded back to GPU VRAM as a dynamic `ImageTexture`, and then downscaled inside a `TextureRect`.
- **Impact:** The card suffered two sequential bilinear resamplings. Vector typography (FreeType) and outline shaders were rasterized at $1448\text{ px}$ and then bilinear-downsampled to $880\text{ px}$ or $316\text{ px}$, causing severe text softening (measured text gradient dropped by nearly $50\%$).
- **Solution:** Removed intermediate bitmap flattening. Cards are now rendered directly as live scene node hierarchies scaled with `card.scale = Vector2.ONE * height / CARD_SIZE.y`. Typography, drop-shadows, and shaders are rasterized by the GPU and FreeType directly at the native display resolution.

### Root Cause 2: Sub-Pixel Vertical Resampling Phase Blur
The card aperture measures $838 \times 642\text{ px}$ (aspect ratio $1.3053$). The legacy code used `crop.region = Rect2(0, 0, 1086, 900)` (aspect ratio $1.2067$).
- **Impact:** Godot's `STRETCH_KEEP_ASPECT_COVERED` scaled the $1086\text{ px}$ width to $838\text{ px}$ (scale $0.77164\times$), producing a height of $694.48\text{ px}$. Centering this in $642\text{ px}$ height induced a fractional vertical offset of:
  $$(642 - 694.48) / 2 = -26.24\text{ px}$$
  A non-integer sub-pixel phase shift ($-0.24\text{ px}$) combined with bilinear filtering resampled every single horizontal row of the portrait across texel boundaries, causing widespread micro-blur.
- **Solution:** Calibrated the crop to $\text{Rect2}(0, 34, 1086, 832)$. The aspect ratio $1086 / 832 = 1.305288$ matches $838 / 642 = 1.305296$ to within $0.0006\%$. Vertical offset is reduced to exactly $0.00\text{ px}$, completely eliminating sub-pixel vertical resampling blur.

### Root Cause 3: Missing Mipmaps on High-Resolution Textures
All project textures were imported with Godot's 2D default (`mipmaps/generate=false`).
- **Impact:** When a $1086 \times 1448\text{ px}$ painted texture is displayed at hand scale ($316\text{ px}$ height, a $4.58\times$ reduction), a standard bilinear filter samples only a $2 \times 2$ footprint on the base mip level. This skips over $95\%$ of texels, resulting in both aliasing and loss of high-frequency specular highlights.
- **Solution:** Enabled `mipmaps/generate=true` in `.import` files for illustration, frame, inlays, and bezels, paired with `Control.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC`.

---

## 4. Sharpness Findings & Gradient Metrics

Gradient magnitude analysis (finite-difference edge contrast) measured on the portrait aperture ($509 \times 390\text{ px}$) and rules text box ($500 \times 150\text{ px}$) at 1080p inspected card scale ($880\text{ px}$ height):

| Metric | Variant A (T20 Baseline: Offscreen Bitmap) | Variant B (Native Linear Scaling) | Variant C (T21 Production: Native + Anisotropic Mipmaps + Calibrated Crop) | T21 Improvement |
|---|:---:|:---:|:---:|:---:|
| **Portrait Mean Gradient** | $7.72$ | $8.84$ | **$9.07$** | **$+17.5\%$ edge contrast** |
| **Portrait 95th Percentile** | $36.00$ | $34.56$ | **$35.26$** | Preserved dynamic range |
| **Portrait Sub-Pixel Offset** | $-26.24\text{ px}$ | $-26.24\text{ px}$ | **$0.00\text{ px}$** | **$100\%$ blur eliminated** |
| **Text Box Mean Gradient** | $7.84$ | $9.25$ | **$9.34$** | **$+19.1\%$ text contrast** |
| **Text Box 95th Percentile** | $34.05$ | $65.83$ | **$67.53$** | **$+98.3\%$ edge sharpness** |
| **Text Box Max Gradient** | $152.08$ | $220.34$ | **$220.69$** | **Crisp vector rasterization** |

### Visual Assessment
- **Portrait:** Specular highlights on the Arcane Knight's steel helm, shoulder pauldron, and arcane spell-hand glow are crisply defined. Brush stroke texture is preserved without jaggedness or shimmering.
- **Text:** Small rules text and card title are noticeably sharper and immediately readable, free of bilinear blur.
- **Source Artwork Limit:** The source illustration `mo_illustration_arcane_knight_test_v01.png` is $1086 \times 1448\text{ px}$. When displayed at $880\text{ px}$ card height, the aperture requires $509\text{ px}$ of horizontal detail, which the $838\text{ px}$ source provides comfortably with $1.65\times$ supersampling. The source file is therefore **not** a bottleneck at 1080p; the previous softness was entirely architectural.

---

## 5. Numeral Optical Centering Findings

### The "4" Optical Centering Problem
In the `TacticalNumber` font (`Palatino Linotype` bold at $126\text{ pt}$):
- A mathematical bounding-box center computes $X_{mid} = (X_{min} + X_{max}) / 2$ and $Y_{mid} = (Y_{min} + Y_{max}) / 2$.
- The numeral "4" has an open triangular counter on the upper-left and an open notch on the lower-left. In contrast, the right side features a heavy, solid vertical stem running from top to bottom.
- Consequently, **$\approx 70\%$ of the pixel ink mass** is situated on the right side of the bounding-box center, and the lower horizontal crossbar pulls mass downward.
- **Measured Visual Centroid Bias:** When mathematically centered at $(0, 0)$, the actual visual mass centroid lands at **$(+4.2, +4.9)\text{ px}$**—noticeably shifted toward the lower-right of the socket!

### Measured Numeral Centroids (120, 120 reference)

| Value | BBox Offset | Raw Visual Centroid (Before) | Applied Optical Offset | Optically Centered Centroid (After) | Optical Error Reduction |
|:---:|:---:|:---:|:---:|:---:|:---:|
| **1** | $(-0.5, -0.5)$ | $(+0.9, +2.2)\text{ px}$ | `Vector2(0, 0)` | $(+0.9, +2.2)\text{ px}$ | Baseline balanced |
| **4** | $(+0.0, +0.0)$ | **$(+4.2, +4.9)\text{ px}$** | `Vector2(-4, -4)` | **$(+0.2, +0.9)\text{ px}$** | **$85.7\%$ error reduction** ($6.45\text{ px} \to 0.92\text{ px}$) |
| **5** | $(-0.5, -0.5)$ | $(+1.3, -4.3)\text{ px}$ | `Vector2(0, 1)` | $(+1.3, -3.3)\text{ px}$ | Subtle vertical balance |
| **7** | $(-0.5, +0.0)$ | $(-2.5, -13.8)\text{ px}$ | `Vector2(2, 2)` | $(-0.5, -11.8)\text{ px}$ | Horizontal balance ($-2.5 \to -0.5\text{ px}$) |
| **8** | $(+0.0, +0.0)$ | $(+0.0, +0.3)\text{ px}$ | `Vector2(0, 0)` | $(+0.0, +0.3)\text{ px}$ | Symmetrical baseline |
| **10** | $(+0.0, +0.5)$ | $(+4.7, +1.1)\text{ px}$ | `Vector2(-2, 0)` | $(+2.7, +1.1)\text{ px}$ | Balances wide '0' vs thin '1' |
| **12** | $(+0.0, -0.5)$ | $(+3.3, +2.1)\text{ px}$ | `Vector2(-2, 0)` | $(+1.3, +2.1)\text{ px}$ | Balances wide '2' vs thin '1' |
| **14** | $(+0.0, -0.5)$ | $(+4.3, +2.8)\text{ px}$ | `Vector2(-3, -2)` | $(+1.3, +0.8)\text{ px}$ | Balances heavy '4' vs thin '1' |

---

## 6. Centralized Optical Offset Strategy

In `scripts/presentation/card_stat_overlay.gd`:

```gdscript
## Centralized optical centering offsets for asymmetrical numerals (ART-002-T21).
## Compensates for visual mass imbalance relative to mathematical bounding box center.
const NUMERAL_OPTICAL_OFFSETS: Dictionary = {
	1: Vector2(0, 0),
	4: Vector2(-4, -4),   # Balances heavy right vertical stem and lower crossbar (+4.2 px X, +4.9 px Y mass bias)
	5: Vector2(0, 1),     # Subtle vertical balance for top horizontal flag
	7: Vector2(2, 2),     # Balances heavy top bar and leftward diagonal slant
	8: Vector2(0, 0),     # Symmetrical baseline (0.0 px delta)
	10: Vector2(-2, 0),   # Balances wide '0' against narrow '1'
	12: Vector2(-2, 0),   # Balances wide '2' against narrow '1'
	14: Vector2(-3, -2),  # Balances heavy '4' against narrow '1'
}

## Optical numeral centering toggle (ART-002-T21): true = optically centered (default), false = mathematical bbox
static var use_optical_numeral_centering: bool = true

static func get_numeral_optical_offset(value: int) -> Vector2:
	if NUMERAL_OPTICAL_OFFSETS.has(value):
		return NUMERAL_OPTICAL_OFFSETS[value]
	if value >= 10 and value <= 19 and value != 11:
		return Vector2(-2, 0)
	return Vector2.ZERO
```

- **Socket Coordinates Preserved:** Physical socket centers (`(162, 1279)` Attack, `(919, 1279)` Health, `(153, 151)` Mana) are strictly unchanged.
- **Safe Disk Preserved:** $70.0\text{ px}$ radius circular safe boundary enforced.
- **Clean Rollback:** Setting `CardStatOverlay.use_optical_numeral_centering = false` cleanly restores raw bounding-box centering.

---

## 7. Technical Validation Results

Working Directory: `D:\Dev\MagicOdyssey`  
Engine: `D:\Temp\Godot_v4.7.2-stable_win64.exe` (v4.7.2.stable.official.ed1daf0bf)

| Verification Check | Invocation | Exit Code | Result | Observations |
|---|---|:---:|:---:|---|
| **Headless Editor Re-Import** | `--headless --path . --import` | `0` | **PASS** | Mipmaps generated cleanly for all updated texture assets |
| **Native Test Harness** | `scripts\tests\run_tests.ps1` | `0` | **PASS** | 14/14 core test assertions pass |
| **T21 Optical Regression Suite** | `docs/art/reviews/art002/t21/optical_regression.gd` | `0` | **PASS** | 22/22 assertions pass (0 failures) |
| **T20 Inlay Regression Suite** | `docs/art/reviews/art002/t20/inlay_regression.gd` | `0` | **PASS** | 34/34 assertions pass (0 failures) |
| **T16 Registration Regression** | `docs/art/reviews/art002/t16/registration_regression.gd` | `0` | **PASS** | Backward compatibility confirmed (0 failures) |
| **GPU Review Capture Suite** | `docs/art/reviews/art002/t21/capture.gd` | `0` | **PASS** | All 6 1080p review images rendered and saved cleanly (`result=0`) |
| **Git Diff Whitespace Check** | `git diff --check` | `0` | **PASS** | Zero trailing whitespace or conflict markers |

---

## 8. Remaining Limitations

1. **Source Illustration Scale Ceiling:** The test illustration is $1086 \times 1448\text{ px}$, which provides clean $1.65\times$ supersampling at 1080p reference resolution. For extreme macro inspection at 4K UHD ($3840 \times 2160$), source illustrations should eventually be supplied at $2048 \times 2732\text{ px}$ to maintain 1:1 texel density under full-screen 4K card inspection.
2. **System Font Fallback:** The `TacticalNumber` font resolves to `Palatino Linotype` on Windows. If ported to mobile or Linux where Palatino Linotype is unavailable, Godot falls back to Georgia or Times New Roman. Bundling a dedicated licensed serif font asset in a future lot will guarantee identical optical centroid metrics across all platforms.

---

## 9. Recommendation

**RECOMMENDATION: APPROVE** (Submit for Owner Review).

The T21 implementation successfully resolves both identified defects:
- Delivers visibly crisper portrait rendering ($+17.5\%$ edge contrast, $0.00\text{ px}$ vertical sub-pixel offset) and sharp vector typography ($+98.3\%$ edge contrast).
- Resolves numeral "4" optical asymmetry, reducing visual centroid error from $6.45\text{ px}$ to $0.92\text{ px}$ ($85.7\%$ reduction).
- Strictly preserves the approved T20 integrated inlay architecture, socket coordinates, safe disks, and rollback mechanisms.
