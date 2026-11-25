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
| **P004** | Design System & UI Baseline | **PASS** | Native Theme, typed tokens, static showcase and asset inventory created. Headless import exit 0; native harness 14/14 assertions PASS (exit 0); showcase headless launch exit 0. Actual graphical captures at 1080p/720p, both exit 0; layout inspected. Interaction/focus review NOT_RUN. Commands and evidence: `docs/art/ui-baseline.md`. | — |

---

### J1 — Combat Interface: Visual Layout (`P005`–`P010`)
*Milestone Gate: G1 (Combat UI Layout)*

> **Artistic Refinement Status Notice (PLAN-001 / P005-CLOSE):**
> `P005` (CombatScreen Composition and Presentation) and its final refinement milestone `P005-R09` have received **explicit owner artistic approval and sign-off** ("I officially approve P005-R09 and the artistic composition of the CombatScreen"). P005 is formally closed with status `TECH PASS / ART OWNER-APPROVED`. Progression to `P006` is authorized.
> **Quality Gate Notice:** `P005` completion does **NOT** validate Gate `G1`. Gate `G1` requires the separate implementation and validation of `P006` (24 Board Slots), `P007` (Hero & Turn HUD data binding), `P008` (CreatureToken), `P009` (CardView variants), and `P010` (Tooltip & Inspector). Gate G1 remains strictly `NOT_VALIDATED`.
> **Hand Capacity Rule Notice:** `P005-R05` supports visual presentation of 0–10 cards. The normative gameplay rule (`specs/01-lot1-vertical-slice/01-scope.md` §3.6 and Decision Q39) remains 7 cards until formal consolidation in `P024`.

