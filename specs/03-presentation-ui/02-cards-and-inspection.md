# Cards Presentation and the Inspection System

**Normative References:** Decisions Q126, Q127, Q128, Q130, Q131, Q133, Q134, Q154.

---

## 1. Hand Cards Architecture

Cards held in the player's hand are presented as premium illustrated physical-style cards:
- **Card Header:** Mana cost (top-left gem), card title, and tribe badge.
- **Card Artwork:** Detailed semi-realistic fantasy digital illustration.
- **Card Body:** Rules text, keyword badges, and rarity-coded borders (Common, Uncommon, Rare, Epic, Legendary) [Q181].
- **Card Footer:** Printed base Attack (bottom-left) and base Max HP (bottom-right) for creatures.

### 1.1 Dual Input Modalities [Q154]
The UI strictly supports two equivalent input workflows:
1. **Drag-and-Drop:** Click and drag the card from the hand directly over the battlefield slot or target unit, releasing to commit.
2. **Click-Select-Click:** Click the card to select it (card lifts and highlights), then click the desired board slot or target unit.
3. **Parity:** Both workflows feed into the exact same validation and submit identical `CombatCommand` objects to the engine.

---

## 2. The Detailed Inspection Panel [Q133, Q134]

Clicking any creature token on the board opens the **Inspection Panel**:

```
+------------------------------------+---------------------------------------+
|   ORIGINAL PRINTED CARD (LEFT)     |     LIVE MODIFIER AUDIT (RIGHT)       |
|                                    |                                       |
|  [ Original Unmodified Card Face ] |  EFFECTIVE ATTACK: 6 (Base 4 + 2)     |
|  - Printed Base Stats: 4 ATK / 5 HP|    - Runic Blade: +2 ATK (Equipped)   |
|  - Printed Abilities & Tribe       |                                       |
|  - Original Artwork & Frame        |  CURRENT HP: 3 / 5 (2 Wounds)         |
|                                    |                                       |
|                                    |  PROTECTIONS:                         |
|  * The printed face is NEVER       |    - Native Armor: 1                  |
|    overwritten with live numbers   |    - Arcane Barrier: 3 Shield (1 turn)|
|                                    |                                       |
|                                    |  ACTIVE TRAITS & DURATIONS:           |
|                                    |    - Martial Blessing: +2 ATK (Turn)  |
|                                    |    - Sickness: Active (Expires turn)  |
+------------------------------------+---------------------------------------+
```

### 2.1 The Non-Overwrite Invariant [Q133]
- Dynamic buffs, equipment bonuses, and temporary modifiers **must never alter the printed text on the card face**.
- The left viewport always shows the pristine original card definition.
- The right viewport displays a comprehensive mathematical breakdown showing:
  - Base stat value.
  - Every individual buff/debuff contributing to the final stat.
  - The source identity (`source_id`) of each modifier.
  - Expiration clocks and remaining durations.
  - Attached equipment details and slot occupancy.
