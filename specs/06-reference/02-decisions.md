# MagicOdyssey — Master Decisions Log (Q01 to Q302)

This document contains the authoritative log of all 302 design decisions governing **MagicOdyssey**.
- **Status:** `VALIDATED` (binding rule), `SUPERSEDED` (overridden by a newer decision), or `OPEN` (future post-Lot 1 balance parameter).
- **Hierarchy:** Newer validated decisions supersede older conflicting provisions.

---

## Index of Consolidation Batches

| Range | Version | Milestone / System Focus |
|---|---|---|
| **Q01 – Q27** | v0.5 – v0.7 | Core Battlefield, Lanes, Attacks, Protections, Event Queue |
| **Q28 – Q55** | v0.8 – v1.0 | Initiative, Mana Growth, Hand & Deck, Resurrection, Fizzling |
| **Q56 – Q84** | v1.1 – v1.3 | Identity, Atomic Resolution, Damage Attribution, Healing, Wounds |
| **Q85 – Q114** | v1.4 – v1.5 | Source Control, Mind-Control Transfers, Sickness, Loop Budgets |
| **Q115 – Q144** | v1.6 | Causal Budgets, Replay Hash, Inspection Panel, Crests, Juicy VFX |
| **Q145 – Q174** | v1.6 | Tactical Previews, Decoupled VFX, Auras, Combat Journal |
| **Q175 – Q204** | v2.0 – v2.1 | Rewards, Rarities, Sphere Grid, Towers, Merchant Economy |
| **Q205 – Q224** | v2.2 – v2.3 | Active Deck (40), 4-Copy Cap, Starter Pool (50), Progressive Fatigue |
| **Q225 – Q254** | v2.4 – v2.6 | 4 MVP Tribes, Equipment Slots (0-2), Weapons & Protection |
| **Q255 – Q274** | v2.7 – v2.8 | 100 Independent Cards, AI Archetypes, Special Missions (Protect & Survive) |
| **Q275 – Q302** | Lot 1 Baseline | Turn 1 Mana, Godot 4 GDScript 2D, 16 Cards, Heuristic AI, Declarative `.tres` |

---

## 1. Core Combat, Board, and Protections (Q01 – Q27)

