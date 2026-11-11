# Control Transfers and Theft Mechanics

**Normative References:** Decisions Q95, Q96, Q97, Q98, Q99, Q100, Q101, Q102, Q103, Q104, Q105, Q106, Q107, Q108.

---

## 1. Principles of Control Transfer

Control transfers allow a player to take command of an opposing creature on the battlefield.

### 1.1 Repositioning [Q95, Q96]
- When control transfers, the creature leaves its current board slot and moves to an open slot on the new controller's board.
- The unit retains its current `instance_id`, accumulated damage, active stat modifiers, and attached equipment.
- If the new controller has no legal unoccupied board slots, the control transfer spell or effect **fizzles cleanly** [Q96].

### 1.2 Transfer Sickness [Q105]
- A stolen creature incurs **Transfer Sickness** upon changing sides.
- It cannot perform normal attacks during the turn it was stolen, unless an effect explicitly grants it immediate attack rights.
- It may, however, utilize natural vertical movement (for 1 mana) if the controller has available mana [Q106].

---

## 2. Ownership vs Control Invariants [Q98, Q99]

1. **Card Ownership [Q98]:** A card's physical owner never changes during a match.
2. **Death and Discard [Q98]:** When a stolen creature dies or leaves the board, it is placed into its **original owner's `DISCARD` pile**, never the temporary captor's discard.
3. **Equipments Attached [Q99]:** Equipment attached to the creature remains equipped during the transfer. The bearer's new controller gains control of granted active abilities [Q284].

---

## 3. Reversion of Control [Q100, Q101, Q102]

When a temporary control effect expires:
1. The creature attempts to return to an open slot on the original controller's board.
2. **Board Overflow [Q101]:** If the original controller's board is completely full when the control effect expires, the creature cannot return and is **sent directly to its owner's `DISCARD` pile** (`cause = BOARD_OVERFLOW`).
3. Reversion does not trigger resurrection effects; it emits `ON_CONTROL_REVERTED`.
