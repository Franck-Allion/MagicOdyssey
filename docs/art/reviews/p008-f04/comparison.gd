extends "res://docs/art/reviews/p008-f04/capture.gd"

func label_at(parent: Node,text: String,at: Vector2,points: int) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = at
	label.add_theme_font_size_override("font_size",points)
	parent.add_child(label)

func _run() -> void:
	for dim: Vector2i in [Vector2i(1280,720),Vector2i(1920,1080)]:
		var vp: SubViewport = SubViewport.new()
		vp.size = dim
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(vp)
		var background: ColorRect = ColorRect.new()
		background.color = Color(0.045,0.052,0.065)
		background.size = Vector2(dim)
		vp.add_child(background)
		var scale_value: float = float(dim.x)/1920.0
		label_at(vp,"P008-F04 / NATIVE TOKEN SIZE / same frame, data and materials",Vector2(40,20)*scale_value,int(24*scale_value))
		var variants: Array[String] = ["a","b","c","c14","n","d"]
		var titles: Array[String] = ["A / original","B / Palatino thin","C / Bahnschrift thin","C14 / heavier stroke","N / no outline","D / mipmaps"]
		for column: int in range(variants.size()):
			label_at(vp,titles[column],Vector2(35+column*315,80)*scale_value,int(19*scale_value))
			for row: int in range(4):
				var model: CreatureTokenViewModel = CreatureTokenDemo.MODELS[0].duplicate_model()
				var values: Vector4i = [CASES[2],CASES[1],CASES[4],Vector4i(7,3,6,8)][row]
				model.effective_attack = values.x
				model.current_health = values.y
				model.maximum_health = 99
				model.armor = values.z
				model.shield = values.w
				var anchor: Control = Control.new()
				anchor.size = Vector2(162,112)
				anchor.position = Vector2(70+column*315,150+row*205)*scale_value
				anchor.scale = Vector2.ONE*scale_value
				vp.add_child(anchor)
				var token: Control = make_token(variants[column])
				token.call("apply_view_model",model)
				anchor.add_child(token)
				label_at(vp,"A %d / H %d / Ar %d / S %d" % [values.x,values.y,values.z,values.w],Vector2(35+column*315,275+row*205)*scale_value,int(17*scale_value))
		await save(vp,"comparison_%dp.png" % dim.y)
		vp.queue_free()
		await process_frame
	# Two complete 1280x720 screens, rendered adjacent without scaling a screenshot.
	var pair: SubViewport = SubViewport.new()
	pair.size = Vector2i(2560,720)
	pair.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(pair)
	for column: int in range(2):
		var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
		screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
		screen.position = Vector2(column*1280,0)
		screen.size = Vector2(1280,720)
		pair.add_child(screen)
		for orb: LiquidResourceOrb in [screen.get_player_health_orb(),screen.get_player_mana_orb(),screen.get_opponent_health_orb(),screen.get_opponent_mana_orb()]: orb.set_animation_enabled(false)
		for index: int in range(24):
			var model: CreatureTokenViewModel = CreatureTokenDemo.MODELS[0].duplicate_model()
			var values: Vector4i = CASES[index%CASES.size()]
			model.instance_id = StringName("pair_%02d" % index)
			model.effective_attack = values.x
			model.current_health = values.y
			model.maximum_health = 99
			model.armor = values.z
			model.shield = values.w
			var token: Control = make_token("a" if column==0 else "c")
			token.call("apply_view_model",model)
			screen.get_slots()[index].get_token_anchor().add_child(token)
		label_at(pair,"A / ORIGINAL" if column==0 else "C / SELECTED CANDIDATE",Vector2(column*1280+450,130),15)
	await save(pair,"full_board_pair_native_720p.png")
	pair.queue_free()
	print("F04_COMPARISONS=",checks.get_summary())
	quit(0 if checks.failed_count==0 else 1)
