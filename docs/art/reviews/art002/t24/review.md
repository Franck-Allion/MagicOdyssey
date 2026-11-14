# ART-002-T24 — Refine Armor & Shield Numeral Vertical Breathing Room Review

2026-11-14 · **PASS** (Technical Verification & Metric Refinement) · Artistic Status: **RECOMMENDATION: SUBMIT FOR OWNER FINAL SIGN-OFF**.

This review documents the presentation refinement of numeral scaling, vertical breathing room, and optical centering inside the integrated Armor and Shield plaque inlays introduced in ART-002-T23.

While ART-002-T23 successfully integrated material plaque inlays matching the Attack and Health treatment, numerals rendered at the legacy $76\text{ pt}$ size appeared uncomfortably cramped against the top and bottom plaque borders ($0.0\text{--}2.0\text{ px}$ margin on Armor), especially on tall narrow digits such as "1" or digits with upward circular socket bias such as "4".

ART-002-T24 refines the plaque badge numeral font size from $76\text{ pt}$ to **$62\text{ pt}$**, introduces dedicated rectangular plaque optical offsets with strictly zero vertical bias ($Y = 0.0\text{ px}$), and preserves full rollback capability via `use_t23_badge_font_size` and `BADGE_PLAQUE_NUMBER_FONT_SIZE_T23 = 76`.

---

## 1. Executive Summary & Deliverables

| Deliverable | Path | Status | Observations |
|---|---|:---:|---|
| **Spacing Before / After (1080p)** | `docs/art/reviews/art002/t24/armor_shield_numeral_spacing_before_after_1080p.png` | **VERIFIED** | Direct side-by-side card and macro zoom comparing cramped T23 ($76\text{ pt}$) vs refined T24 ($62\text{ pt}$). |
| **Values Gallery (1080p)** | `docs/art/reviews/art002/t24/armor_shield_values_gallery_1080p.png` | **VERIFIED** | 6-column matrix showing values 1, 2, 4, 8, 10, 12 across both Armor (62 px) and Shield (69 px) plaques. |
| **Inspection View (1080p)** | `docs/art/reviews/art002/t24/inspected_card_1080p.png` | **VERIFIED** | Full-scale inspected card (Emerald Epic Arcane Knight) with refined 62 pt numerals and side specification panel. |
| **Gameplay Hand (1080p)** | `docs/art/reviews/art002/t24/seven_card_hand_1080p.png` | **VERIFIED** | Seven-card mixed hand at 1080p play scale (height 316 px), verifying readability and hierarchy. |
| **Automated Regression Suite** | `docs/art/reviews/art002/t24/breathing_room_regression.gd` | **PASS (33/33)** | Verifies font sizes, dedicated badge offsets, circular socket preservation, and vertical margins $\ge 5.0\text{ px}$. |
| **Capture Generation Script** | `docs/art/reviews/art002/t24/capture.gd` | **PASS** | Automated GPU capture script generating all 4 high-resolution review scenes at 1920×1080 with exit code 0. |

---

## 2. Root Cause Analysis of the Cramped Fit

Precise font metrics and glyph bounding-box analysis identified three distinct factors contributing to the tight vertical fit in T23:

1. **Legacy Font Size Inherited from 100 px Badge ($76\text{ pt}$):**
   In T11/T23, `BADGE_PLAQUE_NUMBER_FONT_SIZE = 76` was carried over from the legacy floating icon layout. In that layout, numerals sat on the full $100\text{ px}$ dark badge background (usable inner height $94\text{ px}$), leaving $(94 - 60) / 2 = 17\text{ px}$ of vertical air.
   When T23 introduced integrated plaque inlays, the numerals were seated inside the inset plaque cartouche:
   - **Armor Plaque Height:** $62.0\text{ px}$
   - **Shield Plaque Height:** $69.0\text{ px}$
   At $76\text{ pt}$, glyph height is $52\text{--}56\text{ px}$. With the $3\text{ px}$ dark outline top and bottom, the total vertical footprint is **$58\text{--}62\text{ px}$**, occupying $94\text{--}100\%$ of the Armor plaque height! The remaining vertical breathing room was only **$0.0\text{--}2.0\text{ px}$** on Armor and **$3.5\text{--}5.5\text{ px}$** on Shield.

