extends SceneTree
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
var OUT: String = "res://docs/art/reviews/p008-d/C/"
var variant: String = "C"
var a: TestAsserts = TestAsserts.new()
var clicks: int = 0
var enters: int = 0

class GlyphProbe extends CardSocketOverlay:
	var value: int = 0
	var primary: bool = false
	func _draw() -> void:
		draw_number(CreatureTokenLayout.ATTACK if primary else CreatureTokenLayout.ARMOR.get_center(), value,
			CreatureTokenLayout.PRIMARY_POINTS if primary else CreatureTokenLayout.SECONDARY_POINTS,
			CreatureTokenLayout.PRIMARY_WIDTH if primary else CreatureTokenLayout.SECONDARY_WIDTH,
			UIDesignTokens.color_token(&"text_bright"), CreatureTokenLayout.PRIMARY_RADIUS if primary else 0.0, Vector2.ZERO)

class MaterialProbe extends CreatureToken:
	var suppress_inserts: bool = false
	func draw_number(_center: Vector2, _value: int, _points: int, _max_width: float, _ink: Color, _safe_radius: float = 0.0, _custom_optical_offset: Variant = null) -> void:
		pass
	func _draw_plaque(rect: Rect2, texture: Texture2D, value: int) -> void:
		super._draw_plaque(rect, texture, 0 if suppress_inserts else value)

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--variant="):
			variant = arg.trim_prefix("--variant=")
	OUT = "res://docs/art/reviews/p008-d/%s/" % variant
	if DisplayServer.get_name() == "headless":
		quit(2)
		return
	for dim: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		await _resolution(dim)
	await _comparison()
	await _source_materials()
	var file: FileAccess = FileAccess.open(OUT + "observations.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"engine": Engine.get_version_info().string, "gpu": RenderingServer.get_video_adapter_name(), "checks": a.get_summary(), "pointer": "SubViewport injected events; Windows OS checks separate"}, "  "))
	print("P008_D_GPU_CHECKS=%d FAILURES=%d" % [a.passed_count, a.failed_count])
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
	for scenario: String in ["empty", "single", "four_stats", "double_digit", "zero_armor_shield", "positive_armor_shield", "status_overflow", "equipment", "full_board", "mixed_board", "selected_token", "values_6_8", "values_0_0"]:
		_populate(screen, scenario)
		_swap_variant(screen)
		await process_frame
		await process_frame
		await _save(vp, "v02_%s_%dp.png" % [scenario, dim.y])
		if scenario in ["full_board", "mixed_board"]:
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
		_swap_variant(screen)
		await _save(vp, "v02_%s_portrait_%dp.png" % ["bright" if bright else "dark", dim.y])
	await _glyph_probes(screen, dim)
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
	await _save(vp, "v02_art002_material_comparison.png")
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

func _populate(screen: CombatScreen, scenario: String) -> void:
	var fixture: String = scenario
	match scenario:
		"four_stats", "double_digit": fixture = "stats"
		"zero_armor_shield", "positive_armor_shield", "values_6_8", "values_0_0": fixture = "single"
		"mixed_board": fixture = "full_board"
		"selected_token": fixture = "selected"
	CreatureTokenDemo.populate(screen, fixture)
	var cases: Array[Vector4i] = [Vector4i(2,3,1,1),Vector4i(6,8,2,3),Vector4i(12,14,10,12),Vector4i(0,0,0,0),Vector4i(2,3,0,12),Vector4i(12,14,10,0)]
	for index: int in range(screen.get_slots().size()):
		var slot: BattlefieldSlot = screen.get_slots()[index]
		var token: CreatureToken = screen.get_creature_token(slot.get_slot_identity())
		if token == null:
			continue
		var model: CreatureTokenViewModel = token.get_view_model()
		var values: Vector4i = Vector4i(model.effective_attack,model.current_health,model.armor,model.shield)
		match scenario:
			"four_stats", "positive_armor_shield": values = cases[0]
			"double_digit": values = cases[2]
			"zero_armor_shield": values = Vector4i(2,3,0,0)
			"values_6_8": values = cases[1]
			"values_0_0": values = cases[3]
			"mixed_board": values = cases[index % cases.size()]
		model.effective_attack = values.x
		model.current_health = values.y
		model.maximum_health = maxi(model.maximum_health,values.y)
		model.armor = values.z
		model.shield = values.w
		a.assert_true(screen.update_creature_token(slot.get_slot_identity(),model), "Required stat case update")

func _glyph_probes(screen: CombatScreen, dim: Vector2i) -> void:
	var vp: SubViewport = SubViewport.new()
	vp.size = Vector2i(160,120)
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var first: CreatureToken = screen.get_creature_token(screen.get_slots()[0].get_slot_identity())
	var probe: CreatureToken = load("res://docs/art/reviews/p008-d/probe_%s.gd" % variant.to_lower()).new()
	vp.add_child(probe)
	# Match actual first-token scaling and fractional raster phase.
	probe.scale = first.get_global_transform().get_scale()
	probe.position = Vector2(10,10) + first.global_position - first.global_position.floor()
	for primary: bool in [false,true]:
		probe.primary = primary
		for value: int in [0,1,2,3,6,8,10,12,14]:
			probe.value = value
			probe.queue_redraw()
			await _save(vp,"glyphs/%s_%d_%dp.png" % ["primary" if primary else "secondary",value,dim.y])
	vp.queue_free()
	await process_frame

func _native_comparison() -> void:
	var vp: SubViewport = SubViewport.new()
	vp.size = Vector2i(1280,720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var bg: ColorRect = ColorRect.new()
	bg.color = UIDesignTokens.color_token(&"background")
	bg.size = Vector2(vp.size)
	vp.add_child(bg)
	var cases: Array[Vector4i] = [Vector4i(2,3,1,1),Vector4i(12,14,10,12),Vector4i(2,3,0,0),Vector4i(6,8,2,3)]
	for row: int in range(cases.size()):
		for column: int in range(2):
			var anchor: Control = Control.new()
			anchor.size = Vector2(162,112)
			anchor.scale = Vector2.ONE * 2.0 / 3.0
			anchor.position = Vector2(180 + column * 570,100 + row * 145)
			vp.add_child(anchor)
			var token: CardSocketOverlay = preload("res://docs/art/reviews/p008-c/c02/legacy_token.gd").new() if column == 0 else CreatureToken.new()
			var model: CreatureTokenViewModel = CreatureTokenDemo.MODELS[0].duplicate_model()
			model.effective_attack = cases[row].x
			model.current_health = cases[row].y
			model.maximum_health = 14
			model.armor = cases[row].z
			model.shield = cases[row].w
			token.apply_view_model(model)
			anchor.add_child(token)
			var label: Label = Label.new()
			label.text = "%s / ATK %d HP %d ARM %d SH %d / native 720p" % ["V01 historical" if column == 0 else "V02 production",model.effective_attack,model.current_health,model.armor,model.shield]
			label.position = anchor.position + Vector2(-100,-25)
			vp.add_child(label)
	await _save(vp,"v01_v02_native_comparison_720p.png")
	vp.queue_free()
	await process_frame

func _source_materials() -> void:
	var vp: SubViewport = SubViewport.new()
	vp.size = Vector2i(1536,1024)
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var token: MaterialProbe = MaterialProbe.new()
	vp.add_child(token)
	var reference: Image
	for positive: bool in [false,true]:
		var model: CreatureTokenViewModel = CreatureTokenDemo.MODELS[0].duplicate_model()
		model.armor = 10 if positive else 0
		model.shield = 12 if positive else 0
		token.apply_view_model(model)
		for suppressed: bool in [true,false]:
			token.suppress_inserts = suppressed
			token.queue_redraw()
			await _save(vp,"material_%s_%s.png" % ["positive" if positive else "zero","suppressed" if suppressed else "actual"])
			var image: Image = vp.get_texture().get_image()
			if suppressed:
				reference = image
			else:
				for rect: Rect2 in [CreatureTokenLayout.ARMOR,CreatureTokenLayout.SHIELD]:
					var count: int = 0
					for y: int in range(int(rect.position.y),int(rect.end.y)):
						for x: int in range(int(rect.position.x),int(rect.end.x)):
							if image.get_pixel(x,y) != reference.get_pixel(x,y):
								count += 1
					a.assert_true(count > 10000 if positive else count == 0,"Real GPU official insert positive/zero activation")
	vp.queue_free()
	await process_frame

func _swap_variant(screen: CombatScreen) -> void:
	if variant == "C":
		return
	for slot: BattlefieldSlot in screen.get_slots():
		var old: CreatureToken = screen.get_creature_token(slot.get_slot_identity())
		if old == null:
			continue
		var model: CreatureTokenViewModel = old.get_view_model()
		var anchor: Control = old.get_parent() as Control
		anchor.remove_child(old)
		old.free()
		var token: CreatureToken = load("res://docs/art/reviews/p008-d/variant_%s.gd" % variant.to_lower()).new()
		token.apply_view_model(model)
		token.diagnostic_indicators_enabled = true
		anchor.add_child(token)