| ID | Choice | Normative Summary | Status | Document |
|---|:---:|---|:---:|---|
| **Q01** | B | Two camps: `PLAYER` and `OPPONENT`. Each has 6 columns × 2 rows (Attack/Defense). | VALIDATED | [battlefield](../02-combat-rules/01-battlefield-and-layout.md) |
| **Q02** | A | Default attack targets: enemy Attack row -> Defense row -> Hero. | VALIDATED | [battlefield](../02-combat-rules/01-battlefield-and-layout.md) |
| **Q03** | A | Mandatory contestation priority: summons must contest uncontested enemy columns. | VALIDATED | [summoning](../02-combat-rules/03-summoning-and-movement.md) |
| **Q04** | B | Free placement into either Attack or Defense row. | VALIDATED | [summoning](../02-combat-rules/03-summoning-and-movement.md) |
| **Q05** | A | Natural movement is strictly vertical within the same column. | VALIDATED | [movement](../02-combat-rules/03-summoning-and-movement.md) |
| **Q06** | A | Natural movement costs 1 mana, once per turn, usable on summoning turn. | VALIDATED | [movement](../02-combat-rules/03-summoning-and-movement.md) |
| **Q07** | A | Ally permutation: two units in same column swap for 1 mana total; consumes both rights. | VALIDATED | [movement](../02-combat-rules/03-summoning-and-movement.md) |
| **Q08** | B | Movement by spell/ability ignores natural movement limits and rights. | VALIDATED | [movement](../02-combat-rules/03-summoning-and-movement.md) |
| **Q09** | B | Attacks deal ATK damage; **no retaliation or counter-attack by default**. | VALIDATED | [damage](../02-combat-rules/04-damage-and-protection.md) |
| **Q10** | A | End-of-turn attacks resolve sequentially column-by-column (Col 1 to 6). | VALIDATED | [damage](../02-combat-rules/04-damage-and-protection.md) |
| **Q11** | B | Trample carries excess damage forward only if the blocking creature is destroyed. | VALIDATED | [damage](../02-combat-rules/04-damage-and-protection.md) |
| **Q12** | A | Unit death: removed to discard immediately, frees slot, triggers `ON_DEATH`. | VALIDATED | [damage](../02-combat-rules/04-damage-and-protection.md) |
| **Q13** | A | Simultaneous triggers enqueued: Active camp first, Col 1 to 6, Attack before Defense. | VALIDATED | [queue](../02-combat-rules/10-abilities-and-queue.md) |
| **Q14** | A | Trigger resolution is strictly FIFO (First In, First Out). | VALIDATED | [queue](../02-combat-rules/10-abilities-and-queue.md) |
| **Q15** | A | Hero HP $\le 0$ causes immediate match conclusion. | VALIDATED | [damage](../02-combat-rules/04-damage-and-protection.md) |
| **Q16** | B | Simultaneous lethal on both heroes resolves as **Player Defeat**. | VALIDATED | [damage](../02-combat-rules/04-damage-and-protection.md) |
| **Q17** | A | Causal depth budget interrupts infinite recursive loops without rollback. | VALIDATED | [technical](../05-technical-systems/01-causal-budgets-and-replay.md) |
| **Q18** | A | Combat damage triggers resolve after the attack's atomic commit. | VALIDATED | [queue](../02-combat-rules/10-abilities-and-queue.md) |
| **Q19** | A | Abilities on queue resolve even if their source unit has died or left the board. | VALIDATED | [targeting](../02-combat-rules/09-targeting-and-identity.md) |
| **Q20** | B | Target loss at resolution time causes fizzling without mana refund. | VALIDATED | [targeting](../02-combat-rules/09-targeting-and-identity.md) |
| **Q21** | A | Trample excess damage is mitigated by protections on the primary target. | VALIDATED | [damage](../02-combat-rules/04-damage-and-protection.md) |
| **Q22** | A | Protection consumption order: Armor -> Shield -> HP -> Lethal Protection. | VALIDATED | [damage](../02-combat-rules/04-damage-and-protection.md) |
| **Q23** | A | Exactly one lethal protection is consumed per lethal event. | VALIDATED | [damage](../02-combat-rules/04-damage-and-protection.md) |
| **Q24** | A | Temporary lethal protections are consumed before permanent ones. | VALIDATED | [damage](../02-combat-rules/04-damage-and-protection.md) |
| **Q25** | A | Zero-damage attacks emit `ON_ATTACK`, but do not emit HP loss events. | VALIDATED | [damage](../02-combat-rules/04-damage-and-protection.md) |
| **Q26** | A | Modifying Max HP preserves accumulated wounds ($\text{HP}' = \text{Max HP}' - \text{Wounds}$). | VALIDATED | [healing](../02-combat-rules/06-healing-and-health.md) |
| **Q27** | B | Direct HP loss bypasses armor and shields; does not count as attack damage. | VALIDATED | [damage](../02-combat-rules/04-damage-and-protection.md) |

---

## 2. Initiative, Resources, and Zones (Q28 – Q55)

