class_name TestBattlefieldSlots
extends RefCounted

const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
var _enters: int = 0
var _leaves: int = 0
var _clicks: int = 0
var _changes: int = 0
var _last_identity: Vector3i

func run_suite(asserts: TestAsserts, _failure_mode: bool = false) -> void:
	asserts.set_current_test("P006: identity, routing, selection and feedback")
	var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
	var slots: Array[BattlefieldSlot] = screen.get_slots()
	asserts.assert_equal(slots.size(), 24, "Exactly 24 components")
	var identities: Dictionary[Vector3i, bool] = {}
	for slot: BattlefieldSlot in slots:
		var identity: Vector3i = slot.get_slot_identity()
		asserts.assert_false(identities.has(identity), "No duplicate identity")
		identities[identity] = true
		asserts.assert_equal(screen.get_slot(slot.camp, slot.column, slot.row), slot, "Identity resolves to original guide")
		asserts.assert_equal(slot.size, Vector2(162, 112), "Protected reference size")
		asserts.assert_equal(slot.position.x, 160.0 + (slot.column - 1) * 180.0, "Protected column spacing and ordering")
		asserts.assert_equal(slot.get_visual_state(), BattlefieldSlot.VisualState.IDLE, "Initially idle")
		asserts.assert_equal(slot.get_theme_stylebox("panel").bg_color, Color(0.045, 0.065, 0.095, 0.42), "Approved idle style remains untouched")
		asserts.assert_equal(slot.get_token_anchor().mouse_filter, Control.MOUSE_FILTER_IGNORE, "Future token anchor does not intercept input")
		asserts.assert_equal(slot.get_token_anchor().get_child_count(), 0, "No placeholder creature")
		var old_column: int = slot.column
		slot.column = 6 if old_column == 1 else 1
		asserts.assert_equal(slot.column, old_column, "Identity is locked after registration")
	for camp: BattlefieldSlot.Camp in [BattlefieldSlot.Camp.PLAYER, BattlefieldSlot.Camp.OPPONENT]:
		for row: BattlefieldSlot.Row in [BattlefieldSlot.Row.ATTACK, BattlefieldSlot.Row.DEFENSE]:
			for column: int in range(1, 7):
				asserts.assert_true(screen.get_slot(camp, column, row) != null, "Complete coordinate product")
	asserts.assert_equal(identities.size(), 24, "24 unique identities")
	for invalid: Vector3i in [Vector3i(-1, 1, 0), Vector3i(2, 1, 0), Vector3i(0, 0, 0), Vector3i(0, 7, 0), Vector3i(0, 1, -1), Vector3i(0, 1, 2)]:
		asserts.assert_false(BattlefieldSlot.is_valid_identity(invalid.x, invalid.y, invalid.z), "Invalid coordinates rejected")
		asserts.assert_equal(screen.get_slot(invalid.x as BattlefieldSlot.Camp, invalid.y, invalid.z as BattlefieldSlot.Row), null, "Invalid lookup returns null")
		asserts.assert_false(screen.select_slot(invalid.x as BattlefieldSlot.Camp, invalid.y, invalid.z as BattlefieldSlot.Row), "Invalid selection rejected")
		asserts.assert_false(screen.set_slot_highlight(invalid.x as BattlefieldSlot.Camp, invalid.y, invalid.z as BattlefieldSlot.Row, true), "Invalid highlight rejected")
	var copy: Array[BattlefieldSlot] = screen.get_slots()
	copy.clear()
	asserts.assert_equal(screen.get_slots().size(), 24, "Iteration copy cannot erase registry")
	screen.slot_hovered.connect(_on_enter)
	screen.slot_unhovered.connect(_on_leave)
	screen.slot_selected.connect(_on_click)
	screen.slot_selection_changed.connect(_on_change)
	# Repeated getter calls must not reconnect signal relays.
	screen.get_slots()
	var first: BattlefieldSlot = slots[0]
	var last: BattlefieldSlot = slots[23]
	first.mouse_entered.emit()
	first.mouse_entered.emit()
	asserts.assert_equal(_enters, 1, "Hover emitted once")
	asserts.assert_equal(_last_identity, first.get_slot_identity(), "Signal carries typed identity")
	asserts.assert_true(first.hovered, "Hover enter state")
	asserts.assert_equal(first.get_visual_state(), BattlefieldSlot.VisualState.HOVERED, "Hover feedback")
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	first.gui_input.emit(click)
	asserts.assert_equal(screen.get_selected_slot(), first, "Left click selects")
	asserts.assert_equal(_clicks, 1, "One click signal")
	asserts.assert_equal(_changes, 1, "One selection change")
	asserts.assert_equal(first.get_visual_state(), BattlefieldSlot.VisualState.SELECTED, "Selected dominates hover")
	first.mouse_exited.emit()
	first.mouse_exited.emit()
	asserts.assert_equal(_leaves, 1, "Unhover emitted once")
	asserts.assert_false(first.hovered, "Hover leave state")
	asserts.assert_true(first.selected, "Selection persists after leave")
	last.gui_input.emit(click)
	asserts.assert_equal(screen.get_selected_slot(), last, "Selection switches")
	asserts.assert_false(first.selected, "Previous selected clears")
	asserts.assert_equal(first.get_visual_state(), BattlefieldSlot.VisualState.IDLE, "Previous style restored")
	last.gui_input.emit(click)
	asserts.assert_equal(screen.get_selected_slot(), null, "Repeated click toggles off")
	asserts.assert_equal(_clicks, 3, "One signal per click")
	screen.select_slot(first.camp, first.column, first.row)
	screen.clear_slot_selection()
	var changes_before: int = _changes
	screen.clear_slot_selection()
	asserts.assert_equal(_changes, changes_before, "Repeated clear is silent")
	asserts.assert_false(first.selected, "Programmatic clear")
	screen.set_slot_highlight(first.camp, first.column, first.row, true)
	asserts.assert_equal(first.get_visual_state(), BattlefieldSlot.VisualState.HIGHLIGHTED, "Passive highlight")
	first.mouse_entered.emit()
	asserts.assert_equal(first.get_visual_state(), BattlefieldSlot.VisualState.HOVERED, "Hover is distinct from highlight")
	first.mouse_exited.emit()
	asserts.assert_equal(first.get_visual_state(), BattlefieldSlot.VisualState.HIGHLIGHTED, "Highlight restored after leave")
	screen.clear_slot_highlights()
	asserts.assert_equal(first.get_visual_state(), BattlefieldSlot.VisualState.IDLE, "Clear highlights restores idle")
	var clicks_before: int = _clicks
	for button: int in [MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
		click.button_index = button
		first.gui_input.emit(click)
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = false
	first.gui_input.emit(click)
	asserts.assert_equal(_clicks, clicks_before, "Right, middle and release do not select")
	click.pressed = true
	click.double_click = true
	first.gui_input.emit(click)
	asserts.assert_equal(_clicks, clicks_before + 1, "Double-click press emits once, like every left press")
	asserts.assert_equal(screen.get_selected_slot(), first, "Double-click press selects normally")
	click.double_click = false
	clicks_before = _clicks
	screen.select_slot(first.camp, first.column, first.row)
	first.mouse_entered.emit()
	first.set_interactable(false)
	asserts.assert_equal(screen.get_selected_slot(), null, "Disabling selected slot clears selection")
	asserts.assert_false(first.hovered, "Disable clears transient hover")
	var enters_before: int = _enters
	first.mouse_entered.emit()
	first.gui_input.emit(click)
	asserts.assert_equal(_enters, enters_before, "Disabled slot ignores hover")
	asserts.assert_equal(_clicks, clicks_before, "Disabled slot ignores click")
	asserts.assert_false(screen.select_slot(first.camp, first.column, first.row), "Disabled programmatic selection rejected")
	screen.set_slot_interaction_enabled(false)
	for slot: BattlefieldSlot in slots:
		asserts.assert_false(slot.interactable, "Whole board disabled")
	screen.set_slot_interaction_enabled(true)
	for slot: BattlefieldSlot in slots:
		asserts.assert_true(slot.interactable, "Whole board re-enabled")
	for dim: Vector2 in [Vector2(1920, 1080), Vector2(1280, 720)]:
		screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
		screen.size = dim
		screen._apply_responsive_layout()
		for slot: BattlefieldSlot in slots:
			asserts.assert_equal(screen.get_slot(slot.camp, slot.column, slot.row), slot, "Stable identity after scaling")
			var transform: Transform2D = slot.get_transform()
			var parent: Node = slot.get_parent()
			while parent is Control and parent != screen:
				transform = (parent as Control).get_transform() * transform
				parent = parent.get_parent()
			var rect: Rect2 = transform * Rect2(Vector2.ZERO, slot.size)
			asserts.assert_true(Rect2(Vector2.ZERO, dim).encloses(rect), "Scaled surface remains inside viewport")
			slot.gui_input.emit(click)
			asserts.assert_equal(screen.get_selected_slot(), slot, "Scaled selection routes correctly")
	screen.free()

func _on_enter(camp: BattlefieldSlot.Camp, column: int, row: BattlefieldSlot.Row) -> void:
	_enters += 1
	_last_identity = Vector3i(camp, column, row)

func _on_leave(_camp: BattlefieldSlot.Camp, _column: int, _row: BattlefieldSlot.Row) -> void:
	_leaves += 1

func _on_click(_camp: BattlefieldSlot.Camp, _column: int, _row: BattlefieldSlot.Row) -> void:
	_clicks += 1

func _on_change(_slot: BattlefieldSlot) -> void:
	_changes += 1
