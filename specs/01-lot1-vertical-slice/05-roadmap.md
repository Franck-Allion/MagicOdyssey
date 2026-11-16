# MagicOdyssey — Lot 1 Implementation Roadmap

**Status:** Normative Execution Plan for Lot 1.
**Structure:** 65 atomic prompts (`P001` to `P065`) across 9 iterations (`J0` to `J8`) and 9 quality gates (`G0` to `G8`).
**Philosophy:** Vertical-slice development tailored for light-reasoning AI assistants (Codex, Gemini Flash, Claude). Each prompt is an isolated unit of work with clear input, bounded scope, and verifiable tests.

---

## A. Development Principles

1. **Granularity:** Prompts are sized for single, tightly bounded tasks (typically 1–4 files changed). If a prompt exceeds model context or reasoning limits, split it using sub-IDs (e.g., `P021a`, `P021b`) without altering milestone targets.
2. **True Visual Slice:** Visual polish and components are created early (J1), not deferred to a hasty "polish" pass at the end.
3. **No Cheating on Completion:** A gate or prompt is only marked complete when all code, tests, and verifications have actually been executed. 65/65 written prompts without passing Gate G8 does **not** mean Lot 1 is complete.

---

## B. Prompt-by-Prompt Execution Workflow

For every prompt execution:
1. **Targeted Reading:** Provide only the relevant spec sections, test IDs, and existing file paths.
2. **Bounded Output:**
   - (a) Files modified / created.
   - (b) Implemented behavior.
   - (c) Added tests and execution report (command + actual console output).
   - (d) Risks, edge cases, and manual test requirements.
3. **Strict Invariants:** Never embed game logic inside UI token nodes (`CreatureToken.gd`). Never mock test results with hardcoded returns.
4. **Godot Headless Commands:**
   ```powershell
   # Headless asset import and verification
   & $GodotExe --headless --editor --path . --quit
   # Headless native test suite runner
   & $GodotExe --headless --path . --script res://scripts/tests/test_runner.gd
   ```

---

## C. The 65 Ordered Prompts

### J0 — Project Foundation & Test Harness · P001–P004
*Objective: Clean, executable Godot 4 project with native headless test runner and theme baseline.*

| Prompt | Autonomous Task | Scope | Verification / Exit Criterion |
|---|---|---|---|
| **P001** | Initialize Godot 4 Project | Create `project.godot`, main entry scene, folder layout, `.gitignore`, and README with locked Godot version. | Godot opens and launches main scene without errors; clean git tracking. |
| **P002** | Install Normative Specs | Place English Lot 1 specs in `specs/01-lot1-vertical-slice/` and global rules in `specs/`; create `AGENTS.md` and progress tracker. | Agents can locate sources of truth without inventing mechanics. |
| **P003** | Native Headless Test Harness | Create GDScript test runner (`test_runner.gd`), custom assertion library, and PowerShell runner script with exit codes. | Deliberate pass/fail tests report accurate status codes; runs headlessly. |
| **P004** | Design System & UI Baseline | Create Godot `Theme`, UI color tokens (rarities, camps), asset manifest, and 1080p/720p screenshot baseline. | Theme demo scene runs cleanly; placeholder asset inventory established. |

**Gate G0:** Project imports, test harness passes, AI conventions active, UI design system established.

---

### J1 — Combat Interface: Visual Layout · P005–P010
*Objective: Build the full 2D presentation board and UI widgets before implementing deep combat logic.*

| Prompt | Autonomous Task | Scope | Verification / Exit Criterion |
|---|---|---|---|
| **P005** | Compose `CombatScreen` | Build central battlefield layout, opponent/player hero zones, hand area, and action bar with responsive anchors. | No UI component clipped at 1920×1080 or 1280×720 (prepares `L1-U01`, `L1-U02`). Refined via `P005-R01`–`R09`. |
| **P006** | Create 24 Board Slots | Draw 2 camps × 6 columns × 2 rows; visually distinguish `ATTACK` and `DEFENSE` rows; wire hover/select signals. | All 24 slots selectable and visually distinct (`L1-U03`). |
| **P007** | Hero & Turn HUDs | Display HP, mana capacity/available, deck counters, active camp banner, and "End Turn" button. | HUD values refresh purely via injected view-models; no engine coupling. |
| **P008** | Fantasy Crest `CreatureToken` | Create shield-shaped crest token: portrait, ATK (bottom-left), HP (bottom-right), armor/shield badges, max 3 statuses + `+N`. Ensure presentation compatibility with Weapon and Protection attachment indicators and stat modifiers (note: represents Creature Equipment, distinct from Hero Artifacts). | Demonstrable on 24 tokens with diverse stats and statuses (`L1-U03`, `L1-U05`). |
| **P009** | `CardView` & `HandView` | Render premium illustrated cards across all three Lot 1 card types: Creature (approved ART-002 design preserved), Spell (dedicated layout variant without creature stats/sockets), and Equipment (dedicated Weapon/Protection layout variant without creature stats/sockets). Single CardView architecture with shared card back, rarity coding, typography, mana gem, and fan/linear hand layout with hover lift. Refined via two-stage packages `P009-R01A/B` and `P009-R02A/B`. | Cards of all 3 types render clearly in hand and hover inspection; readable at 720p; handles multi-instance copies; no inappropriate stat badges. |
| **P010** | Tooltip & Inspector Panel | Hover: concise tactical tooltip; Click: opens side inspector with original printed card + live modifier breakdown. Renders Spell details without Creature-only fields; displays Equipment effects and categories; inspects Creature Equipment attachments on board creatures (future Hero Artifact inspection planned separately). | Demonstrates `L1-U04` on a buffed creature, spell, and equipment; visual review at 1080p and 720p. |

**Gate G1:** Coherent 2D visual board with 24 slots, crest tokens, hand, and inspector. No temporary debug boxes.