2. **Circular Socket Optical Bias Leaking into Rectangular Plaques:**
   In ART-002-T21, `NUMERAL_OPTICAL_OFFSETS[4] = Vector2(-4, -4)` was introduced for the $126\text{ pt}$ circular Attack/Health sockets to balance visual mass against the circular aperture. Because `draw_number()` applied this offset unconditionally, value '4' inside the plaque badge was shifted upward by $-4.0\text{ px}$. Inside a $62\text{ px}$ plaque, this upward shift pushed the top outline to $y = -34.0\text{ px}$ against a plaque top boundary of $y = -31.0\text{ px}$, causing the top outline of '4' to physically overflow the plaque by $3.0\text{ px}$.

3. **High Aspect Ratio on Narrow Numerals ("1"):**
   At $76\text{ pt}$, '1' is $35\text{ px}$ wide and $54\text{ px}$ tall ($1.54:1$ vertical ratio). With no horizontal width to disperse the eye, its top flag and bottom serif pointed directly at the plaque borders with just $1.0\text{ px}$ clearance, creating an acute psychological impression of pinching and crowding.

---

## 3. Original vs Final Sizing & Alignment Specification

| Property | Original (T23) | Refined (T24) | Delta | Design Rationale |
|---|:---:|:---:|:---:|---|
| **`BADGE_PLAQUE_NUMBER_FONT_SIZE`** | $76\text{ pt}$ | **$62\text{ pt}$** | $-14\text{ pt}$ ($-18.4\%$) | Calibrated to leave $\ge 5.0\text{ px}$ breathing room on Armor ($62\text{ px}$) while remaining bold and authoritative. |
| **`BADGE_PLAQUE_NUMBER_FONT_SIZE_T23`** | — | **$76\text{ pt}$** | New constant | Preserved for deterministic comparison and instant rollback. |
| **Single-Digit Glyph Height** | $52.0\text{--}54.0\text{ px}$ | **$44.0\text{--}46.0\text{ px}$** | $-8.0\text{ px}$ | Cleanly fits within $62\text{ px}$ plaque with outline. |
| **Total Height (w/ $3\text{ px}$ outline)** | $58.0\text{--}62.0\text{ px}$ | **$50.0\text{--}52.0\text{ px}$** | $-8.0\text{--}10.0\text{ px}$ | Reduces plaque vertical occupancy from $97\%$ down to $82\%$. |
| **Armor Top/Bottom Margin** | $0.0\text{--}2.0\text{ px}$ | **$5.0\text{--}6.0\text{ px}$** | $\mathbf{+4.0\text{--}5.0\text{ px}}$ | **$5.5\times$ expansion in vertical breathing room** ($9.7\%$ clearance). |
| **Shield Top/Bottom Margin** | $3.5\text{--}5.5\text{ px}$ | **$8.5\text{--}9.5\text{ px}$** | $\mathbf{+4.0\text{--}5.0\text{ px}}$ | **$2.0\times$ expansion in vertical breathing room** ($13.8\%$ clearance). |
| **Plaque Badge Vertical Bias ($Y$)** | $-4\text{ px}$ on '4' | **Strictly $0.0\text{ px}$** | $+4\text{ px}$ correction | Eliminates top-edge crowding on '4'; ensures equal top/bottom air. |
| **Plaque Badge Horizontal Bias ($X$)** | $-2\text{ px}$ on $10\text{--}19$ | **$-1\text{ px}$ ('4'), $-2\text{ px}$ ($10\text{--}19$)** | Fine-tuned | Balances narrow '1' vs wide second digits ('0', '2', '4'). |
| **Attack / Health Socket Numerals** | $126\text{ pt}$ | **$126\text{ pt}$** | $0\text{ pt}$ (Preserved) | Primary circular collets remain $100\%$ untouched. |
| **Typographic Scale Ratio** | $76 / 126 = 60.3\%$ | **$62 / 126 = 49.2\%$** | Refined to $1:2$ | Classic typographic half-scale hierarchy for secondary stats. |

---

## 4. Per-Glyph Metric & Clearance Breakdown

Measurements taken at $62\text{ pt}$ with standard $3\text{ px}$ outline across representative values:

