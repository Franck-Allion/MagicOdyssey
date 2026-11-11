# MagicOdyssey — Lot 1 Godot 4 Technical Architecture

**Platform:** Windows Standalone / PC  
**Engine:** Godot 4.x (Stable)  
**Language:** Fully typed GDScript  
**Rendering:** 2D Canvas (Target: 1920×1080 native 16:9, responsive down to 1280×720)

---

## 1. Architectural Philosophy: The Domain / Presentation Split

The game engine is built on a strict **hexagonal / decoupled** architecture:

```
+------------------------------------------------------------------------+
|                         PRESENTATION LAYER                             |
|  (Control nodes, Node2D, Sprites, Tweens, Particles, Audio, ViewModels)|
+------------------------------------+-----------------------------------+
                                     |
                                     | Dispatches CombatCommand
                                     | Subscribes to CombatEvents
                                     v
+------------------------------------------------------------------------+
|                          CONTROLLER ADAPTER                            |
|             (CombatPresenter, InputHandler, AIController)              |
+------------------------------------+-----------------------------------+
                                     |
                                     | Calls validate() & execute()
                                     v
+------------------------------------------------------------------------+
|                            DOMAIN ENGINE                               |
|        (Pure GDScript Objects: RefCounted, zero Node dependencies)     |
|   CombatEngine <---> CombatState <---> EffectRegistry <---> EventQueue |
+------------------------------------+-----------------------------------+
                                     |
                                     | References
                                     v
+------------------------------------------------------------------------+
|                           DATA CATALOG                                 |
|             (Godot .tres Resources: CardDefinition, etc.)              |
+------------------------------------------------------------------------+
```

### Absolute Rules
1. **No Node Dependencies in Domain:** `CombatEngine`, `CombatState`, `CombatCommand`, `CombatResult`, and `CombatEvent` inherit from `RefCounted`, never from `Node` or `Control`.
2. **Headless Executability:** The entire combat engine can run in Godot headless mode (`--headless --script tests/run_all.gd`) without opening a window, initializing audio, or loading visual nodes.
3. **Deterministic State Mutation:** State is mutated strictly within `CombatEngine.execute()`. No UI script may ever directly set `unit.hp -= 3` or `player.mana -= 1`.

---

## 2. Domain Data Structures

### 2.1 `CombatState` (`res://scripts/domain/combat_state.gd`)
```gdscript
class_name CombatState
extends RefCounted

var combat_id: StringName = &""
var rules_version: String = "2.8"
var state_revision: int = 0
var rng_seed: int = 0
var rng_state: int = 0

enum Camp { PLAYER, OPPONENT }
enum Phase { ACTION_PHASE, ATTACK_PHASE, CLEANUP_PHASE, MATCH_OVER }
enum MatchResult { IN_PROGRESS, PLAYER_VICTORY, OPPONENT_VICTORY }

var active_camp: Camp = Camp.PLAYER
var current_turn: int = 1
var current_phase: Phase = Phase.ACTION_PHASE
var match_result: MatchResult = MatchResult.IN_PROGRESS

# Players
var heroes: Dictionary = {} # Camp -> HeroState
var zones: Dictionary = {}  # Camp -> Dictionary[ZoneType, Array[CardCopy]]

# Board: 2 camps x 6 columns (0..5) x 2 rows (ATTACK=0, DEFENSE=1)
# Stored as Dictionary[StringName, BoardInstance] keyed by "camp:col:row"
var board: Dictionary = {}

# Execution queues
var event_queue: Array[CombatEvent] = []
var next_instance_sequence: int = 1000

func get_slot_key(camp: Camp, column: int, row: int) -> StringName:
    return StringName("%d:%d:%d" % [camp, column, row])
```

### 2.2 `CombatCommand` (`res://scripts/domain/combat_command.gd`)
```gdscript
class_name CombatCommand
extends RefCounted

enum ActionType {
    SUMMON,
    MOVE_UNIT,
    SWAP_UNITS,
    PLAY_SPELL,
    PLAY_EQUIPMENT,
    ACTIVATE_ABILITY,
    END_TURN
}

var actor: CombatState.Camp = CombatState.Camp.PLAYER
var action_type: ActionType = ActionType.END_TURN
var source_card_copy_id: StringName = &""
var source_instance_id: StringName = &""
var target_slot_key: StringName = &""
var target_instance_ids: Array[StringName] = []
var optional_params: Dictionary = {}
```

### 2.3 `CombatResult` and `CombatEvent`
```gdscript
class_name CombatResult
extends RefCounted

var accepted: bool = false
var rejection_code: StringName = &""
var state_revision: int = 0
var events: Array[CombatEvent] = []
var resulting_status: CombatState.MatchResult = CombatState.MatchResult.IN_PROGRESS
```

