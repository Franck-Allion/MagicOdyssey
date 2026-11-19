extends "res://docs/art/reviews/p008-f01/capture.gd"
func _run() -> void:
	for variant_name: String in ["baseline","a","b","c"]:
		for dim: Vector2i in [Vector2i(1920,1080),Vector2i(1280,720)]:
			for scenario: String in ["bright","dark"]:
				var vp: SubViewport = SubViewport.new()
				vp.size = dim
				vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
				root.add_child(vp)
				var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
				screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
				screen.size = Vector2(dim)
				vp.add_child(screen)
				for orb: LiquidResourceOrb in [screen.get_player_health_orb(),screen.get_player_mana_orb(),screen.get_opponent_health_orb(),screen.get_opponent_mana_orb()]: orb.set_animation_enabled(false)
				var model: CreatureTokenViewModel = CreatureTokenDemo.MODELS[0].duplicate_model()
				model.effective_attack = 12
				model.current_health = 14
				model.maximum_health = 99
				model.armor = 10
				model.shield = 12
				var image: Image = model.portrait.get_image()
				if image.is_compressed(): image.decompress()
				image.adjust_bcs(2.5 if scenario=="bright" else 0.18,1.0,1.0)
				model.portrait = ImageTexture.create_from_image(image)
				var token: CreatureToken = CreatureToken.new() if variant_name=="baseline" else TOKEN.new()
				if variant_name!="baseline": token.variant = variant_name.to_upper()
				token.apply_view_model(model)
				screen.get_slots()[0].get_token_anchor().add_child(token)
				var label: Label = Label.new()
				label.text = "F01 / NON-PRODUCTION / BRIGHT-DARK PORTRAIT DIAGNOSTIC"
				label.position = Vector2(450,193)*dim.x/1920.0
				label.add_theme_font_size_override("font_size",int(16.0*dim.x/1920.0))
				vp.add_child(label)
				await _save(vp,"%s_%s_%dp.png" % ["baseline" if variant_name=="baseline" else "variant_"+variant_name,scenario,dim.y])
				vp.queue_free()
				await process_frame
	quit(0 if checks.failed_count == 0 else 1)
