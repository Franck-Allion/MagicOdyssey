# MagicOdyssey — Lot 1 Official Card Catalog (16 Cards)

**Status:** Validated baseline mini-catalog [Q297–Q298].  
**Implementation:** Declarative Godot 4 `.tres` Resources. No per-card custom code or branching scripts.

---

## 1. The 16 Official Cards

### 1.1 Creatures (10 Definitions)

All creatures define: `card_id`, `display_name`, `tribe`, `mana_cost`, `base_attack`, `base_max_hp`, `base_armor`, `equipment_slots`, and optional declarative abilities.

| `card_id` | Name | Tribe | Mana | ATK / HP / ARM | Slots | Role & Declarative Ability |
|---|---|---|---:|---|:---:|---|
| `human_recruit` | Realm Recruit | Human | 1 | 2 / 2 / 0 | 1W, 1P | Fast economic attacker. No extra ability. |
| `human_guard` | Rampart Guard | Human | 2 | 1 / 5 / 1 | 1W, 1P | Early defense. Native Armor 1 `[CONFIG]`. |
| `human_knight` | Oathbound Knight | Human | 4 | 4 / 5 / 0 | 1W, 1P | Versatile frontline. Passive: `+1 ATK` while in `ATTACK` row `[PROPOSAL]`. |
| `elf_archer` | Sylvan Archer | Elf | 2 | 3 / 2 / 0 | 1W, 1P | Fragile high-damage striker. No extra ability. |
| `elf_healer` | Woodland Healer | Elf | 3 | 1 / 4 / 0 | 1W, 1P | Support backline. Active: Pay 1 mana $\rightarrow$ Heal 2 HP to an allied creature `[CONFIG]`. |
| `elf_sentinel` | Mist Sentinel | Elf | 4 | 3 / 5 / 0 | 1W, 1P | Defensive lane anchor. Passive: `+1 Armor` while in `DEFENSE` row `[PROPOSAL]`. |
| `dwarf_guardian` | Iron Guardian | Dwarf | 2 | 2 / 4 / 1 | 1W, 1P | Resilient defender. Native Armor 1 `[CONFIG]`. |
| `dwarf_runecrafter` | Rune Crafter | Dwarf | 4 | 3 / 5 / 0 | 1W, 1P | Fortification support. Triggered `ON_SUMMON`: Grant `+2 Shield` to self `[PROPOSAL]`. |
| `dragon_whelp` | Ember Whelp | Dragon | 3 | 4 / 3 / 0 | **0 Slots** | Aggressive airborne threat. Cannot equip items [Q253]. |
| `dragon_drake` | Ancestral Drake | Dragon | 6 | 7 / 7 / 0 | **0 Slots** | Late-game colossal finisher. Cannot equip items [Q253]. |

*Note on Equipment Slots:* Dragons possess **0 equipment slots** [Q253]. Humans, Elves, and Dwarves have 2 slots: 1 Weapon (`WEAPON`) and 1 Protection (`PROTECTION`).

---

### 1.2 Spells (4 Definitions)

All spells are played from hand, spend mana, validate targets, and execute atomic operations.

| `card_id` | Name | Mana | Target Specification | Declarative Operation |
|---|---|---:|---|---|
| `spell_fireball` | Fireball | 3 | 1 Enemy Creature | `DAMAGE(amount=4)` |
| `spell_heal` | Mending Light | 2 | 1 Allied Creature | `HEAL(amount=3)` |
| `spell_barrier` | Arcane Barrier | 2 | 1 Allied Creature | `ADD_SHIELD(amount=3, duration=PERMANENT)` |
| `spell_blessing` | Martial Blessing | 2 | 1 Allied Creature | `MODIFY_STAT(stat=ATK, value=+2, duration=UNTIL_TURN_END)` |

---

### 1.3 Equipments (2 Definitions)

Equipments attach to an eligible board creature occupying an open slot. Replacing an item discards the previous one [Q252].