| ID | Choice | Normative Summary | Status | Document |
|---|:---:|---|:---:|---|
| **Q28** | A | Human player always starts the combat match. | VALIDATED | [turn](../02-combat-rules/02-turn-sequence-and-mana.md) |
| **Q29** | A | Newly summoned units incur summoning sickness (cannot attack this turn). | VALIDATED | [turn](../02-combat-rules/02-turn-sequence-and-mana.md) |
| **Q30** | A | Distinct mana properties: capacity, available, cap, and growth rate. | VALIDATED | [turn](../02-combat-rules/02-turn-sequence-and-mana.md) |
| **Q31** | A | Available mana restores to capacity at turn start; unspent mana is lost. | VALIDATED | [turn](../02-combat-rules/02-turn-sequence-and-mana.md) |
| **Q32** | A | Mana capacity grows by +1 per personal turn up to the hero cap. | VALIDATED | [turn](../02-combat-rules/02-turn-sequence-and-mana.md) |
| **Q33** | B | Growth rate modifications apply starting from subsequent turn-start growth steps. | VALIDATED | [turn](../02-combat-rules/02-turn-sequence-and-mana.md) |
| **Q34** | B | Raising mana cap does not grant immediate available mana. | VALIDATED | [turn](../02-combat-rules/02-turn-sequence-and-mana.md) |
| **Q35** | A | Turn-start sequence: expirations -> mana growth -> mana restore -> triggers -> draw. | VALIDATED | [turn](../02-combat-rules/02-turn-sequence-and-mana.md) |
| **Q36** | A | Initial hand is 6 cards; replaces normal draw on personal turn 1. | VALIDATED | [cards](../02-combat-rules/07-cards-and-zones.md) |
| **Q37** | A | Normal card draw is 1 card at personal turn start (beginning Turn 2). | VALIDATED | [cards](../02-combat-rules/07-cards-and-zones.md) |
| **Q38** | A | Cards drawn beyond max hand size are automatically sent to discard. | VALIDATED | [cards](../02-combat-rules/07-cards-and-zones.md) |
| **Q39** | A | Standard maximum hand size is 7 cards. | VALIDATED | [cards](../02-combat-rules/07-cards-and-zones.md) |
| **Q40** | B | Lowering max hand size discards newest cards to reach limit. | VALIDATED | [cards](../02-combat-rules/07-cards-and-zones.md) |
| **Q41** | — | Fixed 1 HP fatigue penalty per empty draw. | **SUPERSEDED by Q210** | [cards](../02-combat-rules/07-cards-and-zones.md) |
| **Q42** | A | Multiple card draws resolve sequentially with reactive triggers between draws. | VALIDATED | [cards](../02-combat-rules/07-cards-and-zones.md) |
| **Q43** | B | Discard pile is never automatically reshuffled into the deck during combat. | VALIDATED | [cards](../02-combat-rules/07-cards-and-zones.md) |
| **Q44** | A | Zone transfers track cause (`PLAYED`, `DIED`, `DISCARDED`, `BANISHED`). | VALIDATED | [cards](../02-combat-rules/07-cards-and-zones.md) |
| **Q45** | B | Banishment exiles cards for combat duration; never permanently removes from player collection. | VALIDATED | [cards](../02-combat-rules/07-cards-and-zones.md) |
| **Q46** | A | Resurrection resets unit to printed baseline stats, clearing old wounds and buffs. | VALIDATED | [resurrection](../02-combat-rules/08-resurrection.md) |
| **Q47** | A | Resurrection is subject to normal summoning contestation priority rules. | VALIDATED | [resurrection](../02-combat-rules/08-resurrection.md) |
| **Q48** | A | Resurrected units incur summoning sickness; trigger `ON_SUMMON` and `ON_RESURRECT`. | VALIDATED | [resurrection](../02-combat-rules/08-resurrection.md) |
| **Q49** | A | Resurrection order: reset baseline -> apply spell modifiers -> enqueue triggers. | VALIDATED | [resurrection](../02-combat-rules/08-resurrection.md) |
| **Q50** | A | FIFO trigger priority: `ON_SUMMON` enqueued before `ON_RESURRECT`. | VALIDATED | [resurrection](../02-combat-rules/08-resurrection.md) |
| **Q51** | B | Resurrection requires a legal slot at cast; fizzles without refund if slot becomes illegal. | VALIDATED | [resurrection](../02-combat-rules/08-resurrection.md) |
| **Q52** | A | Multi-resurrections resolve sequentially; partial successes are retained if space runs out. | VALIDATED | [resurrection](../02-combat-rules/08-resurrection.md) |
| **Q53** | B | Recovering a card from discard with full hand returns it to discard without fatigue. | VALIDATED | [cards](../02-combat-rules/07-cards-and-zones.md) |
| **Q54** | A | Transferred cards preserve origin zone and timestamp metadata. | VALIDATED | [cards](../02-combat-rules/07-cards-and-zones.md) |
| **Q55** | A | All multi-resurrection units place on board before their triggers execute. | VALIDATED | [resurrection](../02-combat-rules/08-resurrection.md) |

---

## 3. Identity, Attribution, and Health (Q56 – Q84)

