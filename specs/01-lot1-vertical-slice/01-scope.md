# MagicOdyssey — Lot 1 Functional and Technical Specifications

**Version:** 1.0 — November 2026  
**Status:** Approved Normative Baseline (Pre-implementation)  
**Target:** First complete, playable, visually professional 2D tactical combat vertical slice on Windows / Godot 4.  
**Upstream Reference:** *MagicOdyssey Full Specifications v2.8* (Decisions Q01–Q274), complemented by Q275–Q302.  
**Primary Usage:** Source of truth for roadmap execution and atomic prompt engineering.

> **Reading Rule — Levels of Authority:**  
> - **[VALIDATED]**: Explicit game design decision approved by designer.  
> - **[LOT1]**: Implementation contract specific to this vertical slice, preserving the long-term target gameplay.  
> - **[CONFIG]**: Fixture or tuning parameter that can be modified without a new game design arbitration.  
> - **[PROPOSAL]**: Recommended detail; must not be portrayed as an already locked historical rule.  
> - **[OUT OF SCOPE]**: Mechanic preserved in the global specifications, but not required to accept Lot 1.  
> If an apparent contradiction arises, the most recent validated decision takes absolute precedence.

---

## 1. Objective, Scope, and Definition of Done

### 1.1 Objective [VALIDATED]
Deliver a standalone Windows Godot 4 executable enabling a player to experience a complete tactical combat match against a heuristic AI:
- Match initialization and deterministic deck shuffle.
- Initial hand draw (6 cards) and alternate turn sequence (player starts).
- Hand card interactions: summoning, placement, vertical movement, and ally swapping.
- Spells, equipment, mana management, and growth (+1 per turn starting turn 1).
- End-of-turn automatic combat resolution (columns 1 to 6), target prioritization, damage, armor, shields, and healing.
- Progressive fatigue, creature death, victory/defeat condition evaluation, and replay loop.

This is a **representative vertical slice**: neither a headless rules library without an interface, nor a clickable mockup without an authentic game engine. An engine without a playable GUI **does not validate** Lot 1.

### 1.2 Included Scope [VALIDATED Q296–Q299]
- **Battlefield Grid:** 6 columns × 2 rows per camp (24 total slots), positioning rules, and contestation priority.
- **Creatures & Lanes:** Attack row vs Defense row, summoning sickness, 1-mana natural vertical movement, and column ally permutation.
- **Player & AI State:** Hero HP, mana capacity, available mana, mana cap, deck, hand, discard, banished, and progressive fatigue.
- **Turn Sequence:** End-of-turn automatic attacks across columns 1 to 6, target acquisition order, damage resolution, armor, shields, healing, death, and victory/defeat checks.
- **Spells & Equipment:** Targeted spells, simple passive and active abilities, Weapon and Protection equipment.
- **Mini-Catalog:** 16 official card definitions (10 creatures, 4 spells, 2 equipments).
- **Heuristic AI:** V1 AI choosing legal commands through the identical engine API without cheating or hidden information leaks.
- **UI/UX & Art Direction:** Premium 2D combat interface (1920×1080 native, 1280×720 responsive), fantasy crest tokens, interactive hand, tactical tooltips, detailed inspection panel, and expressive VFX.
- **Automated Verification:** Native headless test runner, 45 acceptance test scenarios (32 core engine + 13 UX), and standalone Windows build.

### 1.3 Deferred Scope (Non-Blocking for Lot 1) [VALIDATED]
- Tower exploration, merchant shops, draft reward selection, and floor navigation.
- World map, final main menu, settings, and out-of-combat meta-progression saving.
- Mind-control mechanics, resurrection chains, complex aura layers, visual card editor, and the complete ~170-card catalog.
- Deterministic test logs and headless replayability are mandatory; persistent cross-session save systems are deferred.

### 1.4 Deliverables [LOT1]
1. Godot 4 project directory containing scenes, GDScript files, 16 `.tres` card resources, legally cleared placeholder/final assets, test runner, fixture configurations, and execution documentation.
2. Verified test reports (32 core engine + 13 UX scenarios).
3. Windows executable export when export templates are installed.

---

## 2. Non-Negotiable Architectural Principles