#### CombatScreen Art Production & Integration Roadmap (PLAN-001)

The initial responsive layout (`P005`) and hand hover interaction (`P005-R05`) are technically accepted as the baseline. However, `P005` is **not artistically complete** until the player HUD, opponent HUD, utility HUD (deck/graveyard/turn controls), and global visual harmony have been approved by the project owner.

To maintain engineering rigor and avoid combining asset creation with engine integration, all visual refinement is split into mandatory two-stage pairs:
- **Stage A (Artistic Asset Generation):** Prompt specification, image generation, visual review, owner approval, and committing standalone PNG assets. No Godot code or scenes are modified.
- **Stage B (Technical Integration):** Integrating approved assets into Godot, preserving component APIs and dynamic shaders, validating across resolutions (1080p and 720p), running automated regression suites, verifying the standalone Windows executable, and obtaining owner visual sign-off.

##### Mandatory Two-Stage Workflow

**Stage A Protocol (Art Asset Generation):**
1. Define exact asset scope, visual specifications, and aspect ratios.
2. Provide a standalone, reproducible image-generation prompt.
3. Define the exact repository destination path and filename using the `mo_` convention.
4. Generate or obtain the required original PNG asset.
5. Ensure correct alpha transparency (transparency preserved; no baked background boxes).
6. Perform visual review against MagicOdyssey's antique-bronze and midnight-blue aesthetic.
7. Iterate until owner visual approval is obtained.
8. Commit approved asset to source control.
9. Mark Stage A task complete. **Do not implement Godot integration during Stage A.**

**Stage B Protocol (Technical Integration):**
1. Read the approved, committed assets from their documented paths.
2. Integrate them into `scenes/combat/` and `scripts/presentation/`.
3. Preserve existing resource APIs, layout anchors, and dynamic shaders (e.g. liquid orbs remain rendered dynamically in Godot).
4. Validate responsive scaling at 1920×1080 and 1280×720 with zero clipping.
5. Run native headless tests (`test_runner.gd`) and visual regression (`capture_baseline.gd`).
6. Rebuild and launch the Windows standalone executable (`build/windows/MagicOdyssey.exe`).
7. Verify ESC-to-quit and process termination.
8. Capture real GPU review evidence under `docs/art/reviews/`.
9. Request owner visual approval. **Never claim artistic approval based on passing automated tests alone.**

##### Proposed Asset Directory & Naming Convention
Image assets are stored under `assets/_source/lot1/hud/` (directories created on-demand when assets are committed):
- `assets/_source/lot1/hud/player/` — Player hero portrait frame, health orb housing, mana orb housing, decorative integration trims.
- `assets/_source/lot1/hud/opponent/` — Opponent identity/portrait framing, health/mana housings, card-back artwork.
- `assets/_source/lot1/hud/utility/` — Deck frame/plate, graveyard frame/plate, turn banner framing, End Turn button visual states, action log frame.

**Naming standard:** `mo_hud_<zone>_<element>_v<NN>.png`
Examples:
- `mo_hud_player_portrait_frame_v01.png`
- `mo_hud_player_health_orb_housing_v01.png`
- `mo_hud_player_mana_orb_housing_v01.png`
- `mo_hud_opponent_portrait_frame_v01.png`
- `mo_hud_opponent_card_back_v01.png`
- `mo_hud_utility_deck_plate_v01.png`
- `mo_hud_utility_end_turn_button_normal_v01.png`

Assets must preserve transparency where applicable and avoid baked-in dynamic gameplay text, counts, or values.

##### P005 Refinement Substeps Breakdown

| Step | Autonomous Task | Scope | Verification / Exit Criterion |
|---|---|---|---|
| **P005-R01** | Animated Liquid Health / Mana Orbs | Procedural liquid shader + bronze housings; 4 independent orbs. | **TECH PASS / ART REVIEW.** 263 assertions PASS; 1080p/720p GPU captures. |
| **P005-R02** | Combat Composition & Windows Preview | Rebalanced 5-region layout, 220 px orbs, compact hand. | **TECH PASS / ART REVIEW.** 266 assertions PASS; Windows standalone test. |
| **P005-R04** | Player HUD / Adaptive 10-Card Fan | Display 0–10 cards, 270 px fan, compact hero, dense liquid settling. | **TECH PASS / ART REVIEW.** 1223 assertions PASS; 3/3 bit-exact parity. |
| **P005-R05** | Hand Recognition & Hover Inspection | Hearthstone-style pointer hover, deterministic OBB picking with hysteresis, left-to-right stacking, 440 px inspection. | **TECH PASS / ART REVIEW.** 1473 assertions PASS; 3/3 bit-exact parity; Windows mouse playtest. |
| **P005-R06A** | Player Hero HUD Art Assets | Standalone PNG assets for hero portrait housing, HP orb housing, Mana orb housing, and decorative integration trims. Antique-bronze & midnight-blue. No Godot code. | Owner visual approval; assets committed to `assets/_source/lot1/hud/player/`. |
| **P005-R06B** | Integrate Player Hero HUD | Integrate approved R06A assets into CombatScreen. Preserve dynamic liquid shaders and public APIs (`get_player_health_orb`). | Layout, proportions, and readability validated at 1080p/720p; Windows executable verified; owner visual acceptance. |
| **P005-R06C** | Player HUD Final Harmony & Typography Polish | Presentation-level housing modulation (Color(0.88, 0.86, 0.85, 1)), balanced vertical gaps (25.7 px / 26.2 px), AAA typography (38 px focal values, 21 px secondary caption, 3/2 px outline, optical aperture centering). | **TECH PASS / ART REVIEW.** 1548 assertions PASS; 3/3 bit-exact; outside regions 100% bit-exact; standalone Windows test. |
| **P005-R06D** | Player HUD Micro-Polish (Orb Fit & Breathing Room) | 180 px diameter orbs, Mana orb bottom clearance 68.2 px (well above 638 px bottom border), '30 / 30' safe-area fit (96 px width, $\ge 11.8$ px liquid margin), 15 px secondary caption. | **TECH PASS / ART REVIEW.** 1553 assertions PASS; 3/3 bit-exact; outside regions 100% bit-exact; standalone Windows test. |
| **P005-R07A** | Opponent HUD Art Assets | Standalone PNG assets for opponent portrait/identity framing, HP/mana housings, card-back artwork. No Godot code. | Owner visual approval; assets committed to `assets/_source/lot1/hud/opponent/`. |
| **P005-R07B** | Integrate Opponent HUD | Integrate R07A assets into CombatScreen. Maintain hidden hand information; ensure visual coherence with player HUD. | Proportions and readability validated at 1080p/720p; Windows executable verified; owner visual acceptance. |
| **P005-R08A** | Deck, Graveyard & Turn Control Assets | Standalone PNG assets for deck representation, graveyard representation, turn/phase indicators, End Turn button states, action log trim. No baked text/counts. No Godot code. | Owner visual approval; assets committed to `assets/_source/lot1/hud/utility/`. |
| **P005-R08B** | Integrate Deck, Graveyard & Turn Controls | Integrate R08A assets into CombatScreen. Improve counter hierarchy, button states, and action log presentation. Strictly presentation-only (no P007 domain binding). | Layout and alignment validated at 1080p/720p; Windows executable verified; owner visual acceptance. |
| **P005-R09** | Global Visual Harmony & P005 Sign-off | Holistic visual review of entire CombatScreen composition (player/opponent HUDs, hand, deck/graveyard, action bar, battlefield integration). Compatibility check: verify space is reserved for a future compact active Hero Artifact indicator (associated visually with Hero zones, without occupying any of the 24 tactical creature slots or colliding with utility controls) and that the visual hierarchy supports a variable active Artifact Capacity. (Reservation and design-compatibility check only; does not require working Artifact inventory/systems or reopening approved HUD artwork unless demonstrable collision exists). | Explicit owner artistic sign-off of P005 at 1080p/720p in Windows standalone. |

