# Cards Presentation and the Inspection System

**Normative References:** Decisions Q126, Q127, Q128, Q130, Q131, Q133, Q134, Q154.

---

## 1. Hand Cards Architecture

Cards held in the player's hand are presented as premium illustrated physical-style cards rendered via a **single reusable `CardView` presentation architecture** (`scripts/presentation/card_view_layout.gd`) supporting three card-type-specific layout variants [PLAN-002]:

### 1.1 Shared Presentation Foundation
- **Card Back:** Official MagicOdyssey card back with opacity shader (`card_back_opacity.gdshader`).
- **Rarity Coding:** Gem treatment and border framing across Common, Uncommon, Rare, Epic, Legendary [Q181].
- **Typography:** Theme fonts, focal values, and high-contrast outlines (`fantasy_theme.tres`).
- **Mana Gem:** Mana cost badge (top-left gem).
- **Artwork Aperture:** Digital illustration frame.
- **Hand Interaction:** Fan layout, left-to-right stacking with exposed cost/identity, pointer hover lift, and click/drag commit [Q154].

### 1.2 The Three Card Layout Variants [PLAN-002]
1. **Creature Card (Approved Baseline):**
   - Retains the approved ART-002 design intact.
   - Artwork aperture, card title, mana cost, tribe badge, and rules text.
   - Printed base Attack (bottom-left) and base Max HP (bottom-right).
   - Armor and Shield badges where applicable.
2. **Spell Card (Dedicated Layout Variant):**
   - Uses shared MagicOdyssey proportions, materials, rarity coding, and mana gem.
   - Displays spell name, spell illustration, clear Spell category indicator, and readable effect description.
   - **Eliminates all Creature Attack/Health indicators and empty stat sockets.**
   - Recognizable in hand and hover inspection.
3. **Equipment Card (Dedicated Layout Variant):**
   - Uses shared MagicOdyssey proportions, materials, rarity coding, and mana gem.
   - Displays equipment name, item illustration, Weapon or Protection category badge, and equipment effect description.
   - **Eliminates all Creature Attack/Health indicators and empty stat sockets.**
   - Visually differentiates Weapon vs Protection while maintaining shared card family identity.

### 1.3 Dual Input Modalities [Q154]
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

### 2.2 Inspection of Spells, Equipments, and Future Artifacts [PLAN-002]
- **Creature Inspection:** Displays original printed creature card on the left; displays live effective stats, attached Creature Equipment, status effects, and expiration clocks on the right.
- **Spell Inspection:** Displays original printed spell card on the left without creature-only fields; displays target specification and declarative effect breakdown on the right.
- **Equipment Inspection:** Displays original printed equipment card on the left; displays Weapon/Protection category, stat modifiers, and bearer attachment requirements on the right.
- **Hero Artifact Inspection (Deferred):** Hero Artifact inspection is planned separately as part of the out-of-combat Hero Inventory interface (Phase 2 Tower Exploration).
