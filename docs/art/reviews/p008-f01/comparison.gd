extends SceneTree
const TOKEN: GDScript = preload("res://docs/art/reviews/p008-f01/token.gd")
const CASES: Array[Vector4i] = [Vector4i(1,1,0,0),Vector4i(6,8,2,3),Vector4i(12,14,10,12),Vector4i(0,0,1,1),Vector4i(99,99,14,14)]
func _init() -> void: _run.call_deferred()
func _run() -> void:
	for dim: Vector2i in [Vector2i(1920,1080),Vector2i(1280,720)]:
		var vp: SubViewport = SubViewport.new()
		vp.size = dim
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(vp)
		var bg: ColorRect = ColorRect.new()
		bg.size = Vector2(dim)
		bg.color = UIDesignTokens.color_token(&"background")
		vp.add_child(bg)
		var scale_factor: float = dim.x/1920.0
		for col: int in range(4):
			var label: Label = Label.new()
			label.text = ["Production V03","A compact band","B raised defenses","C console"][col]+" / DIAGNOSTIC"
			label.position = Vector2(40+col*470,30)*scale_factor
			label.add_theme_font_size_override("font_size",int(21*scale_factor))
			vp.add_child(label)
			for row: int in range(CASES.size()):
				var anchor: Control = Control.new()
				anchor.size = Vector2(162,112)
				anchor.position = Vector2(150+col*470,120+row*175)*scale_factor
				anchor.scale = Vector2.ONE*scale_factor
				vp.add_child(anchor)
				var model: CreatureTokenViewModel = CreatureTokenDemo.MODELS[0].duplicate_model()
				model.effective_attack = CASES[row].x
				model.current_health = CASES[row].y
				model.maximum_health = 99
				model.armor = CASES[row].z
				model.shield = CASES[row].w
				var token: CreatureToken = CreatureToken.new() if col==0 else TOKEN.new()
				if col>0: token.variant = ["a","a","b","c"][col].to_upper()
				token.apply_view_model(model)
				anchor.add_child(token)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		if vp.get_texture().get_image().save_png("res://docs/art/reviews/p008-f01/comparison_%dp.png" % dim.y)!=OK:
			quit(1)
			return
		vp.queue_free()
		await process_frame
	quit()