| Prompt | Title | Status | Verification Evidence / Reference | Commit SHA |
|---|---|:---:|---|:---:|
| **P005** | Compose `CombatScreen` | **TECH PASS / ART OWNER-APPROVED** | Final artistic composition and layout officially approved by project owner ("I officially approve P005-R09 and the artistic composition of the CombatScreen"). Final artistic approval: CONFIRMED. Owner sign-off: CONFIRMED. Evidence: P005-R09C final acceptance review (`docs/art/reviews/p005-r09c/review.md`). Technical baseline: 2507/2507 native assertions PASS; ART-002 visual regression: 3/3 bit-exact PASS; real Windows standalone desktop verified at 1080p, 720p, and default window modes (ESC 0). P005 formally closed as protected visual baseline. Authorized to proceed to P006. | — |
| **P005-R01** | Animated liquid Health / Mana orbs | **TECH PASS / ART REVIEW** | Four independent orbs; 263/263 native assertions PASS; GPU 1080p/720p and animated evidence; ART-002 3/3 bit-exact. Recommendation KEEP_WITH_ADJUSTMENTS; owner artistic review pending. `docs/art/reviews/p005-r01/review.md`. | — |
| **P005-R02** | Combat composition / Windows preview | **TECH PASS / ART REVIEW** | Rebalanced five-region layout, 220 px player orbs, compact seven-card fan; 266 native assertions PASS; GPU 1080p/720p and isolated Windows shell launches at both sizes; ESC exits 0. KEEP_WITH_ADJUSTMENTS, owner approval pending. `docs/art/reviews/p005-r02/review.md`. | — |
| **P005-R04** | Player HUD / adaptive ten-card display | **TECH PASS / ART REVIEW** | Display 0–10; 270 px fan; compact hero; dense liquid with settling. 1223 native assertions PASS; ART-002 3/3 bit-exact; GPU and isolated Windows 7/10-card 1080p/720p, ESC 0. KEEP_WITH_ADJUSTMENTS; normative gameplay cap remains 7. `docs/art/reviews/p005-r04/review.md`. | — |
| **P005-R05** | Hand Recognition & Hover Inspection | **TECH PASS / ART REVIEW** | Hearthstone-style pointer hover inspection; deterministic card picking with hysteresis; left-to-right stacking exposing mana & identity; 440 px readable inspection; smooth interruption; 1473 native assertions PASS; ART-002 3/3 bit-exact; GPU 1080p/720p; isolated Windows desktop playtest at default/1080p/720p with real pointer hover, ESC 0. `docs/art/reviews/p005-r05/review.md`. | — |
| **P005-R06A** | Player Hero HUD Art Assets | **ASSETS OWNER-APPROVED** | Approved portrait frame, one shared HP/Mana housing and panel supplied; owner explicitly accepts panel interior alpha 252–254 for this asset only. Original PNGs included unchanged in R06B. Integrated composition approval remains pending. | — |
| **P005-R06B** | Integrate Player Hero HUD | **TECH PASS / ART REVIEW** | Approved portrait frame, shared HP/Mana housing and backplate integrated. Panel-specific alpha exception retained. 1532 native assertions PASS; ART-002 3/3 bit-exact; GPU 1080p/720p states/animation; unchanged regions bit-exact; isolated Windows hover/animation/default/1080p/720p playtest, ESC 0. KEEP_WITH_ADJUSTMENTS pending owner composition review. `docs/art/reviews/p005-r06b/review.md`. P005 remains incomplete. | — |
| **P005-R06C** | Player HUD Final Harmony & Typography Polish | **TECH PASS / ART REVIEW** | Restrained housing modulation (Color(0.88, 0.86, 0.85, 1)); vertical gaps optically balanced (25.7 px / 26.2 px); AAA typography (38 px focal values, 21 px secondary caption, 3/2 px outline, optical aperture centering); 1548 native assertions PASS; ART-002 3/3 bit-exact; outside regions 100% bit-exact; standalone Windows playtest 1080p/720p/default ESC 0. `docs/art/reviews/p005-r06c/review.md`. | — |
| **P005-R06D** | Player HUD Micro-Polish (Orb Fit & Breathing Room) | **TECH PASS / ART REVIEW** | 180 px diameter orbs; Mana orb bottom clearance 68.2 px (well above 638 px border); '30 / 30' safe-area fit (96 px width, $\ge 11.8$ px liquid margin); 15 px secondary caption; 1553 native assertions PASS; ART-002 3/3 bit-exact; outside regions 100% bit-exact; standalone Windows playtest 1080p/720p/default ESC 0. `docs/art/reviews/p005-r06d/review.md`. | — |
| **P005-R06E** | Player HUD Bottom Anchoring | **TECH PASS / ART REVIEW** | Parent moved down 124 reference px to (24, 344), size 272 x 700; 36 px bottom margin. Approved children unchanged; 272 x 296 upper-left envelope reserved. 1598 native assertions PASS; ART-002 3/3 bit-exact; real GPU 1080p/720p containment and animated orbs PASS; Windows standalone hover/animation and ESC exit 0. `docs/art/reviews/p005-r06e/review.md`. Owner composition approval pending; P005 remains incomplete. | � |
| **P005-R07A** | Opponent HUD Art Assets | **ASSETS AVAILABLE / OWNER-APPROVED FOR INTEGRATION** | Panel committed in 8af7bd5, premium 1086x1448 card back committed in c9984d2; reuse approved R06A portrait frame/housing. Current R07B request approves the T04B external-value arrangement. Source PNGs unchanged. | 8af7bd5, c9984d2 |
| **P005-R07B** | Integrate Opponent HUD | **TECH PASS / ART REVIEW** | Upper-left 272x296 HUD, 44px animated indicators with external 23px values; six premium hidden card backs centered above battlefield. 1818 native assertions PASS, ART-002 3/3 bit-exact, real GPU 1080p/720p and isolated Windows hover/animation/ESC 0. [Review](../art/reviews/p005-r07b/review.md). Owner composition approval pending; P005 remains incomplete. | - |
| **P005-R08A** | Deck, Graveyard & Turn Control Assets | **ASSETS AVAILABLE / OWNER-APPROVED FOR INTEGRATION** | Four supplied RGBA utility/status/button/empty-graveyard sources committed unchanged in 101cc8f; reuse official card back. Near-opaque interiors accepted; transparent graveyard aperture preserved. [Preflight](../art/reviews/p005-r08b/asset_preflight.json). | 101cc8f |
| **P005-R08B** | Integrate Deck, Graveyard & Turn Controls | **TECH PASS / ART KEEP_WITH_ADJUSTMENTS** | Approved backplates, shared DeckStackView/GraveyardView, native End Turn states; 2452 assertions PASS, ART-002 3/3 bit-exact, GPU 1080p/720p and isolated Windows button/hand/animation/ESC 0. [Review](../art/reviews/p005-r08b/review.md). Presentation-only; card-back move deferred; owner requested typography, spacing and button refinement in R08C. P005 incomplete; stop after R08B. | - |
| **P005-R08C** | Utility HUD Layout & Typography Polish | **TECH PASS / ART REVIEW** | Centered 19px semibold heading, quiet 16px body, measured card margins 11.52/12.43px and gap 16.26px, 112px miniatures, inset 190px End Turn. 2476 assertions PASS; ART-002 3/3 bit-exact; GPU 1080p/720p and isolated Windows mouse/focus/Space/animation/ESC 0. [Review](../art/reviews/p005-r08c/review.md). Source PNGs and shared components unchanged; optional full-size art widening documented, not started. Owner approval pending; P005 incomplete; stop after R08C. | - |
| **P005-R09A** | Global CombatScreen Visual Audit (AUDIT) | **AUDIT COMPLETE / TARGETED_CORRECTIONS_REQUIRED** | Read-only production audit at baseline 9ae59b6; 2476 native assertions PASS, ART-002 3/3 bit-exact, all GPU scenarios and isolated Windows input/animation/ESC 0. One MAJOR: 720p hover long title 8.51px and rules 9.32-9.72px. [Review, issue register and acceptance matrix](../art/reviews/p005-r09a/review.md). Token density and dedicated card art deferred; Artifact reservation proposed without capacity assumptions. No production changes. P005/R09 owner sign-off remains open; G1 NOT_VALIDATED. Stop after audit. | - |
| **P005-R09B** | Premium Card Hover Readability & Inspection Polish | **TECH PASS / ART REVIEW** | Resolves R09A-001: 540 px inspection height (360 px at 720p); adaptive vertical clamping (inspect_center_y = -20 px, 26 px bottom margin, zero bottom clipping); controlled 2-line title wrapping for long titles (48 pt); 720p physical text scaled to ~12 px (long title 11.93 px, rules 11.93 px, short title 16.91 px). 2507 native assertions PASS; ART-002 3/3 bit-exact; real GPU candidate and scenario evidence; isolated Windows standalone playtest default/1080p/720p, ESC 0. [Review](../art/reviews/p005-r09b/review.md). P005 remains incomplete pending explicit owner artistic sign-off in P005-R09; G1 remains NOT_VALIDATED. | — |
| **P005-R09C** | Final CombatScreen Artistic Acceptance Review | **REVIEW COMPLETE / OWNER-APPROVED** | Definitive artistic acceptance package at commit 32484f5; 2507 native assertions PASS; ART-002 3/3 bit-exact; 18 GPU captures across standard/stress/inspection/utility/diagnostic; isolated Windows standalone playtest default/1080p/720p, ESC 0. R09A-001 verified resolved; zero BLOCKER/MAJOR issues open. [Review](../art/reviews/p005-r09c/review.md). Formal owner sign-off explicitly confirmed on 2026-11-16 ("I officially approve P005-R09 and the artistic composition of the CombatScreen"). P005 formally closed. G1 remains NOT_VALIDATED. | — |
| **P005-R09** | Global Visual Harmony & P005 Sign-off | **OWNER-APPROVED / COMPLETE** | Global visual harmony and CombatScreen artistic composition officially approved by project owner ("I officially approve P005-R09 and the artistic composition of the CombatScreen"). Evaluated across audit (`P005-R09A`), 720p hover readability polish (`P005-R09B`), and final acceptance review (`P005-R09C`). Space reservation verified for future compact active Hero Artifact indicator without slot collision. Explicit owner sign-off confirmed on 2026-11-16. [Review](../art/reviews/p005-r09c/review.md). Progression to P006 authorized. | — |
| **P006** | Create 24 Board Slots | **TECH PASS / ART REVIEW** | Original 24 guides now typed, uniquely addressed and interactive; single selection, hover, passive highlight, disable and token-anchor APIs. 2996 native assertions PASS; 256 GPU checks; P005 idle 0 differing pixels at 1080p/720p; ART-002 3/3 bit-exact. Isolated Windows OS pointer: all 24 identities, switching/toggle, hand isolation, End Turn and ESC 0 at default/1080p/720p. [Review](../art/reviews/p006/review.md). P006 owner artistic acceptance pending; presentation only; P007–P010 TODO; G1 NOT_VALIDATED. | — |
| **P007** | Hero & Turn HUDs | **TECH PASS / ART REVIEW** | Implemented typed view-models (`HeroHudViewModel`, `CombatHudViewModel`) and presentation data-binding APIs (`apply_hud_view_model`, granular helpers, `end_turn_requested` signal). Verified health/mana orbs, deck/graveyard counters, turn/phase banner, and End Turn states across 1080p and 720p. 3098 native assertions PASS (+102 new); ART-002 3/3 bit-exact; 18 GPU captures; isolated Windows playtest default/1080p/720p ESC 0. [Review](../art/reviews/p007/review.md). Presentation only; P008–P010 remain TODO; G1 remains NOT_VALIDATED. | — |
| **P008** | Premium rectangular `CreatureToken` | **OWNER ART-APPROVED / WINDOWS FOLLOW-UP PASS** | Final owner approval explicitly confirmed 2026-11-22 after actual Windows executable viewing: V05 frame/geometry/portrait/four-stat layout and P008-F04 Bahnschrift 700 natural-width white numerals with thin black outline accepted, including the deliberate native 720p compromise. No further V05 redesign required. [Final sign-off and preserved limitations](../art/reviews/p008/owner-sign-off-2026-11-22.md). Historical 14/11 targets, residual material interference, reduced 99 height and approved-icon dependency remain documented. [New Windows follow-up](../art/reviews/p008/final-windows-2026-11-22/review.md) PASS at default/1080p/720p: all 24 real-pointer slots, raised hand, End Turn mouse/Space and ESC 0. P009-R01A preparation authorized; G1 NOT_VALIDATED. | - |
| **P008-C** | CreatureToken V02 alpha and stat readability refinement (C01/C02) | **C02 TECH PASS / ART CORRECTIONS REQUIRED** | Corrected V02 is now the production frame; C01 PNG bytes and ART-002 materials preserved. Measured secondary inserts/170-point numerals, neutral zero state, unchanged P005–P007 APIs/grid. 3662 native assertions PASS (3620 retained +42); 718 GPU checks; ART-002 3/3 bit-exact; P006 empty parity 0 pixels at both sizes. Six isolated Windows single/full runs, including exact 1080p/720p: 24 OS-pointer identities, hand/raised inspection, End Turn and ESC 0. Native 720p ink: primary single 10 px, primary double 7 px, secondary 7 px; four-stat comfort remains inadequate. [Evidence and recommendation](../art/reviews/p008-c/review.md). Owner acceptance pending; P009/P010 TODO; G1 NOT_VALIDATED. | — |
| **P008-D** | CreatureToken tactical readability polish | **TECH PASS / OWNER ART REVIEW** | Native GPU A/B/C comparison retained C: hidden defensive zeros, upper development-only diagnostics, condensed safe primary fit. 720p primary ink: singles 10?11 px, doubles 7?9 px; positive secondary ink remains 7 px. V02/ART-002 and P005?P008 APIs preserved. 3681 native assertions PASS (3662 retained +19); 717 GPU checks per variant; ART-002 3/3 bit-exact; three isolated full-board Windows modes including exact 1080p/720p, all 24 OS-pointer slots, hand isolation, End Turn and ESC 0. [Review and remaining icon/readability decisions](../art/reviews/p008-d/review.md). Owner acceptance pending; P009/P010 TODO; G1 NOT_VALIDATED. | ? |
| **P008-E** | Minimal rectangular CreatureToken V03 integration | **TECH PASS / READABILITY TARGETS NOT MET** | Owner V03 RGBA source preserved; runtime byte-identical; measured stat/portrait calibration and reversible development V02/V03 GPU comparison. 3681 native assertions PASS (geometry expectations recalibrated; count unchanged), 717 GPU checks per frame, ART-002 3/3 bit-exact, empty parity 0 pixels, final isolated Windows default/1080p/720p all 24 real-pointer slots, hand/End Turn and ESC 0. Native 720p primary ink 11 px single / 9 px double, secondary 7 px: targets not reached. No artistic acceptance. [Review](../art/reviews/p008-e/review.md). P009/P010 TODO; G1 NOT_VALIDATED. | - |
| **P008-F01** | Tactical CreatureToken layout benchmark | **DIAGNOSTIC REVIEW COMPLETE / OWNER LAYOUT DECISION PENDING** | Three review-only equal-footprint layouts compared with unchanged production V03 at native 1080p/720p. Recommend B: 720p primary ink 14 px and secondary 11 px; portrait area 55.1% before indicators. 240 measured stat/value/resolution records; 24-token boards and genuine side-by-side captures, contrast/contour limitations documented. 3681 native assertions unchanged/PASS; 1136 GPU checks +32 hover/selection checks; ART-002 3/3 bit-exact; 215 production files verified unchanged. No production implementation, new artwork or Windows build. [Review, matrix and evidence](../art/reviews/p008-f01/review.md). Owner choice required; P009/P010 TODO; G1 NOT_VALIDATED. | - |
| **P008-F03** | V05 integration and final tactical readability verification | **TARGETED_CORRECTIONS_REQUIRED / NOT TECHNICALLY COMPLETE** | 2026-11-21 verification of existing HEAD V05 integration: RGBA/alpha normalization and runtime bytes PASS; 3691 native assertions, 1276 GPU checks +6 active backgrounds, ART-002 3/3 bit-exact; 225 production files preserved; P006 empty parity 0 pixels. Fresh same-data V03/B/V05 comparison and 240 actual-renderer measurements: V05 720p primary single/double 12/10 px versus B 14/14, secondary 10 versus 11; defense glyphs cross material/bronze. Existing defense centers y851 do not implement B y653; localized internal-housing correction proposed without editing owner PNG or shrinking numerals. Six isolated Windows single/full runs at default/1080p/720p pass real OS pointer, selection, raised hand isolation, End Turn mouse/Space and ESC 0. [Review and authoritative evidence](../art/reviews/p008-f03/review.md). P008 owner approval pending; P009/P010 TODO; G1 NOT_VALIDATED. No V06 or later prompt started. | — |
| **P008-F04** | CreatureToken numeral clarity polish | **OWNER ART-APPROVED / WINDOWS FOLLOW-UP PASS** | Owner explicitly accepted V05 and Bahnschrift treatment on 2026-11-22 after actual executable viewing; [sign-off](../art/reviews/p008/owner-sign-off-2026-11-22.md). Historical evidence retained: six native-size candidates, 528 records, 3588 GPU checks +3 comparisons +324 installed-production checks, 3691 native assertions unchanged/PASS, ART-002 3/3 bit-exact. Native 720p singles 12-14 px, doubles 8-10 px (99 compromise), secondary 9-10 px; numerical targets are not retroactively changed. Old focus-blocked attempts remain historical; [2026-11-22 Windows follow-up](../art/reviews/p008/final-windows-2026-11-22/review.md) PASS at default/1080p/720p, all requested real OS-input checks and ESC 0. G1 NOT_VALIDATED. | - |
| **P009** | `CardView` & `HandView` | **IN PROGRESS — SPELL CORRECTION VERIFIED** | Shared `CardView` and Spell presentation integrated in R01B and corrected in R01C. Spell owner artistic review pending. R02A/R02B and P010 TODO. G1 NOT_VALIDATED. | — |
| **P009-R01A** | Spell Card Variant Art Preparation | **PROMPT / SPECIFICATION PREPARED - ARTWORK AND OWNER REVIEW PENDING** | Verified ART-002 canvas 1086x1448 (3:4); retained mana/title/aperture/rarity landmarks; proposed wider 806x240 effect-text area and no Creature-stat reservations. [Brief](../art/reviews/p009-r01a/brief.md), [English prompt](../art/reviews/p009-r01a/image-generation-prompt.md), [upload references](../art/reviews/p009-r01a/references.md), [future pixel-validation protocol](../art/reviews/p009-r01a/validation-protocol.md). Epic purple/emerald mismatch documented; neutral source required. Expected `assets/_source/lot1/cards/mo_card_frame_spell_v01.png` not created. No generation, alpha validation or owner Spell approval claimed. | - |
| **P009-R01B** | Integrate Spell Card Variant into `CardView` | **PASS - PENDING OWNER ARTISTIC REVIEW** | Normalized runtime texture installed at `assets/textures/cards/mo_card_frame_spell_v01.png`; source candidate preserved; 3820/3820 native assertions PASS (+129); ART-002 3/3 bit-exact (0 regressions); enlarged `SPELL_RULES_BOUNDS` 806x240 (+62.7% area); `CardView`, `CardVisualVariant`, `CardPresentationModel`, `CardManaOverlay` implemented; mixed/spells/creatures scenarios in `CombatPreviewCards`; Windows release build `MagicOdyssey.exe` with CLI preview options; review evidence and observations recorded. [Review package](../art/reviews/p009-r01b/review.md). P009-R02A/R02B and P010 TODO; G1 NOT_VALIDATED. | — |
| **P009-R01C** | Spell Category Alignment and Rarity Gem Mask Correction | **DEFECT CORRECTION VERIFIED — OWNER ART REVIEW PENDING** | Spell-specific 36 px category with calibrated tracking clears the bronze rails and bridge bezel. Full-frame Spell mask registers all three crystals and removes 2,236 wrongly recolored description pixels. 3,881 native assertions, 160 GPU checks, and ART-002 3/3 bit-exact. Windows export passed, with OS interaction results in the review. The label is small in a resting 720p hand. Epic remains emerald under the existing palette despite Q181 purple. [Review package](../art/reviews/p009-r01c/review.md). R02A/R02B and P010 TODO. G1 NOT_VALIDATED. | — |
| **P009-R02A** | Equipment Card Variant Art Asset Generation | **TODO** | Standalone PNG layout artwork for Equipment card frame (`assets/_source/lot1/cards/mo_card_frame_equipment_v01.png`). Weapon/Protection category framing, transparency, game-size review. No Godot code. | — |
| **P009-R02B** | Integrate Equipment Card Variant into `CardView` | **TODO** | Technical integration of approved R02A asset into `CardView` (`card_view_layout.gd`). Render Weapon/Protection badge and effect; omit Creature stats/sockets; validate 1080p/720p and ART-002 parity. | — |
| **P010** | Tooltip & Inspector Panel | **TODO** | Hover tooltip; click side inspector with original printed card + live breakdown. Extended criteria (PLAN-002): render Spell details without Creature-only fields; display Equipment effects/categories; inspect Creature Equipment attachments (future Hero Artifact inspection planned separately). | — |

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
5. **P005 CombatScreen Artistic Sign-off:** `COMPLETE / OWNER-APPROVED` (P005 and P005-R09 officially approved by project owner on 2026-11-16 based on P005-R09C final acceptance package; 2507/2507 assertions PASS; ART-002 3/3 bit-exact; standalone Windows verified at default/1080p/720p with ESC 0. P005 is formally closed as the protected visual baseline. Progression to P006 authorized. Gate G1 remains NOT_VALIDATED pending P006–P010).
6. **Hand Capacity Discrepancy:** `P005-R05` presentation supports 0–10 cards per owner guidance; normative gameplay rules (`01-scope.md` §3.6, Decision Q39) define a 7-card maximum. This discrepancy is formally recorded and will be reconciled in `P024` without altering normative gameplay rules prematurely.
7. **PLAN-002 Design Dependencies & Substeps:** Formally planned card visual variants (P009-R01A/B for Spells, P009-R02A/B for Equipment) under single `CardView` architecture, and Hero Artifact system (HUD reservation check in P005-R09; distinct from cards and creature equipment; deferred to Phase 2 exploration). No gameplay code or assets implemented; P005–P065 remain in progress / TODO and Gates G0–G8 remain NOT_VALIDATED.

