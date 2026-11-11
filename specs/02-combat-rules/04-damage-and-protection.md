# Damage Resolution and Protection Layers

**Normative References:** Decisions Q09, Q10, Q11, Q12, Q15, Q16, Q21, Q22, Q23, Q24, Q25, Q27, Q73, Q278, Q279, Q280, Q281, Q288, Q289.

---

## 1. Attack Execution and Targeting

During the End-of-Turn Attack Phase:
1. **Column Resolution Order [Q10]:** The engine resolves attacks sequentially from **Column 1 to Column 6**. Each column finishes all damage, protections, deaths, and immediate triggers before the next column begins.
2. **Attacking Units:** Only active camp units situated in the `ATTACK` row attack. Units with summoning sickness are skipped [Q29].
3. **Target Priority [Q02]:**
   $$\text{Attacker in Col } c \longrightarrow \text{Enemy Attack}[c] \longrightarrow \text{Enemy Defense}[c] \longrightarrow \text{Enemy Hero}$$
4. **No Default Retaliation [Q09]:** A defender does not retaliate or deal damage to the attacker unless explicitly endowed with a counter-attack keyword.
5. **Excess Damage and Trample [Q11, Q21]:**
   - By default, excess damage exceeding the defender's remaining HP is lost.
   - **Trample:** If an attacker has Trample, residual damage carries over to the next target in the column sequence (Defense unit $\rightarrow$ Hero) **only if the current target is completely eliminated**. Protections on the blocker reduce the residual damage that carries forward [Q21].

---

## 2. Protection Hierarchy [Q22]

When a creature or hero receives damage from an attack or spell, damage is absorbed through a strict, deterministic sequence of protection layers:

$$\mathbf{Incoming\ Damage} \longrightarrow \mathbf{1.\ Armor} \longrightarrow \mathbf{2.\ Shield} \longrightarrow \mathbf{3.\ Current\ HP} \longrightarrow \mathbf{4.\ Lethal\ Protection}$$

### 2.1 Layer 1: Armor [Q279, Q281]
- **Mechanism:** Reusable flat damage reduction applied to **every individual damage instance**.
- **Calculation:** $\text{Effective Damage} = \max(0, \text{Incoming Damage} - \text{Total Armor})$.
- **Properties:**
  - Armor is **never consumed or depleted** by taking damage.
  - Sum of base printed armor + active modifications/equipment.
  - Minimum 0; no global ceiling [Q281].

### 2.2 Layer 2: Shield [Q279, Q280]
- **Mechanism:** Consumable pool of temporary health points absorbing post-armor damage.
- **Consumption Priority [Q280]:**
  - If a unit has multiple shield grants, shields are consumed in order of **earliest expiration timestamp**.
  - Ties are broken using deterministic canonical ordering (order of application) [Q73].
- **Depletion:** Absorbed damage reduces the shield pool. Depleted shields are removed and do not regenerate.

### 2.3 Layer 3: Current HP Loss
- Any remaining damage after armor reduction and shield absorption is deducted directly from current HP.
- Emits the `ON_DAMAGE_TAKEN` event if effective HP loss $\ge 1$ [Q25, Q65].
- Zero-damage attacks emit `ON_ATTACK`, but do not emit HP loss events [Q25].

### 2.4 Layer 4: Lethal Protection [Q23, Q24, Q73]
- If an instance of damage would reduce HP to 0 or below, the unit checks for lethal protection effects (e.g., "survive with 1 HP").
- **Consumption Rule [Q23]:** Exactly **one** lethal protection is consumed per lethal event. Remaining protections are preserved.
- **Priority Hierarchy [Q24, Q73]:**
  1. **Temporary lethal protections** are consumed before permanent ones [Q24].
  2. Among identical categories, protections with the **earliest expiration** are consumed first.
  3. Stable canonical order (oldest applied) breaks remaining ties [Q73].

---

## 3. Simultaneous Damage Aggregation [Q288, Q289]

When multiple damage sources strike a single target simultaneously (e.g., AoE effects or multi-source combat):
1. **Compatible Damage Grouping [Q288]:** Instances sharing the same effective protection profile are aggregated before applying defenses.
2. **Incompatible Damage [Q289]:** Shared consumable shields are consumed in canonical order, followed by a **simultaneous commit of HP loss**.
3. **No Intermediate State:** No victory checks or triggered abilities fire between the phases of a simultaneous damage operation; all HP deductions commit together before deaths are processed.

---

## 4. Death and Match Conclusion [Q12, Q15, Q16]

1. **Creature Death [Q12]:** When a creature's HP reaches 0:
   - It is removed from the board slot, freeing the slot immediately.
   - Any attached equipment is detached and placed in its owner's discard pile [Q251].
   - The creature card is placed in the owner's `DISCARD` pile.
   - Emits `ON_DEATH` into the FIFO queue.
2. **Hero Death and Victory [Q15, Q16]:**
   - Opponent Hero HP $\le 0 \implies$ **Player Victory**.
   - Player Hero HP $\le 0 \implies$ **Player Defeat**.
   - **Simultaneous Hero Death [Q16]:** If both heroes reach $\le 0$ HP during the same atomic commit, the outcome is **Player Defeat**.
   - Upon victory or defeat, combat immediately stops; all pending queue events and animations are terminated.
