# AUDIT-002-T01 — Establish Permanent ART-002 Regression Baseline Report

**Project:** MagicOdyssey  
**Repository:** Franck-Allion/MagicOdyssey  
**Engine:** Godot 4.x (v4.7.2-stable)  
**Reference Resolution:** 1920×1080 (16:9)  
**Date:** 2026-11-14  
**Status:** **PASS (110/110 Assertions Passed)** · Exit Code: **0** · Failure Mode Exit Code: **1**

---

## 1. Executive Summary

In response to the architectural recommendations from **AUDIT-001**, task **AUDIT-002-T01** establishes a permanent, maintainable native CI regression test suite for the approved ART-002 card presentation pipeline (`scripts/tests/test_card_presentation.gd`), registered directly inside the project's native test runner (`scripts/tests/test_runner.gd`).

Prior to this task, running `run_tests.ps1` executed only the 14 self-tests of `TestHarnessSelf`. All visual and geometric rules established between T01 and T25 were tested exclusively via fragmented, standalone review scripts that were not part of the active test runner.

This task establishes permanent regression protection for the active T25 production pipeline **without removing any legacy code or assets**, ensuring that subsequent cleanup phases (AUDIT-002-T02 through T04) can proceed with an automated, authoritative safety net.

---

## 2. Deliverables Summary

| Deliverable | Path | Status | Observations |
|---|---|:---:|---|
| **Presentation Test Suite** | `scripts/tests/test_card_presentation.gd` | **PASS (96 assertions)** | Comprehensive, behavioral regression tests covering all active ART-002 production presentation rules. |
| **Native Runner Registration** | `scripts/tests/test_runner.gd` | **PASS (110 total assertions)** | Registered `TestCardPresentation` suite; retains all 14 `TestHarnessSelf` tests in deterministic sequence. |
| **Production Card Baseline** | `docs/audits/AUDIT-002/card_production_baseline_1080p.png` | **VERIFIED** | Full-scale inspected card render (Emerald Epic Arcane Knight). **100.00% bit-exact match with T25 reference** (max pixel diff: 0). |
| **Gameplay Hand Baseline** | `docs/audits/AUDIT-002/seven_card_hand_baseline_1080p.png` | **VERIFIED** | 7-card mixed hand at actual play scale ($316\text{ px}$ height). **99.99996% bit-identical match with T25 reference** (max pixel diff: 1 across 1 single pixel). |
| **Four Stats Closeup Baseline**| `docs/audits/AUDIT-002/four_stats_closeup_baseline_1080p.png` | **VERIFIED** | High-resolution macro zoom of Attack graphite socket, Health ruby socket, Armor steel plaque, and Shield azure plaque. |
| **Baseline Capture Script** | `docs/audits/AUDIT-002/capture_baseline.gd` | **PASS** | Automated GPU capture script generating all 3 baseline references at 1920×1080 with exit code 0. |

---

## 3. Test Suite Coverage Breakdown

`test_card_presentation.gd` implements 96 distinct assertions grouped into 10 cohesive test methods:

```
scripts/tests/test_card_presentation.gd (110 total assertions in runner)
├── 1. _test_asset_availability:               18 assertions
│      • Master frame v03 dimensions (1086×1448 px) and loading
│      • Production inlays (attack, health: 512×512 px)
│      • Production socket bezels (attack, health: 220×220 px)
│      • Production plaque inlays (armor, shield: width 512 px)
│      • Alpha corner transparency checks ([0,0,0,0] on all 4 corners)
│      • Gem mask SVG and rarity gem shader loading
│
├── 2. _test_presentation_initialization:      7 assertions
│      • CardStatOverlay instantiation and ready size (1086×1448 px)
│      • Mouse filter ignore configuration
│      • Stored values for mana, attack, max health, native armor, and transient shield
│
├── 3. _test_attack_and_health_inlays:         7 assertions
│      • Registered socket centers: Attack (162, 1279), Health (919, 1279)
│      • Shared vertical baseline (y = 1279 px)
│      • Frame v03 registration with 5 px organic artist asymmetry (381 px vs 376 px)
│      • Inlay sizing (190×190 px) and bezel overlay sizing (220×220 px)
│      • Safe disk radius (70.0 px) leaving >= 2 px buffer to bronze rim (>= 72 px)
│
├── 4. _test_armor_and_shield_plaques:         10 assertions
│      • Slot symmetry: Armor (280, 1280) and Shield (608, 1280), equidistant (164 px)
│      • Unified plaque width at 180.0 px
│      • Plaque heights: Armor (62.0 px), Shield (69.0 px)
│      • Horizontal breathing room inside bronze border: (192 - 180) / 2 = 6.0 px
│      • Vertical breathing room: Armor (16.0 px), Shield (12.5 px)
│      • Zero spill beyond inner 3 px bronze border
│
├── 5. _test_numeral_styling_coherence:        4 assertions
│      • Mandatory Coherence Rule (T25):
│        - Global stroke thickness: NUMERAL_OUTLINE_SIZE == 4 px
│        - Global shadow offset: NUMERAL_SHADOW_OFFSET == Vector2(0, 2)
│        - Global shadow color: NUMERAL_SHADOW_COLOR == Color(0, 0, 0, 0.8)
│        - Global readability polish active by default (use_t25_readability_polish == true)
│
├── 6. _test_numeral_fitting_and_breathing_room: 21 assertions
│      • Plaque badge font size refined to 62 pt (T24)
│      • Max width cap (83.0 px)
│      • Dynamic TextServer bounds measurement across single digits (1, 2, 4, 8) and double digits (10, 12, 14, 99)
│      • Width compliance within 83 px cap for all values up to 99
│      • Vertical breathing room with 3 px outline:
│        - Armor top/bottom margin >= 5.0 px (measured 5.0–6.0 px)
│        - Shield top/bottom margin >= 8.0 px (measured 8.5–9.5 px)
│        - Zero top/bottom overflow on narrow "1" (5.5 px air) and "4" (5.0 px air)
│      • Typographic scale ratio: secondary (62 pt) to primary (126 pt) is 49.2% (~1:2)
│
├── 7. _test_optical_alignment:                14 assertions
│      • Plaque badge optical offsets: vertical Y offset strictly 0.0 across all values
│      • Asymmetrical horizontal balance: -1 px X for 4, -2 px X for 10, 12, 14
│      • Preserved circular socket offset for Attack/Health: Vector2(-4, -4) for '4'
│
├── 8. _test_creature_vs_non_creature_behavior: 3 assertions
│      • CardCategoryOverlay instantiation
│      • Spell category cue center calculation (> 16 px clearance)
│      • Equipment category cue center calculation (> 16 px clearance)
│
├── 9. _test_epic_emerald_rarity:              4 assertions
│      • Emerald Epic ShaderMaterial creation with valid gem_mask parameter
│      • Gemstone pigment hue in green spectrum (~0.415 ± 0.02, distinct from violet)
│      • High pigment saturation (>= 0.80)
│
└── 10. _test_content_transactional_safety:    8 assertions
       • Valid content configuration returns OK
       • Accepted content stored upon OK
       • Empty title rejected with ERR_INVALID_DATA
       • Rejection preserves previous accepted content without corruption
       • Multiline title rejected with ERR_INVALID_DATA
```