1. **Strict Decoupling of Domain and Presentation:** Rules and game logic must never be computed from UI nodes, Control positions, Sprites, Tweens, animations, or pixel measurements.
2. **Single Authoritative State (`CombatState`):** The state is mutated exclusively via accepted `CombatCommand` objects processed by `CombatEngine`.
3. **Immutable Definitions vs Transient Instances:**
   - `definition_id`: Immutable card archetype (`CardDefinition` Resource).
   - `copy_id`: Unique physical card owned in the deck (`CardCopy`).
   - `instance_id`: Ephemeral presence of a creature on the board (`BoardInstance`). A creature re-entering the board receives a new `instance_id`.
4. **Declarative Card Catalog:** Cards must not contain hardcoded logic branches (`if card_id == ...`). Cards are composed of reusable atomic `EffectOperation` primitives [Q300–Q301].
5. **Deterministic Engine:** `f(State, Command, RNG_State, Rules_Version) -> (New_State, Ordered_Events, Result)`. Zero uncontrolled randomness.
6. **Separation of Validation and Execution:** An action submitted by the UI must be pre-validated against current state and re-validated upon execution.
7. **Atomic Transactions:** An action executes through: prepare -> validate invariants -> commit. Any unexpected engine failure rolls back the uncommitted operation without corrupting previously committed state [Q287].
8. **Gameplay Events Decoupled from VFX:** Logical events are emitted sequentially in the engine. The presentation layer consumes events asynchronously [Q277, Q302].
9. **Protected Hidden Information:** The AI controller only receives observed public state and its own private hand; it must never receive the opponent's private hand or deck order.
10. **Extensibility Verification:** Adding a 17th declarative card definition combining existing operations without modifying engine code is a required architectural regression test.

---

## 3. Combat Model and Functional Rules

### 3.1 Battlefield and Grid [VALIDATED Q01–Q02]
- Two camps: `PLAYER` and `OPPONENT`.
- Each camp has 6 columns (`1..6`) and 2 rows: `ATTACK` (front) and `DEFENSE` (back), totaling 12 slots per side (24 total).
- Maximum 1 creature per slot. A position is identified by `(camp, column, row)`.
- The `ATTACK` row performs end-of-turn attacks. The `DEFENSE` row protects its column and does not attack normally.
- Default attack targeting for column `c`:
  1. Enemy creature at `ATTACK[c]`.
  2. If none, enemy creature at `DEFENSE[c]`.
  3. If none, enemy Hero.
- There is no default counter-attack / retaliation.

### 3.2 Summoning [VALIDATED Q03–Q04]
- Summoning a creature requires: sufficient available mana, card in hand, active turn, and a legal free slot.
- Can be placed in either `ATTACK` or `DEFENSE` row (subject to card-specific constraints).
- **Contestation Priority [Q03]:** If an enemy creature occupies a column where the player has no creatures, and a legal placement is possible in that column, the summon **must** target that contested column. If all contested columns are filled or none exist, the player may summon freely into any legal empty slot.
- Summoning incurs **Summoning Sickness [Q29]**: the creature cannot perform normal attacks during the turn it was summoned.

### 3.3 Movement and Permutation [VALIDATED Q05–Q08]
- **Natural Movement [Q05, Q06]:** A creature can move vertically between `ATTACK` and `DEFENSE` rows within its column if the destination slot is empty.
  - Cost: **1 mana**.
  - Limit: **Once per personal turn per creature**.
  - Timing: Allowed on the turn the creature is summoned (even though it cannot attack).
- **Ally Permutation [Q07]:** Two allied creatures occupying the same column (`ATTACK` and `DEFENSE`) may swap positions.
  - Cost: **1 mana total**.
  - Requirement: Both creatures must have their natural movement available for that turn.
  - Effect: Consumes the natural movement of both creatures.
- **Effect Movement [Q08]:** Movement caused by spells or card effects ignores natural movement limits and does not consume the once-per-turn natural movement right.

