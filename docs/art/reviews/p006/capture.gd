extends SceneTree
## Real GPU rendering + engine-injected pointer events. OS pointer proof is
## produced separately by playtest_windows_p006.ps1, never by emitted signals.
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const OUT: String = "res://docs/art/reviews/p006/"
var checks: TestAsserts = TestAsserts.new()
var observations: Dictionary[String, Variant] = {}
var clicks: int = 0
var enters: int = 0
var leaves: int = 0
var button_presses: int = 0

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		quit(2)
		return
	observations["gpu"] = RenderingServer.get_video_adapter_name()
	observations["engine"] = Engine.get_version_info().string
	observations["input"] = "SubViewport.push_input; not OS pointer"
	for dim: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		await _resolution(dim)
	observations["assertions"] = checks.get_summary()
	var file: FileAccess = FileAccess.open(OUT + "observations.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(observations, "  "))
	print("P006_GPU_CHECKS=%d FAILURES=%d" % [checks.passed_count, checks.failed_count])
	quit(0 if checks.failed_count == 0 else 1)

func _motion(vp: SubViewport, point: Vector2) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = point
	event.global_position = point
	vp.push_input(event, true)
	await process_frame

func _click(vp: SubViewport, point: Vector2) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = point
		event.global_position = point
		vp.push_input(event, true)
		await process_frame

func _image(vp: SubViewport) -> Image:
	await create_timer(0.16).timeout
	await RenderingServer.frame_post_draw
	return vp.get_texture().get_image()

func _save(vp: SubViewport, filename: String) -> Image:
	var img: Image = await _image(vp)
	checks.assert_equal(img.save_png(OUT + filename), OK, "Capture " + filename)
	return img

func _resolution(dim: Vector2i) -> void:
	checks.set_current_test("P006_GPU_%dp" % dim.y)
	var vp: SubViewport = SubViewport.new()
	vp.size = dim
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
	screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
	screen.size = Vector2(dim)
	vp.add_child(screen)
	var fan: CombatPreviewCards = screen.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
	var initial_mana: int = screen.get_player_mana_orb().current_value
	for orb: LiquidResourceOrb in [screen.get_player_health_orb(), screen.get_player_mana_orb(), screen.get_opponent_health_orb(), screen.get_opponent_mana_orb()]:
		orb.set_animation_enabled(false)
	screen.slot_selected.connect(func(_c: BattlefieldSlot.Camp, _n: int, _r: BattlefieldSlot.Row) -> void: clicks += 1)
	screen.slot_hovered.connect(func(_c: BattlefieldSlot.Camp, _n: int, _r: BattlefieldSlot.Row) -> void: enters += 1)
	screen.slot_unhovered.connect(func(_c: BattlefieldSlot.Camp, _n: int, _r: BattlefieldSlot.Row) -> void: leaves += 1)
	screen.get_end_turn_button().pressed.connect(func() -> void: button_presses += 1)
	await process_frame
	await process_frame
	var factor: float = float(dim.y) / 1080.0
	var idle: Image = await _save(vp, "board_idle_%dp.png" % dim.y)
	await _save(vp, "full_combat_after_p006_%dp.png" % dim.y)
	# Measured P005 reference: static orbs and the standard seven-card hand.
	var baseline: Image = Image.load_from_file("res://docs/art/reviews/p005-r09c/final_combat_%dp.png" % dim.y)
	var different: int = 0
	if idle.get_data() != baseline.get_data():
		for y: int in range(dim.y):
			for x: int in range(dim.x):
				if idle.get_pixel(x, y) != baseline.get_pixel(x, y):
					different += 1
	observations["idle_p005_differing_pixels_%dp" % dim.y] = different
	checks.assert_equal(different, 0, "Approved P005 idle pixels preserved")
	# All 24 surfaces including the eight row/column extremes, through GUI picking.
	var before_clicks: int = clicks
	var before_enters: int = enters
	var before_leaves: int = leaves
	for slot: BattlefieldSlot in screen.get_slots():
		var center: Vector2 = slot.get_global_rect().get_center()
		await _motion(vp, center)
		checks.assert_equal(vp.gui_get_hovered_control(), slot, "GUI picks " + str(slot.get_slot_identity()))
		checks.assert_true(slot.hovered, "Pointer hover state")
		await _click(vp, center)
		checks.assert_equal(screen.get_selected_slot(), slot, "Pointer selects identity")
		checks.assert_true(slot.selected, "Persistent selected state")
	await _motion(vp, Vector2(960, 500) * factor)
	checks.assert_equal(clicks - before_clicks, 24, "Exactly 24 routed clicks")
	checks.assert_equal(enters - before_enters, 24, "Exactly 24 hover enters")
	checks.assert_equal(leaves - before_leaves, 24, "Exactly 24 hover leaves")
	screen.clear_slot_selection()
	for identity: Vector3i in [Vector3i(0, 3, 0), Vector3i(1, 1, 1)]:
		var slot: BattlefieldSlot = screen.get_slot(identity.x as BattlefieldSlot.Camp, identity.y, identity.z as BattlefieldSlot.Row)
		var label: String = "player_attack" if identity.x == 0 else "opponent_defense"
		await _motion(vp, slot.get_global_rect().get_center())
		var hover: Image = await _save(vp, "board_hover_%s_%dp.png" % [label, dim.y])
		await _click(vp, slot.get_global_rect().get_center())
		var selected: Image = await _save(vp, "board_selected_%s_%dp.png" % [label, dim.y])
		checks.assert_true(hover.get_data() != selected.get_data(), "Hover and selected GPU pixels differ")
		await _motion(vp, Vector2(960, 500) * factor)
		screen.clear_slot_selection()
	# Disabled GUI surface cannot select. Re-enable under stationary pointer.
	var first: BattlefieldSlot = screen.get_slots()[0]
	first.set_interactable(false)
	await _motion(vp, first.get_global_rect().get_center())
	await _click(vp, first.get_global_rect().get_center())
	checks.assert_equal(screen.get_selected_slot(), null, "Disabled pointer click ignored")
	checks.assert_false(first.hovered, "Disabled pointer hover ignored")
	first.set_interactable(true)
	checks.assert_true(first.hovered, "Re-enable under pointer recovers hover")
	# Future token routing fixture. PASS lets child input propagate to the slot.
	var token: Panel = Panel.new()
	token.mouse_filter = Control.MOUSE_FILTER_PASS
	first.get_token_anchor().add_child(token)
	token.position = Vector2(8, 8)
	token.size = first.size - Vector2(16, 16)
	await _motion(vp, first.get_global_rect().get_center())
	await _click(vp, first.get_global_rect().get_center())
	checks.assert_equal(screen.get_selected_slot(), first, "Future token child routes click to slot")
	token.queue_free()
	await process_frame
	screen.clear_slot_selection()
	# An overlay consumes a click over a slot; no slot signal can leak through.
	var overlay: Button = Button.new()
	screen.get_overlay_layer().add_child(overlay)
	overlay.position = first.get_global_rect().position
	overlay.size = first.get_global_rect().size
	before_clicks = clicks
	await _motion(vp, first.get_global_rect().get_center())
	await _click(vp, first.get_global_rect().get_center())
	checks.assert_equal(clicks, before_clicks, "Overlay blocks underlying slot")
	checks.assert_false(first.hovered, "Overlay hides slot hover")
	overlay.queue_free()
	await process_frame
	# Hand inspection extends over the board; pointer over its upper visible body
	# must pick the fan rather than a tactical slot behind it.
	await _motion(vp, Vector2(960, 900) * factor)
	await create_timer(0.3).timeout
	checks.assert_true(fan.get_hovered_index() >= 0, "Hand hover still works")
	checks.assert_equal(fan.inspection_height, 540.0, "540 px inspection preserved")
	await _motion(vp, Vector2(960, 620) * factor)
	checks.assert_true(fan.get_hovered_index() >= 0, "Raised inspection owns pointer")
	var hand_control: Control = vp.gui_get_hovered_control()
	checks.assert_true(hand_control == fan or (hand_control != null and fan.is_ancestor_of(hand_control)), "Raised artwork owns GUI input")
	before_clicks = clicks
	await _click(vp, Vector2(960, 620) * factor)
	checks.assert_equal(clicks, before_clicks, "No slot click through raised hand")
	await _save(vp, "regression_hand_inspection_%dp.png" % dim.y)
	for point: Vector2 in [Vector2(100, 100), Vector2(100, 900), Vector2(1760, 700), Vector2(960, 500), Vector2(650, 580)]:
		await _motion(vp, point * factor)
		await _click(vp, point * factor)
	checks.assert_equal(clicks, before_clicks, "HUD, utility, divider and slot gap do not select")
	var button_before: int = button_presses
	await _motion(vp, screen.get_end_turn_button().get_global_rect().get_center())
	await _click(vp, screen.get_end_turn_button().get_global_rect().get_center())
	checks.assert_equal(button_presses, button_before + 1, "End Turn stays interactive")
	checks.assert_equal(clicks, before_clicks, "End Turn does not select")
	checks.assert_equal(screen.get_player_health_orb().current_value, 30, "No health mutation")
	checks.assert_equal(screen.get_player_mana_orb().current_value, initial_mana, "No mana mutation")
	checks.assert_equal((screen.get_match_status().get_node("Turn") as Label).text, "TURN 01", "No turn mutation")
	await _motion(vp, Vector2(960, 500) * factor)
	await create_timer(0.3).timeout
	var restored: Image = await _image(vp)
	# Button focus is a real interaction state; release it for idle parity.
	screen.get_end_turn_button().release_focus()
	restored = await _image(vp)
	checks.assert_true(restored.get_data() == idle.get_data(), "Full idle pixels restored after interactions")
	# Explicit programmatic multi-state diagnostic, labeled in the image itself.
	screen.set_slot_highlight(BattlefieldSlot.Camp.PLAYER, 2, BattlefieldSlot.Row.ATTACK, true)
	screen.select_slot(BattlefieldSlot.Camp.PLAYER, 4, BattlefieldSlot.Row.ATTACK)
	await _motion(vp, screen.get_slot(BattlefieldSlot.Camp.PLAYER, 6, BattlefieldSlot.Row.ATTACK).get_global_rect().get_center())
	var caption: Label = Label.new()
	caption.text = "P006 FIXTURE - API: highlight C2 / selected C4 | injected pointer: hover C6"
	caption.position = Vector2(380, 170) * factor
	caption.scale = Vector2.ONE * factor
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.get_overlay_layer().add_child(caption)
	await _save(vp, "board_multi_state_diagnostic_%dp.png" % dim.y)
	vp.queue_free()
	await process_frame
