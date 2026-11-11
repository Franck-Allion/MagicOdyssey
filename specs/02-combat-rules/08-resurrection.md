# Resurrection Mechanics

**Normative References:** Decisions Q46, Q47, Q48, Q49, Q50, Q51, Q52, Q55.

---

## 1. The Clean Baseline Principle [Q46]

Resurrection returns a deceased creature card from the `DISCARD` pile back to the `BOARD`.
1. **Reset to Printed Baseline:** The creature returns in its printed base reference state:
   - Previous wounds, temporary stat buffs, armor reductions, and attached equipments from its prior lifetime are **completely wiped out**.
2. **Resurrection-Specific Buffs [Q46, Q49]:** Any bonuses explicitly granted by the resurrecting spell itself (e.g. "Resurrect a creature with +2 ATK") are applied immediately upon re-entry.
3. **New Board Identity [Q57]:** The resurrected creature receives a **brand-new `instance_id`**. It is treated by the engine as a distinct lifetime.

---

## 2. Placement and Contestation [Q47, Q51]

1. **Summoning Rules Apply [Q47]:** Resurrection is subject to the identical column contestation and placement priorities as normal summoning [Q03]:
   - Uncontested enemy columns must be prioritized if legal slots exist.
2. **Legality at Cast and Resolution [Q51]:**
   - A resurrection spell cannot be cast if no legal placement slot exists.
   - If the designated destination becomes occupied or illegal prior to spell resolution, the resurrection **fizzles cleanly without mana refund** [Q51].

---

## 3. Lifecycle and Ability Queue Ordering [Q48, Q49, Q50, Q55]

When a creature is resurrected:
1. **Summoning Status [Q48]:** Resurrection constitutes a new summoning event. The resurrected unit enters with **Summoning Sickness** (cannot attack this turn).
2. **Order of Operations [Q49]:**
   $$\text{Restore to Baseline} \longrightarrow \text{Apply Resurrection Modifiers} \longrightarrow \text{Enqueue Triggered Abilities}$$
3. **Trigger Priority in FIFO [Q50]:**
   - Entering triggers are enqueued in fixed order: `ON_SUMMON` abilities are enqueued before `ON_RESURRECT` abilities.
4. **Multiple Resurrections Resolution [Q52, Q55]:**
   - If an effect resurrects multiple units, **all resurrection attempts must resolve and place their units on the board before any of their triggered abilities begin processing** [Q55].
   - Each successful placement enqueues its triggers in order into the FIFO queue.
   - Partial successes are retained if board space runs out during the sequence [Q52].