---

## E. Progress Update Instructions for AI Agents

When executing subsequent prompts (`P003` through `P065`):
1. **Factual Status Only:** Set a prompt status to `PASS` **only after** actual verification commands have succeeded with exit code 0. Never guess or pre-mark a prompt as complete.
2. **Record Real Evidence:** In the *Verification Evidence* column, log the exact command executed, exit code, and key assertion counts.
3. **Record Commit SHA:** Record the git commit hash in the *Commit SHA* column only when the commit has been created.
4. **Preserve Normative Content:** Never modify the underlying game rules, acceptance criteria, or prompt definitions when updating this tracker.
5. **Quality Gates:** Never set a Quality Gate (`G0`–`G8`) to `VALIDATED` until all constituent prompts in that iteration have passed and all gate exit criteria are demonstrably satisfied.
6. **Keep Updates Concise:** Maintain clean tabular Markdown formatting without conversational fluff.

## Premium presentation revision ? 2026-11-11

PASS: replaced the gallery with a static six-column combat shell, layered Theme variants, native original procedural motifs, hero/token/card studies and corrected rarity identities. Headless import and showcase launch exit 0; existing harness 14/14 assertions PASS (exit 0). Real 1080p/720p captures refreshed and visually inspected; detailed evidence and limitations: `docs/art/ui-baseline.md`. Interaction/focus review NOT_RUN. This is a P004 presentation refinement; P005?P065 remain TODO and G0 remains NOT_VALIDATED.
