# Turn Sequence and Mana System

**Normative References:** Decisions Q09, Q10, Q28, Q29, Q30, Q31, Q32, Q33, Q34, Q35, Q36, Q37, Q275, Q276.

---

## 1. Initiative and Turn Structure

1. **Initiative [Q28, Q276]:** The human player **always acts first** in combat.
2. **Alternating Turns:** The game alternates between `PLAYER` turn and `OPPONENT` turn.
3. **Voluntary Action Exclusivity [Q276]:** Only the active camp may submit voluntary actions (summoning, movement, spells, abilities). The inactive camp can only trigger automatic passive or reactive effects.

---

## 2. Detailed Turn Phases

```
+-------------------------------------------------------------+
| 1. TURN START PHASE                                         |
|    - Process early-turn expirations                         |
|    - Mana Capacity Growth: +1 up to cap (starts Turn 1)     |
|    - Mana Restoration: Available mana = Capacity            |
|    - Emit & resolve turn-start triggers                     |
|    - Card Draw: Draw 1 card (Skipped on Turn 1)             |
+------------------------------+------------------------------+
                               |
                               v
+-------------------------------------------------------------+
| 2. ACTION PHASE                                             |
|    - Player/AI plays cards, summons, moves, swaps, abilities|
|    - Each action fully resolves and stabilizes via FIFO     |
|    - Ends when active player clicks "End Turn"              |
+------------------------------+------------------------------+
                               |
                               v
+-------------------------------------------------------------+
| 3. ATTACK PHASE (COLUMNS 1 TO 6)                            |
|    - Active camp ATTACK row units strike sequentially:      |
|      Col 1 -> Col 2 -> Col 3 -> Col 4 -> Col 5 -> Col 6     |
|    - Units summoned this turn suffer sickness (do not strike|
|    - Each column resolves damage, protections, and deaths   |
+------------------------------+------------------------------+
                               |
                               v
+-------------------------------------------------------------+
| 4. CLEANUP PHASE                                            |
|    - Resolve combat reaction triggers                       |
|    - Emit & resolve ON_TURN_END triggers                    |
|    - Process end-of-turn effect expirations                 |
|    - Unspent mana discarded (no carryover)                  |
|    - Switch active camp to opponent                         |
+-------------------------------------------------------------+
```

---

## 3. The Mana System

### 3.1 State Tracking [Q30]
Each hero maintains four distinct mana properties:
- `mana_capacity`: Maximum mana the hero can utilize in the current turn.
- `mana_available`: Current unspent mana remaining for actions.
- `mana_cap`: The hard ceiling above which capacity cannot naturally grow.
- `growth_rate`: Normal capacity increment per personal turn (default: `+1`).

### 3.2 Rules of Mana Flow
1. **Turn 1 Growth [Q275]:** On personal Turn 1, the hero's capacity increases by their growth rate (starts at 1 capacity) and restores available mana to 1.
2. **Full Restoration [Q31]:** Available mana restores fully to `mana_capacity` at the beginning of each personal turn.
3. **No Carry-Over [Q31]:** Any unspent mana remaining at the end of the turn is lost.
4. **Delayed Growth Modifiers [Q33]:** Effects that increase mana growth rate apply to future turn-start growth steps, not retroactively.
5. **Cap vs Immediate Mana [Q34]:** Increasing `mana_cap` raises the upper ceiling but grants no immediate available mana. Temporary bonus mana beyond current capacity is allowed if explicitly granted by an effect, but is clamped to `mana_cap`.

---

## 4. Summoning Sickness [Q29]

- Any creature summoned to the board during the current turn incurs **Summoning Sickness**.
- A creature with summoning sickness:
  - **Cannot** perform automatic attacks during the end-of-turn attack phase.
  - **Can** intercept incoming attacks if positioned in the defense row or attacked in its column.
  - **Can** use its natural vertical movement or ally permutation during the turn it was summoned (costing 1 mana) [Q06].
  - Sickness clears automatically at the start of the creature's next personal turn.
