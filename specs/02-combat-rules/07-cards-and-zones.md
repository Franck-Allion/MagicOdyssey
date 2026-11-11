# Cards, Zones, and Progressive Fatigue

**Normative References:** Decisions Q36, Q37, Q38, Q39, Q40, Q41, Q42, Q43, Q44, Q45, Q53, Q54, Q207, Q208, Q209, Q210, Q211, Q212, Q213, Q214.

---

## 1. Zone Architecture

Every card copy in a combat match resides in exactly one authoritative zone:
- `DECK`: Face-down ordered library of cards.
- `HAND`: Private hand of cards held by the player or opponent.
- `BOARD`: Active battlefield grid (managed as `BoardInstance` objects).
- `DISCARD`: Face-up graveyard of spent spells, fallen creatures, and discarded cards.
- `BANISHED`: Exile zone for cards removed from gameplay for the duration of the match.

Zone transfers record the reason for movement (`PLAYED`, `DIED`, `OVERFLOW_DISCARD`, `BANISHED`, `RECOVERED`) to maintain clear causal logs [Q44, Q54].

---

## 2. Deck and Hand Limits

1. **Standard Deck Size [Q208]:** A standard active combat deck consists of **40 cards**.
2. **Four-Copy Rule [Q207, Q227]:** A player may possess at most **4 copies** of any card definition (or variant family) across active deck and ascension reserve combined.
3. **Initial Hand [Q36]:** Both camps draw **6 cards** at match initialization. This replaces the standard draw on their first personal turn.
4. **Normal Draw [Q37]:** Beginning on their second personal turn, each camp draws **1 card** at turn start.
5. **Sequential Multi-Draw [Q42]:** If an effect instructs a player to draw multiple cards, draws resolve sequentially one-by-one.
6. **Maximum Hand Size [Q39, Q40]:**
   - Standard hand capacity is **7 cards**.
   - If a card is drawn when hand size is at maximum, the drawn card is automatically sent to the `DISCARD` pile (`cause = OVERFLOW_DISCARD`) [Q38].
   - If an effect reduces maximum hand size mid-game, the most recently added cards are discarded to meet the new limit [Q40].

---

## 3. Progressive Fatigue [Q210]

> **Historical Supersession:** Decision Q210 (v2.2) explicitly **supersedes** the earlier fixed 1 HP fatigue rule from Q41.

When a player is required to draw a card from an empty `DECK`:
1. **No Automatic Deck Reshuffle [Q43]:** The discard pile is **never** reshuffled into the deck during combat.
2. **Progressive HP Penalty [Q210]:** Each successive failed draw attempt within the same match inflicts strictly escalating direct HP loss:
   $$\text{Attempt 1} \implies -1\ \text{HP}$$
   $$\text{Attempt 2} \implies -2\ \text{HP}$$
   $$\text{Attempt 3} \implies -3\ \text{HP}$$
   $$\text{Attempt } n \implies -n\ \text{HP}$$
3. **Direct Loss Property:** Fatigue is **direct HP reduction**:
   - It completely **bypasses armor and shields**.
   - It does not count as combat attack damage.
   - The fatigue counter does not reset if cards are later added to the deck.

---

## 4. Discard Recovery and Banishment

### 4.1 Recovery from Discard [Q43, Q53]
- When an effect retrieves a card from the discard pile to the hand:
  - If the hand is full, the card is immediately returned to the discard pile [Q53].
  - Recovery with a full hand **never triggers fatigue** [Q53].
  - Emits `ON_ZONE_TRANSFER` with reason `RECOVERED`.

### 4.2 Banishment [Q45]
- Banished cards are removed to the `BANISHED` zone.
- They cannot be targeted by graveyard recovery, resurrection, or normal deck interactions during the combat.
- Banishment is strictly scoped to the active combat; it **never permanently removes** cards from the player's overarching deck or collection outside of combat [Q45].

---

## 5. Deck Search Mechanics [Q211–Q214]

- **Targeted Search [Q211, Q214]:** When an effect allows a player to search their library for a card:
  - Every eligible card copy is displayed as an individual selectable instance [Q214].
  - The internal hidden order of the remaining cards in the deck is **never revealed** to the player.
- **Random Search [Q211]:** If an effect fetches a random card from the library, the engine uses the deterministic combat RNG stream without opening a player selection UI.
