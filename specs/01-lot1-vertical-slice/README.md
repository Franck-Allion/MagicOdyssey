# MagicOdyssey — Lot 1 (Vertical Slice)

**Target:** Complete, playable, premium 2D tactical combat vertical slice in Godot 4 (GDScript, Windows).  
**Status:** Approved normative baseline ready for implementation.  
**Upstream Reference:** MagicOdyssey Full Specifications (Decisions Q01–Q274 + Q275–Q302).

---

## Overview

Lot 1 is the foundational milestone of **MagicOdyssey**. It delivers a fully functional, deterministic tactical card combat experience between a human player and a heuristic AI.

It is a **representative vertical slice**: not a headless rules library without an interface, and not a clickable UI mockup without an authentic game engine. Lot 1 requires both a deterministic combat engine and a polished, responsive 2D combat screen.

---

## Key Lot 1 Documents

| Document | Purpose |
|---|---|
| [01-scope.md](01-scope.md) | Full functional and technical specification (rules, engine, UI/UX, contracts). |
| [02-catalog.md](02-catalog.md) | Official 16-card mini-catalog (10 creatures, 4 spells, 2 equipments) + Godot Resource schemas. |
| [03-acceptance-tests.md](03-acceptance-tests.md) | The 45 normative acceptance criteria (32 core engine tests `L1-B01..B32` + 13 UX tests `L1-U01..U13`). |
| [04-architecture-godot.md](04-architecture-godot.md) | Godot 4 architecture: engine vs presentation decoupling, state immutability, event pipeline. |
| [05-roadmap.md](05-roadmap.md) | Step-by-step implementation plan (65 atomic prompts `P001..P065`, 9 iterations `J0..J8`, 9 quality gates `G0..G8`). |

---

## Core Boundaries

### Included in Lot 1
- **Battlefield:** 6 columns × 2 rows per side (24 total slots), attack row vs defense row, column contestation priority.
- **Creatures:** Summoning, summoning sickness, 1-mana natural vertical movement, column ally permutation.
- **Resources & Zones:** Mana system (growth +1/turn starting turn 1, full restore, capacity cap), Hand (6 initial cards, 7 max), Deck (40 cards), Discard, Banished, progressive fatigue (1, 2, 3... direct HP damage).
- **Combat Resolution:** Automatic end-of-turn attack sequence (columns 1 to 6), target priority (enemy attack -> defense -> hero), no default counter-attack.
- **Protections & Health:** Priority order (Armor -> Shield -> HP -> Lethal Protection), reusable per-instance armor, consumable shield pools, positive healing, immediate victory/defeat checks.
- **Card Catalog:** 16 declarative cards (10 creatures across 4 tribes: Humans, Elves, Dwarves, Dragons; 4 spells; 2 equipments).
- **Heuristic AI:** Non-cheating tactical AI scoring legal actions using the identical engine command API.
- **2D UI/UX:** 1920×1080 native resolution (1280×720 responsive), fantasy crest tokens, dynamic inspection panel, decoupled juicy VFX, combat result screen.
- **Testing & Deliverables:** Headless test runner, 45 acceptance test scenarios, Windows standalone export.

### Excluded from Lot 1 (Preserved for Future Lots)
- Tower exploration, world map, merchant shops, draft reward screens, metagame progression, hero skill tree (Sphere Grid).
- Complex mind-control, resurrection chains, complex auras/layer graphs, visual card editor, full 170-card catalog.

---

## Acceptance Gates Summary

| Gate | Iteration | Milestone Focus |
|---|---|---|
| **G0** | J0 (P001–P004) | Importable Godot 4 project, native headless test harness, theme baseline. |
| **G1** | J1 (P005–P010) | Responsive 2D combat UI with 24 slots, hero HUDs, and fantasy crest tokens. |
| **G2** | J2 (P011–P020) | Typed `.tres` card catalog, valid 40-card decks, reproducible initial state. |
| **G3** | J3 (P021–P031) | Core deterministic engine simulating full combats headlessly with PASS assertions. |
| **G4** | J4 (P032–P037) | Interactive playable mouse combat loop (summon, move, attack, end turn). |
| **G5** | J5 (P038–P048) | Complete 16-card mechanics (spells, shields, temporary buffs, equipment, atomic damage). |
| **G6** | J6 (P049–P053) | Autonomous, legal, non-cheating heuristic AI opponent. |
| **G7** | J7 (P054–P060) | Semi-realistic fantasy visual identity, juicy decoupled VFX, 1080p/720p layout sign-off. |
| **G8** | J8 (P061–P065) | 45/45 acceptance tests PASS, regression suites verified, Windows executable verified. |
