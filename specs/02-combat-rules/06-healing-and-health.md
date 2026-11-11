# Healing and Health Modifications

**Normative References:** Decisions Q26, Q75, Q76, Q77, Q78, Q79, Q80, Q81, Q82, Q83, Q84, Q278.

---

## 1. Healing Mechanics

Healing restores lost health to a creature or hero.

### 1.1 Quantities and Clamping [Q75]
- **Requested Heal ($H_{\text{req}}$):** The raw healing value specified by the card or ability.
- **Effective Heal ($H_{\text{eff}}$):** The actual number of HP restored:
  $$H_{\text{eff}} = \min(H_{\text{req}}, \text{Max HP} - \text{Current HP})$$
- **Overheal ($H_{\text{over}}$):** Any excess healing ($H_{\text{req}} - H_{\text{eff}}$) is discarded. Overheal does not increase max HP or convert into shield unless explicitly granted by a specific keyword.

### 1.2 Event Emission
- **`ON_HEAL` [Q75]:** Emitted if and only if $H_{\text{eff}} \ge 1$.
- If a full-health unit receives a healing spell, $H_{\text{eff}} = 0$ and no positive `ON_HEAL` event is emitted.

---

## 2. Max HP Modifications and Wound Preservation [Q26, Q278]

Max HP modifications are distinct from healing and damage. They alter the upper health threshold while maintaining damage state:

### 2.1 The Wound Preservation Invariant [Q278]
- A unit's damage taken is tracked as **Accumulated Wounds**:
  $$\text{Wounds} = \text{Max HP} - \text{Current HP}$$
- When Max HP changes to $\text{Max HP}'$:
  $$\text{Current HP}' = \text{Max HP}' - \text{Wounds}$$

### 2.2 Examples
- **Max HP Increase:** A creature with base 5 Max HP and 3 Current HP has 2 Wounds. If an aura grants $+2$ Max HP (new Max HP = 7), Current HP becomes $7 - 2 = 5$.
- **Max HP Decrease:** If the buff expires (Max HP drops back to 5), Current HP becomes $5 - 2 = 3$.
- **Lethal Max HP Drop [Q278]:** If a creature with 6 Max HP has taken 4 damage (Current HP = 2, Wounds = 4) and suffers a $-3$ Max HP debuff (new Max HP = 3), Current HP becomes $3 - 4 = -1$. **The creature dies immediately from the Max HP reduction.**
- **Minimum Max HP:** A creature's Max HP cannot drop below 1 while alive; if an effect would reduce it below 1, it triggers lethal check [Q278].

---

## 3. Temporary Effects and Expirations [Q78–Q84]

1. **State Tracking:** Every temporary stat modifier or buff records:
   - `effect_id`: Unique identifier.
   - `source_id`: The originating card or ability instance.
   - `duration_type`: E.g., `UNTIL_TURN_END`, `UNTIL_NEXT_TURN_START`, `WHILE_EQUIPPED`.
   - `applied_camp`: The camp that initiated the effect.
2. **Batch Expirations [Q80, Q81]:** When an expiration checkpoint is reached (e.g., turn end):
   - All effects reaching their scheduled expiration are detached simultaneously.
   - Authoritative stats are recalculated atomically.
   - Each removed effect emits `ON_EFFECT_EXPIRED`.
   - Any resulting deaths (e.g. from lost Max HP buffs) are resolved in a single stabilization step.
