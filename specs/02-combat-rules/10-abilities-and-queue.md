# Abilities and the Event Queue

**Normative References:** Decisions Q12, Q13, Q14, Q17, Q18, Q19, Q105, Q106, Q107, Q108, Q109, Q110, Q111, Q112, Q113, Q114, Q115.

---

## 1. Ability Modes

Every ability defined in the game catalog belongs to one of three operational modes:

| Mode | Execution Trigger | State Modification | Example |
|---|---|---|---|
| **PASSIVE** | Continuous evaluation | Calculates dynamic stat modifiers from current board state | *+1 ATK while in Attack row* |
| **ACTIVE** | Voluntary player command | Consumes costs (mana, tap, charges), verifies timing and targets | *Pay 1 mana: Heal 2 HP* |
| **TRIGGERED** | Event listener | Enqueued into the FIFO queue when an event occurs | *ON_SUMMON: Gain 2 Shield* |

---

## 2. The FIFO Event Queue [Q14]

All reactions, triggers, and secondary effects are scheduled through a deterministic **FIFO (First-In, First-Out)** event queue:
1. **Resolution Order:** The oldest queued trigger resolves first.
2. **Cascading Effects:** If resolving trigger $T_1$ produces new triggers $T_2$ and $T_3$, they are appended to the tail of the FIFO queue.
3. **Queue Drainage:** The queue must drain completely and reach board stabilization before the next voluntary player command is accepted.

### 2.1 Simultaneous Trigger Tie-Breaking [Q13]
When multiple triggers fire from the same atomic event, they are enqueued in deterministic priority:
1. **Camp Priority:** Active camp triggers enqueue before Inactive camp triggers.
2. **Column Priority:** Left-to-right (Column 1 through Column 6).
3. **Row Priority:** `ATTACK` row before `DEFENSE` row.

### 2.2 Combat Phase Trigger Timing [Q12, Q18]
- Damage triggers (such as `ON_DAMAGE_TAKEN`) and death triggers (`ON_DEATH`) generated during a combat attack are deferred until the attack's atomic damage commits [Q18].
- The attack finishes dealing damage before death consequences and triggered abilities resolve [Q12].

---

## 3. Loop Prevention and Causal Budgets [Q17, Q111–Q114]

To eliminate infinite recursion between reacting cards (e.g., Unit A buffs on heal, Unit B heals on buff):

1. **Causal Tracking [Q111]:** Each queued event tracks its root causal origin and ancestry depth.
2. **Chain Budgets [Q112, Q113]:** The engine enforces a configurable causal depth budget per command (default maximum depth: 16 cascading steps).
3. **Targeted Branch Neutralization [Q113, Q114]:**
   - When a causal chain exceeds its budget, the engine interrupts **only that repeating branch**.
   - Events already committed are **never rolled back**.
   - Unrelated legitimate events already sitting in the FIFO queue are preserved and resolve normally.
   - The engine logs a structured diagnostic warning detailing the suppressed recursion.