##### Architectural Boundaries & Invariants
1. **Preservation of P006–P010:** The subsequent prompts retain their original scope, responsibilities, and numbers:
   - `P006`: 24 Board Slots (Attack/Defense rows, hover/select signals).
   - `P007`: Hero & Turn HUDs (Domain view-model data binding for HP/mana/counters).
   - `P008`: Fantasy Crest `CreatureToken`.
   - `P009`: `CardView` & `HandView`.
   - `P010`: Tooltip & Inspector Panel.
2. **P005 vs P007 Distinction:** P005 and its refinement substeps (`R01`–`R09`) govern **static visual composition and layout presentation only**. Live gameplay data binding, engine event subscription, and combat view-models belong strictly to `P007` and `P033`.
3. **Hand Capacity Rule vs Presentation:** `P005-R05` supports visual presentation of 0–10 cards. Normative gameplay rules (`01-scope.md` §3.6, Decision Q39) define a 7-card maximum capacity. This known discrepancy will be formally reconciled in `P024` without altering normative gameplay rules prematurely.
4. **Hero Artifact Visual Reservation Invariant:** In `P005-R09`, confirming spatial reservation for future compact active Hero Artifact indicators is strictly a design-compatibility check. Hero Artifact inventory, slot equipping, and exploration acquisition are deferred to Phase 2 (Tower Exploration). Approved HUD artwork will not be reopened unless a demonstrable collision exists.

#### Card Layout Variants Art Production & Integration Roadmap (PLAN-002)

The approved ART-002 card framework was designed around Creature cards. However, the Lot 1 catalog contains 10 Creatures, 4 Spells, and 2 Equipments. To provide professional visual differentiation without fragmenting the presentation codebase, MagicOdyssey adopts a **single reusable `CardView` presentation architecture** with card-type-specific layouts.

##### Architectural Principle: Single Reusable CardView Architecture
1. **No Fragmented Renderers:** Do not introduce three independent rendering systems. All card types are rendered through the unified `CardView` pipeline (`scripts/presentation/card_view_layout.gd`).
2. **Shared Foundation Preserved:**
   - Card back illustration and opacity shader (`card_back_opacity.gdshader`).
   - Rarity coding (gem shader `card_rarity_gems.gdshader`, border tints, and corner flourishes across Common, Uncommon, Rare, Epic, Legendary).
   - Typography tokens, fonts, and outline treatments (`fantasy_theme.tres`).
   - Mana cost gem badge (top-left).
   - Card artwork presentation aperture.
   - Hand fan placement, left-to-right stacking, hover lift, and click/drag interaction semantics.
3. **Card-Type Layout Variants:**
   - **Creature Cards (Approved Baseline):** Retain the approved ART-002 design intact: artwork aperture, card title, mana cost, Attack (bottom-left) and Health (bottom-right) badges, Armor/Shield badges where applicable, rarity treatment, tribe badge, and rules text. No redesign is scheduled.
   - **Spell Cards (Dedicated Layout Variant):** Uses shared materials and proportions; displays mana cost, spell name, spell illustration, clear Spell category indicator, and readable spell effect description. **Explicitly eliminates all Creature Attack/Health indicators and empty stat sockets.** Recognizable both in the player's hand and during hover inspection.
   - **Equipment Cards (Dedicated Layout Variant):** Uses shared materials and proportions; displays mana cost, equipment name, item illustration, Weapon or Protection category badge, and equipment effect description. **Explicitly eliminates all Creature Attack/Health indicators and empty stat sockets.** Distinguishes Weapon vs Protection without breaking the shared card identity.

