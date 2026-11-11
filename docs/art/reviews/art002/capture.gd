extends SceneTree
## Real graphical SubViewport capture. -- <output.png> <width> <height> --mode=N
func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var arguments: PackedStringArray = OS.get_cmdline_user_args()
	if arguments.size() < 3 or DisplayServer.get_name() == "headless":
		push_error("Graphical renderer and output/width/height arguments required")
		quit(2)
		return
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(arguments[1].to_int(), arguments[2].to_int())
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var packed: PackedScene = load("res://scenes/ui/art002_card_integration_test.tscn") as PackedScene
	var scene: Control = packed.instantiate() as Control
	scene.set_anchors_preset(Control.PRESET_TOP_LEFT)
	scene.size = Vector2(viewport.size)
	viewport.add_child(scene)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var result: Error = viewport.get_texture().get_image().save_png(arguments[0])
	print("ART002_CAPTURE size=%s path=%s result=%d" % [viewport.size, arguments[0], result])
	quit(result)
