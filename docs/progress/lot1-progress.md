# MagicOdyssey — Lot 1 Implementation Progress Tracker

**Document Version:** 1.0
**Last Updated:** November 2026
**Status:** Active Implementation Tracking

---

## A. Project Baseline

- **Project:** MagicOdyssey
- **Target:** Lot 1 Playable Combat Vertical Slice
- **Engine:** Godot 4.7.2 stable (`D:\Temp\Godot_v4.7.2-stable_win64.exe`)
- **Platform:** Windows PC (Standalone)
- **Language:** Typed GDScript (2D Canvas)
- **Roadmap:** 65 atomic prompts (`P001`–`P065`) across 9 iterations (`J0`–`J8`) and 9 quality gates (`G0`–`G8`)
- **Source of Truth:** Existing normative specifications in `specs/01-lot1-vertical-slice/`, `specs/02-combat-rules/`, `specs/03-presentation-ui/`, `specs/04-progression-rpg/`, `specs/05-technical-systems/`, `specs/06-reference/`

---

## B. Prompt Progress

### J0 — Project Foundation & Test Harness (`P001`–`P004`)
*Milestone Gate: G0 (Project Foundation)*

| Prompt | Title | Status | Verification Evidence / Reference | Commit SHA |
|---|---|:---:|---|:---:|
| **P001** | Initialize Godot 4 Project | **PASS** | `project.godot`, `scenes/main.tscn`, `.gitignore` created. Headless import exit 0; headless launch exit 0; `git diff --check` clean. | `c193bfc` |
| **P002** | Install Normative Specs & Progress Tracking | **PASS** | Normative specs and `AGENTS.md` verified; all paths checked; progress tracker created; Godot headless import exit 0. | `0be2b62` |
| **P003** | Native Headless Test Harness | **PASS** | `test_runner.gd`, `test_asserts.gd`, `test_harness_self.gd`, `run_tests.ps1` created. 14 assertions PASS (exit 0); intentional failure mode verified (1 fail, exit 1); wrapper exit code propagation verified (exit 0 and 1). | — |
| **P004** | Design System & UI Baseline | **TODO** | Scheduled: `Theme`, color tokens, asset manifest, 1080p/720p screenshot baseline. | — |

---

### J1 — Combat Interface: Visual Layout (`P005`–`P010`)
*Milestone Gate: G1 (Combat UI Layout)*

| Prompt | Title | Status | Verification Evidence / Reference | Commit SHA |
|---|---|:---:|---|:---:|
| **P005** | Compose `CombatScreen` | **TODO** | Central battlefield, hero zones, hand area, action bar responsive layout. | — |
| **P006** | Create 24 Board Slots | **TODO** | 2 camps × 6 columns × 2 rows; distinct Attack/Defense rows; slot signals. | — |
| **P007** | Hero & Turn HUDs | **TODO** | HP, mana capacity/available, deck counters, turn banner, End Turn button. | — |
| **P008** | Fantasy Crest `CreatureToken` | **TODO** | Shield token: portrait, ATK (BL), HP (BR), armor/shield badges, max 3 statuses + `+N`. | — |
| **P009** | `CardView` & `HandView` | **TODO** | Illustrated card rendering, fan/linear layout, hover lift. | — |
| **P010** | Tooltip & Inspector Panel | **TODO** | Hover tooltip; click side inspector with original printed card + live breakdown. | — |

---

### J2 — Typed Catalog & Combat Model (`P011`–`P020`)
*Milestone Gate: G2 (Card Catalog & Domain Baseline)*

