# MagicOdyssey — Specifications Architecture

This directory contains the entire normative game design, rules engine, UI/UX, progression, and implementation specifications for **MagicOdyssey**.

The specifications are organized into strictly numbered, logically partitioned modules:

---

## Directory Structure

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
├── 02-combat-rules/                   # Global Combat System Rules
│   ├── README.md                      # Combat reading guide & index
│   ├── 01-battlefield-and-layout.md   # 6x2 grid per camp, frontline/backline, contestation
│   ├── 02-turn-sequence-and-mana.md   # Turn phases, player first, mana capacity & growth
│   ├── 03-summoning-and-movement.md   # Summoning priority, vertical movement, ally permutation
│   ├── 04-damage-and-protection.md    # Attack sequence (Col 1-6), armor, shields, lethal protection
│   ├── 05-damage-attribution.md       # Proportional shares, Hamilton-Hare method, lifelink
│   ├── 06-healing-and-health.md       # Positive healing, Max HP modifications, wound preservation
│   ├── 07-cards-and-zones.md          # 40-card deck, 7-card hand cap, progressive fatigue (1, 2, 3...)
│   ├── 08-resurrection.md             # Baseline reset, new instance identity, queue ordering
│   ├── 09-targeting-and-identity.md   # Target validation, fizzling, cardId vs copyId vs instanceId
│   ├── 10-abilities-and-queue.md      # Passive/Active/Triggered modes, FIFO queue, loop budgets
│   ├── 11-effect-resolution.md        # Atomic transactions, compound effects, simultaneous commit
│   ├── 12-equipment-and-tribes.md     # Equipment slots (0-2), weapons/armor, 4 MVP tribes
│   └── 13-control-transfers.md        # Mind-control, transfer sickness, ownership retention
│
├── 03-presentation-ui/                # UI/UX & Art Direction Specifications
│   ├── README.md                      # UI/UX overview & reading guide
│   ├── 01-board-and-preview.md        # 16:9 layout, fantasy crest tokens, non-mutating preview
│   ├── 02-cards-and-inspection.md     # Hand cards, intact printed face, live modifier inspector
│   ├── 03-tooltips-and-vfx.md         # Natural-language tooltips, juicy VFX, decoupled scheduler
│   ├── 04-continuous-effects-ui.md    # Auras, layer evaluation display, continuous modifier visuals
│   └── 05-combat-journal.md           # Contextual combat log, inspection linking, hidden info compliance
│
├── 04-progression-rpg/                # Progression, Metagame, & RPG Specifications
│   ├── README.md                      # Progression overview & reading guide
│   ├── 01-deck-and-starter.md         # 50-card starter pool (20+15+15), 40-card deck, 4-copy rule
│   ├── 02-hero-sphere.md              # Sphere Grid / Skill tree, stat nodes, variant upgrades
│   ├── 03-rewards-and-rarities.md     # Post-combat draft, 5 rarities, boss relics, run artifacts
│   ├── 04-towers-and-merchants.md     # Tower ascent, merchant inventory, rerolls, card purges
│   ├── 05-independent-catalog.md      # 100 independent cards (50 units, 30 spells, 20 equipments)
│   └── 06-enemy-encounters.md         # AI tactical archetypes, special missions (Protect & Survive)
│
├── 05-technical-systems/              # Transversal Technical Specifications
│   ├── README.md                      # Technical systems index
│   ├── 01-causal-budgets-and-replay.md# Causal depth budgets, loop safety, determinism, replay hash
│   └── 02-full-acceptance-tests.md    # Matrix of 274 legacy regression tests (T-001 to T-274)
│
├── 06-reference/                      # Reference Governance & Agent Guidelines
│   ├── README.md                      # Reference index
│   ├── 01-glossary.md                 # English domain vocabulary and concepts
│   ├── 02-decisions.md                # Master log of 302 design decisions (Q01 to Q302)
│   └── 03-agents-protocol.md          # Godot 4 coding conventions and prompt execution rules
│
└── 99-archive/                        # Historical French v2.8 Archive (100% Data Preservation)
    └── specs-v2.8-fr/                 # Intact original French documentation
```