##### Mandatory Two-Stage Workflow for Card Layout Variants
Following the mandatory A/B work package structure:
- **Stage A (Artistic Creation):** Standalone PNG card-layout artwork specifications (`assets/_source/lot1/cards/mo_card_frame_spell_v01.png` and `assets/_source/lot1/cards/mo_card_frame_equipment_v01.png`). Prompt specification, transparency verification, game-size review (hand ~270px, hover/inspector ~440px), owner approval, and source control commit. No Godot code or scenes are modified during Stage A.
- **Stage B (Technical Integration):** Integration of approved frames into `CardView`. Validate that creature cards remain unchanged, spell cards have no inappropriate stat indicators, equipment cards display category and effects, mana and rarity remain consistent, hand fan and hover inspection operate with zero regression, 1080p and 720p readability is verified, and ART-002 visual regression tests pass bit-exact.

##### P009 Refinement Substeps Breakdown

| Step | Autonomous Task | Scope | Verification / Exit Criterion |
|---|---|---|---|
| **P009-R01A** | Spell Card Variant Art Asset Generation | Standalone PNG layout artwork for Spell card frame (`assets/_source/lot1/cards/mo_card_frame_spell_v01.png`). Prompt specification, antique-bronze & midnight-blue styling, clean aperture, transparency check. No Godot code. | Owner visual approval; asset committed to `assets/_source/lot1/cards/`. |
| **P009-R01B** | Integrate Spell Card Variant into `CardView` | Integrate approved R01A asset into `CardView` (`card_view_layout.gd`). Implement layout conditional on `card_type == SPELL`: render spell category and effect text; omit Attack/Health badges and sockets. Preserve shared mana, rarity, typography, and hover lift. | All 4 Lot 1 spells render cleanly in hand and hover; no ATK/HP badges or sockets; 1080p/720p verified; ART-002 regression suite PASS; owner visual acceptance. |
| **P009-R02A** | Equipment Card Variant Art Asset Generation | Standalone PNG layout artwork for Equipment card frame (`assets/_source/lot1/cards/mo_card_frame_equipment_v01.png`). Distinct framing for Weapon/Protection category badges. Prompt specification, transparency check, game-size review. No Godot code. | Owner visual approval; asset committed to `assets/_source/lot1/cards/`. |
| **P009-R02B** | Integrate Equipment Card Variant into `CardView` | Integrate approved R02A asset into `CardView` (`card_view_layout.gd`). Implement layout conditional on `card_type == EQUIPMENT`: render Weapon/Protection badge and effect description; omit Attack/Health badges and sockets. Preserve shared mana, rarity, typography, and hover lift. | Both Lot 1 equipments render cleanly in hand and hover; distinct from spells/creatures; 1080p/720p verified; ART-002 regression suite PASS; owner visual acceptance. |

---

### J2 — Typed Catalog & Combat Model · P011–P020
*Objective: Build `.tres` card resources, immutable definitions, and reproducible match initialization.*

| Prompt | Autonomous Task | Scope | Verification / Exit Criterion |
|---|---|---|---|
| **P011** | Define `CardDefinition` | Implement typed `Resource` with `definition_id`, type, tribe, rarity, mana cost, base stats, and presentation refs. | Resource editable in Godot inspector; validates missing fields. |
| **P012** | Ability & Operation Resources | Implement `AbilityDefinition`, `TargetSpec`, `CostSpec`, `DurationSpec`, and `EffectOperation` resources. | Test resource describes `DAMAGE(4)` without custom GDScript logic. |
| **P013** | Catalog Validator | `CardCatalog` loads all cards, catches duplicates, missing fields, invalid slot types, or unrecognized opcodes. | Produces clear error report on malformed `.tres` (`L1-B32`). |
| **P014** | Define First 5 Creatures | Create `.tres` definitions for Humans and Elves (`human_recruit`, `human_guard`, `human_knight`, `elf_archer`, `elf_healer`). | 5 resources load and validate cleanly; correct stats and tags. |
| **P015** | Define Next 5 Creatures | Create `.tres` definitions for Elves, Dwarves, and Dragons (`elf_sentinel`, `dwarf_guardian`, `dwarf_runecrafter`, `dragon_whelp`, `dragon_drake`). | 10/10 creature definitions loaded; Dragons have 0 equipment slots. |
| **P016** | Define 4 Spells | Create `.tres` resources for Fireball, Mending Light, Arcane Barrier, and Martial Blessing. | 4 spells reference `DAMAGE`, `HEAL`, `ADD_SHIELD`, `MODIFY_STAT`. |
| **P017** | Define 2 Equipments | Create `.tres` resources for Runic Blade (`WEAPON`, +2 ATK) and Bastion Armor (`PROTECTION`, +2 ARMOR). | 2 equipments loaded; slot types and passive modifiers valid. |
| **P018** | Domain Model Entities | Implement `HeroState`, `CardCopy`, `BoardInstance`, and `BoardPosition`; differentiate `definition_id`, `copy_id`, `instance_id`. | Unit movement preserves `instance_id`; re-summoning generates a new `instance_id`. |
| **P019** | Zones & 40-Card Fixtures | Implement `DECK`, `HAND`, `BOARD`, `DISCARD`, `BANISHED`; define default fixture with valid 40-card decks (max 4 copies). | Validates deck size and copy caps; fixture parameters are `[CONFIG]`. |
| **P020** | Deterministic Match Factory | `CombatFactory` initializes state, seeds RNG, shuffles decks, and deals 6 initial cards to each player. | `L1-B01`: Same seed produces identical initial hands; opponent deck hidden. |

**Gate G2:** All 16 card resources exist; 40-card decks validate; match factory initializes reproducibly.

