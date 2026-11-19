extends "res://docs/art/reviews/p008-f01/capture.gd"
func _run() -> void:
	for variant_name: String in ["baseline","a","b","c"]:
		for dim: Vector2i in [Vector2i(1920,1080),Vector2i(1280,720)]:
			var vp: SubViewport = SubViewport.new()
			vp.size = dim
			vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			root.add_child(vp)
			var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
			screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
			screen.size = Vector2(dim)
			vp.add_child(screen)
			for orb: LiquidResourceOrb in [screen.get_player_health_orb(),screen.get_player_mana_orb(),screen.get_opponent_health_orb(),screen.get_opponent_mana_orb()]: orb.set_animation_enabled(false)
			for index: int in range(24):
				var model: CreatureTokenViewModel = CreatureTokenDemo.MODELS[0].duplicate_model()
				model.instance_id = StringName("hover_%02d" % index)
				model.effective_attack = CASES[index%5].x
				model.current_health = CASES[index%5].y
				model.maximum_health = 99
				model.armor = CASES[index%5].z
				model.shield = CASES[index%5].w
				var token: CreatureToken = CreatureToken.new() if variant_name=="baseline" else TOKEN.new()
				if variant_name!="baseline": token.variant = variant_name.to_upper()
				token.apply_view_model(model)
				screen.get_slots()[index].get_token_anchor().add_child(token)
			await process_frame
			var first: BattlefieldSlot = screen.get_slots()[0]
			var motion: InputEventMouseMotion = InputEventMouseMotion.new()
			motion.position = first.get_global_rect().get_center()
			motion.global_position = motion.position
			vp.push_input(motion,true)
			await process_frame
			checks.assert_true(first.hovered,"Actual SubViewport GUI hover reaches populated slot")
			await create_timer(0.15).timeout
			await _save(vp,"%s_hover_%dp.png" % [variant_name,dim.y])
			for pressed: bool in [true,false]:
				var button: InputEventMouseButton = InputEventMouseButton.new()
				button.position = motion.position
				button.button_index = MOUSE_BUTTON_LEFT
				button.pressed = pressed
				vp.push_input(button,true)
				await process_frame
			checks.assert_equal(screen.get_selected_slot(),first,"Selection follows real GUI routing")
			await create_timer(0.15).timeout
			await _save(vp,"%s_selected_first_%dp.png" % [variant_name,dim.y])
			vp.queue_free()
			await process_frame
	var file: FileAccess = FileAccess.open(OUT+"hover_results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(checks.get_summary(),"  "))
	print("F01_HOVER_CHECKS=%d FAILURES=%d" % [checks.passed_count,checks.failed_count])
	quit(0 if checks.failed_count == 0 else 1)