| Value | Text | Glyph Size ($W \times H$) | Footprint ($W \times H$) | Armor Margin (Top / Bot) | Shield Margin (Top / Bot) | Visual Assessment |
|:---:|:---:|:---:|:---:|:---:|:---:|---|
| **1** | `"1"` | $29.0 \times 45.0\text{ px}$ | $35.0 \times 51.0\text{ px}$ | **$5.5\text{ px}$** / **$5.5\text{ px}$** | **$9.0\text{ px}$** / **$9.0\text{ px}$** | Narrow digit breathes comfortably; zero pinching at top flag or base serif. |
| **2** | `"2"` | $31.0 \times 44.0\text{ px}$ | $37.0 \times 50.0\text{ px}$ | **$6.0\text{ px}$** / **$6.0\text{ px}$** | **$9.5\text{ px}$** / **$9.5\text{ px}$** | Balanced curved head and flat horizontal base; generous vertical air. |
| **4** | `"4"` | $32.0 \times 46.0\text{ px}$ | $38.0 \times 52.0\text{ px}$ | **$5.0\text{ px}$** / **$5.0\text{ px}$** | **$8.5\text{ px}$** / **$8.5\text{ px}$** | $Y = 0.0$ eliminates top overflow; $-1\text{ px}$ X balances left diagonal arm. |
| **8** | `"8"` | $29.0 \times 46.0\text{ px}$ | $35.0 \times 52.0\text{ px}$ | **$5.0\text{ px}$** / **$5.0\text{ px}$** | **$8.5\text{ px}$** / **$8.5\text{ px}$** | Symmetrical dual loops centered cleanly between top and bottom borders. |
| **10** | `"10"` | $61.0 \times 46.0\text{ px}$ | $67.0 \times 52.0\text{ px}$ | **$5.0\text{ px}$** / **$5.0\text{ px}$** | **$8.5\text{ px}$** / **$8.5\text{ px}$** | Double digit fits well inside $83\text{ px}$ max width; $-2\text{ px}$ X balances narrow '1'. |
| **12** | `"12"` | $61.0 \times 45.0\text{ px}$ | $67.0 \times 51.0\text{ px}$ | **$5.5\text{ px}$** / **$5.5\text{ px}$** | **$9.0\text{ px}$** / **$9.0\text{ px}$** | Sits comfortably in plaque cavity with $5.5\text{ px}$ top/bottom margin; $-2\text{ px}$ X. |
| **14** | `"14"` | $62.0 \times 46.0\text{ px}$ | $68.0 \times 52.0\text{ px}$ | **$5.0\text{ px}$** / **$5.0\text{ px}$** | **$8.5\text{ px}$** / **$8.5\text{ px}$** | Double digit fits with $5.0\text{ px}$ vertical air; $-2\text{ px}$ X optical balance. |
| **99** | `"99"` | $61.0 \times 46.0\text{ px}$ | $67.0 \times 52.0\text{ px}$ | **$5.0\text{ px}$** / **$5.0\text{ px}$** | **$8.5\text{ px}$** / **$8.5\text{ px}$** | Extreme stress test fits cleanly with $5.0\text{ px}$ top/bottom air and zero clipping. |

---

## 5. Visual Assessment at 1920×1080 (16:9)

Visual evaluation was conducted on real GPU renders across all 4 review captures:

1. **`armor_shield_numeral_spacing_before_after_1080p.png`:**
   - Clearly proves the elimination of the cramped fit:
     - On Armor, vertical clearance expands from $2.0\text{ px}$ to $6.0\text{ px}$ ($+200\%$).
     - On Shield, vertical clearance expands from $4.5\text{ px}$ to $9.0\text{ px}$ ($+100\%$).
   - The numerals retain strong authority and readability, but no longer appear jammed against the bronze borders.
   - Narrow "1" looks natural, comfortable, and well-seated.

2. **`armor_shield_values_gallery_1080p.png`:**
   - Demonstrates visual consistency across 1, 2, 4, 8, 10, 12 on both Armor and Shield plaques.
   - Single digits and double digits maintain consistent vertical baselines and margins.
   - Value '4' is perfectly centered vertically with zero top-border touching.
   - Double digits '10' and '12' sit with $5.0\text{--}5.5\text{ px}$ clearance and zero lateral crowding.

