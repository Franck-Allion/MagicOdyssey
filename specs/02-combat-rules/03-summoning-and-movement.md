# Summoning and Movement

**Normative References:** Decisions Q03, Q04, Q05, Q06, Q07, Q08, Q29.

---

## 1. Summoning Rules

Summoning introduces a creature from the player's hand onto the battlefield.

### 1.1 Requirements
1. Active personal turn.
2. Sufficient available mana to pay the creature's mana cost.
3. At least one legal, unoccupied slot on the player's board.

### 1.2 Placement and Row Choice [Q04]
Unless constrained by specific card text, a creature may be summoned directly into either the `ATTACK` row or the `DEFENSE` row of any legally eligible column.

### 1.3 Contestation Priority Enforcement [Q03]
The player does not always have unrestricted column selection:
- An **uncontested enemy column** is any column where the opponent controls at least one creature and the player controls zero creatures.
- If one or more uncontested enemy columns exist, and the player can legally place the creature in at least one of those columns, the summon **must** be placed in one of those uncontested columns.
- Only when all opposing columns are contested (or the opposing board is empty) may the player summon freely into any available column.

### 1.4 Board Instance Lifecycle
- Summoning instantiates a new `instance_id` associated with the card's `copy_id`.
- Emits the `ON_SUMMON` gameplay event into the FIFO queue.
- The unit enters with **Summoning Sickness [Q29]**: it cannot perform normal attacks during this turn.

---

## 2. Movement Mechanics

Movement allows creatures already on the board to adjust their tactical positioning.

### 2.1 Natural Vertical Movement [Q05, Q06]
A creature may move vertically between rows within its own column:
- **Direction:** Exclusively vertical (`ATTACK` $\leftrightarrow$ `DEFENSE`) within the same column [Q05].
- **Precondition:** The destination slot in that column must be empty.
- **Resource Cost:** **1 mana** deducted from available mana [Q06].
- **Turn Frequency:** Limited to **once per personal turn per creature** [Q06].
- **Summoning Turn Usability:** A creature **may use natural movement on the turn it was summoned** [Q06].

### 2.2 Ally Permutation [Q07]
If an allied creature occupies `ATTACK` and another allied creature occupies `DEFENSE` in the same column:
- The two allied creatures may swap positions simultaneously.
- **Resource Cost:** **1 mana total** (not 1 per creature).
- **Precondition:** Both creatures must have their natural movement right available for that turn.
- **Result:** Both creatures swap slots; both creatures' natural movement rights for the turn are consumed.

### 2.3 Effect-Driven Movement [Q08]
Movement initiated by spells, triggered abilities, or card effects:
- May move creatures horizontally, change columns, or move to designated destinations according to card text.
- Does **not** consume the creature's natural movement right.
- Ignores natural movement restrictions (unless the card text specifies otherwise).
- Preserves the creature's existing `instance_id`, active buffs, damage, and equipment.