> **Hero Artifacts vs Card Catalog Invariant (PLAN-002):**
> Hero Artifacts are **NOT cards** and are **NOT Creature Equipment**. They are permanent Hero progression objects. They must never be merged into `CardDefinition` and are not counted among the 16 Lot 1 cards (10 creatures, 4 spells, 2 equipments). Gate G2 requires strictly the 16 official cards; no Artifact catalog is required or expected for G2.

---

### J3 — Core Deterministic Combat Engine · P021–P031
*Objective: Build and headless-test the core rules: turns, mana, summoning, movement, attacks, and deaths.*

| Prompt | Autonomous Task | Scope | Verification / Exit Criterion |
|---|---|---|---|
| **P021** | Transaction Pipeline | Implement `CombatCommand`, `ValidationResult`, and `CombatResult` with atomic commit and rollback on failure. | `L1-B04`: Illegal command rejected with zero state mutation or mana loss. |
| **P022** | Legal Action Enumerator | Implement `CombatEngine.get_legal_actions(actor)` for summon, move, swap, and end turn. | Only truly legal commands exposed; non-active camp commands rejected (`L1-B04`). |
| **P023** | Turn Phases & Mana Growth | Implement turn-start: growth (+1 capacity including turn 1), mana restoration, and no draw on turn 1. | `L1-B02`, `L1-B03`: Correct mana and card draw progression. |
| **P024** | Draw, Hand Cap & Fatigue | Implement 1 card draw on turn $\ge 2$, max hand 7 (overflow to discard), and progressive fatigue (1, 2, 3... HP). | `L1-B26`, `L1-B27`: Progressive fatigue ignores armor/shields; overflow discards. |
| **P025** | Summoning & Priority | Implement summoning cost deduction, empty slot verification, column contestation priority, and `ON_SUMMON`. | `L1-B05`, `L1-B06`: Contested column priority enforced strictly. |
| **P026** | Movement & Permutation | Implement natural vertical movement (1 mana, 1/turn) and column ally swapping (1 mana total, consumes both). | `L1-B08`, `L1-B09`: Movement rules and summoning turn movement verified. |
| **P027** | Damage & Protection Core | Implement attack order: reusable armor $\rightarrow$ consumable shield pool $\rightarrow$ HP loss. | `L1-B12`, `L1-B13`, `L1-B14`: Correct absorption sequence and residual HP loss. |
| **P028** | End-of-Turn Combat Phase | Implement columns 1 to 6 attack order, active `ATTACK` row only, priority (enemy attack $\rightarrow$ defense $\rightarrow$ hero), no retaliation. | `L1-B07`, `L1-B10`, `L1-B11`: Attacks resolve column-by-column; sick units skip. |
| **P029** | Death & Match Conclusion | Remove dead units to discard; evaluate hero deaths immediately; simultaneous hero death = player defeat. | `L1-B20`, `L1-B23`, `L1-B24`, `L1-B25`: Immediate match termination on lethal. |
| **P030** | Event FIFO & Stabilization | Queue gameplay events in FIFO; process triggers before next voluntary command; enforce loop budgets. | Events ordered deterministically; triggers do not execute after match conclusion. |
| **P031** | Headless Core Simulation | Run headless test suite covering `L1-B01` to `L1-B14` and `L1-B20` to `L1-B27`; generate state hashes. | Gate G3: Complete scripted combat match runs headlessly with 100% PASS. |

**Gate G3:** Full creature combat simulates headlessly to match conclusion with deterministic seed reproduction.

> **Battlefield Invariant & Combat Engine Extension Point (PLAN-002):**
> - **Battlefield Invariant:** The battlefield grid remains strictly 2 camps × 6 columns × 2 rows (24 tactical Creature positions across `ATTACK` and `DEFENSE` rows). Hero Artifacts do not occupy battlefield slots and do not introduce an Artifact row or board positions.
> - **Engine Extension Point:** The core Lot 1 combat engine is decoupled and declarative. A future extension point allows an active Hero Artifact snapshot (aggregating passive modifiers through generic `EffectOperation` primitives) to be injected at match setup (`HeroState`), without card-specific or artifact-specific code branches. Gate G3 is strictly validated on the core Lot 1 rules; Hero Artifact progression does not block Gate G3.

---

### J4 — Playable Interactive Combat Loop · P032–P037
*Objective: Connect the domain engine to the presentation layer for a complete mouse-playable match.*

| Prompt | Autonomous Task | Scope | Verification / Exit Criterion |
|---|---|---|---|
| **P032** | `CombatPresenter` Adapter | Map `CombatState` to presentation view-models; subscribe to engine events; keep scenes read-only. | Presenter refreshes UI without scene scripts ever reading raw engine private state. |
| **P033** | Connect Board, Tokens & HUD | Bind 24 slots, creature crests, hero HUDs, and mana counters to presenter signals. | Summoning, moving, and HP loss visually update UI instantly without UI logic. |
| **P034** | Click-to-Play Card Flow | Hand card click $\rightarrow$ highlight legal slots from `get_legal_actions()` $\rightarrow$ slot click $\rightarrow$ submit command; Escape cancels. | Invalid click returns card to hand; input parity verified (`L1-U06`, `L1-U07`). |
| **P035** | Drag-and-Drop Card Flow | Drag card over board $\rightarrow$ highlight slots $\rightarrow$ drop $\rightarrow$ issue identical `CombatCommand`. | Drag-and-drop and click-click produce identical engine commands (`L1-U06`). |
| **P036** | Basic Opponent Bot | Integrate temporary AI loop: executes legal actions on opponent turn or ends turn; hides opponent hand. | Player can alternate full turns against AI without getting stuck (`L1-U11`, `L1-U12`). |
| **P037** | Manual Match Playthrough | Full manual mouse playthrough: summon, move, attack, defeat hero, view result banner, restart match. | Gate G4: Playable creature combat loop verified on screen at 1080p and 720p. |

**Gate G4:** Playable, interactive mouse combat loop verified on screen.

---

