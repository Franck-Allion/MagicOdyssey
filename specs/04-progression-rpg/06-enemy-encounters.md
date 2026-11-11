# Enemy Encounters, AI Archetypes, and Special Missions

**Normative References:** Decisions Q265, Q266, Q267, Q268, Q269, Q270, Q271, Q272, Q273, Q274.

---

## 1. Tactical AI Archetypes [Q265, Q266]

Enemy AI opponents in MagicOdyssey evaluate legal actions using tactical evaluation archetypes parameterized by heuristic weights:

| Archetype | Tactical Focus | Priority Weights | Typical Encounter |
|---|---|---|---|
| **Balanced** (Lot 1 Baseline) | Generalist | Equal weight on hero preservation, board control, and lethal | Standard tower encounters |
| **Aggro (Rush)** | Face damage | Prioritizes attacking open lanes, early low-cost summons, ignores enemy defenders | Goblin packs, wild beasts |
| **Fortified (Control)** | Defensive lane anchor | Prioritizes high armor blockers in contested columns, defensive equipment | Dwarven guards, stone golems |
| **Sniper (Disruption)** | High-value removal | Saves spells for high-ATK player threats, utilizes ranged elves | Elven archers, cultist mages |

All AI archetypes operate strictly within the legal engine action space without cheating or private information leakage [Q299].

---

## 2. Special Mission Encounters [Q269–Q274]

> **Validated MVP Scope [Q271=A]:** Special missions for the MVP are strictly restricted to **two distinct families**: **Protection** and **Survival**. Earlier drafts suggesting additional families are superseded.

### 2.1 Protection Missions
- **Objective:** The player must safeguard a designated friendly objective unit (e.g. *Royal Caravan*, *Sleeping Elder*) occupying a specific board slot.
- **Defeat Condition:** If the protected objective's HP reaches 0, the player suffers immediate defeat, regardless of their hero's current HP.

### 2.2 Survival Missions
- **Objective:** The player must survive a fixed number of combat rounds (e.g. 8 turns) against an overwhelming or continuous wave of enemy reinforcements.
- **Victory Condition:** Successfully completing the final turn with the player's hero alive achieves victory.

### 2.3 Open Design Questions [Q274]
*Note for Post-Lot 1 Implementation:*
- The exact resolution order if both the protected objective and the enemy hero reach 0 HP on the same atomic commit is slated for future balance arbitration.
- Movement rules for immovable protected targets remain documented as open implementation details.
