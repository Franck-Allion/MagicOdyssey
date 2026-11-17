class_name BattlefieldSlot
extends Panel
## Presentation coordinates only. P032 will adapt domain positions to these enums.
## Token content should leave the outer 4 px clear and use MOUSE_FILTER_IGNORE
## (or PASS for interactive descendants) so input reaches this slot.

enum Camp { PLAYER, OPPONENT }
enum Row { ATTACK, DEFENSE }
enum VisualState { IDLE, HOVERED, HIGHLIGHTED, SELECTED }

signal slot_hovered(camp: Camp, column: int, row: Row)
signal slot_unhovered(camp: Camp, column: int, row: Row)
signal slot_selected(camp: Camp, column: int, row: Row)
signal interaction_changed()

const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")

@export var camp: Camp = Camp.PLAYER:
	set(value):
		if not _identity_locked:
			camp = value
@export_range(1, 6) var column: int = 1:
	set(value):
		if not _identity_locked:
			column = value
@export var row: Row = Row.ATTACK:
	set(value):
		if not _identity_locked:
			row = value

var hovered: bool = false
var selected: bool = false
var highlighted: bool = false
var interactable: bool = true
var _identity_locked: bool = false
var _feedback: StyleBoxFlat = StyleBoxFlat.new()
var _strength: float = 0.0:
	set(value):
		_strength = value
		queue_redraw()
var _fade: Tween
var _token_anchor: Control

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	_feedback.set_corner_radius_all(12)
	_feedback.set_border_width_all(2)

func _ready() -> void:
	lock_identity()
	get_token_anchor()

func lock_identity() -> void:
	_identity_locked = true

func get_slot_identity() -> Vector3i:
	return Vector3i(camp, column, row)

static func is_valid_identity(camp_value: int, column_value: int, row_value: int) -> bool:
	return camp_value in [Camp.PLAYER, Camp.OPPONENT] and column_value >= 1 and column_value <= 6 and row_value in [Row.ATTACK, Row.DEFENSE]

func get_visual_state() -> VisualState:
	if selected:
		return VisualState.SELECTED
	if hovered:
		return VisualState.HOVERED
	if highlighted:
		return VisualState.HIGHLIGHTED
	return VisualState.IDLE

## A passive presentation anchor; child count can later express occupied state.
func get_token_anchor() -> Control:
	if _token_anchor == null:
		_token_anchor = Control.new()
		_token_anchor.name = "TokenAnchor"
		_token_anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_token_anchor)
		_token_anchor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return _token_anchor

## Selection is owned by CombatScreen. This setter only renders its decision.
func set_selected(value: bool) -> void:
	if selected == value:
		return
	selected = value
	_update_feedback()

func set_highlighted(value: bool) -> void:
	if highlighted == value:
		return
	highlighted = value
	_update_feedback()

func set_interactable(value: bool) -> void:
	if interactable == value:
		return
	interactable = value
	# STOP while disabled prevents leakage to any underlying surface.
	if not value:
		_on_mouse_exited()
	elif is_inside_tree() and get_viewport().gui_get_hovered_control() == self:
		_on_mouse_entered()
	interaction_changed.emit()

func _on_mouse_entered() -> void:
	if not interactable or hovered:
		return
	hovered = true
	_update_feedback()
	slot_hovered.emit(camp, column, row)

func _on_mouse_exited() -> void:
	if not hovered:
		return
	hovered = false
	_update_feedback()
	slot_unhovered.emit(camp, column, row)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button: InputEventMouseButton = event as InputEventMouseButton
		if interactable and button.button_index == MOUSE_BUTTON_LEFT and button.pressed:
			slot_selected.emit(camp, column, row)
			if is_inside_tree():
				accept_event()

func _update_feedback() -> void:
	var target: float = 0.0
	match get_visual_state():
		VisualState.SELECTED: target = 1.0
		VisualState.HOVERED: target = 0.55
		VisualState.HIGHLIGHTED: target = 0.32
	if _fade != null:
		_fade.kill()
	if is_inside_tree():
		_fade = create_tween()
		_fade.tween_property(self, "_strength", target, 0.10)
	else:
		_strength = target

func _draw() -> void:
	if _strength <= 0.001:
		return
	_feedback.border_color = Color(TOKENS.color_token(&"accent_bright"), _strength * 0.88)
	_feedback.bg_color = Color(TOKENS.color_token(&"accent_dim"), _strength * 0.10)
	draw_style_box(_feedback, Rect2(Vector2.ZERO, size))
