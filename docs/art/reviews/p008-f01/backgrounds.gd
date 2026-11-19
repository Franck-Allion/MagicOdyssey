extends SceneTree
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const TOKEN: GDScript = preload("res://docs/art/reviews/p008-f01/token.gd")
func _init() -> void: _run.call_deferred()
func _run() -> void:
	var positions: Array[Dictionary] = []
	for variant: String in ["a","b","c"]:
		for dim: Vector2i in [Vector2i(1920,1080),Vector2i(1280,720)]:
			var vp: SubViewport = SubViewport.new()
			vp.size = dim
			vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			root.add_child(vp)
			var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
			screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
			screen.size = Vector2(dim)
			vp.add_child(screen)
			var token: CreatureToken = TOKEN.new()
			token.variant = variant.to_upper()
			token.hide_ink = true
			token.apply_view_model(CreatureTokenDemo.MODELS[5])
			screen.get_slots()[0].get_token_anchor().add_child(token)
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			positions.append({"variant":variant,"height":dim.y,"position":[token.global_position.x,token.global_position.y]})
			var error: Error = vp.get_texture().get_image().save_png("res://docs/art/reviews/p008-f01/background_%s_%dp.png" % [variant,dim.y])
			if error != OK:
				quit(1)
				return
			vp.queue_free()
			await process_frame
	var file: FileAccess = FileAccess.open("res://docs/art/reviews/p008-f01/background_positions.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(positions,"  "))
	quit()
