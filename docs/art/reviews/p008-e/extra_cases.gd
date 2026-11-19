extends "res://docs/art/reviews/p008-e/capture.gd"
func _run() -> void:
	for name_value: String in ["A","C"]:
		variant = name_value
		OUT = "res://docs/art/reviews/p008-e/%s/" % variant
		for dim: Vector2i in [Vector2i(1920,1080),Vector2i(1280,720)]:
			var vp: SubViewport = SubViewport.new()
			vp.size = dim
			vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			root.add_child(vp)
			var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
			screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
			screen.size = Vector2(dim)
			vp.add_child(screen)
			for orb: LiquidResourceOrb in [screen.get_player_health_orb(),screen.get_player_mana_orb(),screen.get_opponent_health_orb(),screen.get_opponent_mana_orb()]:
				orb.set_animation_enabled(false)
			_populate(screen,"mixed_board")
			_swap_variant(screen)
			await _save(vp,"v02_mixed_board_%dp.png" % dim.y)
			vp.queue_free()
			await process_frame
	quit(0 if a.failed_count == 0 else 1)
