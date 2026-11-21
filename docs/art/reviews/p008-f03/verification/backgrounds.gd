extends "res://docs/art/reviews/p008-f03/verification/capture.gd"
## All four active ART-002 materials, genuine no-ink first-slot GPU background.
func _run() -> void:
	for variant: String in ["v03","b","v05"]:
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
			var token: Control = make_token(variant)
			var model: CreatureTokenViewModel = CreatureTokenDemo.MODELS[0].duplicate_model()
			model.armor = 12
			model.shield = 12
			token.call("apply_view_model",model)
			token.set("hide_ink",true)
			screen.get_slots()[0].get_token_anchor().add_child(token)
			await save(vp,"%s_background_%dp.png" % [variant,dim.y])
			vp.queue_free()
			await process_frame
	print("ACTIVE_BACKGROUNDS=",checks.get_summary())
	quit(0 if checks.failed_count == 0 else 1)