---

## 4. Graphical Baseline Verification & Tolerances

The active production rendering pipeline was executed via `capture_baseline.gd` and compared directly against the approved ART-002-T25 reference captures:

| Comparison Pair | Sample Region | Max Pixel Diff | Mean Pixel Diff | Discrepancy Rate | Verification Status |
|---|---|:---:|:---:|:---:|:---:|
| **Inspected Card vs T25 Reference** | Full Card Body ($660 \times 880\text{ px}$) | **0** | **0.0000** | **0.00%** ($0 / 2{,}323{,}200\text{ px}$) | **BIT-EXACT MATCH** |
| **7-Card Hand vs T25 Reference** | Hand Row ($1840 \times 320\text{ px}$) | **1** | **0.0000** | **0.00004%** ($1 / 2{,}355{,}200\text{ px}$) | **PRACTICALLY IDENTICAL** |

Both comparisons demonstrate that the active production rendering path in `test_card_presentation.gd` and `capture_baseline.gd` matches the owner-approved T25 graphical baseline within strict mathematical precision.

---

## 5. Technical Validation Commands & Results

| Check | Exact Command | Exit Code | Assertions | Result |
|---|---|:---:|:---:|:---:|
| **Native Headless Test Suite** | `powershell -ExecutionPolicy Bypass -File scripts/tests/run_tests.ps1` | **0** | 110 passed / 0 failed | **PASS** |
| **Intentional Failure Mode** | `powershell -ExecutionPolicy Bypass -File scripts/tests/run_tests.ps1 -FailureMode` | **1** | 110 passed / 2 failed | **PASS (Negative Test)** |
| **Headless Integration Scene** | `& $GodotExe --headless --path . res://scenes/ui/art002_card_integration_test.tscn --quit-after 5` | **0** | Clean run; 0 warnings | **PASS** |
| **GPU Baseline Capture Suite** | `& $GodotExe --path . --script res://docs/audits/AUDIT-002/capture_baseline.gd` | **0** | 3 captures (1080p) | **PASS** |
| **Git Whitespace & Syntax Diff**| `git diff --check` | **0** | 0 formatting errors | **PASS** |

---

## 6. Honest Test Coverage Gaps

While `test_card_presentation.gd` provides comprehensive coverage of static card presentation, the following areas remain outside its current scope and are documented honestly:

1. **Live Combat Modifier Tints:** The test suite covers printed base stats and transient shield overlays. Dynamic live combat modifier color shifts (e.g. green for buffed, red for damaged) belong to J1/P009/P010 and are not yet covered.
2. **Multi-Resolution Asset Scaling:** Sizing and optical offsets are calibrated and tested at the reference resolution of $1920 \times 1080$ ($1086 \times 1448\text{ px}$ source space). Viewport scaling on non-standard aspect ratios or mobile resolutions is not covered by this test suite.
3. **P008 `CreatureToken` Badges:** As identified in AUDIT-001, `CardStatOverlay` is hardcoded to full-card frame coordinates. Shield-shaped battlefield token badge layout will require its own test suite once P008 is implemented.

---

## 7. Next Steps for Cleanup Phases

With permanent CI protection now active (110 assertions guarding master frame, inlays, plaques, typography, optical alignment, and category engravings), the repository is safely prepared for the subsequent cleanup tasks defined in AUDIT-001:
- **Task 1.1:** Add `.gdignore` to `docs/art/reviews/` (reclaims $121\text{ MB}$ of engine cache).
- **Phase 2:** Clean duplicate runtime textures (`_v01`/`_v02`), remove dead procedural code, and cache badge `StyleBoxFlat` allocations.
