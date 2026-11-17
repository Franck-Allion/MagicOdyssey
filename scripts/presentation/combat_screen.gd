class_name CombatScreen
extends Control
## Root presentation scene for MagicOdyssey tactical combat (P005).
## Composes the 2D tactical battlefield, hero zones, hand area, and action bar.
## Prepares responsive layout and clean injection points for:
##   - P006: 24 Board Slots
##   - P007: Hero & Turn HUDs
##   - P008: CreatureToken (crest tokens)
##   - P009: CardView & HandView
##   - P010: Tooltip & Inspector Panel
## Strictly presentation-only: no domain rules, card catalogs, or state mutations.

const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")
const REFERENCE_SIZE: Vector2 = Vector2(1920, 1080)

signal slot_hovered(camp: BattlefieldSlot.Camp, column: int, row: BattlefieldSlot.Row)
signal slot_unhovered(camp: BattlefieldSlot.Camp, column: int, row: BattlefieldSlot.Row)
signal slot_selected(camp: BattlefieldSlot.Camp, column: int, row: BattlefieldSlot.Row)
signal slot_selection_changed(slot: BattlefieldSlot)

var _slots: Dictionary[Vector3i, BattlefieldSlot] = {}
var _slots_initialized: bool = false
var _selected_slot: BattlefieldSlot

## Node references to authoritative presentation regions
@onready var background_layer: Control = $BackgroundLayer
@onready var battlefield_environment: TextureRect = $BackgroundLayer/BattlefieldEnvironment
@onready var atmospheric_overlay: ColorRect = $BackgroundLayer/AtmosphericOverlay

@onready var combat_layout: Control = $CombatLayout
@onready var match_header: Panel = $CombatLayout/MatchHeader
@onready var opponent_hero_zone: Panel = $CombatLayout/OpponentHeroZone
@onready var match_status: Panel = $CombatLayout/MatchStatus

@onready var battlefield_zone: Panel = $CombatLayout/BattlefieldZone
@onready var opponent_board_area: Control = $CombatLayout/BattlefieldZone/OpponentBoardArea
@onready var opponent_defense_row: Control = $CombatLayout/BattlefieldZone/OpponentBoardArea/OpponentDefenseRow
@onready var opponent_attack_row: Control = $CombatLayout/BattlefieldZone/OpponentBoardArea/OpponentAttackRow
@onready var center_divider_area: Control = $CombatLayout/BattlefieldZone/CenterDividerArea
@onready var player_board_area: Control = $CombatLayout/BattlefieldZone/PlayerBoardArea
@onready var player_attack_row: Control = $CombatLayout/BattlefieldZone/PlayerBoardArea/PlayerAttackRow
@onready var player_defense_row: Control = $CombatLayout/BattlefieldZone/PlayerBoardArea/PlayerDefenseRow

@onready var player_hero_zone: Panel = $CombatLayout/PlayerHeroZone
@onready var player_hand_zone: Panel = $CombatLayout/PlayerHandZone
@onready var action_bar_zone: Panel = $CombatLayout/ActionBarZone
@onready var end_turn_button: Button = $CombatLayout/ActionBarZone/EndTurnButton

@onready var overlay_layer: Control = $OverlayLayer

func _ready() -> void:
	if theme == null:
		theme = TOKENS.THEME
	resized.connect(_apply_responsive_layout)
	_apply_responsive_layout()
	_connect_opponent_resource_labels()
	_setup_utility_hud()
	_initialize_slots()