| `card_id` | Name | Mana | Slot Category | Modifier / Effect |
|---|---|---:|:---:|---|
| `equip_runic_blade` | Runic Blade | 2 | `WEAPON` | `MODIFY_STAT(stat=ATK, value=+2, duration=WHILE_EQUIPPED)` |
| `equip_bastion_armor` | Bastion Armor | 3 | `PROTECTION` | `MODIFY_STAT(stat=ARMOR, value=+2, duration=WHILE_EQUIPPED)` |

---

## 2. Godot 4 Typed Resource Schemas

### 2.1 `CardDefinition.gd` (`res://scripts/catalog/card_definition.gd`)
```gdscript
class_name CardDefinition
extends Resource

enum CardType { CREATURE, SPELL, EQUIPMENT }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }
enum Tribe { NONE, HUMAN, ELF, DWARF, DRAGON }
enum SlotType { WEAPON, PROTECTION }

@export var definition_id: StringName = &""
@export var display_name: String = ""
@export var card_type: CardType = CardType.CREATURE
@export var rarity: Rarity = Rarity.COMMON
@export var tribe: Tribe = Tribe.NONE
@export_range(0, 20) var mana_cost: int = 1

# Creature specific stats
@export var base_attack: int = 0
@export var base_max_hp: int = 1
@export var base_armor: int = 0
@export var allowed_slots: Array[SlotType] = []

# Spell & Equipment specifics
@export var target_spec: TargetSpec = null
@export var abilities: Array[AbilityDefinition] = []

# Visual / Presentation Metadata
@export var illustration: Texture2D = null
@export var frame_style: StringName = &"standard"
```

### 2.2 `AbilityDefinition.gd` (`res://scripts/catalog/ability_definition.gd`)
```gdscript
class_name AbilityDefinition
extends Resource

enum AbilityMode { PASSIVE, ACTIVE, TRIGGERED }

@export var mode: AbilityMode = AbilityMode.PASSIVE
@export var activation_cost_mana: int = 0
@export var trigger_event: StringName = &"" # e.g. &"ON_SUMMON", &"ON_DEATH"
@export var target_spec: TargetSpec = null
@export var condition: ConditionSpec = null # e.g. row == ATTACK
@export var operations: Array[EffectOperation] = []
```

### 2.3 `EffectOperation.gd` (`res://scripts/catalog/effect_operation.gd`)
```gdscript
class_name EffectOperation
extends Resource

enum OpCode {
    DAMAGE,
    HEAL,
    ADD_SHIELD,
    MODIFY_STAT,
    EQUIP,
    UNEQUIP,
    SUMMON,
    MOVE_CARD_ZONE
}

enum StatType { ATK, HP_MAX, ARMOR }
enum DurationType { PERMANENT, UNTIL_TURN_END, WHILE_EQUIPPED, WHILE_CONDITION_MET }

@export var op_code: OpCode = OpCode.DAMAGE
@export var int_value: int = 0
@export var stat_type: StatType = StatType.ATK
@export var duration_type: DurationType = DurationType.PERMANENT
```

---

## 3. Deck Composition Fixture (40-Card Legal Deck)

Both players use a 40-card deck constructed strictly within the rule of **maximum 4 copies per definition** [Q207–Q209]:

| Card Definition | Type | Quantity in Deck | Cumulative Total |
|---|:---:|:---:|:---:|
| `human_recruit` | Creature | 4 | 4 |
| `human_guard` | Creature | 3 | 7 |
| `human_knight` | Creature | 2 | 9 |
| `elf_archer` | Creature | 4 | 13 |
| `elf_healer` | Creature | 3 | 16 |
| `elf_sentinel` | Creature | 2 | 18 |
| `dwarf_guardian` | Creature | 3 | 21 |
| `dwarf_runecrafter` | Creature | 2 | 23 |
| `dragon_whelp` | Creature | 3 | 26 |
| `dragon_drake` | Creature | 1 | 27 |
| `spell_fireball` | Spell | 3 | 30 |
| `spell_heal` | Spell | 3 | 33 |
| `spell_barrier` | Spell | 2 | 35 |
| `spell_blessing` | Spell | 2 | 37 |
| `equip_runic_blade` | Equipment | 2 | 39 |
| `equip_bastion_armor` | Equipment | 1 | **40** |
