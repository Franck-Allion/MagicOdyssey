# Deck Construction, Starter Pool, and the Four-Copy Rule

**Normative References:** Decisions Q205, Q206, Q207, Q208, Q209, Q215, Q216, Q217, Q218, Q219, Q220, Q221, Q222, Q223, Q224, Q227.

---

## 1. Run Initialization: The 50-Card Preparation Pool [Q215–Q218]

At the start of an Ascension run, the player begins with an initial collection pool of **50 cards**:
1. **Neutral Starter Core [Q215]:** Exactly **20 fixed neutral cards** ensuring a consistent baseline mana curve and fundamental combat tools.
2. **Two Draft Boosters [Q216, Q217]:** Two 15-card randomized booster packs generated from the player's unlocked faction/tribe catalogs.
3. **Total Pool [Q218]:** $20 \text{ (Starter)} + 15 \text{ (Booster 1)} + 15 \text{ (Booster 2)} = \mathbf{50\text{ Cards}}$.

---

## 2. Active Deck and Reserve Architecture [Q205, Q208]

Before entering combat, the player configures their pool into two partitions:
- **Active Deck (Combat Library) [Q208]:** Exactly **40 cards**. This is the library shuffled and drawn from during battles.
- **Ascension Reserve (Sideboard) [Q205]:** The remaining cards (minimum 10 at start; expands as cards are earned). Cards in reserve are inactive during combat, but can be swapped into the active deck between floors.

### 2.1 The Four-Copy Rule [Q207, Q227]
- A player may possess at most **4 copies** of any card definition (or variant family) across their **active deck and reserve combined**.
- If a reward or merchant purchase would cause copies to exceed 4, the transaction is rejected or converted into compensation currency [Q204].

### 2.2 Deck Auto-Build [Q221]
- If a player modifies their deck and leaves it below 40 cards, an **Auto-Build** algorithm is available.
- It deterministically fills missing slots from the reserve using a balanced mana-curve heuristic to produce a legal 40-card deck.
- The game will not allow entering a combat floor without an active deck of exactly 40 cards.