| ID | Choice | Normative Summary | Status | Document |
|---|:---:|---|:---:|---|
| **Q56** | A | Queued abilities querying dead sources use their Last Known State at board exit. | VALIDATED | [targeting](../02-combat-rules/09-targeting-and-identity.md) |
| **Q57** | A | Strict identity separation: `definition_id` $\neq$ `copy_id` $\neq$ `instance_id`. | VALIDATED | [targeting](../02-combat-rules/09-targeting-and-identity.md) |
| **Q58** | A | Units leaving the board permanently retire their `instance_id`. | VALIDATED | [targeting](../02-combat-rules/09-targeting-and-identity.md) |
| **Q59** | A | Dual target verification: checked at command submission and re-checked at commit. | VALIDATED | [targeting](../02-combat-rules/09-targeting-and-identity.md) |
| **Q60** | B | Multi-target effects resolve on remaining valid targets if some targets fizzle. | VALIDATED | [targeting](../02-combat-rules/09-targeting-and-identity.md) |
| **Q61** | A | Compound card operations are independent by default unless explicitly conditional. | VALIDATED | [effects](../02-combat-rules/11-effect-resolution.md) |
| **Q62** | A | All sub-operations of a compound card commit before queued triggers execute. | VALIDATED | [effects](../02-combat-rules/11-effect-resolution.md) |
| **Q63** | A | Hero death checks occur immediately after each atomic sub-operation. | VALIDATED | [effects](../02-combat-rules/11-effect-resolution.md) |
| **Q64** | A | Simultaneous damage instances sharing rules are aggregated before applying protections. | VALIDATED | [effects](../02-combat-rules/11-effect-resolution.md) |
| **Q65** | A | `ON_DAMAGE_TAKEN` emitted once per target per atomic operation (if $\ge 1$ HP lost). | VALIDATED | [attribution](../02-combat-rules/05-damage-attribution.md) |
| **Q66** | A | `ON_DAMAGE_DEALT` emitted once per contributing source per target. | VALIDATED | [attribution](../02-combat-rules/05-damage-attribution.md) |
| **Q67** | B | All sources contributing positive damage participate in triggers even if rounded to 0. | VALIDATED | [attribution](../02-combat-rules/05-damage-attribution.md) |
| **Q68** | A | Allocated damage quanta sum exactly to net target HP loss ($\sum Q_i = \Delta \text{HP}$). | VALIDATED | [attribution](../02-combat-rules/05-damage-attribution.md) |
| **Q69** | A | Proportional damage shares apportioned using Hamilton-Hare Largest Remainder Method. | VALIDATED | [attribution](../02-combat-rules/05-damage-attribution.md) |
| **Q70** | A | Lifelink heals equal to allocated integer damage share; cannot retroactively save dead hero. | VALIDATED | [attribution](../02-combat-rules/05-damage-attribution.md) |
| **Q71** | A | At most one armor event and one shield event emitted per target per atomic operation. | VALIDATED | [attribution](../02-combat-rules/05-damage-attribution.md) |
| **Q72** | B | Simultaneous defensive absorptions grouped into single log event per target. | VALIDATED | [attribution](../02-combat-rules/05-damage-attribution.md) |
| **Q73** | A | Lethal protection tie-breaker: temporary first, earliest expiration, then canonical order. | VALIDATED | [damage](../02-combat-rules/04-damage-and-protection.md) |
| **Q74** | A | Damage attribution metadata attached to all emitted damage events. | VALIDATED | [attribution](../02-combat-rules/05-damage-attribution.md) |
| **Q75** | A | Healing restores up to Max HP, never above; `ON_HEAL` emitted only if effective heal $\ge 1$. | VALIDATED | [healing](../02-combat-rules/06-healing-and-health.md) |
| **Q76** | A | Overheal is discarded without effect unless explicitly converted by card keyword. | VALIDATED | [healing](../02-combat-rules/06-healing-and-health.md) |
| **Q77** | B | Multi-target heals resolve simultaneously before triggers fire. | VALIDATED | [healing](../02-combat-rules/06-healing-and-health.md) |
| **Q78** | A | Temporary buffs record source, duration type, and application order. | VALIDATED | [healing](../02-combat-rules/06-healing-and-health.md) |
| **Q79** | A | Max HP reductions can be fatal if remaining HP drops to 0 or below [Q278]. | VALIDATED | [healing](../02-combat-rules/06-healing-and-health.md) |
| **Q80** | A | Temporary buffs expiring at same checkpoint detach simultaneously. | VALIDATED | [healing](../02-combat-rules/06-healing-and-health.md) |
| **Q81** | A | Scheduled expirations process at turn boundaries. | VALIDATED | [turn](../02-combat-rules/02-turn-sequence-and-mana.md) |
| **Q82** | A | Expiration triggers enqueue into FIFO queue. | VALIDATED | [queue](../02-combat-rules/10-abilities-and-queue.md) |
| **Q83** | B | Extending an active buff's duration updates its clock without reapplying base values. | VALIDATED | [tooltips](../03-presentation-ui/03-tooltips-and-vfx.md) |
| **Q84** | A | Buff expirations re-evaluate effective unit stats in a single atomic recalculation. | VALIDATED | [healing](../02-combat-rules/06-healing-and-health.md) |

---

## 4. Mind Control, Loop Safety, and Causal Budgets (Q85 – Q125)