### J5 — Full 16-Card Declarative Mechanics · P038–P048
*Objective: Implement all spell, equipment, and ability operations declaratively.*

| Prompt | Autonomous Task | Scope | Verification / Exit Criterion |
|---|---|---|---|
| **P038** | `EffectRegistry` Dispatcher | Build declarative dispatcher for `EffectOperation` resources; enforce standard error if opcode unsupported. | Reusable handlers; zero card-id specific branching scripts. |
| **P039** | Implement `DAMAGE` Operation | Support Fireball: deduct mana, validate single enemy creature target, apply 4 damage, emit events. | Fireball functions via generic handler; second spell definition works instantly. |
| **P040** | Implement `HEAL` Operation | Support Mending Light: deduct mana, validate allied target, restore up to max HP, emit `ON_HEAL`. | `L1-B15`, `L1-B16`: Correct HP restoration and overheal handling. |
| **P041** | Implement `ADD_SHIELD` Operation | Support Arcane Barrier: add 3 shield to allied creature, track expiration, handle absorption. | `L1-B13`, `L1-B14`: Shields absorb damage correctly and expire on schedule. |
| **P042** | Temporary `MODIFY_STAT` | Support Martial Blessing: grant +2 ATK until turn end; register duration; revert at turn cleanup. | `L1-B17`: ATK bonus clears at turn end; updates inspection panel. |
| **P043** | Positional Passives | Implement row-based passives: Oathbound Knight (+1 ATK on attack row), Mist Sentinel (+1 Armor on defense). | Changing row recalculates effective stats once without stacking on refresh. |
| **P044** | Active Ability Handler | Support Woodland Healer: pay 1 mana to heal allied unit 2 HP; validate controller, turn, and target. | Active ability validates mana and target; reuses `HEAL` handler. |
| **P045** | `ON_SUMMON` Trigger Handler | Support Rune Crafter: triggers `ON_SUMMON` $\rightarrow$ queues `ADD_SHIELD(2)` to self in FIFO. | Trigger resolves via queue before next voluntary command. |
| **P046** | `EQUIP` Operation & Slots | Support Runic Blade and Bastion Armor: attach to valid slot, apply passive buff, replace old items. | `L1-B18`, `L1-B19`: Replaced equipment sent to discard; 0-slot Dragons enforced. |
| **P047** | Target Fizzle & Compound Safety | Re-validate targets at atomic resolution; fizzle gracefully if target died/moved; partial success in multi-target. | `L1-B21`: Target death does not crash engine or refund mana. |
| **P048** | Atomic Grouping & Simultaneous Damage | Group compatible simultaneous damage instances; consume shields in canonical order; commit HP simultaneously. | `L1-B22`, `L1-B30`: Q287–Q289 verified; all 16 cards fully playable. |

**Gate G5:** All 16 cards fully functional via declarative operations; tests `L1-B15` to `L1-B22` passing.

> **Scope Boundary Notice (PLAN-002):**
> Gate G5 validates the 16 declarative cards (spells, equipments, creature abilities) and Creature Equipment slots (0–2 slots: at most 1 Weapon and 1 Protection; Dragons have 0). Hero Artifact progression, active artifact capacity, and artifact inventory are deferred to Phase 2 (Tower Exploration) and are strictly non-blocking for Gate G5.

---

### J6 — Non-Cheating Heuristic AI V1 · P049–P053
*Objective: Build an autonomous, non-cheating heuristic AI that plays strategically and completes matches.*

| Prompt | Autonomous Task | Scope | Verification / Exit Criterion |
|---|---|---|---|
| **P049** | Complete Legal Action Space | Expose all valid actions to AI: summon, move, swap, spells, equipment, abilities, end turn. | Every candidate command returned by engine is guaranteed legal and affordable. |
| **P050** | Secured `CombatObservation` | Sanitize AI observation: mask player hand card identities and deck draw order. | `L1-B28`: Modifying player hidden hand does not alter AI decision. |
| **P051** | Heuristic Scoring Function | Score candidate actions: immediate lethal, threat reduction, board presence, mana efficiency, healing injured units. | AI avoids wasteful healing on full-HP units and prioritizes high-value plays. |
| **P052** | Tactical Guardrails | Enforce loop safety: max 10 voluntary actions per AI turn; guaranteed "End Turn" command; deterministic tie-breaking. | AI never loops infinitely on turn; cleanly completes turns. |
| **P053** | AI Automated Match Suite | Run 20 automated AI vs AI matches across multiple seeds; verify no crashes, no illegal moves, and deterministic results. | Gate G6: Fully autonomous, robust, legal AI verified (`L1-B28`, `L1-B29`). |

**Gate G6:** Robust, non-cheating heuristic AI opponent capable of completing full matches autonomously.

---

### J7 — Art Direction & Juicy VFX · P054–P060
*Objective: Achieve professional visual polish, snappy animations, and responsive feedback.*

| Prompt | Autonomous Task | Scope | Verification / Exit Criterion |
|---|---|---|---|
| **P054** | Integrate Visual Assets | Import board background, 16 card illustrations, crest portraits, UI frames, and particle textures. | All 16 cards have distinct illustrations; no missing asset errors. |
| **P055** | Finalize Card & Token Shaders | Add subtle card foil/border shaders, rarity gem tints (Common to Legendary), and clean typography. | Cards look premium and distinct; rarity conveyed by frame and icon (`L1-U13`). |
| **P056** | Decoupled Visual Sequencer | Feed engine events to animation sequencer; animate sequentially while keeping domain decoupled. | `L1-U09`, `L1-U10`: Delayed VFX never rewrites newer state. |
| **P057** | Card & Token Animations | Animate card draw, hand hover lift, drag trail, summon impact, token drop, and unit movement. | Smooth 60fps animations; drag and click flows feel responsive. |
| **P058** | Combat & Protection VFX | Animate attack lunge/strike, red floating damage numbers, metallic armor deflection sparks, and shield shimmer. | `L1-U08`: Distinct visual feedback for HP damage, armor, and shield. |
| **P059** | Ability & Match Result Polish | Animate spell casts, heal glow, equipment attachment, victory/defeat modal banner, and replay button. | Satisfying match conclusion feedback with clear replay action. |
| **P060** | Resolution & Ergonomics Audit | Audit 1920×1080 and 1280×720 layouts with full 24-unit boards; verify button hitboxes and text scaling. | Gate G7: Visual sign-off on both resolutions (`L1-U01`..`U13`). |

