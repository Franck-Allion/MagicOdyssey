# Battlefield and Grid Layout

**Normative References:** Decisions Q01, Q02, Q03, Q04.

---

## 1. Grid Structure and Coordinates

The tactical combat battlefield is divided into two symmetrical opposing camps:
- `PLAYER` (Human player, bottom)
- `OPPONENT` (AI / Enemy, top)

Each camp controls a 6 × 2 grid consisting of:
- **6 Columns:** Numbered `1` to `6` from left to right.
- **2 Rows:**
  - `ATTACK` (Frontline): Nearest to the center board division. Creatures here perform automatic attacks at the end of their turn.
  - `DEFENSE` (Backline): Behind the frontline. Creatures here provide support and intercept enemy attacks targeting the column, but do not attack normally.

```
       [ OPPONENT HERO & RESOURCES ]
Col:     1       2       3       4       5       6
      +-------+-------+-------+-------+-------+-------+
      |  D1   |  D2   |  D3   |  D4   |  D5   |  D6   |  DEFENSE Row (Opponent)
      +-------+-------+-------+-------+-------+-------+
      |  A1   |  A2   |  A3   |  A4   |  A5   |  A6   |  ATTACK Row (Opponent)
======+=======+=======+=======+=======+=======+=======+====== Center Division
      |  A1   |  A2   |  A3   |  A4   |  A5   |  A6   |  ATTACK Row (Player)
      +-------+-------+-------+-------+-------+-------+
      |  D1   |  D2   |  D3   |  D4   |  D5   |  D6   |  DEFENSE Row (Player)
      +-------+-------+-------+-------+-------+-------+
         [ PLAYER HERO & RESOURCES ]
```

Every board slot is uniquely addressed by the coordinate tuple:  
$$\text{Slot} = (\text{Camp}, \text{Column}, \text{Row})$$

---

## 2. Slot Capacity and Invariants

1. **Uniqueness:** At most one creature instance may occupy a slot at any time.
2. **Persistence:** Moving or swapping preserves the creature's board instance (`instance_id`).
3. **No Retaliation:** When attacked by an opposing unit, the defending creature does not strike back automatically [Q09].

---

## 3. Targeting Order by Column [Q02]

When a creature in `ATTACK[c]` strikes at the end of the turn, it directs its attack strictly down its column in the following fixed priority:
1. Enemy creature at `ATTACK[c]`.
2. If `ATTACK[c]` is empty: Enemy creature at `DEFENSE[c]`.
3. If both `ATTACK[c]` and `DEFENSE[c]` are empty: The enemy **Hero**.

---

## 4. Column Contestation [Q03]

- **Contested Column:** A column containing at least one creature from both camps.
- **Uncontested Enemy Column:** A column containing at least one enemy creature and zero allied creatures.
- **Contestation Priority Rule [Q03]:**  
  When summoning a creature from hand, if one or more **uncontested enemy columns** exist on the board, and a legal placement is possible in at least one of those columns, the player **must** summon into one of those uncontested columns. Free placement into any empty slot on the board is only permitted when no uncontested enemy columns exist (i.e. all enemy columns are already contested, or the enemy board is empty).
