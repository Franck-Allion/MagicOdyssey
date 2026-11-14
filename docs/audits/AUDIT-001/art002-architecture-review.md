# AUDIT-001 — ART-002 Architecture, Maintainability & Cleanup Review

**Project:** MagicOdyssey  
**Repository:** Franck-Allion/MagicOdyssey  
**Engine:** Godot 4.x (v4.7.2-stable)  
**Reference Resolution:** 1920×1080 (16:9)  
**Date:** 2026-11-14  
**Audit Scope:** Read-only architectural, maintainability, performance, asset, and test quality review of ART-002 presentation components (`scripts/presentation/`, `assets/textures/cards/`, `assets/_source/lot1/cards/`, `resources/shaders/`, `resources/themes/`, and associated regression suites).

---

## 1. Executive Summary

MagicOdyssey has completed ART-002-T01 through ART-002-T25, establishing an approved visual baseline for card presentation:
- Master frame v03 with native alpha aperture.
- Five rarity crystal treatments (Epic = emerald green).
- Integrated Attack and Health inlays with original bronze socket bezels.
- Integrated Armor and Shield plaque inlays ($180\text{ px}$ width, $62\text{ px} / 69\text{ px}$ height).
- Unified numeral styling: TacticalNumber font, optical centering, refined $62\text{ pt}$ secondary stat size, $4\text{ px}$ dark boundary stroke, and directional depth shadow ($y = +2\text{ px}$).
- Adaptive card typography and non-creature dormant socket engravings.

Because development spanned 25 progressive milestones, several earlier architectural and graphical approaches (procedural silhouettes, floating mini-icons V1/V2, independent cabochons, experimental registration nudges) were superseded but remain preserved in the codebase alongside the active production pipeline.

### High-Level Audit Findings
- **Zero Functional Defects:** All approved production features render correctly with zero crashes, leaks, or visual clipping.
- **10 Byte-for-Byte Duplicate Assets ($1.52\text{ MB}$):** Every runtime texture in `assets/textures/cards/icons/` has an identical duplicate clone (`_v01.png` / `_v02.png`).
- **Engine Import Bloat ($121.1\text{ MB}$):** $91.6\text{ MB}$ of documentation review screenshots in `docs/art/reviews/art002/` are scanned and converted into $213$ `.ctex` files in `.godot/imported/` because `docs/` lacks a `.gdignore` file.
- **27 Preloaded Textures in `CardStatOverlay`:** All historical icon and cabochon textures are unconditionally preloaded as constants, loading over $3.18\text{ MB}$ of textures into memory even though production only utilizes $928\text{ KB}$ ($6$ textures).
- **14 Static Variables in a Single Class:** `CardStatOverlay` carries extensive legacy rollback state, creating global mutable state risks.
- **Theme Token Disconnect:** `DesignTokens/colors/epic` in `fantasy_theme.tres` remains amethyst violet, forcing hardcoded hue overrides in `RarityGemTreatment`.
- **Zero Presentation CI Coverage:** `test_runner.gd` only runs 14 self-test assertions; no card presentation tests are hooked into the native test runner.
- **Missing Reusable `CardView` Control:** The proto-card composition is duplicated across 15+ capture scripts and integration scenes rather than encapsulated in a clean, reusable component for P009.

---

## 2. Current Component Architecture

The current card presentation architecture consists of five core presentation scripts:

