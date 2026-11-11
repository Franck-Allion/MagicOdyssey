# MagicOdyssey — Master Specification Repository

**Project:** MagicOdyssey  
**Genre:** Tactical Turn-Based Fantasy TCG/RPG  
**Target Platform:** PC / Windows Standalone  
**Engine & Tech Stack:** Godot 4.x (Stable), Typed GDScript, 2D Canvas  
**Status:** Approved normative specifications ready for Lot 1 implementation.

---

## 1. Project Overview

**MagicOdyssey** is a tactical fantasy card battler combining grid-based positioning, deterministic combat resolution, and roguelike ascension progression:
- **Battlefield:** 6 columns × 2 rows per camp (24 total slots), front `ATTACK` row vs back `DEFENSE` row, column contestation priority.
- **Combat Flow:** Turn-based, human starts, mana growth (+1/turn starting turn 1), vertical movement (1 mana), automatic end-of-turn column combat (Cols 1 to 6).
- **Protections & Health:** Layered defense hierarchy ($\text{Armor} \rightarrow \text{Shield} \rightarrow \text{HP} \rightarrow \text{Lethal Protection}$), wound preservation, positive healing, progressive fatigue (1, 2, 3...).
- **Architecture:** Pure decoupled domain engine (deterministic, headless-testable) driving an expressive, juicy 2D presentation layer via an asynchronous event bus.

---

## 2. Specifications Directory (`specs/`)

All functional, technical, and architectural documentation is isolated inside the [`specs/`](specs/README.md) directory, preserving the project root for Godot source files (`project.godot`, `scenes/`, `scripts/`, `resources/`, `assets/`, `tests/`):

```
specs/
├── 01-lot1-vertical-slice/            # ACTIVE TARGET: First Playable 2D Combat Slice
│   ├── README.md                      # Lot 1 overview, core scope, and quality gate summary
│   ├── 01-scope.md                    # Lot 1 functional & technical specifications
│   ├── 02-catalog.md                  # 16-card mini-catalog & Godot .tres resource schemas
│   ├── 03-acceptance-tests.md         # 45 acceptance test criteria (32 engine + 13 UX)
│   ├── 04-architecture-godot.md       # Godot 4 architecture (Domain vs View, Event Bus, Layout)
│   └── 05-roadmap.md                  # 65-prompt execution roadmap (P001..P065, J0..J8, G0..G8)
│
├── 02-combat-rules/                   # Global Combat System Rules (13 modules)
├── 03-presentation-ui/                # UI/UX & Art Direction Specifications (5 modules)
├── 04-progression-rpg/                # Progression, Metagame, & RPG Specifications (6 modules)
├── 05-technical-systems/              # Transversal Technical Specifications (2 modules)
├── 06-reference/                      # Reference Governance & Protocols (Glossary, Decisions, Agents)
└── 99-archive/                        # Historical French v2.8 Archive (100% Data Preservation)
```

---

## 3. Immediate Implementation Target: Lot 1

The active focus of the project is **Lot 1: The Playable Combat Vertical Slice**.
- **Scope:** 1v1 tactical combat against heuristic AI, 16 declarative cards (10 creatures across 4 tribes, 4 spells, 2 equipments), 40-card starter decks, 24-slot 2D board with fantasy crest tokens, juicy decoupled VFX, and headless test runner.
- **Roadmap:** Structured into **65 atomic prompts** (`P001` to `P065`) across **9 iterations** (`J0` to `J8`) and **9 quality gates** (`G0` to `G8`).
- **Next Step:** Execute **Iteration J0 / Prompt P001** (`Create Godot 4 project and initialize project.godot`). See [specs/01-lot1-vertical-slice/05-roadmap.md](specs/01-lot1-vertical-slice/05-roadmap.md).

---

## 4. Guidance for AI Agents

All AI assistants (Codex, Gemini Flash, Claude) must consult:
1. [specs/06-reference/03-agents-protocol.md](specs/06-reference/03-agents-protocol.md) for architectural invariants and prompt execution rules.
2. [specs/01-lot1-vertical-slice/01-scope.md](specs/01-lot1-vertical-slice/01-scope.md) and [specs/01-lot1-vertical-slice/02-catalog.md](specs/01-lot1-vertical-slice/02-catalog.md) as the primary truth sources for current development.
3. [specs/06-reference/01-glossary.md](specs/06-reference/01-glossary.md) for standard English code identifiers and concepts.
4. [specs/06-reference/02-decisions.md](specs/06-reference/02-decisions.md) when auditing design rationale.
