extends SceneTree
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const OUT: String = "res://docs/art/reviews/p008/"
var a: TestAsserts = TestAsserts.new()
var clicks: int = 0
var enters: int = 0

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		quit(2)
		return
	for dim: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		await _resolution(dim)
	await _comparison()
	var file: FileAccess = FileAccess.open(OUT + "observations.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"engine": Engine.get_version_info().string, "gpu": RenderingServer.get_video_adapter_name(), "checks": a.get_summary(), "pointer": "SubViewport injected events; Windows OS checks separate"}, "  "))
	print("P008_GPU_CHECKS=%d FAILURES=%d" % [a.passed_count, a.failed_count])
	quit(0 if a.failed_count == 0 else 1)

func _resolution(dim: Vector2i) -> void:
	var vp: SubViewport = SubViewport.new()
	vp.size = dim
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
	screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
	screen.size = Vector2(dim)
	vp.add_child(screen)
	for orb: LiquidResourceOrb in [screen.get_player_health_orb(), screen.get_player_mana_orb(), screen.get_opponent_health_orb(), screen.get_opponent_mana_orb()]:
		orb.set_animation_enabled(false)
	screen.slot_selected.connect(func(_c: BattlefieldSlot.Camp, _n: int, _r: BattlefieldSlot.Row) -> void: clicks += 1)
	screen.slot_hovered.connect(func(_c: BattlefieldSlot.Camp, _n: int, _r: BattlefieldSlot.Row) -> void: enters += 1)
	for scenario: String in ["empty", "single", "stats", "armor_shield", "zero_stats", "status_overflow", "equipment", "full_board", "selected"]:
		CreatureTokenDemo.populate(screen, scenario)
		await process_frame
		await process_frame
		await _save(vp, "token_%s_%dp.png" % [scenario, dim.y])
		if scenario == "full_board":
			for slot: BattlefieldSlot in screen.get_slots():
				var token: CreatureToken = screen.get_creature_token(slot.get_slot_identity())
				a.assert_true(token != null and token.is_visible_in_tree(), "24 visible")
				var rect: Rect2 = token.get_global_rect()
				a.assert_true(slot.get_global_rect().encloses(rect), "Complete frame inside slot")
				var point: Vector2 = slot.get_global_rect().get_center()
				var before: int = clicks
				var before_enter: int = enters
				await _motion(vp, point)
				await _click(vp, point)
				a.assert_equal(clicks, before + 1, "One routed click")
				a.assert_equal(enters, before_enter + 1, "Populated hover routing")
				a.assert_equal(screen.get_selected_slot(), slot, "Selection switches")
			screen.clear_slot_selection()
	# Actual aspect-fill under bright/dark and asymmetric source dimensions.
	for bright: bool in [false, true]:
		CreatureTokenDemo.populate(screen, "stats")
		var slot: BattlefieldSlot = screen.get_slots()[0]
		var model: CreatureTokenViewModel = screen.get_creature_token(slot.get_slot_identity()).get_view_model()
		var image: Image = Image.create(80 if bright else 320, 320 if bright else 80, false, Image.FORMAT_RGBA8)
		image.fill(Color(0.98, 0.98, 0.95) if bright else Color(0.01, 0.01, 0.02))
		model.portrait = ImageTexture.create_from_image(image)
		screen.update_creature_token(slot.get_slot_identity(), model)
		await _save(vp, "token_diagnostic_%s_%dp.png" % ["bright" if bright else "dark", dim.y])
	vp.queue_free()
	await process_frame

func _comparison() -> void:
	var vp: SubViewport = SubViewport.new()
	vp.size = Vector2i(1200, 760)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var background: ColorRect = ColorRect.new()
	background.color = UIDesignTokens.color_token(&"background")
	background.size = Vector2(vp.size)
	vp.add_child(background)
	var stats: CardStatOverlay = CardStatOverlay.new()
	stats.set_printed_values(2, 14, 12, 10)
	stats.set_shield_overlay(12)
	stats.scale = Vector2.ONE * 0.5
	stats.position = Vector2(25, -350)
	vp.add_child(stats)
	var token: CreatureToken = CreatureToken.new()
	token.apply_view_model(CreatureTokenDemo.MODELS[5])
	vp.add_child(token)
	token.position = Vector2(600, 60)
	token.scale = Vector2.ONE * 0.36
	for index: int in range(2):
		var label: Label = Label.new()
		label.text = "ART-002 official card overlay" if index == 0 else "P008 token / existing bronze housing"
		label.position = Vector2(24 + index * 575, 650)
		label.add_theme_font_size_override("font_size", 24)
		vp.add_child(label)
	await _save(vp, "art002_token_stat_comparison.png")
	vp.queue_free()
	await process_frame

func _save(vp: SubViewport, filename: String) -> void:
	await process_frame
	await create_timer(0.16).timeout
	await RenderingServer.frame_post_draw
	var image: Image = vp.get_texture().get_image()
	a.assert_equal(image.save_png(OUT + filename), OK, "Real GPU capture " + filename)

func _motion(vp: SubViewport, point: Vector2) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = point
	event.global_position = point
	vp.push_input(event, true)
	await process_frame

func _click(vp: SubViewport, point: Vector2) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		vp.push_input(event, true)
		await process_frame