```
┌────────────────────────────────────────────────────────────────────────┐
│                         Proto-Card Composition                         │
│   (Currently assembled in art002_card_integration_test.gd & captures)  │
├────────────────────────────────────────────────────────────────────────┤
│ 1. Root Container:        Control (size: 1086×1448 px, scaled)         │
│ 2. Portrait Aperture:     Control (Rect2(124, 207, 838, 642), clipped) │
│    └─ Portrait Image:     TextureRect (AtlasTexture on illustration)   │
│ 3. Master Frame:          TextureRect (mo_card_frame_master_v03.png)   │
│    └─ ShaderMaterial:     card_rarity_gems.gdshader (RarityGemTreatment)│
│ 4. Content Overlay:       CardContentOverlay (Title, Type/Tribe, Rules)│
│ 5. Stat / Category Layer: CardStatOverlay (Creatures)                  │
│                        or CardCategoryOverlay (Spells / Equipment)     │
└────────────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities & Coupling Matrix

| Component | Path | Lines / Size | Base Class | Primary Responsibility | Active In Production? |
|---|---|:---:|---|---|:---:|
| **`CardStatOverlay`** | `scripts/presentation/card_stat_overlay.gd` | $544\text{ lines}$ ($27.4\text{ KB}$) | `Control` | Renders primary sockets (Mana, Attack, Health) and secondary badges (Armor, Shield). | **YES** (Default mode) |
| **`CardContentOverlay`** | `scripts/presentation/card_content_overlay.gd` | $162\text{ lines}$ ($6.8\text{ KB}$) | `Control` | Transactional auto-fitting of title, type/tribe, and formatted rules text. | **YES** |
| **`CardCategoryOverlay`** | `scripts/presentation/card_category_overlay.gd` | $75\text{ lines}$ ($3.5\text{ KB}$) | `CardStatOverlay` | Engraves dormant quatrefoil sockets and draws category flare/clasp for non-creatures. | **YES** |
| **`RarityGemTreatment`** | `scripts/presentation/rarity_gem_treatment.gd` | $68\text{ lines}$ ($2.7\text{ KB}$) | `RefCounted` | Generates `ShaderMaterial` with SVG mask and pigment colors for 5 rarities. | **YES** |
| **`UIDesignTokens`** | `scripts/presentation/ui_design_tokens.gd` | $14\text{ lines}$ ($0.6\text{ KB}$) | `RefCounted` | Accessor wrapper around `resources/themes/fantasy_theme.tres`. | **YES** |
| **`PremiumCombatShell`** | `scripts/presentation/premium_combat_shell.gd` | $175\text{ lines}$ ($8.6\text{ KB}$) | `Control` | Static procedural art-direction study from P004 / ART-001. | **NO** (Study only) |
| **`ART001IntegrationTest`**| `scripts/presentation/art001_integration_test.gd` | $95\text{ lines}$ ($4.9\text{ KB}$) | `PremiumCombatShell` | Visual fixture testing Sundered Observatory battlefield background. | **NO** (Test fixture) |
| **`ART002CardIntegrationTest`**| `scripts/presentation/art002_card_integration_test.gd`| $213\text{ lines}$ ($11.6\text{ KB}$) | `Control` | Interactive visual harness for ART-002 card modes (keys 1–6). | **NO** (Test fixture) |

---

## 3. Dead Code and Superseded Implementations

`CardStatOverlay` contains over $250$ lines of superseded rendering code and constants that are completely bypassed when running in default production mode (`presentation_mode = 0`, `use_inlays = true`, `use_plaque_inlays = true`):

```
scripts/presentation/card_stat_overlay.gd
├── Lines 14-22:   Preloads of 4 floating icons (mo_icon_*.png)                     [SUPERSEDED]
├── Lines 24-30:   Preloads of 5 cabochons (mo_cabochon_*.png)                     [SUPERSEDED]
├── Lines 80-82:   Preloads of 4 V1 icons (mo_icon_*_v01.png)                      [SUPERSEDED]
├── Lines 84-88:   Preloads of 4 V2 icons (mo_icon_*_v02.png)                      [SUPERSEDED]
├── Lines 90-111:  12 cabochon size/offset constants (CABOCHON_SIZE, etc.)         [SUPERSEDED]
├── Lines 113-172: 22 floating icon size/offset constants (T10, V01, V2)          [SUPERSEDED]
├── Lines 233-246: Separate Mini-Icons Mode branch in _draw()                      [DEAD IN PROD]
├── Lines 247-255: Independent Cabochons Mode branch in _draw()                    [DEAD IN PROD]
├── Lines 398-405: _socket_emblem() helper                                         [DEAD IN PROD]
├── Lines 427-443: Legacy floating-icon branch in _badge()                         [DEAD IN PROD]
├── Lines 445-497: _symbol() icon selection and rendering                          [DEAD IN PROD]
└── Lines 499-544: _draw_procedural_symbol() vector drawing (T01/T02)              [DEAD IN PROD]
```

### Classification of Historical Rendering Implementations

| Subsystem | Implementation | Production Status | Test Dependency | Recommendation |
|---|---|---|---|---|
| **Procedural Silhouettes** | `_draw_procedural_symbol()` | Unreachable (`use_procedural_icons = false`) | None in active CI (`test_runner.gd`); referenced in historical `t06` test | **REMOVE CANDIDATE** |
| **Separate Icons V1 & V2** | `_socket_emblem()`, `_symbol()` | Unreachable (`presentation_mode = 0`) | None in active CI; referenced in historical `t08`, `t10`, `t11` | **REMOVE CANDIDATE** |
| **Independent Cabochons** | Cabochon branch in `_draw()` | Unreachable (`use_inlays = true`) | None in active CI; referenced in historical `t13`, `t15`, `t16` | **REMOVE CANDIDATE** |
| **Plaque Rollback to Icons** | Legacy branch in `_badge()` | Unreachable (`use_plaque_inlays = true`) | Referenced in `t23`, `t24` comparisons | **KEEP FOR ROLLBACK** (Deprecate post-P009) |
| **T23 Font Size Rollback** | `use_t23_badge_font_size` | Unreachable (default `false`) | Referenced in `t24` comparison | **KEEP FOR ROLLBACK** (Deprecate post-P009) |
| **T24 Stroke Rollback** | `use_t25_readability_polish`| Unreachable (default `true`) | Referenced in `t25` comparison | **KEEP FOR ROLLBACK** (Deprecate post-P009) |

---

## 4. Asset Inventory and Cleanup Opportunities

### A. Runtime Textures (`assets/textures/cards/icons/`)
Total Directory Size: **$3,182\text{ KB}$ ($3.18\text{ MB}$)** across $28\text{ PNG files}$ and $28\text{ .import files}$.

| Category | File Count | Disk Size | Production Active? | Status | Recommended Action |
|---|:---:|:---:|:---:|:---:|---|
| **Active Production Inlays & Bezels** | 6 files | $928\text{ KB}$ | **YES** | **KEEP** | Retain as core production assets (`mo_inlay_attack.png`, `mo_inlay_health.png`, `mo_socket_bezel_attack.png`, `mo_socket_bezel_health.png`, `mo_plate_armor.png`, `mo_plate_shield.png`). |
| **Exact Version Clones (`_v01`, `_v02`)** | 10 files | $1,518\text{ KB}$ | **NO** | **REMOVE CANDIDATE** | Delete byte-for-byte duplicate clones. Update references to point to canonical non-suffixed files. Saves $1.52\text{ MB}$. |
| **Superseded Cabochons** | 3 files | $779\text{ KB}$ | **NO** | **ARCHIVE** | Move to `assets/_archive/` or delete from runtime textures. Saves $779\text{ KB}$. |
| **Superseded Floating Mini-Icons** | 8 files | $473\text{ KB}$ | **NO** | **ARCHIVE** | Move to `assets/_archive/` or delete from runtime textures. Saves $473\text{ KB}$. |

**Net Runtime Texture Savings:** Up to **$2.25\text{ MB}$ ($70.7\%$)** removed from `assets/textures/cards/icons/`, leaving a lean $928\text{ KB}$ production folder.

### B. Source Assets (`assets/_source/lot1/cards/`)
Total Directory Size: **$28.2\text{ MB}$** across $18\text{ PNG files}$.

| Asset | Size | Status | Rationale |
|---|:---:|:---:|---|
| `frames/mo_card_frame_master_v03.png` | $1.87\text{ MB}$ | **KEEP** | Active master card frame source artwork. |
| `frames/mo_card_frame_master_v02.png` | $2.24\text{ MB}$ | **ARCHIVE** | Superseded RGB frame with painted checkerboard background. |
| `icons/mo_stat_inlay_attack_v01.png` | $1.31\text{ MB}$ | **KEEP** | Active high-resolution source for attack inlay. |
| `icons/mo_stat_inlay_health_v01.png` | $1.19\text{ MB}$ | **KEEP** | Active high-resolution source for health inlay. |
| `icons/mo_stat_plate_armor_v01.png` | $1.25\text{ MB}$ | **KEEP** | Active high-resolution source for armor plaque. |
| `icons/mo_stat_plate_shield_v01.png` | $1.66\text{ MB}$ | **KEEP** | Active high-resolution source for shield plaque. |
| `icons/mo_stat_cabochon_*.png` (3 files) | $4.53\text{ MB}$ | **ARCHIVE** | Historical source cabochons from T13/T15. Preserve in source control. |
| `icons/mo_stat_icon_*.png` (8 files) | $10.91\text{ MB}$ | **ARCHIVE** | Historical source icons from T08/T10. Preserve in source control. |
| `illustrations/mo_illustration_arcane_knight_test_v01.png`| $2.53\text{ MB}$ | **KEEP** | Active reference card illustration. |

### C. Engine Cache & Documentation Assets
- **Documentation Captures (`docs/art/reviews/art002/`):** $91.6\text{ MB}$ across 20 review folders.
- **Engine Compilation (`.godot/imported/`):** $213\text{ .ctex files}$ totaling **$121.1\text{ MB}$**.
- **Action:** Adding a `.gdignore` file inside `docs/` prevents Godot from compiling $91.6\text{ MB}$ of documentation screenshots into $121\text{ MB}$ of `.ctex` engine files, slashing engine startup and project export overhead.

---

## 5. Maintainability and Architectural Health

### Finding 1: Theme Disconnect on Epic Rarity Token (Severity: MEDIUM)
- **File:** `resources/themes/fantasy_theme.tres` (line 906), `scripts/presentation/rarity_gem_treatment.gd` (lines 11, 41–51).
- **Evidence:** `DesignTokens/colors/epic = Color(0.773, 0.635, 0.961, 1)` remains amethyst violet. `RarityGemTreatment` bypasses this token by hardcoding `EMERALD_PIGMENT_HUE = 0.415` and requiring `force_emerald_epic = true`.
- **Risk:** Any future UI calling `TOKENS.color_token(&"epic")` receives violet instead of emerald green, breaking visual consistency between card frames and UI labels.
- **Recommendation:** Update `DesignTokens/colors/epic` in `fantasy_theme.tres` to Colombian emerald beryl (`Color(0.2, 0.85, 0.45)`). Simplify `RarityGemTreatment` to consume the theme token naturally.

### Finding 2: Static State Proliferation in `CardStatOverlay` (Severity: HIGH)
- **File:** `scripts/presentation/card_stat_overlay.gd` (lines 173–204).
- **Evidence:** Contains 14 mutable static variables (`icon_version`, `presentation_mode`, `use_inlays`, `use_separate_icons`, `use_plaque_inlays`, `use_t23_badge_font_size`, `use_t25_readability_polish`, etc.).
- **Risk:** Static variables in Godot survive across scene transitions. If an integration test or inspector changes a static flag, every subsequent card drawn inherits that mutation unless manually reset.
- **Recommendation:** Group operational rollback flags into a dedicated `CardPresentationConfig` resource or eliminate superseded legacy modes, leaving only active production properties.

### Finding 3: Architectural Inheritance Inversion in `CardCategoryOverlay` (Severity: MEDIUM)
- **File:** `scripts/presentation/card_category_overlay.gd` (line 2).
- **Evidence:** `class_name CardCategoryOverlay extends CardStatOverlay`.
- **Risk:** Spells and Equipment cards do not draw creature stats or inlays, yet instantiating `CardCategoryOverlay` preloads all 27 stat and cabochon textures.
- **Recommendation:** Refactor the hierarchy so that `CardCategoryOverlay` inherits from a lightweight base class (`CardSocketOverlay`) or shares utility methods for socket engraving without preloading creature stat textures.

### Finding 4: Hardcoded Dimensions & Apertures Across Multiple Files (Severity: LOW)
- **Evidence:** `CARD_SIZE = Vector2(1086, 1448)` is redefined in `card_stat_overlay.gd`, `card_content_overlay.gd`, `art002_card_integration_test.gd`, and capture scripts. Aperture bounds `Rect2(124, 207, 838, 642)` are hardcoded directly in script bodies.
- **Recommendation:** Centralize card geometry constants in a single authoritative script (`CardViewLayout` or `UIDesignTokens`).

---

## 6. Performance Assessment

### Finding 5: Runtime Object Allocation inside `_draw()` (Severity: MEDIUM)
- **File:** `scripts/presentation/card_stat_overlay.gd` (lines 408–417).
- **Evidence:**
  ```gdscript
  func _badge(bounds: Rect2, kind: StringName, value: int) -> void:
      var plate: StyleBoxFlat = StyleBoxFlat.new()
      plate.bg_color = TOKENS.color_token(&"background")
      plate.border_color = TOKENS.color_token(&"accent_dim")
      plate.set_border_width_all(3)
      plate.set_corner_radius_all(23)
      plate.shadow_color = Color(0, 0, 0, 0.7)
      plate.shadow_size = 6
      draw_style_box(plate, bounds)
  ```
- **Performance Impact:** For a card with both Armor and Shield, `StyleBoxFlat.new()` is called twice every time the card redraws. In a 7-card hand with hover animations, this creates unnecessary garbage collection churn.
- **Recommendation:** Cache the badge `StyleBoxFlat` as a static constant or class-level instance.

### Finding 6: Unnecessary Texture VRAM Footprint via Static Preloads (Severity: HIGH)
- **File:** `scripts/presentation/card_stat_overlay.gd` (lines 14–88).
- **Evidence:** 27 `Texture2D` instances are preloaded at script load time, including duplicate and superseded $512\times 512$ cabochons.
- **Performance Impact:** Unnecessary GPU texture memory allocation and slower scene compilation.
- **Recommendation:** Remove preloads for superseded cabochons and floating icons. Retain only the 6 active production textures.

### Finding 7: Godot Import Engine Overhead on `docs/` (Severity: HIGH)
- **Evidence:** 213 `.ctex` files totaling $121.1\text{ MB}$ exist in `.godot/imported/` due to unignored review PNGs in `docs/art/reviews/`.
- **Performance Impact:** Slows down initial editor import, project export, and workspace indexing.
- **Recommendation:** Add `.gdignore` to `docs/art/reviews/` or `docs/`.

---

## 7. Test Quality Assessment

### Finding 8: Absence of Presentation Tests in Native Test Runner (Severity: HIGH)
- **File:** `scripts/tests/test_runner.gd` (lines 44–48).
- **Evidence:** `test_runner.gd` registers and executes only `TestHarnessSelf`.
  ```gdscript
  func _run_registered_suites(asserts: TestAsserts, failure_mode: bool) -> void:
      print("[RUN] TestHarnessSelf")
      var self_suite: TestHarnessSelf = TestHarnessSelfScript.new()
      self_suite.run_suite(asserts, failure_mode)
  ```
- **Risk:** Running `run_tests.ps1` gives a false sense of security (14/14 passed), while zero presentation, layout, typography, or rendering regressions are evaluated.
- **Recommendation:** Create `scripts/tests/test_card_presentation.gd` inheriting from the test harness, integrating the key assertions from T20–T25 (geometry bounds, zero border spill, font sizes, optical offsets, category engraving), and register it in `test_runner.gd`.

### Finding 9: Fragmented, Unmaintained Review Regression Scripts (Severity: MEDIUM)
- **Evidence:** 12 standalone `*regression.gd` scripts are scattered across `docs/art/reviews/art002/t06/` through `t25/`. Many verify historical constants that were subsequently updated (e.g. `t13` tests cabochons, `t23` tests 76 pt font size).
- **Recommendation:** Treat review folder scripts as historical milestone records (do not modify them). Establish a single authoritative, maintained test suite under `scripts/tests/`.

---

## 8. Future Integration Readiness (P008, P009, P010)

```
┌────────────────────────────────────────────────────────────────────────┐
│                        ROADMAP READINESS AUDIT                         │
├────────────────────┬──────────────┬────────────────────────────────────┤
│ Prompt             │ Readiness    │ Key Architectural Blockers         │
├────────────────────┼──────────────┼────────────────────────────────────┤
│ **P008**           │ **PARTIAL**  │ • CardStatOverlay is hardcoded to  │
│ `CreatureToken`    │              │   1086×1448 px card coordinates.   │
│                    │              │ • Cannot be reused directly on     │
│                    │              │   shield-shaped battlefield tokens.│
│                    │              │ • Sockets & badges need local      │
│                    │              │   coordinate parameterization.     │
├────────────────────┼──────────────┼────────────────────────────────────┤
│ **P009**           │ **HIGH**     │ • Proto-card composition works,    │
│ `CardView` &       │              │   but needs extraction into a      │
│ `HandView`         │              │   clean, standalone CardView scene.│
│                    │              │ • Needs binding to CardDefinition  │
│                    │              │   domain resource.                 │
│                    │              │ • Clean input/hover lifecycle.     │
├────────────────────┼──────────────┼────────────────────────────────────┤
│ **P010**           │ **HIGH**     │ • Full-size card inspection view   │
│ `Tooltip` &        │              │   is proven (T20–T25).             │
│ `InspectorPanel`   │              │ • Needs dynamic modifier display   │
│                    │              │   (buffed/damaged stat colors).    │
└────────────────────┴──────────────┴────────────────────────────────────┘
```

### Downstream Integration Guidelines
1. **For P008 (`CreatureToken`):**
   Do not subclass or instance `CardStatOverlay` for tokens. Instead, extract the unified numeral drawing logic (`draw_number()`, outline, and shadow) and badge rendering into a shared static utility or standalone component (`StatBadgeRenderer`) that takes local token coordinates.
2. **For P009 (`CardView` & `HandView`):**
   Create `scenes/cards/card_view.tscn` and `scripts/presentation/card_view.gd`. Encapsulate the approved 5-layer hierarchy. Provide a single typed configuration method: `bind_card(definition: CardDefinition, instance_state = null) -> void`.
3. **For P010 (`Tooltip` & `InspectorPanel`):**
   Reuse the standalone `CardView` inside the inspector panel at full scale ($880\text{ px}$ height). Add support for modifier tints on numerals (`ink` parameter already supports custom colors).

---

## 9. Risk Classification and Prioritized Cleanup Backlog

| ID | Title | Severity | Impact Area | Proposed Action | Regr. Risk |
|:---:|---|:---:|:---:|---|:---:|
| **F-01** | Documentation `.ctex` Import Bloat | **HIGH** | Performance | Add `.gdignore` to `docs/art/reviews/` to prevent Godot from compiling $91.6\text{ MB}$ of review images into $121\text{ MB}$ of `.ctex` files. | **Zero** |
| **F-02** | Missing Presentation CI Regression Suite | **HIGH** | Testing | Create `scripts/tests/test_card_presentation.gd` covering active production paths (T20–T25) and register in `test_runner.gd`. | **Zero** |
| **F-03** | 10 Duplicate Runtime Textures ($1.52\text{ MB}$) | **HIGH** | Assets / Disk | Remove identical `_v01.png` / `_v02.png` duplicates in `assets/textures/cards/icons/`. Retain canonical non-suffixed files. | **Low** |
| **F-04** | Dead Superseded Textures in Runtime Folder | **HIGH** | Memory / Disk | Remove superseded cabochon and icon textures from runtime folder ($1.25\text{ MB}$). Retain high-res originals in `_source/`. | **Low** |
| **F-05** | Dead Code & Preloads in `CardStatOverlay` | **HIGH** | Code / Memory | Remove superseded procedural drawing, floating icon branches, and independent cabochon code. Remove 21 unused preloads. | **Low** |
| **F-06** | Theme Token Disconnect on Epic Rarity | **MEDIUM** | Architecture | Update `DesignTokens/colors/epic` in `fantasy_theme.tres` to Colombian emerald green. Remove hardcoded hue in `RarityGemTreatment`. | **Low** |
| **F-07** | Runtime `StyleBoxFlat.new()` Allocation | **MEDIUM** | Performance | Statically cache the badge background `StyleBoxFlat` instead of reallocating twice per card redraw. | **Zero** |
| **F-08** | Inheritance Coupling in `CardCategoryOverlay` | **MEDIUM** | Architecture | Decouple `CardCategoryOverlay` from `CardStatOverlay` to prevent loading creature stat textures for spells/equipment. | **Low** |
| **F-09** | Static Mutable State Proliferation | **MEDIUM** | Maintainability | Consolidate or eliminate the 14 static flags in `CardStatOverlay`. | **Low** |
| **F-10** | Card Dimensions Hardcoded Across Scripts | **LOW** | Code Style | Centralize `CARD_SIZE = Vector2(1086, 1448)` and aperture bounds in a shared layout definition. | **Zero** |

---

## 10. Recommended Execution Order

To minimize regression risk and preserve the approved graphical presentation, cleanup should proceed in **three small, atomic phases**:

```
Phase 1: Zero-Risk Non-Code Optimizations (Immediate)
  ├── Task 1.1: Add .gdignore to docs/art/reviews/ (reclaims 121 MB engine cache)
  └── Task 1.2: Add scripts/tests/test_card_presentation.gd to test_runner.gd (establishes CI safety net)