| ID | Choice | Normative Summary | Status | Document |
|---|:---:|---|:---:|---|
| **Q85–Q94** | A | Source snapshots, dynamic property caching, and continuous aura registration. | VALIDATED | [targeting](../02-combat-rules/09-targeting-and-identity.md) |
| **Q95** | A | Mind-control moves unit to an open slot on new controller's board; retains `instance_id`. | VALIDATED | [control](../02-combat-rules/13-control-transfers.md) |
| **Q96** | B | Control transfer fizzles cleanly if new controller's board has no open slots. | VALIDATED | [control](../02-combat-rules/13-control-transfers.md) |
| **Q97** | A | Stolen unit keeps attached equipment; new controller gains ability activation rights. | VALIDATED | [control](../02-combat-rules/13-control-transfers.md) |
| **Q98** | A | Stolen unit death sends card copy to original owner's discard pile. | VALIDATED | [control](../02-combat-rules/13-control-transfers.md) |
| **Q99** | A | Equipment on stolen units returns to its respective owner's discard upon unit death. | VALIDATED | [control](../02-combat-rules/13-control-transfers.md) |
| **Q100** | A | Control expiration returns unit to previous controller's board. | VALIDATED | [control](../02-combat-rules/13-control-transfers.md) |
| **Q101** | B | If original board is full upon control expiration, unit is sent to owner's discard. | VALIDATED | [control](../02-combat-rules/13-control-transfers.md) |
| **Q102–Q104** | A | Control tracking metadata and clean event emission (`ON_CONTROL_REVERTED`). | VALIDATED | [control](../02-combat-rules/13-control-transfers.md) |
| **Q105** | A | Stolen units incur Transfer Sickness (cannot attack on transfer turn). | VALIDATED | [control](../02-combat-rules/13-control-transfers.md) |
| **Q106** | A | Stolen units may use natural vertical movement (1 mana) if controller has mana. | VALIDATED | [control](../02-combat-rules/13-control-transfers.md) |
| **Q107–Q110** | A | Voluntary action limits and loop safety during turn execution. | VALIDATED | [turn](../02-combat-rules/02-turn-sequence-and-mana.md) |
| **Q111** | A | Causal context attached to all operations (`root_command_id`, `chain_depth`). | VALIDATED | [technical](../05-technical-systems/01-causal-budgets-and-replay.md) |
| **Q112** | A | Maximum causal trigger depth capped at 16 nested levels. | VALIDATED | [technical](../05-technical-systems/01-causal-budgets-and-replay.md) |
| **Q113** | A | Targeted branch interruption: suppresses only the looping branch, preserves queue. | VALIDATED | [technical](../05-technical-systems/01-causal-budgets-and-replay.md) |
| **Q114** | A | Diagnostics emitted upon loop budget limit; no rollback of committed events. | VALIDATED | [technical](../05-technical-systems/01-causal-budgets-and-replay.md) |
| **Q115–Q118** | A | Formal causal budget thresholds (depth 16, max 64 events per command). | VALIDATED | [technical](../05-technical-systems/01-causal-budgets-and-replay.md) |
| **Q119–Q122** | A | Deterministic replay contract: seed + command log reproduces identical state hashes. | VALIDATED | [technical](../05-technical-systems/01-causal-budgets-and-replay.md) |
| **Q123–Q125** | A | Full state snapshot serialization and resume capability. | VALIDATED | [technical](../05-technical-systems/01-causal-budgets-and-replay.md) |

---

## 5. UI, Tokens, Inspection, and VFX (Q126 – Q174)