| Prompt | Title | Status | Verification Evidence / Reference | Commit SHA |
|---|---|:---:|---|:---:|
| **P011** | Define `CardDefinition` | **TODO** | Typed `Resource`: `definition_id`, type, tribe, rarity, cost, base stats. | — |
| **P012** | Ability & Operation Resources | **TODO** | `AbilityDefinition`, `TargetSpec`, `CostSpec`, `DurationSpec`, `EffectOperation`. | — |
| **P013** | Catalog Validator | **TODO** | `CardCatalog` resource loader, duplicate detection, malformed `.tres` rejection. | — |
| **P014** | Define First 5 Creatures | **TODO** | `.tres` resources for Humans & Elves (`human_recruit` .. `elf_healer`). | — |
| **P015** | Define Next 5 Creatures | **TODO** | `.tres` resources for Elves, Dwarves, Dragons; 0 slots for Dragons. | — |
| **P016** | Define 4 Spells | **TODO** | `.tres` resources for Fireball, Mending Light, Arcane Barrier, Martial Blessing. | — |
| **P017** | Define 2 Equipments | **TODO** | `.tres` resources for Runic Blade (`WEAPON`) and Bastion Armor (`PROTECTION`). | — |
| **P018** | Domain Model Entities | **TODO** | `HeroState`, `CardCopy`, `BoardInstance`; `definition_id` vs `copy_id` vs `instance_id`. | — |
| **P019** | Zones & 40-Card Fixtures | **TODO** | Zones (`DECK`, `HAND`, `BOARD`, `DISCARD`, `BANISHED`); 40-card fixtures (max 4 copies). | — |
| **P020** | Deterministic Match Factory | **TODO** | `CombatFactory` state init, seeded PRNG shuffle, 6 initial cards drawn. | — |

---

### J3 — Core Deterministic Combat Engine (`P021`–`P031`)
*Milestone Gate: G3 (Deterministic Engine Core)*

| Prompt | Title | Status | Verification Evidence / Reference | Commit SHA |
|---|---|:---:|---|:---:|
| **P021** | Transaction Pipeline | **TODO** | `CombatCommand`, `ValidationResult`, atomic commit and rollback on failure. | — |
| **P022** | Legal Action Enumerator | **TODO** | `CombatEngine.get_legal_actions(actor)` for summon, move, swap, end turn. | — |
| **P023** | Turn Phases & Mana Growth | **TODO** | Turn start: +1 capacity (starts Turn 1), mana restore, no draw on Turn 1. | — |
| **P024** | Draw, Hand Cap & Fatigue | **TODO** | 1 draw Turn $\ge 2$, max hand 7 (overflow discard), progressive fatigue (1, 2, 3...). | — |
| **P025** | Summoning & Priority | **TODO** | Cost deduction, empty slot validation, contestation priority enforcement. | — |
| **P026** | Movement & Permutation | **TODO** | Vertical natural move (1 mana, 1/turn), column ally swap (1 mana total). | — |
| **P027** | Damage & Protection Core | **TODO** | Attack order: reusable armor $\rightarrow$ consumable shield pool $\rightarrow$ HP loss. | — |
| **P028** | End-of-Turn Combat Phase | **TODO** | Columns 1 to 6 attack order, active Attack row, target priority, no retaliation. | — |
| **P029** | Death & Match Conclusion | **TODO** | Unit death to discard; immediate hero lethal checks; simultaneous lethal = defeat. | — |
| **P030** | Event FIFO & Stabilization | **TODO** | Deterministic FIFO queue; process triggers before next voluntary command. | — |
| **P031** | Headless Core Simulation | **TODO** | Headless test suite for `L1-B01`..`B14`, `L1-B20`..`B27`; deterministic state hashes. | — |

---

### J4 — Playable Interactive Combat Loop (`P032`–`P037`)
*Milestone Gate: G4 (Interactive Combat Loop)*

| Prompt | Title | Status | Verification Evidence / Reference | Commit SHA |
|---|---|:---:|---|:---:|
| **P032** | `CombatPresenter` Adapter | **TODO** | Map `CombatState` to view-models; subscribe to engine events; scenes read-only. | — |
| **P033** | Connect Board, Tokens & HUD | **TODO** | Bind 24 slots, crest tokens, hero HUDs, and mana counters to presenter. | — |
| **P034** | Click-to-Play Card Flow | **TODO** | Click hand card $\rightarrow$ highlight legal slots $\rightarrow$ click slot $\rightarrow$ command. | — |
| **P035** | Drag-and-Drop Card Flow | **TODO** | Drag card over board $\rightarrow$ highlight slots $\rightarrow$ drop to submit command. | — |
| **P036** | Basic Opponent Bot | **TODO** | Temporary AI loop executing legal actions on opponent turn; hidden opponent hand. | — |
| **P037** | Manual Match Playthrough | **TODO** | Full manual mouse playthrough: summon, move, attack, defeat hero, restart match. | — |

---

### J5 — Full 16-Card Declarative Mechanics (`P038`–`P048`)
*Milestone Gate: G5 (Full Declarative Catalog)*

