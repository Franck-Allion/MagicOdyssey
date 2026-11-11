# Damage Attribution and Defensive Events

**Normative References:** Decisions Q65, Q66, Q67, Q68, Q69, Q70, Q71, Q72, Q74.

---

## 1. Principles of Damage Attribution

When one or more damage sources inflict damage on a target, the engine distinguishes between **trigger eligibility** (which sources participated) and **allocated quantum** (how much net HP loss each source is credited for).

### 1.1 Trigger Emission Rules
- **`ON_DAMAGE_TAKEN` [Q65]:** Emitted exactly **once per target** per atomic operation if the target suffered an effective HP loss of at least 1.
- **`ON_DAMAGE_DEALT` [Q66]:** Emitted exactly **once per contributing source** per target per atomic operation, provided the source contributed positive damage and the target suffered net HP loss.
- **Collective Participation [Q67]:** All sources contributing positive damage to an attack that caused net HP loss are credited as having dealt damage. A source whose allocated integer quantum rounds to 0 still triggers `ON_DAMAGE_DEALT`.

---

## 2. Allocated Quantum Calculation [Q68, Q69]

When multiple sources contribute to an attack (e.g. combined strikes or multi-source damage):
1. **Integer Conservation:** The sum of quanta attributed across all sources must exactly equal the target's net HP lost:
   $$\sum_{i} Q_i = \Delta \text{HP}_{\text{lost}}$$
2. **Largest Remainder Method (Hamilton-Hare) [Q69]:**
   - Calculate exact proportional share: $S_i = \Delta \text{HP}_{\text{lost}} \times \frac{D_i}{D_{\text{total}}}$.
   - Assign integer floor: $Q_i = \lfloor S_i \rfloor$.
   - Calculate remainders: $R_i = S_i - Q_i$.
   - Distribute unallocated points $+1$ to sources with the largest remainders $R_i$ until the sum equals $\Delta \text{HP}_{\text{lost}}$.
   - Ties in remainders are broken using deterministic canonical ordering (e.g., source `instance_id` sequence).

---

## 3. Lifelink Mechanics [Q70]

- **Mechanism:** When a source with Lifelink successfully deals damage, it queues a healing effect.
- **Heal Amount:** Equal to the source's **allocated integer quantum** $Q_i$, not the raw unmitigated damage.
- **Queue Timing:** Lifelink healing is enqueued into the **FIFO event queue** and resolves as a separate operation.
- **No Retroactive Rescue:** If the source or hero died during the damage commit, the deferred Lifelink heal cannot retroactively undo the death [Q70].

---

## 4. Defensive Absorption Events [Q71]

To prevent log flooding during simultaneous or multi-source hits:
- The engine emits at most **one armor absorption event** per target per atomic operation (reporting total armor absorbed).
- The engine emits at most **one shield absorption event** per target per atomic operation (reporting total shield consumed).
