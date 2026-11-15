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