| Prompt | Title | Status | Verification Evidence / Reference | Commit SHA |
|---|---|:---:|---|:---:|
| **P038** | `EffectRegistry` Dispatcher | **TODO** | Declarative opcode dispatcher for `EffectOperation` resources. | — |
| **P039** | Implement `DAMAGE` Operation | **TODO** | Fireball support: 4 damage, enemy creature target validation, event emission. | — |
| **P040** | Implement `HEAL` Operation | **TODO** | Mending Light support: heal 3 HP, clamp to max HP, overheal discard. | — |
| **P041** | Implement `ADD_SHIELD` Operation | **TODO** | Arcane Barrier support: grant 3 shield, expiration tracking, absorption. | — |
| **P042** | Temporary `MODIFY_STAT` | **TODO** | Martial Blessing support: +2 ATK until turn end, cleanup revert. | — |
| **P043** | Positional Passives | **TODO** | Row passives: Oathbound Knight (+1 ATK Attack row), Mist Sentinel (+1 Armor Defense). | — |
| **P044** | Active Ability Handler | **TODO** | Woodland Healer support: pay 1 mana $\rightarrow$ heal allied unit 2 HP. | — |
| **P045** | `ON_SUMMON` Trigger Handler | **TODO** | Rune Crafter support: triggers `ON_SUMMON` $\rightarrow$ queues `ADD_SHIELD(2)` to self. | — |
| **P046** | `EQUIP` Operation & Slots | **TODO** | Runic Blade & Bastion Armor; slot replacement to discard; 0-slot Dragons. | — |
| **P047** | Target Fizzle & Compound Safety | **TODO** | Target re-validation at commit; clean fizzle on target loss; multi-target partial. | — |
| **P048** | Atomic Grouping & Simultaneous Damage | **TODO** | Group compatible damage; canonical shield depletion; simultaneous HP commit. | — |

---

### J6 — Non-Cheating Heuristic AI V1 (`P049`–`P053`)
*Milestone Gate: G6 (Tactical AI Opponent)*

| Prompt | Title | Status | Verification Evidence / Reference | Commit SHA |
|---|---|:---:|---|:---:|
| **P049** | Complete Legal Action Space | **TODO** | Expose all legal actions to AI: summon, move, swap, spells, equipment, abilities. | — |
| **P050** | Secured `CombatObservation` | **TODO** | Sanitize AI view: mask player hand cards and deck library order. | — |
| **P051** | Heuristic Scoring Function | **TODO** | Tactical scoring: lethal priority, board control, mana efficiency, injury healing. | — |
| **P052** | Tactical Guardrails | **TODO** | Max 10 actions per turn; guaranteed End Turn; deterministic tie-breaking. | — |
| **P053** | AI Automated Match Suite | **TODO** | 20 automated AI vs AI matches across seeds; zero crashes; deterministic replay. | — |

---

### J7 — Art Direction & Juicy VFX (`P054`–`P060`)
*Milestone Gate: G7 (Visual Polish & Juice)*

| Prompt | Title | Status | Verification Evidence / Reference | Commit SHA |
|---|---|:---:|---|:---:|
| **P054** | Integrate Visual Assets | **TODO** | Board background, 16 card arts, crest portraits, UI frames, particle textures. | — |
| **P055** | Finalize Card & Token Shaders | **TODO** | Card foil/border shaders, rarity gem tints, accessible high-contrast cues. | — |
| **P056** | Decoupled Visual Sequencer | **TODO** | Event queue to animation sequencer; decoupled domain; non-blocking particles. | — |
| **P057** | Card & Token Animations | **TODO** | Smooth card draw, hand hover lift, drag trail, token drop, unit movement. | — |
| **P058** | Combat & Protection VFX | **TODO** | Attack strike, red damage numbers, metallic armor sparks, blue shield shimmer. | — |
| **P059** | Ability & Match Result Polish | **TODO** | Spell casts, heal glow, equipment attachment, victory/defeat modal banner. | — |
| **P060** | Resolution & Ergonomics Audit | **TODO** | Audit 1080p and 720p layouts with full 24-token board; hitbox validation. | — |

---

### J8 — Acceptance Audit & Windows Build (`P061`–`P065`)
*Milestone Gate: G8 (Lot 1 Final Acceptance)*

