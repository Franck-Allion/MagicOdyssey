# Tower Structure and Merchant Economy

**Normative References:** Decisions Q190, Q191, Q192, Q193, Q194, Q195, Q196, Q197, Q198, Q199, Q200, Q201, Q202, Q203, Q204.

---

## 1. Tower Ascent Architecture [Q190–Q194]

A standard MagicOdyssey run takes place inside the mystical Towers of Ascension:
- **Floor Hierarchy:** Each tower tier comprises a sequence of floors:
  - **Standard Encounter:** Tactical fight against wild beasts, raiders, or wandering spirits.
  - **Elite Encounter:** Challenging miniboss offering guaranteed high-rarity card drafts and relics.
  - **Sanctum (Rest Site):** Choose between Hero Healing, Card Upgrade, or Sphere Point Respec [Q189].
  - **Tower Merchant:** Trade accumulated gold for cards, equipment, relics, and deck thinning.
  - **Floor Boss:** Climactic multi-phase combat concluding the floor tier.
- **Diminishing Returns [Q194]:** Grinding or stalling encounters incurs diminishing gold rewards to maintain run momentum.

---

## 2. Tower Merchant Economy [Q195–Q204]

### 2.1 Inventory Structure [Q195]
Merchants generate a randomized stock tailored to current floor difficulty:
- 3–5 Creature & Spell cards across varied rarities.
- 1–2 Equipment cards.
- 1–2 Run Relics.
- **Card Purge Service [Q200]:** Pay gold to permanently remove a card from the active deck or reserve. The cost scales with each purge during the run.

### 2.2 Reroll Mechanism [Q197]
- Players may spend gold to refresh the merchant's inventory.
- Each successive reroll at the same merchant costs an escalating gold fee:
  $$\text{Reroll Cost} = \text{Base Cost} \times (1 + \text{Reroll Count})$$

### 2.3 Four-Copy Purchase Guard [Q204]
- Merchants will **refuse to sell** a card if the player already owns 4 copies across their active deck and reserve combined.
- The item is disabled with an explanatory tooltip or substituted with bonus gold compensation.