### 3.4 Turn Sequence [VALIDATED Q09–Q10, Q28–Q37, Q275–Q277]
1. **Match Setup:** Decks shuffled with deterministic RNG seed. Each player draws an initial hand of **6 cards**. This initial draw replaces the normal draw on their first personal turn.
2. **Initiative:** The human player **always takes the first turn** [Q28, Q276].
3. **Turn Start Phase:**
   - Early-turn expirations processed.
   - **Mana Capacity Growth:** Capacity increases by +1 (including turn 1, starting from base capacity up to cap) [Q275].
   - **Mana Restoration:** Available mana restored to current capacity.
   - Turn-start triggered abilities fire.
   - **Normal Card Draw:** Draw 1 card from deck (skipped on player's and opponent's first personal turns).
4. **Action Phase:** Active player voluntarily submits actions (summon, move, swap, play spells/equipment, activate abilities). Each command executes and resolves fully before the next voluntary command is accepted.
5. **End-of-Turn Attack Phase:** The player triggers "End Turn". Active camp creatures in the `ATTACK` row strike sequentially from **Column 1 to Column 6**.
   - Each column resolves fully (damage, protections, deaths) before the next column resolves.
   - Newly summoned creatures with summoning sickness do not attack.
6. **Turn Cleanup Phase:**
   - Reactions to combat resolved.
   - `ON_TURN_END` abilities trigger and resolve.
   - End-of-turn temporary effect expirations process.
   - Active turn switches to the opposing camp.
7. **Game Termination:** Immediate victory/defeat check occurs after any atomic operation. If a hero dies, the match terminates immediately, discarding any remaining pending queue events.

### 3.5 Mana System [VALIDATED Q30–Q34, Q275]
- State tracking: `mana_capacity`, `mana_available`, `mana_cap`, and growth modifiers.
- Capacity increases by +1 at the start of each personal turn up to `mana_cap`. Available mana restores to capacity.
- Unspent mana is lost at turn end (no carry-over).
- Increasing the mana cap does not grant immediate available mana. Temporary growth modifiers apply starting from subsequent turn-start growth steps.
- Initial hero HP and starting mana values are defined in fixtures (`[CONFIG]`).

### 3.6 Deck, Hand, Zones, and Progressive Fatigue [VALIDATED Q36–Q45, Q210]
- **Decks:** Starting active deck consists of **40 cards**. Max 4 copies per card definition.
- **Hand Limits:** Initial hand is 6 cards; maximum hand size is 7 cards.
- **Hand Overflow:** Drawing beyond 7 causes the drawn card to be sent directly to the `DISCARD` pile. Multiple draws resolve sequentially.
- **Progressive Fatigue [Q210]:** When attempting to draw from an empty deck:
  - 1st attempt: Hero loses **1 HP**.
  - 2nd attempt: Hero loses **2 HP**.
  - 3rd attempt: Hero loses **3 HP** (and so on).
  - Fatigue is **direct HP loss**, bypassing armor and shields. It does not trigger damage-taken events.
- **Zones:** `DECK`, `HAND`, `BOARD`, `DISCARD`, `BANISHED`. Discard order and transfer causes (`PLAYED`, `DIED`, `OVERFLOW_DISCARD`) are tracked.

### 3.7 Damage, Protection, and Death Resolution [VALIDATED Q21–Q24, Q63–Q80, Q278–Q281, Q288–Q289]
- Normal attack damage equals the creature's effective attack. Excess damage is lost unless Trample applies.
- **Protection Consumption Order [Q22]:**
  $$\text{Incoming Damage} \longrightarrow \mathbf{Armor} \longrightarrow \mathbf{Shield} \longrightarrow \mathbf{HP} \longrightarrow \mathbf{Lethal\ Protection}$$
- **Armor [Q279, Q281]:** Reusable flat reduction applied to **each incoming damage instance**. Minimum 0, no global ceiling.
- **Shield [Q279, Q280]:** Consumable reserve pool. Multiple shields are tracked by source; absorbed in order of earliest expiration, then canonical order.
- **Creature Max HP [Q278]:** Minimum 1. When max HP changes, existing wounds are preserved. If max HP drops to or below current wounds, the creature dies.
- **Simultaneous Damage Aggregation [Q288, Q289]:** Compatible damage instances on a single target are aggregated by effective protection profile. Common shields are consumed, followed by simultaneous HP commit without intermediate triggers.
- **Attribution [Q65–Q74]:** Damage dealt is attributed to sources using the largest remainder method for proportional shares.

