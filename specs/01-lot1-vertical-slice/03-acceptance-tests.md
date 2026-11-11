# MagicOdyssey — Lot 1 Acceptance Test Suite (45 Scenarios)

**Status:** Normative verification criteria for Lot 1.  
**Structure:** 32 Core Engine Tests (`L1-B01` to `L1-B32`) + 13 UX / Presentation Tests (`L1-U01` to `L1-U13`).  
**Verification Principle:** Headless automated execution for engine tests; reproducible visual inspection for UX criteria. No test is marked PASS without empirical proof.

---

## 1. Core Engine Tests (`L1-B01` to `L1-B32`)

| ID | Category | Scenario / Preconditions | Action / Stimulus | Expected Assertions |
|---|---|---|---|---|
| **L1-B01** | Init | 2 valid 40-card decks configured in fixture. | `CombatFactory.new_combat(fixture, seed)` | State valid; both heroes at fixture HP; active camp is `PLAYER`; each camp holds exactly 6 initial cards; deck sizes are 34; turn number is 1. |
| **L1-B02** | Turn 1 | Match freshly initialized (Turn 1). | Engine starts Turn 1 for `PLAYER`. | Mana capacity increases by +1 (starts at 1); available mana restores to 1 [Q275]; **no normal card draw occurs** (initial 6 cards replace turn 1 draw). |
| **L1-B03** | Later Turns | Turn 2 begins for `PLAYER`. | Turn-start sequence executes. | Mana capacity increases by +1; available mana restored to full capacity; exactly 1 card is drawn from deck into hand. |
| **L1-B04** | Resources | Player has 1 available mana and a 3-cost card in hand. | Attempt `PLAY_CARD` command. | Command rejected with `INSUFFICIENT_MANA`; no mana spent; hand unchanged; no board state mutation. |
| **L1-B05** | Summoning | Enemy creature occupies Column 3. Player has no creatures in Column 3. | Attempt `SUMMON_CREATURE` into empty Column 1. | Command rejected with `CONTESTATION_REQUIRED`; legal actions only expose valid slots in Column 3 [Q03]. |
| **L1-B06** | Summoning | Board is empty (no enemy units). | Submit `SUMMON_CREATURE` to `ATTACK` or `DEFENSE` row. | Command accepted; creature placed; mana deducted; instance created; `ON_SUMMON` emitted. |
| **L1-B07** | Sickness | Creature summoned during current turn. | End turn and reach combat attack phase. | Newly summoned unit has `summoning_sickness = true`; it performs no attack during this turn [Q29]. |
| **L1-B08** | Movement | Creature on `ATTACK` row with empty `DEFENSE` row in same column; player has 1 mana. | Submit `MOVE_UNIT` command. | Accepted; creature moves to `DEFENSE`; 1 mana deducted; creature's movement flag for this turn set to used. Attempting a 2nd move in the same turn is rejected. |
| **L1-B09** | Permutation | Allied creatures in `ATTACK` and `DEFENSE` rows of same column; both have unused movement; 1 mana available. | Submit `SWAP_UNITS` command. | Both swap positions; exactly 1 mana deducted total; both creatures' movement rights consumed for the turn [Q07]. |
| **L1-B10** | Attack | Allied creature in `ATTACK` row (Col 2). Opponent has units in Col 2 `ATTACK` and `DEFENSE`. | Trigger `END_TURN`. | Attacker strikes Col 2 enemy `ATTACK` unit first. If enemy dies and has no Trample, remaining Col 2 enemy `DEFENSE` unit takes no damage this attack [Q10]. |
| **L1-B11** | Retaliation | Allied unit attacks enemy unit in combat phase. | Attack resolves. | Target suffers damage; defending unit **does not strike back** (no default counter-attack) [Q09]. |
| **L1-B12** | Protection | Target has 2 Armor, 3 Shield, and 10 HP. Receives 7 incoming damage. | Apply 7 damage atomically. | Armor absorbs 2 (damage reduced to 5); Shield absorbs 3 (shield pool depleted to 0); target loses 2 HP (remaining HP = 8) [Q21–Q22]. |
| **L1-B13** | Multi-Shield | Target has Shield A (2 pts, expires end of turn) and Shield B (3 pts, permanent). Takes 3 damage. | Apply 3 damage. | Shield A is fully consumed (2 pts); Shield B absorbs remaining 1 pt (2 pts remaining) [Q280]. |
| **L1-B14** | Shield Deplete | Target has 3 Shield. Takes 3 damage. | Damage resolves. | Shield reduced to 0; shield removed from active pools; does not regenerate automatically [Q279]. |
| **L1-B15** | Healing | Target has base max HP 5, current HP 2. Cast `spell_heal` (heals 3). | Spell resolves. | Target restored to 5 HP (effective heal = 3); `ON_HEAL` event emitted with value 3 [Q75–Q77]. |
| **L1-B16** | Overheal | Target has base max HP 5, current HP 5. Cast `spell_heal`. | Spell resolves. | Target remains at 5 HP; effective heal = 0; no positive `ON_HEAL` event emitted. |
| **L1-B17** | Temp Stat | Cast `spell_blessing` on allied unit (+2 ATK until turn end). | Spell resolves, then turn ends. | ATK increases by +2 immediately; at turn end cleanup, expiration triggers and ATK returns to base value [Q78–Q84]. |
| **L1-B18** | Equipment | Play `equip_runic_blade` (+2 ATK) on valid Human bearer. | Equipment resolves. | Equipment attached to bearer's `WEAPON` slot; bearer effective ATK increases by +2 while equipped. |
| **L1-B19** | Equip Slot | Bearer already has a Weapon equipped. Play 2nd Weapon card on bearer. | Submit equip command. | Old weapon is detached and moved to owner's `DISCARD` pile; new weapon is equipped [Q252]. |
| **L1-B20** | Death | Creature HP reduced to 0. | Damage commits. | Creature removed from board slot; slot becomes legal empty; card copy sent to owner's `DISCARD`; `ON_DEATH` event emitted [Q12]. |
| **L1-B21** | Fizzle | Single-target spell launched. Target dies or leaves board before execution. | Spell resolves. | Spell fizzles cleanly; mana is not refunded; engine state remains consistent without crashing [Q20, Q58]. |
| **L1-B22** | Atomic Damage | Multiple simultaneous damage sources hit target in atomic group. | Resolve atomic group. | Total compatible damage aggregated; protections applied once; HP deducted simultaneously; death/victory evaluated once [Q63, Q288]. |
| **L1-B23** | Victory | Opponent Hero HP reduced to 0 while Player Hero HP > 0. | Damage commits. | Match terminates immediately with `RESULT = PLAYER_VICTORY`; all remaining queued commands/events aborted [Q15]. |
| **L1-B24** | Defeat | Player Hero HP reduced to 0 while Opponent Hero HP > 0. | Damage commits. | Match terminates immediately with `RESULT = OPPONENT_VICTORY`; match halted [Q15]. |
| **L1-B25** | Tie-Breaker | Both heroes reach $\le 0$ HP simultaneously during the same atomic operation. | Commit resolves. | Match terminates with `RESULT = OPPONENT_VICTORY` (simultaneous hero death is player defeat) [Q16]. |
| **L1-B26** | Fatigue | Player deck is empty. Attempt 3 successive draws during the match. | 3 draw attempts execute. | Attempt 1: Hero takes 1 direct HP loss; Attempt 2: Hero takes 2 direct HP loss; Attempt 3: Hero takes 3 direct HP loss; armor/shields ignored [Q210]. |
| **L1-B27** | Hand Overflow | Player holds 7 cards (hand max). Draws 1 additional card. | Draw executes. | 8th card drawn is immediately discarded to `DISCARD` pile with cause `OVERFLOW_DISCARD` [Q38–Q40]. |
| **L1-B28** | AI Fairness | Run AI decision cycle with identical public board state but differing opponent hidden hands. | Compare chosen AI commands. | AI selects the identical command regardless of opponent's hidden hand; no cheating or information leakage [Q299]. |
| **L1-B29** | Determinism | Initialize 2 identical combat states with identical seed and replay identical command log. | Compare final state hash. | Both matches produce identical state revision, identical event log, and identical outcome. |
| **L1-B30** | Rollback | Simulate technical validation failure inside an uncommitted transaction. | Transaction fails. | Uncommitted transaction rolled back; previously committed state preserved intact; error diagnostic logged [Q287]. |
| **L1-B31** | Extensibility | Add a 17th dummy card definition combining `DAMAGE` and `ADD_SHIELD` without modifying engine GDScript. | Load card and play in engine. | Card successfully validated by catalog, played, and executed without engine code changes. |
| **L1-B32** | Schema Error | Load malformed `.tres` (negative mana cost, missing required fields). | Run `CardCatalog.load_and_validate()`. | Loader rejects resource with clear diagnostic report; prevents match startup [Q300]. |

