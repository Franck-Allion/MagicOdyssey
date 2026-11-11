# Continuous Effects, Auras, and Layer Presentation

**Normative References:** Decisions Q155, Q156, Q157, Q158, Q159, Q160, Q161, Q162, Q163, Q164.

---

## 1. Continuous Effects Architecture

Continuous effects and passive auras modify the characteristics of game objects dynamically as long as their conditions remain satisfied.

### 1.1 The Evaluation Layer System [Q155, Q158]
Continuous effects are evaluated using a deterministic layer pipeline to prevent circular recalculations:
1. **Layer 1:** Base printed card values.
2. **Layer 2:** Type, tribe, and slot structure modifications.
3. **Layer 3:** Granted or removed abilities.
4. **Layer 4:** Numerical modifiers to Attack, Armor, and Max HP (evaluated: flat bonuses $\rightarrow$ multiplicative modifiers).

### 1.2 State Invariant
- Continuous effects are **computed dynamically from current board state**; they are not repeatedly applied as permanent increments upon each frame or refresh [Q155].
- Moving a creature immediately updates all relevant positional auras in a single atomic recalculation step.

---

## 2. Visual Presentation of Auras [Q156, Q157]

1. **Source Indicator [Q156]:** A creature or card projecting an aura displays a subtle, ambient energetic border or ground glyph beneath its slot.
2. **Receiving Beneficiaries [Q156]:** Affected allied creatures display matching subtle particle threads or tint markers.
3. **Tactical Preview Integration [Q157]:** When the player hovers or drags a card into a slot influenced by an aura, the preview dynamically reflects the aura's projected bonus in the ghosted stat display before the card is released.
4. **Clean Detachment:** When an aura source is destroyed, banished, or silenced, all tethered visual markers and stat bonuses dissolve simultaneously in the subsequent frame [Q158].
