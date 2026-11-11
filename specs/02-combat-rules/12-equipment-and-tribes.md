# Equipment and MVP Tribes

**Normative References:** Decisions Q235, Q236, Q237, Q238, Q239, Q240, Q241, Q242, Q243, Q244, Q245, Q246, Q247, Q248, Q249, Q250, Q251, Q252, Q253, Q254, Q283, Q284, Q285, Q286.

---

## 1. The Four MVP Tribes [Q235]

The game's foundational catalog is anchored around four fantasy tribes with distinct tactical identities:

| Tribe | Tactical Identity | Mechanical Signatures | Equipment Affinity |
|---|---|---|---|
| **HUMANS** | Disciplined army | Position-based combat, solid armor, frontline synergy | Standard (1 Weapon, 1 Protection) |
| **ELVES** | Agile rangers & mages | High ranged burst, healing support, defensive ambushes | Standard (1 Weapon, 1 Protection) |
| **DWARVES** | Heavy fortifications | High native armor, runic shields, defensive anchors | Standard (1 Weapon, 1 Protection) |
| **DRAGONS** | Colossal threats | Massive stats, high mana costs, airborne dominance | **0 Equipment Slots [Q253]** |

---

## 2. Equipment Mechanics

Equipment cards represent weapons and protective gear attached to creatures on the battlefield.

### 2.1 Casting and Attachment [Q285]
- An equipment card is played from hand during the action phase by paying its mana cost.
- It requires a legal, eligible target creature currently residing on the player's board.
- It targets the creature according to standard targeting validation [Q59].

### 2.2 Equipment Slots [Q250, Q253]
- Every creature definition declares its available equipment slots: **0, 1, or 2 slots**.
- Slots are strictly categorized:
  - At most **one Weapon slot** (`WEAPON`).
  - At most **one Protection slot** (`PROTECTION`).
- **Dragons possess 0 equipment slots** and can never bear equipment [Q253].

### 2.3 Slot Replacement [Q252]
- If a creature already has a Weapon equipped, playing a new Weapon onto it is legal.
- Upon successful attachment of the new item, the previously equipped item is **detached and sent directly to its owner's `DISCARD` pile** [Q252].

### 2.4 Ability Control and Bearer Death [Q251, Q284]
- **Granted Abilities [Q284]:** By default, abilities granted to a creature by its equipment are activated and controlled by the **bearer's controller** (even if the equipment card is owned by another player).
- **Bearer Death [Q251]:** When an equipped creature dies or leaves the board, all attached equipments are detached and sent to their respective owners' `DISCARD` piles.

### 2.5 Charges and Durability [Q254, Q286]
- There is no universal passive durability degradation.
- Equipments with limited charges require the **entire charge cost** to be available before activating; partial activations are rejected [Q286].
