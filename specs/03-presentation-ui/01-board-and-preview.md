# Battlefield Presentation and Tactical Preview

**Normative References:** Decisions Q129, Q145, Q146, Q147, Q148, Q149, Q150, Q151, Q152, Q153, Q154, Q291, Q292, Q293, Q294.

---

## 1. Resolution and Viewport Standards [Q291, Q292]

- **Native Resolution:** **1920×1080 (16:9)**.
- **Minimum Responsive Resolution:** **1280×720**.
- **Layout Architecture:**
  - Immersive central battlefield occupying the main screen area.
  - Opponent Hero HUD at top center/left; Player Hero HUD at bottom left.
  - Player hand fan/linear tray situated at bottom center.
  - Turn indicator banner and "End Turn" button accessible on the right.
  - Contextual sliding drawers for inspection and logs (no permanent sidebar eating board space) [Q292].

---

## 2. Creature Tokens: The Fantasy Crest [Q293, Q294]

> **Historical Supersession:** Decision Q294 formally validated the **Fantasy Crest / Shield shape**, explicitly replacing the circular/oval medallion draft from Q129.

Creatures on the battlefield are represented by shield-shaped fantasy crest tokens:
1. **Dominant Artwork:** Distinct character portrait occupying the upper two-thirds of the crest.
2. **Effective Attack:** Displayed prominently in the **bottom-left corner** [Q128].
3. **Current HP:** Displayed prominently in the **bottom-right corner** [Q128].
4. **Protections:**
   - **Armor:** Displayed with a metallic shield pip or badge.
   - **Shield:** Displayed with an azure glowing energy overlay and counter.
5. **Status Badges [Q132]:**
   - Displays up to **3 highest-priority status icons** (e.g. Sickness, Stun, Blessing).
   - If more than 3 active statuses exist, the 4th slot renders a `+N` badge showing the surplus count.
   - Full status details are accessible via hover tooltip and click inspection.

---

## 3. Tactical Preview Pipeline [Q148–Q152]

When the player selects a card or hovers over potential board moves:
1. **Valid Destination Highlighting [Q148]:** Legal slots glow softly (e.g. subtle green/gold border); illegal slots remain unhighlighted. Contested lane requirements [Q03] restrict highlights exclusively to valid contested slots.
2. **Projected Trajectory Arrows [Q149]:** When an attack or targeted spell is dragged, a curved trajectory line connects the source to the candidate target.
3. **Stat Delta Preview [Q150]:** Hovering a combat action previews the projected post-combat HP, armor, and shield numbers on both attacker and defender in ghosted numbers.
4. **Strict Non-Mutation Invariant [Q151]:** All preview calculations are performed in a read-only projection sandbox. **No preview interaction may ever mutate `CombatState`**.
5. **Clean Cancellation [Q153]:** Releasing a card outside a valid target, dragging it back to hand, or pressing Escape immediately clears all preview highlights and restores the UI without penalty or mana deduction.
