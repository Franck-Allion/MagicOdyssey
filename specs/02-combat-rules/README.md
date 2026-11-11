# MagicOdyssey — Comprehensive Combat Rules

**Status:** Consolidated normative combat specification (Decisions Q01–Q114, Q235–Q254, Q275–Q289).  
**Architecture:** Pure deterministic engine model; decoupled from visual presentation.

---

## Combat Systems Index

| Document | Key Concepts | Governing Decisions |
|---|---|---|
| [01-battlefield-and-layout.md](01-battlefield-and-layout.md) | 2×6 grid per camp, attack row, defense row, column contestation | Q01–Q04 |
| [02-turn-sequence-and-mana.md](02-turn-sequence-and-mana.md) | Turn phases, player first, mana capacity, growth +1, summoning sickness | Q09–Q10, Q28–Q35, Q275 |
| [03-summoning-and-movement.md](03-summoning-and-movement.md) | Summoning, contested lane priority, natural vertical movement (1 mana), ally permutation | Q03–Q08 |
| [04-damage-and-protection.md](04-damage-and-protection.md) | Attack order (Col 1 to 6), target priority, armor, shield pools, lethal protection | Q09–Q24, Q73, Q278–Q281 |
| [05-damage-attribution.md](05-damage-attribution.md) | Proportional damage shares, largest remainder method, lifelink, defense events | Q65–Q74 |
| [06-healing-and-health.md](06-healing-and-health.md) | Healing caps, positive restoration events, max HP changes, wound retention | Q26, Q75–Q77, Q278 |
| [07-cards-and-zones.md](07-cards-and-zones.md) | Hand (7 max), deck (40), discard, banishment, recovery, progressive fatigue (1, 2, 3...) | Q36–Q45, Q53–Q54, Q207–Q214 |
| [08-resurrection.md](08-resurrection.md) | Clean baseline resurrection, new instance identity, summoning triggers | Q46–Q52, Q55 |
| [09-targeting-and-identity.md](09-targeting-and-identity.md) | Target validation, fizzle on loss, cardId vs copyId vs instanceId, last known state | Q20, Q56–Q60 |
| [10-abilities-and-queue.md](10-abilities-and-queue.md) | Passive, active, triggered abilities, FIFO queue, loop prevention, causal budgets | Q12–Q14, Q17–Q19, Q105–Q114 |
| [11-effect-resolution.md](11-effect-resolution.md) | Atomic operations, compound effects, simultaneous damage aggregation, rollback | Q55, Q60–Q64, Q287–Q289 |
| [12-equipment-and-tribes.md](12-equipment-and-tribes.md) | Equipment cards, 0 to 2 slots, weapon/protection, 4 MVP tribes (Human, Elf, Dwarf, Dragon) | Q235–Q254 |
| [13-control-transfers.md](13-control-transfers.md) | Control theft, transfer sickness, board repositioning, ownership retention | Q95–Q104 |