| Prompt | Title | Status | Verification Evidence / Reference | Commit SHA |
|---|---|:---:|---|:---:|
| **P061** | Core Engine Acceptance Audit | **TODO** | Execute all 32 core tests (`L1-B01`..`B32`) via headless test runner; 100% PASS. | — |
| **P062** | UX & Presentation Audit | **TODO** | Visual audit for all 13 UX criteria (`L1-U01`..`U13`) with screenshot proof. | — |
| **P063** | Extensibility & Robustness Test | **TODO** | 17th declarative card definition test without altering engine GDScript. | — |
| **P064** | Windows Standalone Export | **TODO** | Build `MagicOdyssey.exe` via Windows export preset; test clean launch. | — |
| **P065** | Final Acceptance Sign-off | **TODO** | Compile validation matrix, bug registry, release notes; sign off on Gate G8. | — |

---

## C. Quality Gates Status

| Gate | Scope | Status | Preconditions / Exit Criteria |
|:---:|---|:---:|---|
| **G0** | J0 (`P001`–`P004`) | **NOT_VALIDATED** | Godot 4.7.2 project imports cleanly; headless test harness operational; UI theme baseline established. |
| **G1** | J1 (`P005`–`P010`) | **NOT_VALIDATED** | 24 board slots, hero HUDs, fantasy crest tokens, interactive hand, and inspection panel visible on screen. |
| **G2** | J2 (`P011`–`P020`) | **NOT_VALIDATED** | 16 card `.tres` resources validate cleanly; 40-card fixtures valid; match factory reproducible with seed. |
| **G3** | J3 (`P021`–`P031`) | **NOT_VALIDATED** | Core rules (summon, move, attack, damage, armor, shields, fatigue, death) simulate headlessly with PASS. |
| **G4** | J4 (`P032`–`P037`) | **NOT_VALIDATED** | Complete mouse-driven interactive match loop (drag/click card, summon, move, attack, end turn, victory). |
| **G5** | J5 (`P038`–`P048`) | **NOT_VALIDATED** | All 16 cards fully functional declaratively; target fizzling, buffs, shields, and equipment operational. |
| **G6** | J6 (`P049`–`P053`) | **NOT_VALIDATED** | Autonomous, non-cheating heuristic AI completes 20 consecutive automated matches without error. |
| **G7** | J7 (`P054`–`P060`) | **NOT_VALIDATED** | Semi-realistic fantasy art style, snappy VFX (100–350ms), decoupled input unlocking, 1080p/720p sign-off. |
| **G8** | J8 (`P061`–`P065`) | **NOT_VALIDATED** | 32/32 engine tests PASS headlessly; 13/13 UX criteria verified; 17th card extensibility PASS; Windows `.exe` verified. |

---

## D. Open Verification Items

1. **P001 Graphical Visual Review:** `NOT_RUN` (P001 was verified via headless import and launch; human graphical window inspection is pending).
2. **Engine Acceptance Tests:** `NOT_RUN` (0 of 32 engine tests executed; test runner scheduled for P003).
3. **UI Acceptance Tests:** `NOT_RUN` (0 of 13 UX criteria evaluated; visual implementation scheduled across J1, J4, J7).
4. **Dedicated Test Harness:** Operational (`scripts/tests/test_runner.gd`, `test_asserts.gd`, `test_harness_self.gd`, `run_tests.ps1`). Self-tests PASS (14 assertions, exit 0); negative failure mode verified (exit 1).

---

## E. Progress Update Instructions for AI Agents

When executing subsequent prompts (`P003` through `P065`):
1. **Factual Status Only:** Set a prompt status to `PASS` **only after** actual verification commands have succeeded with exit code 0. Never guess or pre-mark a prompt as complete.
2. **Record Real Evidence:** In the *Verification Evidence* column, log the exact command executed, exit code, and key assertion counts.
3. **Record Commit SHA:** Record the git commit hash in the *Commit SHA* column only when the commit has been created.
4. **Preserve Normative Content:** Never modify the underlying game rules, acceptance criteria, or prompt definitions when updating this tracker.
5. **Quality Gates:** Never set a Quality Gate (`G0`–`G8`) to `VALIDATED` until all constituent prompts in that iteration have passed and all gate exit criteria are demonstrably satisfied.
6. **Keep Updates Concise:** Maintain clean tabular Markdown formatting without conversational fluff.
