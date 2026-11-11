# MagicOdyssey — Comprehensive Acceptance Test Matrix (T-001 to T-274)

**Status:** Complete regression test specification for the full game design.  
**Traceability:** Directly validates Decisions Q01 through Q274.  
**Lot 1 Subset:** Scenarios relevant to the vertical slice are mapped to the 45 Lot 1 Acceptance Tests (`L1-B01..B32` and `L1-U01..U13`) in `lot1/acceptance_tests.md`.

---

## 1. Test Suite Architecture

The full test catalog contains 274 structured verification scenarios categorized by subsystem:

| Test Group | System Scope | Governing Decisions | Lot 1 Mapping |
|---|---|---|---|
| **T-001 – T-016** | Battlefield Grid, Lanes, Attacks, Sickness, Deaths | Q01–Q16 | `L1-B01`, `L1-B05..B11`, `L1-B20..B25` |
| **T-017 – T-027** | Event FIFO, Trigger Timing, Trample, Protections | Q17–Q27 | `L1-B10..B14`, `L1-B22` |
| **T-028 – T-035** | Initiative, Turn Sequence, Mana Growth & Restoration | Q28–Q35, Q275 | `L1-B02..B04` |
| **T-036 – T-045** | Initial Hand, Draw Limits, Fatigue, Banishment | Q36–Q45, Q210 | `L1-B26..B27` |
| **T-046 – T-055** | Resurrection, Baseline Reset, Queue Ordering | Q46–Q55 | Out of Lot 1 scope (Deferred) |
| **T-056 – T-064** | Last Known State, Target Fizzling, Atomic Operations | Q56–Q64 | `L1-B21`, `L1-B22`, `L1-B30` |
| **T-065 – T-074** | Damage Attribution, Hamilton-Hare Method, Lifelink | Q65–Q74 | Out of Lot 1 scope (Deferred) |
| **T-075 – T-084** | Healing Caps, Max HP Changes, Wound Preservation, Buffs | Q75–Q84, Q278 | `L1-B15..B17` |
| **T-085 – T-094** | Source Control, Property Snapshots | Q85–Q94 | Out of Lot 1 scope (Deferred) |
| **T-095 – T-104** | Mind Control Transfers, Positioning, Discard Ownership | Q95–Q104 | Out of Lot 1 scope (Deferred) |
| **T-105 – T-114** | Transfer Sickness, Combat Loops, Causal Interruption | Q105–Q114 | Out of Lot 1 scope (Deferred) |
| **T-115 – T-125** | Causal Budgets, Snapshot Serialization, Replay Hash | Q115–Q125 | `L1-B29`, `L1-B30` |
| **T-126 – T-154** | UI Tokens, Crest Layout, Inspection Panel, Previews | Q126–Q154, Q291–Q294 | `L1-U01..U07`, `L1-U13` |
| **T-155 – T-174** | Auras, Continuous Layers, Combat Journal, VFX Juice | Q155–Q174, Q302 | `L1-U08..U10` |
| **T-175 – T-204** | Rewards, Rarities, Towers, Merchant Stock & Rerolls | Q175–Q204 | Out of Lot 1 scope (Deferred) |
| **T-205 – T-224** | 40-Card Decks, 4-Copy Cap, Starter Pool (20+15+15), Fatigue | Q205–Q224 | `L1-B01`, `L1-B19`, `L1-B26` |
| **T-225 – T-254** | 4 MVP Tribes, Equipment Slots (0-2), Weapons & Armor | Q225–Q254 | `L1-B18..B19`, `L1-B31..B32` |
| **T-255 – T-274** | 100 Independent Cards, AI Archetypes, Special Missions | Q255–Q274, Q299 | `L1-B28` |

---

## 2. Core Sample Invariants Across Full Suite

- **Determinism:** Any test scenario initialized with seed $S$ and replaying command sequence $C_1..C_n$ must evaluate to identical assertions and identical canonical state hashes.
- **Transaction Rollback:** An unexpected error occurring within an uncommitted transaction must leave previous revisions 100% untouched.
- **Hidden Info Integrity:** No AI evaluation or log rendering may query cards marked with zone `DECK` or opponent `HAND`.
- **Zero Loss Guarantee:** The complete legacy test assertions from French v2.8 are preserved in `archive/specs-v2.8-fr/09-technical/acceptance-tests.md` for historical traceability.