```gdscript
class_name CombatEvent
extends RefCounted

enum EventType {
    TURN_STARTED,
    MANA_RESTORED,
    CARD_DRAWN,
    CARD_DISCARDED,
    CREATURE_SUMMONED,
    CREATURE_MOVED,
    CREATURE_SWAPPED,
    ATTACK_DECLARED,
    DAMAGE_APPLIED,
    ARMOR_ABSORBED,
    SHIELD_ABSORBED,
    HEAL_APPLIED,
    EFFECT_APPLIED,
    EFFECT_EXPIRED,
    CREATURE_DIED,
    HERO_DAMAGED,
    FATIGUE_SUFFERED,
    MATCH_CONCLUDED
}

var event_type: EventType
var event_id: int
var source_id: StringName
var target_id: StringName
var amount: int = 0
var metadata: Dictionary = {}
```

---

## 3. Presentation Architecture & UI Pipeline

### 3.1 `CombatPresenter` (`res://scripts/presentation/combat_presenter.gd`)
The presenter acts as the bridge between the domain and Godot SceneTree:
1. Listens for UI user intentions (card drop, slot click, button click).
2. Constructs a `CombatCommand` and calls `CombatEngine.validate(command)`.
3. If valid, executes `CombatEngine.execute(command)`.
4. Receives `CombatResult` with ordered `CombatEvent` list.
5. Feeds events into the **Visual Event Sequencer**.
6. Updates UI view-models when events reach their presentation checkpoint.

### 3.2 Visual Event Sequencer (Decoupled VFX)
- Events are converted into visual animations (Tweens, particles).
- **Fast-Paced & Juicy:** Gameplay animations are snappy (100–350ms per action).
- **Input Unlocking:** As soon as board numbers and unit positions match the authoritative state revision, user input is re-enabled. Lingering particles or audio do not lock the player from making their next move.

---

## 4. Recommended Directory Structure

```text
res://
├── project.godot
├── icon.svg
│
├── scenes/
│   ├── combat/
│   │   ├── combat_screen.tscn        # Root combat presentation
│   │   ├── battlefield_view.tscn     # 24-slot grid view
│   │   ├── creature_token.tscn       # Fantasy crest token
│   │   └── camp_board_view.tscn      # 12-slot camp container
│   ├── cards/
│   │   ├── card_view.tscn            # Premium card rendering
│   │   ├── hand_view.tscn            # Interactive player hand
│   │   ├── card_tooltip.tscn         # Tactical tooltip
│   │   └── card_inspector.tscn       # Side inspection panel
│   ├── hud/
│   │   ├── hero_hud.tscn             # Hero HP, mana, deck counter
│   │   ├── turn_hud.tscn             # Turn counter, End Turn button
│   │   └── combat_result_overlay.tscn# Victory/Defeat screen
│   └── effects/
│       ├── combat_vfx_layer.tscn     # Floating numbers, particles
│       └── damage_number.tscn
│
├── scripts/
│   ├── domain/                       # Pure GDScript (no Node inheritance)
│   │   ├── combat_state.gd
│   │   ├── combat_engine.gd
│   │   ├── combat_command.gd
│   │   ├── combat_result.gd
│   │   ├── combat_event.gd
│   │   ├── event_queue.gd
│   │   ├── hero_state.gd
│   │   ├── board_instance.gd
│   │   └── card_copy.gd
│   ├── catalog/                      # Resource definitions & catalog
│   │   ├── card_definition.gd
│   │   ├── ability_definition.gd
│   │   ├── effect_operation.gd
│   │   ├── target_spec.gd
│   │   └── card_catalog.gd
│   ├── ai/                           # Heuristic tactical AI
│   │   ├── ai_controller.gd
│   │   ├── combat_observation.gd
│   │   └── heuristic_evaluator.gd
│   ├── presentation/                 # View controllers & adapters
│   │   ├── combat_presenter.gd
│   │   ├── visual_event_sequencer.gd
│   │   └── input_handler.gd
│   └── tests/                        # Headless test runner & assertions
│       ├── test_runner.gd
│       ├── test_asserts.gd
│       ├── test_lot1_engine.gd
│       └── test_lot1_extensibility.gd
│
├── resources/
│   ├── cards/                        # 16 .tres card definitions
│   │   ├── human_recruit.tres
│   │   ├── ...
│   │   └── equip_bastion_armor.tres
│   ├── fixtures/                     # Test fixtures and starter decks
│   │   └── default_combat_fixture.tres
│   └── themes/                       # UI fonts, styles, colors
│       └── fantasy_theme.tres
│
└── assets/                           # Visual and audio assets
    ├── textures/
    │   ├── cards/
    │   ├── tokens/
    │   ├── board/
    │   └── ui/
    └── audio/
        ├── sfx/
        └── music/
```