| ID | Choice | Normative Summary | Status | Document |
|---|:---:|---|:---:|---|
| **Q126** | A | 16:9 layout, central battlefield, hero HUDs visible, bottom hand tray. | VALIDATED | [preview](../03-presentation-ui/01-board-and-preview.md) |
| **Q127** | A | Distinct visual differentiation for Attack row and Defense row. | VALIDATED | [preview](../03-presentation-ui/01-board-and-preview.md) |
| **Q128** | A | Effective Attack in bottom-left; current HP in bottom-right of token. | VALIDATED | [preview](../03-presentation-ui/01-board-and-preview.md) |
| **Q129** | — | Creature tokens shaped as circular/oval medallions. | **SUPERSEDED by Q294** | [preview](../03-presentation-ui/01-board-and-preview.md) |
| **Q130–Q131** | A | Distinct visual badges for armor (metallic pip) and shield (azure shimmer). | VALIDATED | [preview](../03-presentation-ui/01-board-and-preview.md) |
| **Q132** | A | Token displays up to 3 priority status icons + `+N` badge for surplus count. | VALIDATED | [preview](../03-presentation-ui/01-board-and-preview.md) |
| **Q133** | A | Inspection panel shows original printed card intact on left; modifiers on right. | VALIDATED | [inspection](../03-presentation-ui/02-cards-and-inspection.md) |
| **Q134** | A | Dynamic modifiers never overwrite the original printed card face. | VALIDATED | [inspection](../03-presentation-ui/02-cards-and-inspection.md) |
| **Q135–Q137** | A | Hovering cards/tokens opens immediate concise tactical tooltip. | VALIDATED | [tooltips](../03-presentation-ui/03-tooltips-and-vfx.md) |
| **Q138** | A | Tooltip durations rendered in natural plain language ("Expires end of turn"). | VALIDATED | [tooltips](../03-presentation-ui/03-tooltips-and-vfx.md) |
| **Q139–Q140** | A | Clock updates trigger visual animation pulses in tooltips and badges. | VALIDATED | [tooltips](../03-presentation-ui/03-tooltips-and-vfx.md) |
| **Q141–Q144** | A | Juicy fast-paced VFX: snappy animations (100–350ms), distinct sound cues. | VALIDATED | [tooltips](../03-presentation-ui/03-tooltips-and-vfx.md) |
| **Q145–Q147** | A | 24 board slots clearly visible and accessible at 1080p and 720p. | VALIDATED | [preview](../03-presentation-ui/01-board-and-preview.md) |
| **Q148–Q152** | A | Tactical previews highlight valid slots and stat deltas without state mutation. | VALIDATED | [preview](../03-presentation-ui/01-board-and-preview.md) |
| **Q153** | A | Cancelling drag or pressing Escape clears preview highlights cleanly. | VALIDATED | [preview](../03-presentation-ui/01-board-and-preview.md) |
| **Q154** | A | Input parity: Drag-and-Drop and Click-Select-Click produce identical commands. | VALIDATED | [inspection](../03-presentation-ui/02-cards-and-inspection.md) |
| **Q155–Q158** | A | Auras evaluated in deterministic layers; source ground glyphs and recipient links. | VALIDATED | [auras](../03-presentation-ui/04-continuous-effects-ui.md) |
| **Q159–Q164** | A | Aura preview integration and clean visual detachment upon source removal. | VALIDATED | [auras](../03-presentation-ui/04-continuous-effects-ui.md) |
| **Q165–Q167** | A | Contextual Combat Journal logging public events; one-click inspection linking. | VALIDATED | [journal](../03-presentation-ui/05-combat-journal.md) |
| **Q168–Q174** | A | Hidden info compliance: opponent draws masked, library order protected. | VALIDATED | [journal](../03-presentation-ui/05-combat-journal.md) |

---

## 6. Progression, Economy, and Catalogs (Q175 – Q274)