## One registry, built in visual top-to-bottom, left-to-right order.
## Invalid scene configuration fails closed; no partial board can be selected.
func _initialize_slots() -> void:
	if _slots_initialized:
		return
	_slots_initialized = true
	var rows: Array[Control] = [get_opponent_defense_row(), get_opponent_attack_row(), get_player_attack_row(), get_player_defense_row()]
	var candidates: Dictionary[Vector3i, BattlefieldSlot] = {}
	for index: int in range(rows.size()):
		var row_node: Control = rows[index]
		if row_node == null:
			push_error("P006: Missing battlefield row %d" % index)
			return
		var count: int = 0
		for child: Node in row_node.get_children():
			if not child.name.begins_with("SlotGuide_"):
				continue
			var slot: BattlefieldSlot = child as BattlefieldSlot
			if slot == null:
				push_error("P006: Missing BattlefieldSlot script on %s" % child.name)
				return
			count += 1
			var expected_camp: BattlefieldSlot.Camp = BattlefieldSlot.Camp.OPPONENT if index < 2 else BattlefieldSlot.Camp.PLAYER
			var expected_row: BattlefieldSlot.Row = BattlefieldSlot.Row.DEFENSE if index in [0, 3] else BattlefieldSlot.Row.ATTACK
			var identity: Vector3i = slot.get_slot_identity()
			if not BattlefieldSlot.is_valid_identity(identity.x, identity.y, identity.z) or candidates.has(identity):
				push_error("P006: Invalid or duplicate slot identity %s at %s" % [identity, slot.name])
				return
			if slot.camp != expected_camp or slot.row != expected_row or slot.column != count or slot.name != StringName("SlotGuide_%02d" % count):
				push_error("P006: Slot identity does not match visual position: %s" % slot.name)
				return
			candidates[identity] = slot
		if count != 6:
			push_error("P006: Expected six slots in %s, found %d" % [row_node.name, count])
			return
	_slots = candidates
	for slot: BattlefieldSlot in _slots.values():
		slot.lock_identity()
		slot.slot_hovered.connect(_on_slot_hovered)
		slot.slot_unhovered.connect(_on_slot_unhovered)
		slot.slot_selected.connect(_on_slot_selected)
		slot.interaction_changed.connect(_on_slot_interaction_changed.bind(slot))

## Invalid coordinates return null, including values outside the enum ranges.
func get_slot(camp: BattlefieldSlot.Camp, column: int, row: BattlefieldSlot.Row) -> BattlefieldSlot:
	_initialize_slots()
	return _slots.get(Vector3i(camp, column, row)) as BattlefieldSlot

func get_slots() -> Array[BattlefieldSlot]:
	_initialize_slots()
	var result: Array[BattlefieldSlot] = []
	result.assign(_slots.values())
	return result

func get_selected_slot() -> BattlefieldSlot:
	return _selected_slot

func clear_slot_selection() -> void:
	if _selected_slot == null:
		return
	_selected_slot.set_selected(false)
	_selected_slot = null
	slot_selection_changed.emit(null)

func select_slot(camp: BattlefieldSlot.Camp, column: int, row: BattlefieldSlot.Row) -> bool:
	var slot: BattlefieldSlot = get_slot(camp, column, row)
	if slot == null or not slot.interactable:
		return false
	if _selected_slot == slot:
		return true
	if _selected_slot != null:
		_selected_slot.set_selected(false)
	_selected_slot = slot
	slot.set_selected(true)
	slot_selection_changed.emit(slot)
	return true

func set_slot_highlight(camp: BattlefieldSlot.Camp, column: int, row: BattlefieldSlot.Row, value: bool) -> bool:
	var slot: BattlefieldSlot = get_slot(camp, column, row)
	if slot == null:
		return false
	slot.set_highlighted(value)
	return true

func clear_slot_highlights() -> void:
	for slot: BattlefieldSlot in get_slots():
		slot.set_highlighted(false)

func set_slot_interaction_enabled(value: bool) -> void:
	for slot: BattlefieldSlot in get_slots():
		slot.set_interactable(value)

func _on_slot_interaction_changed(slot: BattlefieldSlot) -> void:
	if not slot.interactable and _selected_slot == slot:
		clear_slot_selection()

func _on_slot_hovered(camp: BattlefieldSlot.Camp, column: int, row: BattlefieldSlot.Row) -> void:
	slot_hovered.emit(camp, column, row)

func _on_slot_unhovered(camp: BattlefieldSlot.Camp, column: int, row: BattlefieldSlot.Row) -> void:
	slot_unhovered.emit(camp, column, row)

