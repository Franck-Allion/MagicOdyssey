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
| **P005** | Compose `CombatScreen` | Build central battlefield layout, opponent/player hero zones, hand area, and action bar with responsive anchors. | No UI component clipped at 1920×1080 or 1280×720 (prepares `L1-U01`, `L1-U02`). |
| **P006** | Create 24 Board Slots | Draw 2 camps × 6 columns × 2 rows; visually distinguish `ATTACK` and `DEFENSE` rows; wire hover/select signals. | All 24 slots selectable and visually distinct (`L1-U03`). |
| **P007** | Hero & Turn HUDs | Display HP, mana capacity/available, deck counters, active camp banner, and "End Turn" button. | HUD values refresh purely via injected view-models; no engine coupling. |
| **P008** | Fantasy Crest `CreatureToken` | Create shield-shaped crest token: portrait, ATK (bottom-left), HP (bottom-right), armor/shield badges, max 3 statuses + `+N`. | Demonstrable on 24 tokens with diverse stats and statuses (`L1-U03`, `L1-U05`). |
| **P009** | `CardView` & `HandView` | Render premium illustrated card with cost, title, tribe, frame, and fan/linear hand layout with hover lift. | Cards render clearly in hand; readable at 720p; handles multi-instance copies. |
| **P010** | Tooltip & Inspector Panel | Hover: concise tactical tooltip; Click: opens side inspector with original printed card + live modifier breakdown. | Demonstrates `L1-U04` on a buffed creature; visual review at 1080p and 720p. |

**Gate G1:** Coherent 2D visual board with 24 slots, crest tokens, hand, and inspector. No temporary debug boxes.

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