| ID | Choice | Normative Summary | Status | Document |
|---|:---:|---|:---:|---|
| **Q175** | A | Post-combat draft: choose 1 card out of 3 offered options (or skip). | VALIDATED | [rewards](../04-progression-rpg/03-rewards-and-rarities.md) |
| **Q176** | A | Combat victories award gold currency and Sphere Points. | VALIDATED | [rewards](../04-progression-rpg/03-rewards-and-rarities.md) |
| **Q177** | A | Floor Boss victories award powerful persistent Boss Relics. | VALIDATED | [rewards](../04-progression-rpg/03-rewards-and-rarities.md) |
| **Q178–Q180** | A | Run relics provide persistent passive combat modifiers. | VALIDATED | [rewards](../04-progression-rpg/03-rewards-and-rarities.md) |
| **Q181** | A | Five card rarities: Common (White), Uncommon (Blue), Rare (Red), Epic (Purple), Legendary (Gold). | VALIDATED | [rewards](../04-progression-rpg/03-rewards-and-rarities.md) |
| **Q182–Q184** | A | 20 Ascension difficulty levels scaling monster power and penalties. | VALIDATED | [rewards](../04-progression-rpg/03-rewards-and-rarities.md) |
| **Q185–Q189** | A | Hero Sphere Grid: stat nodes, passive talents, card variant upgrades, respec at sanctums. | VALIDATED | [sphere](../04-progression-rpg/02-hero-sphere.md) |
| **Q190–Q194** | A | Tower floor flow: standard, elite, sanctum, merchant, boss; diminishing farm returns. | VALIDATED | [towers](../04-progression-rpg/04-towers-and-merchants.md) |
| **Q195–Q204** | A | Merchant economy: cards, relics, card purges, escalating reroll costs, 4-copy purchase guard. | VALIDATED | [towers](../04-progression-rpg/04-towers-and-merchants.md) |
| **Q205–Q206** | A | Run card collection partitioned into Active Deck (40 cards) and Ascension Reserve. | VALIDATED | [starter](../04-progression-rpg/01-deck-and-starter.md) |
| **Q207** | A | Four-Copy Rule: max 4 copies of any card definition across active deck + reserve combined. | VALIDATED | [starter](../04-progression-rpg/01-deck-and-starter.md) |
| **Q208–Q209** | A | Standard active combat deck is exactly 40 cards. | VALIDATED | [starter](../04-progression-rpg/01-deck-and-starter.md) |
| **Q210** | A | Progressive fatigue: 1, then 2, then 3... direct HP loss per empty draw attempt. | VALIDATED | [cards](../02-combat-rules/07-cards-and-zones.md) |
| **Q211–Q214** | A | Deck search mechanics: individual card selection without revealing library order. | VALIDATED | [cards](../02-combat-rules/07-cards-and-zones.md) |
| **Q215–Q218** | A | Starter pool (50 cards): 20 fixed neutral cards + two 15-card draft boosters. | VALIDATED | [starter](../04-progression-rpg/01-deck-and-starter.md) |
| **Q219–Q224** | A | Initial active deck (40) configured from 50-card pool; auto-build completes legal decks. | VALIDATED | [starter](../04-progression-rpg/01-deck-and-starter.md) |
| **Q225–Q234** | A | Total MVP catalog (~170 cards): 40 fundamental (4 tribes) + 30 variants + 100 independent. | VALIDATED | [catalog](../04-progression-rpg/05-independent-catalog.md) |
| **Q235–Q244** | A | The 4 MVP tribes: Humans, Elves, Dwarves, Dragons with distinct tactical identities. | VALIDATED | [equipment](../02-combat-rules/12-equipment-and-tribes.md) |
| **Q245–Q249** | A | Equipment taxonomy: permanent attachment cards of type `WEAPON` or `PROTECTION`. | VALIDATED | [equipment](../02-combat-rules/12-equipment-and-tribes.md) |
| **Q250** | — | Every creature has 2 equipment slots (weapon + protection). | **SUPERSEDED by Q253** | [equipment](../02-combat-rules/12-equipment-and-tribes.md) |
| **Q251–Q252** | A | Equipment replacement discards old item; bearer death discards equipment to owner. | VALIDATED | [equipment](../02-combat-rules/12-equipment-and-tribes.md) |
| **Q253** | A | Creature equipment slots: 0, 1, or 2 slots per creature. Dragons have 0 slots. | VALIDATED | [equipment](../02-combat-rules/12-equipment-and-tribes.md) |
| **Q254** | A | No universal durability; charged equipment requires full charge payment before use. | VALIDATED | [equipment](../02-combat-rules/12-equipment-and-tribes.md) |
| **Q255–Q264** | A | 100 independent cards: 50 creatures, 30 spells, 20 equipments; cross-tribe bridge synergies. | VALIDATED | [catalog](../04-progression-rpg/05-independent-catalog.md) |
| **Q265–Q268** | A | AI tactical profiles (Balanced, Aggro, Fortified, Sniper) parameterized by weights. | VALIDATED | [encounters](../04-progression-rpg/06-enemy-encounters.md) |
| **Q269–Q270** | A | Special mission encounters introducing non-standard combat victory/defeat rules. | VALIDATED | [encounters](../04-progression-rpg/06-enemy-encounters.md) |
| **Q271** | A | Special missions strictly restricted to two families for MVP: **Protection** and **Survival**. | VALIDATED | [encounters](../04-progression-rpg/06-enemy-encounters.md) |
| **Q272–Q274** | A | Special mission constraints, protected target defeat triggers, open balance questions. | VALIDATED | [encounters](../04-progression-rpg/06-enemy-encounters.md) |

---

## 7. Lot 1 Decisions (Q275 – Q302)