**Gate G7:** Visual and presentation sign-off at 1080p and 720p with juicy, decoupled VFX.

---

### J8 — Acceptance Audit & Windows Build · P061–P065
*Objective: Final verification of all 45 acceptance criteria, extensibility test, and Windows export.*

| Prompt | Autonomous Task | Scope | Verification / Exit Criterion |
|---|---|---|---|
| **P061** | Core Engine Acceptance Audit | Execute all 32 core tests (`L1-B01` to `L1-B32`) via headless test runner; record command and console log. | 32/32 tests report PASS with zero failures. |
| **P062** | UX & Presentation Audit | Execute and document visual verification for all 13 UX tests (`L1-U01` to `L1-U13`) with captured screenshots. | 13/13 UX criteria verified with screenshot evidence. |
| **P063** | Extensibility & Robustness Test | Add a 17th declarative card definition combining existing effects; verify catalog validation and gameplay execution. | `L1-B31`: Extensibility proven without modifying engine GDScript. |
| **P064** | Windows Standalone Export | Configure Godot Windows export preset; build `MagicOdyssey.exe`; test game launch on clean Windows machine. | Standalone `.exe` runs full match cleanly outside Godot editor. |
| **P065** | Final Acceptance Sign-off | Compile final validation matrix, bug registry, and release documentation; sign off on Gate G8. | Gate G8: Lot 1 officially accepted and delivered. |

**Gate G8:** Complete, validated, reproducible Lot 1 vertical slice ready for human review.

---

## D. Acceptance Test Traceability Matrix

| Test ID Range | Focus Area | First Implemented In | Audited In |
|---|---|---|---|
| `L1-B01` – `L1-B04` | Match init, turn flow, mana growth, resource rejection | J2, J3 (P020–P023) | J8 (P061) |
| `L1-B05` – `L1-B09` | Contestation priority, summon, sickness, move, swap | J3 (P025–P026) | J8 (P061) |
| `L1-B10` – `L1-B14` | Combat order, retaliation, armor, shields, depletion | J3 (P027–P028) | J8 (P061) |
| `L1-B15` – `L1-B19` | Healing, overheal, temp stat expiration, equipment | J5 (P040–P046) | J8 (P061) |
| `L1-B20` – `L1-B25` | Death, target fizzle, atomic damage, victory/defeat | J3, J5 (P029, P047–P048) | J8 (P061) |
| `L1-B26` – `L1-B27` | Progressive fatigue (1, 2, 3...), hand overflow | J3 (P024) | J8 (P061) |
| `L1-B28` – `L1-B30` | AI fairness, deterministic replay, atomic rollback | J3, J6 (P021, P050, P053) | J8 (P061, P063) |
| `L1-B31` – `L1-B32` | 17th card extensibility, malformed `.tres` rejection | J2, J5 (P013, P048) | J8 (P063) |
| `L1-U01` – `L1-U05` | 1080p, 720p, crowded board, inspection, status icons | J1, J7 (P005–P010, P060) | J8 (P062) |
| `L1-U06` – `L1-U10` | Input parity, abort drag, VFX feedback, responsive input | J4, J7 (P034–P035, P056–P058) | J8 (P062) |
| `L1-U11` – `L1-U13` | Opponent hand privacy, game loop & replay, accessibility | J4, J7 (P036–P037, P060) | J8 (P062) |

---

## E. Single Prompt Template for AI Execution

When invoking an AI agent for prompt `PNNN`:
```text
Task: Implement MagicOdyssey Lot 1 Prompt PNNN — [Title]
Upstream Specs: specs/01-lot1-vertical-slice/01-scope.md, specs/01-lot1-vertical-slice/02-catalog.md, specs/01-lot1-vertical-slice/04-architecture-godot.md
Relevant Acceptance Criteria: [e.g. L1-B05, L1-B06]
Allowed Files to Modify/Create: [e.g. res://scripts/domain/combat_engine.gd]
Invariants Forbidden to Touch: [e.g. No logic in CreatureToken.gd; keep engine RefCounted]

Execution Steps:
1. Review the required behavior and assertions.
2. Implement typed GDScript code strictly within the allowed files.
3. Run the headless test harness via PowerShell:
   & $GodotExe --headless --path . --script res://scripts/tests/test_runner.gd
4. Report output: modified files, test execution logs, and risks.
```

---

## F. Definition of Done for Lot 1

Lot 1 is strictly accepted when:
1. 32/32 core engine acceptance tests pass headlessly without failures.
2. 13/13 UX criteria pass visual inspection with screenshot proof.
3. The 16 cards are loaded purely from `.tres` Resources without per-card engine scripts.
4. Extensibility test (17th card) succeeds without altering engine GDScript.
5. The standalone Windows executable runs a complete combat match outside the editor.
6. The codebase contains zero placeholder debug boxes, zero unhandled errors, and clean typed GDScript.

---

## G. Post-Lot 1 Roadmap: Hero Artifacts & Exploration Architecture (PLAN-002)

While Lot 1 delivers the self-contained tactical combat vertical slice (`P001`–`P065`), the owner-validated **Hero Artifact System** establishes the foundation for exploration progression across subsequent phases.