### 3.8 Healing and Temporary Modifiers [VALIDATED Q75–Q84, Q140]
- **Healing:** Restores HP up to max HP, never above. Emits `ON_HEAL` only if effective HP restored > 0.
- **Temporary Effects:** Tracked with `source_id`, duration type (`UNTIL_TURN_END`, etc.), and application order. Modifying durations triggers a visual clock update.

### 3.9 Targeting, Identity, and Event FIFO [VALIDATED Q19–Q20, Q55–Q64, Q276–Q287]
- Pre-validated upon command submission; re-validated upon atomic execution.
- If a target becomes invalid before execution, the effect fizzles without refund. In multi-target effects, valid targets still resolve.
- **Identity Model:** `card_id` (catalog) $\neq$ `copy_id` (deck instance) $\neq$ `instance_id` (board lifetime). Leaving the board destroys the `instance_id`.
- **FIFO Event Queue:** Triggered abilities queue in FIFO order. Queue drains fully between voluntary player commands. Causal budgets prevent infinite loops.

### 3.10 Equipment [VALIDATED Q245–Q255, Q283–Q286]
- Equipment types: `WEAPON` and `PROTECTION`.
- Fixed slots per creature: **0 to 2 slots** (at most 1 Weapon and 1 Protection).
- Played from hand targeting a valid bearer.
- By default, granted abilities are controlled by the bearer's controller.
- Replacing an equipped item sends the old equipment to its owner's discard pile [Q252].
- Lot 1 equipments are passive stat buffs (`+2 ATK` for weapon, `+2 ARMOR` for protection).

### 3.11 Victory and Defeat [VALIDATED Q15–Q16, Q63]
- Opponent Hero HP $\le 0$ (and Player Hero HP $> 0$): **Player Victory**.
- Player Hero HP $\le 0$ (and Opponent Hero HP $> 0$): **Player Defeat**.
- Both Heroes HP $\le 0$ simultaneously: **Player Defeat** [Q16].
- Match halts immediately upon victory/defeat; all remaining queue events are aborted.

---

## 4. UI/UX and Presentation Specifications [VALIDATED Q126–Q154, Q290–Q295, Q302]

### 4.1 Resolution and Layout
- Native Resolution: **1920×1080 (16:9)**. Responsive down to **1280×720**.
- Central battlefield with 24 distinct slots (6 columns × 2 rows × 2 camps).
- Opponent Hero HUD at top, Player Hero HUD at bottom-left/center, Player Hand at bottom.
- Action bar with turn indicator and prominent "End Turn" button.

### 4.2 Creature Tokens (Fantasy Crests) [Q294]
- Represented as **Fantasy Crest / Shield tokens** (replacing circular medallions).
- Effective Attack displayed at **bottom-left**.
- Current HP displayed at **bottom-right**.
- Distinct visual indicators for Armor and Shield.
- Up to 3 active status icons; additional statuses displayed as `+N` badge.

### 4.3 Cards and Inspection Panel [Q133–Q134]
- **Hand Cards:** Full illustrated fantasy card showing cost, title, tribe, artwork, printed stats, and rule text.
- **Hover/Tooltip:** Concise tactical summary with effective values and active buffs.
- **Click Inspection:** Side panel displaying the **unmodified original printed card** alongside a detailed calculation breakdown of effective stats, sources, and durations.

### 4.4 Decoupled Visual Scheduling (Juicy VFX) [Q277, Q302]
- Engine emits events immediately; the visual presenter processes them smoothly.
- Player input is re-enabled as soon as critical board state is visually coherent (decorative particles continue in background).
- Visual feedback contracts:
  - Summoning: card flight -> board impact -> morph into crest token.
  - Movement: smooth interpolation / synchronized swap.
  - Attack: anticipation wind-up -> projectile/strike -> damage shake.
  - Damage/Shield/Armor: red floating numbers for HP loss, blue shimmer for shield, metallic sparks for armor deflection.
  - Victory/Defeat: dramatic modal banner with stats summary and restart button.

---

## 5. Non-Blocking Config / Fixtures [CONFIG]
The following parameters are isolated in `combat_fixture.tres` and tunable without engine refactoring:
- Hero starting HP (default 30).
- Hero starting mana capacity and max cap.
- Exact quantities of the 16 cards in starting 40-card decks.
- Visual animation durations and particle densities.
- AI evaluation weights.