| ID | Choice | Normative Summary | Status | Document |
|---|:---:|---|:---:|---|
| **Q275** | A | Mana capacity growth (+1) applies including Turn 1 (starts at 1 capacity). | VALIDATED | [turn](../02-combat-rules/02-turn-sequence-and-mana.md) |
| **Q276** | A | Human player always starts; alternate turns; only active camp submits voluntary commands. | VALIDATED | [turn](../02-combat-rules/02-turn-sequence-and-mana.md) |
| **Q277** | A | Gameplay events produced immediately by engine; visual scheduling is decoupled. | VALIDATED | [tooltips](../03-presentation-ui/03-tooltips-and-vfx.md) |
| **Q278** | A | Minimum creature max HP is 1; preserve wounds during Max HP changes; Max HP drop can kill. | VALIDATED | [healing](../02-combat-rules/06-healing-and-health.md) |
| **Q279** | A | Armor is a reusable flat reduction per damage instance; Shield is a consumable pool. | VALIDATED | [damage](../02-combat-rules/04-damage-and-protection.md) |
| **Q280** | A | Multiple shield pools consumed in order of earliest expiration, then canonical order. | VALIDATED | [damage](../02-combat-rules/04-damage-and-protection.md) |
| **Q281** | A | Armor minimum is 0; no global ceiling. | VALIDATED | [damage](../02-combat-rules/04-damage-and-protection.md) |
| **Q282** | A | Shield pools have no global ceiling. | VALIDATED | [damage](../02-combat-rules/04-damage-and-protection.md) |
| **Q283** | A | Equipment played from hand paying mana cost and targeting valid bearer. | VALIDATED | [equipment](../02-combat-rules/12-equipment-and-tribes.md) |
| **Q284** | A | Bearer's controller activates granted active abilities by default. | VALIDATED | [equipment](../02-combat-rules/12-equipment-and-tribes.md) |
| **Q285** | A | Equipment card play follows standard generic action and targeting validation. | VALIDATED | [equipment](../02-combat-rules/12-equipment-and-tribes.md) |
| **Q286** | A | Whole charge spending required; partial activation rejected. | VALIDATED | [equipment](../02-combat-rules/12-equipment-and-tribes.md) |
| **Q287** | A | Atomic transactions: prepare -> validate -> commit; rollback uncommitted operation on error. | VALIDATED | [effects](../02-combat-rules/11-effect-resolution.md) |
| **Q288** | A | Simultaneous compatible damage grouped by effective protection profile. | VALIDATED | [effects](../02-combat-rules/11-effect-resolution.md) |
| **Q289** | A | Incompatible damage profiles: common reserves consumed canonically, simultaneous HP commit. | VALIDATED | [effects](../02-combat-rules/11-effect-resolution.md) |
| **Q290** | A | Platform & Engine: Windows standalone export priority; Godot 4, typed GDScript, 2D. | VALIDATED | [lot1/scope](../01-lot1-vertical-slice/01-scope.md) |
| **Q291** | A | Resolution: 16:9 aspect ratio, 1920×1080 native reference, 1280×720 responsive. | VALIDATED | [lot1/scope](../01-lot1-vertical-slice/01-scope.md) |
| **Q292** | A | Board Layout: Immersive central board, visible heroes, bottom hand, contextual drawers. | VALIDATED | [lot1/scope](../01-lot1-vertical-slice/01-scope.md) |
| **Q293** | B | Creature Representation: Illustrated tokens on board, tooltip on hover, click inspection. | VALIDATED | [lot1/scope](../01-lot1-vertical-slice/01-scope.md) |
| **Q294** | B | Token Geometry: Fantasy crest / shield token with dominant portrait (replaces medallion). | VALIDATED | [lot1/scope](../01-lot1-vertical-slice/01-scope.md) |
| **Q295** | A | Art Direction: Semi-realistic fantasy digital painting, high tactical readability, multi-modal cues. | VALIDATED | [lot1/scope](../01-lot1-vertical-slice/01-scope.md) |
| **Q296** | B | Lot 1 Combat Core: Representative tactical core (protections, healing, simple active/passive, equip). | VALIDATED | [lot1/scope](../01-lot1-vertical-slice/01-scope.md) |
| **Q297** | B | Lot 1 Catalog Size: Exactly 16 card definitions (10 creatures, 4 spells, 2 equipments). | VALIDATED | [lot1/catalog](../01-lot1-vertical-slice/02-catalog.md) |
| **Q298** | A | Lot 1 Card Balance: Validated mini-catalog with rebalanceable `.tres` fixture parameters. | VALIDATED | [lot1/catalog](../01-lot1-vertical-slice/02-catalog.md) |
| **Q299** | B | AI Opponent: Heuristic AI scoring legal candidate actions without cheating or hidden info leaks. | VALIDATED | [lot1/scope](../01-lot1-vertical-slice/01-scope.md) |
| **Q300** | A | Data Storage: Godot typed `.tres` Resources for card and ability definitions. | VALIDATED | [lot1/catalog](../01-lot1-vertical-slice/02-catalog.md) |
| **Q301** | B | Ability Engine: Generic atomic operations library and declarative composition. | VALIDATED | [lot1/architecture_godot](../01-lot1-vertical-slice/04-architecture-godot.md) |
| **Q302** | B | Presentation Pipeline: Immediate engine resolution, decoupled juicy VFX, controlled visual sync. | VALIDATED | [lot1/scope](../01-lot1-vertical-slice/01-scope.md) |
