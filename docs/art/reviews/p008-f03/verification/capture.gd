extends SceneTree
## Equal-data, equal-footprint GPU audit. No production mutation.
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const V03: GDScript = preload("res://docs/art/reviews/p008-f03/verification/v03.gd")
const V05: GDScript = preload("res://docs/art/reviews/p008-f03/verification/v05.gd")
const BENCH: GDScript = preload("res://docs/art/reviews/p008-f01/token.gd")
const OUT: String = "res://docs/art/reviews/p008-f03/verification/"
const CASES: Array[Vector4i] = [Vector4i(1,1,0,0),Vector4i(6,8,2,3),Vector4i(12,14,10,12),Vector4i(0,0,1,1),Vector4i(99,99,14,14)]
var checks: TestAsserts = TestAsserts.new()
var metadata: Array[Dictionary] = []

func _init() -> void:
	_run.call_deferred()

func make_token(variant: String) -> Control:
	var token: Control = (V03 if variant == "v03" else V05 if variant == "v05" else BENCH).new() as Control
	if variant == "b": token.set("variant","B")
	return token

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT+"probes"))
	for variant: String in ["v03","b","v05"]:
		for dim: Vector2i in [Vector2i(1920,1080),Vector2i(1280,720)]:
			await capture(variant,dim)
	var file: FileAccess = FileAccess.open(OUT+"results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks.get_summary(),"layout":metadata,"gpu":RenderingServer.get_video_adapter_name(),"input":"SubViewport events, not OS pointer"},"  "))
	print("F03_VERIFIED_GPU=",checks.get_summary())
	quit(0 if checks.failed_count == 0 else 1)

func save(vp: SubViewport,path: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	checks.assert_equal(vp.get_texture().get_image().save_png(OUT+path),OK,"GPU save "+path)

func capture(variant: String,dim: Vector2i) -> void:
	var vp: SubViewport = SubViewport.new()
	vp.size = dim
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
	screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
	screen.size = Vector2(dim)
	vp.add_child(screen)
	for orb: LiquidResourceOrb in [screen.get_player_health_orb(),screen.get_player_mana_orb(),screen.get_opponent_health_orb(),screen.get_opponent_mana_orb()]: orb.set_animation_enabled(false)
	var first_position: Vector2 = Vector2.ZERO
	var first_scale: Vector2 = Vector2.ONE
	for scenario: String in ["empty","single","four_positive","two_digit","zero_defense","status_overflow","equipment","bright","dark","stress_99","full_board","mixed_stats"]:
		for slot: BattlefieldSlot in screen.get_slots():
			for child: Node in slot.get_token_anchor().get_children():
				slot.get_token_anchor().remove_child(child)
				child.queue_free()
		screen.clear_slot_selection()
		var count: int = 24 if scenario in ["full_board","mixed_stats"] else 0 if scenario == "empty" else 1
		for index: int in range(count):
			var model: CreatureTokenViewModel = CreatureTokenDemo.MODELS[0].duplicate_model()
			var values: Vector4i = CASES[index%CASES.size()] if count == 24 else CASES[1] if scenario in ["single","four_positive"] else CASES[0] if scenario == "zero_defense" else CASES[4] if scenario == "stress_99" else CASES[2]
			model.instance_id = StringName("identical_%02d" % index)
			model.effective_attack = values.x
			model.current_health = values.y
			model.maximum_health = 99
			model.armor = values.z
			model.shield = values.w
			if scenario in ["status_overflow","equipment"] or (count == 24 and index%6 == 3): model.statuses = CreatureTokenDemo.MODELS[3].duplicate_model().statuses
			model.weapon_attached = scenario == "equipment" or (count == 24 and index%3 == 0)
			model.protection_attached = model.weapon_attached
			if scenario in ["bright","dark"]:
				var image: Image = model.portrait.get_image()
				if image.is_compressed(): image.decompress()
				image.adjust_bcs(2.5 if scenario == "bright" else 0.18,1.0,1.0)
				model.portrait = ImageTexture.create_from_image(image)
			var token: Control = make_token(variant)
			checks.assert_true(token.call("apply_view_model",model),"Identical valid model")
			screen.get_slots()[index].get_token_anchor().add_child(token)
			# Historical B includes documented placeholder letters. Production flags stay false.
		await save(vp,"%s_%s_%dp.png" % [variant,scenario,dim.y])
		if count > 0:
			var first: Control = screen.get_slots()[0].get_token_anchor().get_child(0) as Control
			first_position = first.global_position
			first_scale = first.get_global_transform().get_scale()
		if scenario == "full_board":
			for slot: BattlefieldSlot in screen.get_slots():
				var token: Control = slot.get_token_anchor().get_child(0) as Control
				checks.assert_true(slot.get_global_rect().encloses(token.get_global_rect()),"Token inside protected slot")
				checks.assert_true(is_equal_approx(token.get_global_rect().size.x,154.0*dim.x/1920.0),"Equal footprint")
				var motion: InputEventMouseMotion = InputEventMouseMotion.new()
				motion.position = slot.get_global_rect().get_center()
				vp.push_input(motion,true)
				await process_frame
				checks.assert_true(slot.hovered,"Occupied hover")
				if slot == screen.get_slots()[0]: await save(vp,"%s_hover_%dp.png" % [variant,dim.y])
				for pressed: bool in [true,false]:
					var click: InputEventMouseButton = InputEventMouseButton.new()
					click.position = motion.position
					click.button_index = MOUSE_BUTTON_LEFT
					click.pressed = pressed
					vp.push_input(click,true)
					await process_frame
				checks.assert_equal(screen.get_selected_slot(),slot,"Occupied selection switches")
			await save(vp,"%s_selected_%dp.png" % [variant,dim.y])
		if scenario == "mixed_stats":
			for slot: BattlefieldSlot in screen.get_slots():
				var token: Control = slot.get_token_anchor().get_child(0) as Control
				token.set("hide_ink",true)
				token.queue_redraw()
			await save(vp,"%s_background_%dp.png" % [variant,dim.y])
	await probes(variant,dim.y,first_position,first_scale)
	vp.queue_free()
	await process_frame

func probes(variant: String,height: int,at: Vector2,token_scale: Vector2) -> void:
	var vp: SubViewport = SubViewport.new()
	vp.size = Vector2i(180,120)
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var token: Control = make_token(variant)
	vp.add_child(token)
	token.scale = token_scale
	token.position = Vector2(5,5)+at-at.floor()
	var cells: Array[Rect2] = token.call("cells")
	metadata.append({"variant":variant,"height":height,"scale":token_scale.x,"origin":[token.position.x,token.position.y],"scene_position":[at.x,at.y],"cells":cells.map(func(r: Rect2) -> Array: return [r.position.x,r.position.y,r.size.x,r.size.y])})
	if variant != "b":
		token.set("frame_only",true)
		token.queue_redraw()
		await save(vp,"probes/%s_frame_%dp.png" % [variant,height])
		token.set("frame_only",false)
	for stat: int in range(4):
		token.set("probe_stat",stat)
		token.set("probe_material",true)
		token.queue_redraw()
		await save(vp,"probes/%s_%d_material_%dp.png" % [variant,stat,height])
		token.set("probe_material",false)
		for value: int in [0,1,2,3,6,8,10,12,14,99]:
			token.set("probe_value",value)
			token.queue_redraw()
			await save(vp,"probes/%s_%d_%d_%dp.png" % [variant,stat,value,height])
	vp.queue_free()
	await process_frame
