extends SceneTree
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const TOKEN: GDScript = preload("res://docs/art/reviews/p008-f01/token.gd")
const OUT: String = "res://docs/art/reviews/p008-f01/"
const CASES: Array[Vector4i] = [Vector4i(1,1,0,0),Vector4i(6,8,2,3),Vector4i(12,14,10,12),Vector4i(0,0,1,1),Vector4i(99,99,14,14)]
var checks: TestAsserts = TestAsserts.new()
var clicks: int = 0
var metadata: Array[Dictionary] = []

func _init() -> void: _run.call_deferred()

func _run() -> void:
	if not TOKEN.can_instantiate():
		quit(1)
		return
	if DisplayServer.get_name() == "headless":
		quit(2)
		return
	for variant: String in ["baseline","a","b","c"]:
		for dim: Vector2i in [Vector2i(1920,1080),Vector2i(1280,720)]:
			await _resolution(variant,dim)
	var f: FileAccess = FileAccess.open(OUT+"gpu_results.json",FileAccess.WRITE)
	f.store_string(JSON.stringify({"checks":checks.get_summary(),"layout":metadata,"gpu":RenderingServer.get_video_adapter_name(),"input":"SubViewport injected mouse; no Windows standalone performed"},"  "))
	print("F01_GPU_CHECKS=%d FAILURES=%d" % [checks.passed_count,checks.failed_count])
	quit(0 if checks.failed_count == 0 else 1)

func _resolution(variant: String,dim: Vector2i) -> void:
	var vp: SubViewport = SubViewport.new()
	vp.size = dim
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
	screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
	screen.size = Vector2(dim)
	vp.add_child(screen)
	for orb: LiquidResourceOrb in [screen.get_player_health_orb(),screen.get_player_mana_orb(),screen.get_opponent_health_orb(),screen.get_opponent_mana_orb()]: orb.set_animation_enabled(false)
	var caption: Label = Label.new()
	caption.text = "F01 %s / STATUS AND W-P PLACEHOLDERS: NON-PRODUCTION" % variant.to_upper()
	caption.position = Vector2(450,193)*dim.x/1920.0
	caption.add_theme_font_size_override("font_size",int(16.0*dim.x/1920.0))
	vp.add_child(caption)
	screen.slot_selected.connect(func(_a: BattlefieldSlot.Camp,_b: int,_c: BattlefieldSlot.Row) -> void: clicks += 1)
	for scenario: String in ["empty","single","full_board","mixed_stats","four_positive","two_digit","zero_defense","status_overflow","equipment","bright","dark","stress_99"]:
		caption.visible = scenario != "empty"
		screen.clear_creature_tokens()
		screen.clear_slot_selection()
		var count: int = 24 if scenario in ["full_board","mixed_stats"] else 0 if scenario == "empty" else 1
		for index: int in range(count):
			var model: CreatureTokenViewModel = CreatureTokenDemo.MODELS[0].duplicate_model()
			var values: Vector4i = CASES[index%CASES.size()] if count==24 else CASES[2]
			if scenario == "zero_defense": values = CASES[0]
			if scenario == "stress_99": values = CASES[4]
			model.instance_id = StringName("benchmark_%02d" % index)
			model.effective_attack = values.x
			model.current_health = values.y
			model.maximum_health = 99
			model.armor = values.z
			model.shield = values.w
			if scenario in ["status_overflow","equipment"] or (count==24 and index%6==3): model.statuses = CreatureTokenDemo.MODELS[3].duplicate_model().statuses
			model.weapon_attached = scenario == "equipment" or (count==24 and index%3==0)
			model.protection_attached = model.weapon_attached
			if scenario in ["bright","dark"]:
				var image: Image = model.portrait.get_image()
				if image.is_compressed(): image.decompress()
				image.adjust_bcs(2.5 if scenario == "bright" else 0.18,1.0,1.0)
				model.portrait = ImageTexture.create_from_image(image)
			var slot: BattlefieldSlot = screen.get_slots()[index]
			if variant == "baseline":
				screen.add_creature_token(slot.get_slot_identity(),model)
				screen.get_creature_token(slot.get_slot_identity()).diagnostic_indicators_enabled = true
			else:
				var token: CreatureToken = TOKEN.new()
				token.variant = variant.to_upper()
				token.apply_view_model(model)
				slot.get_token_anchor().add_child(token)
		await process_frame
		await process_frame
		await _save(vp,"%s_%s_%dp.png" % ["baseline" if variant=="baseline" else "variant_"+variant,scenario,dim.y])
		if scenario == "full_board":
			for slot: BattlefieldSlot in screen.get_slots():
				var token: CreatureToken = screen.get_creature_token(slot.get_slot_identity())
				checks.assert_true(slot.get_global_rect().encloses(token.get_global_rect()),"Same footprint inside P006 slot")
				checks.assert_true(is_equal_approx(token.get_global_rect().size.x,154.0*dim.x/1920.0),"Exact common token width")
				var before: int = clicks
				for pressed: bool in [true,false]:
					var e: InputEventMouseButton = InputEventMouseButton.new()
					e.position = slot.get_global_rect().get_center()
					e.button_index = MOUSE_BUTTON_LEFT
					e.pressed = pressed
					vp.push_input(e,true)
					await process_frame
				checks.assert_equal(clicks,before+1,"One populated-slot routed click")
				checks.assert_equal(screen.get_selected_slot(),slot,"P006 selection preserved")
			await _save(vp,"%s_selected_%dp.png" % [variant,dim.y])
	var first: CreatureToken = screen.get_creature_token(screen.get_slots()[0].get_slot_identity())
	await _probes(variant,dim,first)
	vp.queue_free()
	await process_frame

func _probes(variant: String,dim: Vector2i,first: CreatureToken) -> void:
	if variant == "baseline": return
	var vp: SubViewport = SubViewport.new()
	vp.size = Vector2i(180,120)
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var token: CreatureToken = TOKEN.new()
	token.variant = variant.to_upper()
	vp.add_child(token)
	token.scale = first.get_global_transform().get_scale()
	token.position = Vector2(5,5)+first.global_position-first.global_position.floor()
	var rects: Array[Rect2] = token.cells()
	metadata.append({"variant":variant,"height":dim.y,"scale":token.scale.x,"origin":[token.position.x,token.position.y],"cells":rects.map(func(r: Rect2) -> Array: return [r.position.x,r.position.y,r.size.x,r.size.y])})
	for stat: int in range(4):
		token.probe_stat = stat
		token.probe_material = true
		token.queue_redraw()
		await _save(vp,"probes/%s_%d_material_%dp.png" % [variant,stat,dim.y])
		token.probe_material = false
		for value: int in [0,1,2,3,6,8,10,12,14,99]:
			token.probe_value = value
			token.queue_redraw()
			await _save(vp,"probes/%s_%d_%d_%dp.png" % [variant,stat,value,dim.y])
	vp.queue_free()
	await process_frame

func _save(vp: SubViewport,name_value: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	checks.assert_equal(vp.get_texture().get_image().save_png(OUT+name_value),OK,"Genuine GPU capture "+name_value)
