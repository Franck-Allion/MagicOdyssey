# Targeting and Identity Architecture

**Normative References:** Decisions Q19, Q20, Q56, Q57, Q58, Q59, Q60.

---

## 1. The Three Tiers of Identity [Q57]

To prevent state corruption across zone transitions, the game engine enforces three distinct identity levels:

| Identifier | Level | Scope | Example |
|---|---|---|---|
| `definition_id` | Archetype | Immutable card model in catalog | `&"human_guard"` |
| `copy_id` | Physical Copy | Unique card instance owned in the deck/match | `&"copy_042"` |
| `instance_id` | Board Lifetime | Ephemeral lifespan of a creature occupying a slot | `&"inst_1089"` |

### 1.1 Invariants
1. When a card moves from `HAND` to `BOARD`, the engine generates a **new, unique `instance_id`**.
2. When a creature moves or swaps between slots, its **`instance_id` is preserved**.
3. When a creature leaves the board (to `DISCARD`, `HAND`, or `BANISHED`), its **`instance_id` is permanently retired** [Q58]. If that same physical card is later resurrected or re-played, it receives a fresh `instance_id`.

---

## 2. Targeting Resolution and Fizzling [Q20, Q58, Q59, Q60]

### 2.1 Dual-Stage Target Validation [Q59]
Target validity is enforced at two distinct points:
1. **Submission Prevalidation:** The engine checks camp, row, column, unit type, and status before accepting a command.
2. **Atomic Execution Re-validation:** Immediately before an effect applies, target conditions are re-verified.

### 2.2 Target Loss and Fizzling [Q20, Q58]
- If a target dies, is banished, or changes zones before an effect targeting it resolves, targeting **fails permanently**.
- The engine does **not** automatically retarget to a nearby unit [Q58].
- The spent mana or card cost is **not refunded** [Q20].
- In **multi-target effects**, the effect resolves normally on all targets that remain valid, while fizzling only for the invalid targets [Q60].

---

## 3. Source Independence and Last Known State [Q19, Q56]

1. **Survival of Pending Effects [Q19]:** Once an effect or triggered ability has been legally placed into the FIFO event queue, it remains in the queue and resolves even if its originating creature source is killed or removed from the board before execution.
2. **Last Known State [Q56]:** When an ability in the queue resolves:
   - If the source creature is still on the board, the engine reads its **current live characteristics** (ATK, buffs, etc.).
   - If the source creature has left the board or died, the engine reads its **Last Known State** recorded at the exact moment it left the board.