func _on_slot_selected(camp: BattlefieldSlot.Camp, column: int, row: BattlefieldSlot.Row) -> void:
	var slot: BattlefieldSlot = get_slot(camp, column, row)
	if slot == null or not slot.interactable:
		return
	if slot == _selected_slot:
		clear_slot_selection()
	else:
		select_slot(camp, column, row)
	slot_selected.emit(camp, column, row)

func _setup_utility_hud() -> void:
	for label: Label in [get_match_status().get_node("Phase"), get_action_bar_zone().get_node("RecentActions")]:
		label.add_theme_color_override("font_color", TOKENS.color_token(&"secondary"))
	(get_action_bar_zone().get_node("RecentTitle") as Label).add_theme_color_override("font_color", TOKENS.color_token(&"text_bright"))
	set_turn_preview("TURN 01", "PLAYER  /  ACTION")

## Text-only presentation injection. Never advances a turn.
func set_turn_preview(turn_text: String, phase_text: String) -> void:
	(get_match_status().get_node("Turn") as Label).text = turn_text
	(get_match_status().get_node("Phase") as Label).text = phase_text

func set_recent_actions_preview(entries: Array[String]) -> void:
	(get_action_bar_zone().get_node("RecentActions") as Label).text = "Awaiting first action..." if entries.is_empty() else "\n".join(entries.slice(0, 3))

func get_player_deck() -> DeckStackView:
	return get_node("CombatLayout/ActionBarZone/DeckStack") as DeckStackView

func get_opponent_deck() -> DeckStackView:
	return get_node("CombatLayout/OpponentPiles/DeckStack") as DeckStackView

func get_player_graveyard() -> GraveyardView:
	return get_node("CombatLayout/ActionBarZone/GraveyardView") as GraveyardView

func get_opponent_graveyard() -> GraveyardView:
	return get_node("CombatLayout/OpponentPiles/GraveyardView") as GraveyardView

func _connect_opponent_resource_labels() -> void:
	var health: LiquidResourceOrb = get_opponent_health_orb()
	var mana: LiquidResourceOrb = get_opponent_mana_orb()
	if not health.resource_values_changed.is_connected(_update_opponent_health_label):
		health.resource_values_changed.connect(_update_opponent_health_label)
	if not mana.resource_values_changed.is_connected(_update_opponent_mana_label):
		mana.resource_values_changed.connect(_update_opponent_mana_label)
	_update_opponent_health_label(health.current_value, health.maximum_value)
	_update_opponent_mana_label(mana.current_value, mana.maximum_value)

func _update_opponent_health_label(current: int, maximum: int) -> void:
	(get_opponent_hero_zone().get_node("HealthValues") as Label).text = "%d / %d" % [current, maximum]

func _update_opponent_mana_label(current: int, maximum: int) -> void:
	(get_opponent_hero_zone().get_node("ManaValues") as Label).text = "%d / %d" % [current, maximum]

## Responsive layout management
## Scales and centers the combat layout proportionally while background & overlay fill viewport.
func _apply_responsive_layout() -> void:
	var layout: Control = get_combat_layout()
	if not is_instance_valid(layout):
		return
	var factor: float = minf(size.x / REFERENCE_SIZE.x, size.y / REFERENCE_SIZE.y)
	layout.size = REFERENCE_SIZE
	layout.scale = Vector2.ONE * factor
	layout.position = ((size - REFERENCE_SIZE * factor) * 0.5).round()

## Public typed accessors for P006–P010 integration (resilient before and after _ready)
func get_combat_layout() -> Control:
	if combat_layout != null:
		return combat_layout
	return get_node_or_null("CombatLayout") as Control

func get_background_layer() -> Control:
	if background_layer != null:
		return background_layer
	return get_node_or_null("BackgroundLayer") as Control

func get_battlefield_environment() -> TextureRect:
	if battlefield_environment != null:
		return battlefield_environment
	return get_node_or_null("BackgroundLayer/BattlefieldEnvironment") as TextureRect