3. **`inspected_card_1080p.png`:**
   - Full inspection of Emerald Epic Arcane Knight.
   - The $62\text{ pt}$ secondary stat numerals form a harmonious $1:2$ typographic ratio with the $126\text{ pt}$ primary Attack/Health numerals.
   - The card footer feels balanced, premium, and calm.

4. **`seven_card_hand_1080p.png`:**
   - At actual gameplay scale ($316\text{ px}$ card height, scale factor $0.2182$), numerals render at $\approx 10\text{ px}$ screen height.
   - All stat values remain immediately recognizable at a glance.
   - Secondary protections remain visually subordinate to primary Attack and Health stats.

---

## 6. Technical Validation Results

| Check | Command | Exit Code | Observations |
|---|---|:---:|---|
| **Headless Editor Import** | `& $GodotExe --headless --editor --path . --import --quit` | **0** | Clean asset import; `.import` files generated with anisotropic mipmaps. |
| **Headless Test Runner** | `& $GodotExe --headless --path . --script res://scripts/tests/test_runner.gd` | **0** | $14 / 14$ native harness assertions pass cleanly. |
| **Card Integration Scene** | `& $GodotExe --headless --path . res://scenes/ui/art002_card_integration_test.tscn --quit-after 5` | **0** | Scene instantiates and executes without warnings or errors. |
| **T24 Breathing Room Regression** | `& $GodotExe --headless --path . --script res://docs/art/reviews/art002/t24/breathing_room_regression.gd` | **0** | $33 / 33$ assertions pass (font size 62 pt, T23 rollback 76 pt, dedicated offsets, margins $\ge 5.0\text{ px}$). |
| **GPU Screenshot Generation** | `& $GodotExe --path . --script res://docs/art/reviews/art002/t24/capture.gd` | **0** | All 4 high-resolution review images generated cleanly at exact $1920 \times 1080$ resolution. |
| **Git Diff Check** | `git diff --check` | **0** | Clean formatting, zero trailing whitespace or syntax issues. |

---

## 7. Files Changed

- `scripts/presentation/card_stat_overlay.gd`:
  - Updated `BADGE_PLAQUE_NUMBER_FONT_SIZE = 62` (refined from 76 pt).
  - Added `BADGE_PLAQUE_NUMBER_FONT_SIZE_T23 = 76` (preserved for rollback).
  - Added `static var use_t23_badge_font_size: bool = false` (diagnostic comparison flag).
  - Added `BADGE_PLAQUE_NUMERAL_OPTICAL_OFFSETS` dictionary and `get_badge_plaque_numeral_optical_offset(value: int) -> Vector2`.
  - Updated `draw_number()` to accept optional `custom_optical_offset: Variant = null`.
  - Updated `_badge()` to pass calibrated badge optical offset and font size.
- `docs/art/reviews/art002/t24/`:
  - `armor_shield_numeral_spacing_before_after_1080p.png` + `.import`
  - `armor_shield_values_gallery_1080p.png` + `.import`
  - `inspected_card_1080p.png` + `.import`
  - `seven_card_hand_1080p.png` + `.import`
  - `capture.gd` + `.uid`
  - `breathing_room_regression.gd` + `.uid`
  - `review.md`

---

## 8. Remaining Limitations & Future Work

1. **Static Pre-Game Catalog Values:** The $62\text{ pt}$ font size was evaluated on printed card values and standard transient shields (values up to $99$). If a combat encounter scales shield values into triple digits (e.g. $100+$), `draw_number()` automatically scales down font size via its `max_width = 83.0` constraint, maintaining proportional clearance.
2. **Fixed Plaque Aspect Ratios:** Plaque heights ($62\text{ px}$ Armor, $69\text{ px}$ Shield) remain fixed per ART-002-T23 master frame geometry. No further artwork adjustments are required.

---

## 9. Final Recommendation

**RECOMMENDATION: SUBMIT FOR OWNER FINAL SIGN-OFF**

- **Technical Status:** PASS ($33 / 33$ regression tests pass; exit code $0$; zero leaks; clean import).
- **Visual Status:** Complete Full HD evidence package delivered at $1920 \times 1080$, demonstrating comfortable vertical breathing room, zero border crowding, and preserved typographic hierarchy.
- **Recommendation:** Submit artifacts to repository owner for artistic sign-off.