### 1. Macro Implementation Phase Sequence
1. **Phase 1 — Combat Engine & Playable Vertical Slice (Current Lot 1):** Complete tactical combat against AI, 16 declarative cards, 24-slot grid, responsive UI, headless test runner (`P001`–`P065`, Gates `G0`–`G8`).
2. **Phase 2 — Tower Exploration:** Floor navigation, merchant shops, draft reward selection, Sanctum respec, persistent Hero Artifact Inventory, limited active artifact slots, and progression-based capacity increases.
3. **Phase 3 — World Exploration:** World map, non-linear node traversal, persistent quest encounters, and multi-run meta-progression.
4. **Phase 4 — Main Menu, Settings & Transverse Systems:** Audio management, user preferences, localization, and full save/load management.

> **Implementation Phase Invariant:** Development must not begin on Phase 2 (Tower Exploration) until Gate `G8` of Lot 1 is fully validated and signed off by the owner.

### 2. Validated Hero Artifact Core Model [VALIDATED]
The project owner has explicitly arbitrated and validated the following design invariants:
1. **Not Cards:** Hero Artifacts are NOT cards and do NOT participate in deck building, hand draws, card play, or graveyard recycling.
2. **Not Creature Equipment:** Hero Artifacts are NOT Creature Equipment. They attach to the Hero's progression state, not to board creature tokens.
3. **Permanent Exploration Objects:** Acquired during exploration (e.g., Tower floor boss rewards, elite encounters, merchant stock).
4. **Hero Artifact Inventory:** Acquired Artifacts are permanently retained in the Hero's Artifact Inventory.
5. **Active vs Inactive State:** Only equipped/activated Artifacts grant active combat or exploration effects.
6. **Limited Active Slots:** The number of simultaneously active Artifacts is strictly limited.
7. **Hero Artifact Capacity:** The Hero possesses an `Artifact Capacity` attribute defining how many Artifacts can be active simultaneously.
8. **Progression-Based Capacity Growth:** Artifact Capacity can increase through Hero progression (e.g., Sphere Grid milestones or level upgrades).
9. **Inactive Artifact Invariant:** Artifacts retained in inventory that are not currently equipped grant zero active effects.
10. **Generic Effect Integration:** Active Artifact effects influence combat through a generic declarative effect system, without hardcoded card-specific or artifact-specific branches in the combat engine.

**Independence from Creature Equipment:**
- Creature Equipment rules remain strictly unchanged: 0 to 2 slots per creature (at most 1 Weapon and 1 Protection; Dragons have 0 slots).
- Hero Artifact Capacity is completely independent of Creature Equipment Slots.
- Artifacts are never counted among the 16 Lot 1 cards and are never placed in the 24 tactical creature slots.

### 3. Open Design Questions & Proposals [OPEN / PROPOSAL]
The following parameters are **not yet validated** and remain open for owner decision during Phase 2 planning:
- Starting Artifact Capacity (proposal: 1 or 2 slots; pending owner validation).
- Maximum Artifact Capacity ceiling across full hero progression.
- Capacity progression curve and unlock milestones (e.g., Sphere Grid node costs).
- Exact acquisition drop rates, loot tables, and merchant pricing.
- Artifact rarity tiers and visual quality coding.
- Complete Artifact catalog and specific effect definitions.
- Whether Artifacts can be consumed, upgraded, fused, or transformed.
- Rules for changing equipped Artifacts during combat (proposal: equipping/unequipping occurs strictly outside combat; pending owner confirmation).
- Persistence between separate Tower runs vs cross-run meta-progression.
- Detailed effect stacking order and precedence resolution.
- Inventory size limits (unbounded vs capped inventory).
- Exact HUD screen placement and interaction behavior.

### 4. UI Presentation Surfaces
The Hero Artifact system spans two complementary presentation surfaces:
- **Surface A — Combat HUD Indicator (Phase 1 Reservation / Phase 2 Implementation):**
  - Compact visual representation of currently active Hero Artifacts.
  - Visually anchored to the Hero HUD zone.
  - **Zero occupation of the 24 tactical Creature positions**; no intrusion into board slots.
  - Compact and readable at both 1920×1080 and 1280×720 without decorative clutter.
  - Recognizable Artifact iconography with hover tooltip showing inspectable effect descriptions.
  - Dynamically supports variable Artifact Capacity (e.g., 1 to N active slots) with clean overflow handling.
  - Visually coherent with the approved player and opponent HUD backplates.
- **Surface B — Hero Artifact Inventory (Phase 2 Tower Exploration):**
  - Full-screen or dedicated modal view in the out-of-combat exploration layer.
  - Displays all acquired Artifacts in persistent storage.
  - Displays currently equipped Artifacts and active slot status.
  - Clearly communicates current Artifact Capacity (active vs available capacity).
  - Handles equipping and unequipping according to validated rules.
  - Provides detailed mathematical inspection of Artifact passive and triggered effects.

### 5. Combat Engine Integration Architecture (Phase 2 Preparation)
To ensure seamless consumption of active Artifact effects when Phase 2 begins:
- **Typed Data Representation:** `ArtifactDefinition` typed Resource inheriting from `Resource`, declaring unique identifier, display metadata, and declarative `Array[EffectOperation]` or passive modifiers.
- **Hero State Snapshot:** At combat match initialization (`CombatFactory`), the player's `HeroState` receives an immutable snapshot of currently equipped active artifacts (`active_artifacts: Array[ArtifactDefinition]`).
- **Generic Effect Dispatch:** Active artifact modifiers (e.g., start-of-combat shields, passive stat auras, fatigue mitigation) hook into the existing `EffectRegistry` and event FIFO queue without adding artifact-specific `if/else` logic to `CombatEngine`.
- **Deterministic Verification:** Artifact effects are covered by automated headless tests ensuring identical RNG seeds produce identical outcomes with active artifacts enabled.
