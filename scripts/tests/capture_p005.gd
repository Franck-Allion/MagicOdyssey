extends SceneTree

## P005: Visual Capture Generator for CombatScreen.
## Generates genuine GPU screenshots at 1920x1080, 1280x720, and diagnostic layout debug.

const COMBAT_SCREEN_SCENE: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")


func _init() -> void:
	if DisplayServer.get_name() == "headless":
		print("ERROR: Graphical renderer required for visual captures (DisplayServer is headless).")
		quit(2)
		return
	call_deferred("_run_captures")


func _run_captures() -> void:
	var out_dir: String = ProjectSettings.globalize_path("res://docs/art/reviews/p005/")
	var make_err: Error = DirAccess.make_dir_recursive_absolute(out_dir)
	if make_err != OK and not DirAccess.dir_exists_absolute(out_dir):
		push_error("Failed to create directory: %s" % out_dir)
		quit(1)
		return

	print("==================================================")
	print("MagicOdyssey — P005 Visual Capture Suite")
	print("Engine: %s" % Engine.get_version_info().string)
	print("Display Server: %s" % DisplayServer.get_name())
	print("Output Directory: %s" % out_dir)
	print("==================================================")

	var anchor: Node = Node.new()
	anchor.name = "Anchor"
	root.add_child(anchor)

	# 1. Primary 1080p Production Capture
	print("[CAPTURE 1/3] Generating combat_screen_1080p.png (1920x1080)...")
	var err_1080p: Error = await _capture_scene(
		Vector2i(1920, 1080),
		out_dir + "combat_screen_1080p.png",
		false
	)
	if err_1080p != OK:
		push_error("Failed 1080p capture (error %d)" % err_1080p)
		quit(1)
		return

	# 2. Secondary 720p Responsive Capture
	print("[CAPTURE 2/3] Generating combat_screen_720p.png (1280x720)...")
	var err_720p: Error = await _capture_scene(
		Vector2i(1280, 720),
		out_dir + "combat_screen_720p.png",
		false
	)
	if err_720p != OK:
		push_error("Failed 720p capture (error %d)" % err_720p)
		quit(1)
		return

	# 3. Diagnostic Layout Debug Capture
	print("[CAPTURE 3/3] Generating combat_screen_layout_debug.png (1920x1080)...")
	var err_debug: Error = await _capture_scene(
		Vector2i(1920, 1080),
		out_dir + "combat_screen_layout_debug.png",
		true
	)
	if err_debug != OK:
		push_error("Failed debug capture (error %d)" % err_debug)
		quit(1)
		return

	print("==================================================")
	print("P005 ALL VISUAL CAPTURES GENERATED SUCCESSFULLY")
	print("==================================================")
	quit(0)


func _capture_scene(vp_size: Vector2i, dest_path: String, with_debug_overlay: bool) -> Error:
	var vp: SubViewport = SubViewport.new()
	vp.size = vp_size
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var screen: CombatScreen = COMBAT_SCREEN_SCENE.instantiate() as CombatScreen
	screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
	screen.size = Vector2(vp_size)
	screen._apply_responsive_layout()
	vp.add_child(screen)

	if with_debug_overlay:
		_add_debug_overlay(screen)

	# Ensure frames are drawn
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw

	var img: Image = vp.get_texture().get_image()
	var err: Error = img.save_png(dest_path)

	print("  -> Saved %s (%d x %d px, exit %d)" % [dest_path.get_file(), img.get_width(), img.get_height(), err])

	root.remove_child(vp)
	vp.queue_free()
	return err


func _add_debug_overlay(screen: CombatScreen) -> void:
	var debug_layer: Control = Control.new()
	debug_layer.name = "DebugOverlay"
	debug_layer.size = screen.REFERENCE_SIZE
	screen.get_combat_layout().add_child(debug_layer)

	var regions: Array[Dictionary] = [
		{"name": "P007 Opponent Hero Zone", "node": screen.get_opponent_hero_zone(), "color": Color(0.85, 0.35, 0.3, 0.8)},
		{"name": "P006 24-Slot Battlefield", "node": screen.get_battlefield_zone(), "color": Color(0.87, 0.79, 0.59, 0.8)},
		{"name": "P007 Player Hero Zone", "node": screen.get_player_hero_zone(), "color": Color(0.24, 0.65, 0.88, 0.8)},
		{"name": "P009 HandView Container", "node": screen.get_player_hand_zone(), "color": Color(0.18, 0.82, 0.48, 0.8)},
		{"name": "P007 Turn & Action Bar", "node": screen.get_action_bar_zone(), "color": Color(0.95, 0.75, 0.25, 0.8)},
	]

	for r: Dictionary in regions:
		var n: Control = r["node"] as Control
		if n == null:
			continue
		var rect_outline: ReferenceRect = ReferenceRect.new()
		rect_outline.position = n.position
		rect_outline.size = n.size
		rect_outline.border_color = r["color"]
		rect_outline.border_width = 3.0
		rect_outline.editor_only = false
		debug_layer.add_child(rect_outline)

		var lbl: Label = Label.new()
		lbl.text = " [ %s ] " % r["name"]
		lbl.position = n.position + Vector2(10, 8)
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.add_theme_color_override("font_color", r["color"])
		debug_layer.add_child(lbl)