func get_atmospheric_overlay() -> ColorRect:
	if atmospheric_overlay != null:
		return atmospheric_overlay
	return get_node_or_null("BackgroundLayer/AtmosphericOverlay") as ColorRect

func get_match_header() -> Panel:
	if match_header != null:
		return match_header
	return get_node_or_null("CombatLayout/MatchHeader") as Panel

func get_opponent_hero_zone() -> Panel:
	if opponent_hero_zone != null:
		return opponent_hero_zone
	return get_node_or_null("CombatLayout/OpponentHeroZone") as Panel

func get_match_status() -> Panel:
	if match_status != null:
		return match_status
	return get_node_or_null("CombatLayout/MatchStatus") as Panel

func get_battlefield_zone() -> Panel:
	if battlefield_zone != null:
		return battlefield_zone
	return get_node_or_null("CombatLayout/BattlefieldZone") as Panel

func get_opponent_board_area() -> Control:
	if opponent_board_area != null:
		return opponent_board_area
	return get_node_or_null("CombatLayout/BattlefieldZone/OpponentBoardArea") as Control

func get_opponent_defense_row() -> Control:
	if opponent_defense_row != null:
		return opponent_defense_row
	return get_node_or_null("CombatLayout/BattlefieldZone/OpponentBoardArea/OpponentDefenseRow") as Control

func get_opponent_attack_row() -> Control:
	if opponent_attack_row != null:
		return opponent_attack_row
	return get_node_or_null("CombatLayout/BattlefieldZone/OpponentBoardArea/OpponentAttackRow") as Control

func get_center_divider_area() -> Control:
	if center_divider_area != null:
		return center_divider_area
	return get_node_or_null("CombatLayout/BattlefieldZone/CenterDividerArea") as Control

func get_player_board_area() -> Control:
	if player_board_area != null:
		return player_board_area
	return get_node_or_null("CombatLayout/BattlefieldZone/PlayerBoardArea") as Control

func get_player_attack_row() -> Control:
	if player_attack_row != null:
		return player_attack_row
	return get_node_or_null("CombatLayout/BattlefieldZone/PlayerBoardArea/PlayerAttackRow") as Control

func get_player_defense_row() -> Control:
	if player_defense_row != null:
		return player_defense_row
	return get_node_or_null("CombatLayout/BattlefieldZone/PlayerBoardArea/PlayerDefenseRow") as Control

func get_player_hero_zone() -> Panel:
	if player_hero_zone != null:
		return player_hero_zone
	return get_node_or_null("CombatLayout/PlayerHeroZone") as Panel

func get_player_hand_zone() -> Panel:
	if player_hand_zone != null:
		return player_hand_zone
	return get_node_or_null("CombatLayout/PlayerHandZone") as Panel

func get_action_bar_zone() -> Panel:
	if action_bar_zone != null:
		return action_bar_zone
	return get_node_or_null("CombatLayout/ActionBarZone") as Panel

func get_end_turn_button() -> Button:
	if end_turn_button != null:
		return end_turn_button
	return get_node_or_null("CombatLayout/ActionBarZone/EndTurnButton") as Button

func get_overlay_layer() -> Control:
	if overlay_layer != null:
		return overlay_layer
	return get_node_or_null("OverlayLayer") as Control

## P005-R01 presentation injection points. No domain dependencies.
func get_player_health_orb() -> LiquidResourceOrb:
	return get_node("CombatLayout/PlayerHeroZone/PlayerHealthOrb") as LiquidResourceOrb

func get_player_mana_orb() -> LiquidResourceOrb:
	return get_node("CombatLayout/PlayerHeroZone/PlayerManaOrb") as LiquidResourceOrb

func get_opponent_health_orb() -> LiquidResourceOrb:
	return get_node("CombatLayout/OpponentHeroZone/OpponentHealthOrb") as LiquidResourceOrb

func get_opponent_mana_orb() -> LiquidResourceOrb:
	return get_node("CombatLayout/OpponentHeroZone/OpponentManaOrb") as LiquidResourceOrb