Phase 2: Codebase & Asset Streamlining (Pre-P009)
  ├── Task 2.1: Cache badge StyleBoxFlat in CardStatOverlay (eliminates runtime allocation churn)
  ├── Task 2.2: Unify DesignTokens/colors/epic in fantasy_theme.tres & simplify RarityGemTreatment
  ├── Task 2.3: Remove dead procedural symbols & superseded cabochon/icon branches from CardStatOverlay
  └── Task 2.4: Clean duplicate _v01/_v02 textures and remove superseded runtime textures

Phase 3: Component Modularization for P009 (During P009 Scaffolding)
  ├── Task 3.1: Centralize card geometry constants in shared layout definition
  ├── Task 3.2: Decouple CardCategoryOverlay from creature texture preloads
  └── Task 3.3: Scaffold standalone CardView component (scenes/cards/card_view.tscn)
```

---

## 11. Final Summary for Repository Owner

- **Confirmed Issues by Severity:**
  - **CRITICAL:** $0$
  - **HIGH:** $5$ (Documentation import bloat, missing CI test suite, duplicate textures, dead runtime assets, dead script branches/preloads)
  - **MEDIUM:** $4$ (Theme epic color mismatch, runtime StyleBoxFlat allocations, category overlay inheritance coupling, static flag proliferation)
  - **LOW:** $1$ (Scattered card dimension constants)
- **Top 3 Cleanup Recommendations:**
  1. Add `.gdignore` to `docs/art/reviews/` to reclaim **$121.1\text{ MB}$** of engine cache.
  2. Establish `test_card_presentation.gd` in `test_runner.gd` so `run_tests.ps1` permanently guards card presentation against regressions.
  3. Clean duplicate and superseded textures in `assets/textures/cards/icons/`, saving **$2.25\text{ MB}$ ($70.7\%$)** of runtime textures and removing 21 unused preloads.
- **Potentially Removable Runtime Assets (Subject to Owner Approval):**
  - 10 duplicate runtime files: `mo_cabochon_attack_v02.png`, `mo_cabochon_health_v01.png`, `mo_icon_armor_v02.png`, `mo_icon_attack_v02.png`, `mo_icon_health_v02.png`, `mo_icon_shield_v02.png`, `mo_inlay_attack_v01.png`, `mo_inlay_health_v01.png`, `mo_plate_armor_v01.png`, `mo_plate_shield_v01.png`.
  - 11 superseded runtime files: `mo_cabochon_attack_v01.png`, `mo_cabochon_attack.png`, `mo_cabochon_health.png`, `mo_icon_armor_v01.png`, `mo_icon_armor.png`, `mo_icon_attack_v01.png`, `mo_icon_attack.png`, `mo_icon_health_v01.png`, `mo_icon_health.png`, `mo_icon_shield_v01.png`, `mo_icon_shield.png`.
  *(All original high-resolution master files remain permanently preserved in `assets/_source/lot1/cards/`).*
- **Risks Requiring Owner Approval:**
  - Deleting superseded runtime textures and legacy rollback branches will retire the ability to toggle pre-T20 independent cabochons or pre-T13 mini-icons in live code.
  - Updating `DesignTokens/colors/epic` in `fantasy_theme.tres` changes the theme's default token from amethyst violet to emerald green.
- **Recommended Next Implementation Task:**
  - Execute Phase 1 (non-code cache optimization & CI regression test suite), then proceed to **P008 (`CreatureToken`)** and **P009 (`CardView` & `HandView`)**.
