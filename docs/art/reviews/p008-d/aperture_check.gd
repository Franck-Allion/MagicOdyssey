extends SceneTree
func _init() -> void:
	_run.call_deferred()
func _run() -> void:
	var vp: SubViewport = SubViewport.new()
	vp.size = Vector2i(1536,1024)
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var probe: CreatureToken = preload("res://docs/art/reviews/p008-d/probe_c.gd").new()
	probe.primary = true
	vp.add_child(probe)
	for value: int in [0,1,2,3,6,8,10,12,14,99]:
		probe.value = value
		probe.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		var result: Error = vp.get_texture().get_image().save_png("res://docs/art/reviews/p008-d/aperture_%d.png" % value)
		if result != OK:
			quit(1)
			return
	vp.queue_free()
	await process_frame
	quit()