---

## 2. UX and Presentation Tests (`L1-U01` to `L1-U13`)

| ID | Focus | Verification Criterion | Proof / Validation Method |
|---|---|---|---|
| **L1-U01** | Resolution 1080p | Native 1920×1080 display: all 24 slots, hero HUDs, hand, turn button, and log are fully visible without clipping or overflow. | Screenshot capture at 1920×1080. |
| **L1-U02** | Resolution 720p | Responsive 1280×720 display: font scales appropriately; cards and buttons remain comfortably clickable. | Screenshot capture at 1280×720. |
| **L1-U03** | Crowded Board | Board with all 24 slots filled: tokens do not overlap illegibly; stats remain readable. | Visual test with 24 active tokens on board. |
| **L1-U04** | Inspection | Hovering a token shows quick tactical tooltip; clicking token opens side inspector with original printed card + live modifier breakdown. | Interactive click test with inspector open. |
| **L1-U05** | Status Icons | Token with >3 active statuses displays top 3 icons + badge `+N` indicating remaining count. | Test with 4 active buffs/debuffs on one token. |
| **L1-U06** | Input Parity | Playing a card via Drag-and-Drop vs via Click-Select-Click produces identical `CombatCommand` and engine response. | Dual input execution log comparison. |
| **L1-U07** | Cancel Input | Dragging card over illegal slot or pressing Escape returns card to hand smoothly with no resource spent. | Drag-drop abort test. |
| **L1-U08** | VFX Feedback | Summoning, physical attack, armor ricochet, shield shimmer, and heal halo each display distinct visual feedback matching event numbers. | Visual capture during each event type. |
| **L1-U09** | Input Responsiveness | Secondary particle effects still fading do not lock input; next player command is accepted as soon as board state is coherent. | Rapid command execution test. |
| **L1-U10** | Visual Order | Delayed VFX never overwrites newer authoritative board state. | Stress test with queued animations. |
| **L1-U11** | Hidden Info | Opponent hand cards display card backs only. | Visual inspection of opponent hand zone. |
| **L1-U12** | Game Loop | Player can play through full match to victory or defeat, observe final modal banner, and click Replay to restart cleanly. | Full manual match playthrough. |
| **L1-U13** | Accessibility | Key information (health, mana, faction, rarity) conveyed through text labels and shapes, not exclusively color hue. | High-contrast visual audit. |
