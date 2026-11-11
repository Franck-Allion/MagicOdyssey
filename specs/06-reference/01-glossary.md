# MagicOdyssey — Domain Glossary

This glossary establishes the normative English domain terminology for **MagicOdyssey**. All code identifiers, GDScript classes, Resource properties, test scenarios, and documentation must adhere to these terms.

---

## 1. Battlefield and Spatial Terminology

- **Camp:** One of the two opposing territories on the battlefield: `PLAYER` (bottom) or `OPPONENT` (top).
- **Column:** One of the six vertical combat lanes numbered `1` to `6` from left to right.
- **Attack Row (Frontline):** The forward row nearest the center division where creatures execute automatic end-of-turn attacks.
- **Defense Row (Backline):** The rear row where creatures protect their column against standard attacks without attacking normally.
- **Slot:** A single position on the grid addressed by `(camp, column, row)`. Holds at most one creature.
- **Contested Column:** A column containing at least one creature from both camps.
- **Uncontested Enemy Column:** A column containing at least one enemy creature and zero allied creatures.
- **Contestation Priority:** The mandatory summoning rule requiring creatures to be played into uncontested enemy columns if legal placement is possible [Q03].

---

## 2. Creature Actions and Movement

- **Summoning:** Playing a creature card from hand to an eligible board slot.
- **Summoning Sickness:** A state preventing a newly summoned creature from making normal attacks during the turn it entered the board [Q29].
- **Natural Movement:** Vertical movement between Attack and Defense rows within the same column; costs 1 mana, limited to once per turn per creature [Q05, Q06].
- **Ally Permutation (Swap):** Two allied creatures in the same column swapping rows simultaneously; costs 1 mana total, consumes both creatures' movement rights [Q07].
- **Effect Movement:** Position changes triggered by spells or abilities; ignores natural movement limits and does not consume natural movement rights [Q08].
- **Transfer Sickness:** Inability to attack during the turn a creature's control is stolen by the opposing player [Q105].

---

## 3. Combat, Protections, and Health

- **Normal Attack:** Automatic combat strike performed by active Attack row creatures at the end of the turn in order of Column 1 to Column 6 [Q10].
- **Retaliation:** Counter-attack by a defender. **Non-existent by default** in MagicOdyssey [Q09].
- **Armor:** Reusable flat damage reduction subtracted from each incoming damage instance; never depleted by hits; minimum 0, no global ceiling [Q279, Q281].
- **Shield:** Consumable temporary health pool that absorbs post-armor damage; tracked by source; consumed in priority of earliest expiration [Q279, Q280].
- **Lethal Protection:** A defensive trait intercepting fatal damage to allow survival at 1 HP; temporary protections consumed before permanent ones [Q23, Q24, Q73].
- **Accumulated Wounds:** The difference between Max HP and Current HP ($\text{Max HP} - \text{Current HP}$). Preserved across Max HP fluctuations [Q278].
- **Overheal:** Excess healing attempted above Max HP; discarded without effect [Q75].
- **Trample:** Keyword allowing residual attack damage to carry over to the next target in the column if the blocker is destroyed [Q11, Q21].
- **Lifelink:** Ability queuing deferred healing equal to the source's allocated integer damage share [Q70].

---

## 4. Cards, Decks, and Zones

- **Active Deck:** The 40-card library used in combat [Q208].
- **Ascension Reserve:** The pool of unequipped/reserve cards held during a run (sideboard) [Q205].
- **Four-Copy Rule:** Hard cap of at most 4 copies of any card definition across active deck and reserve combined [Q207, Q227].
- **Hand:** Private zone holding up to 7 cards [Q39].
- **Hand Overflow:** Automatically discarding extra drawn cards to the graveyard when hand capacity is exceeded [Q38].
- **Discard Pile:** Face-up graveyard of spent spells and defeated units. Never automatically reshuffled into the deck during combat [Q43].
- **Banished Zone:** Out-of-combat exile for cards removed for the duration of the match [Q45].
- **Progressive Fatigue:** Direct HP loss suffered when drawing from an empty deck; escalates by 1 point per failed attempt (1, then 2, then 3...) [Q210].

---

## 5. Technical Identity Model

- **`definition_id`:** The immutable card model defined in the catalog (`CardDefinition` Resource) [Q57].
- **`copy_id`:** A specific card instance owned in the player's deck or collection [Q57].
- **`instance_id`:** The ephemeral presence of a unit on the board. Created upon entering the board, preserved during movement, and destroyed upon leaving [Q57, Q58].
- **Last Known State:** The frozen snapshot of a unit's properties at the exact moment it left the board, queried by resolving queued abilities [Q56].

---

## 6. Equipment and Tribes

- **Equipment:** Permanent attachment cards of type `WEAPON` or `PROTECTION` [Q249].
- **Equipment Slots:** Fixed capacity per creature (0, 1, or 2 slots; at most 1 Weapon and 1 Protection) [Q250, Q253].
- **MVP Tribes:** The four foundational factions:
  - **Humans:** Frontline formation and armor.
  - **Elves:** Ranged strikes and healing.
  - **Dwarves:** Heavy fortifications and runic shields.
  - **Dragons:** Colossal monsters; **0 equipment slots** [Q253].

---

## 7. Engine and Presentation

- **FIFO Event Queue:** Deterministic First-In, First-Out queue executing all triggered abilities and reactions [Q14].
- **Causal Budget:** Safety limits on recursive trigger chain depth (max 16) preventing infinite loops [Q115–Q118].
- **Fantasy Crest:** Shield-shaped token representing creatures on the board (replaces circular medallion) [Q294].
- **Inspection Panel:** Side interface displaying the intact original printed card on the left and live modifier breakdowns on the right [Q133].
- **Juicy VFX:** Fast-paced, punchy visual animations decoupled from engine logic [Q141, Q277, Q302].
