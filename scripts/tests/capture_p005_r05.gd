extends SceneTree
## Genuine GPU captures for P005-R05 hand recognition and hover inspection.
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const OUT: String = "res://docs/art/reviews/p005-r05/"
var _failed: bool = false
var _frame_dir: String = OS.get_environment("TEMP").path_join("magicodyssey-p005-r05-frames")

func _init() -> void:
	if DisplayServer.get_name() == "headless":
		print("GPU renderer required")
		quit(2)
		return
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	DirAccess.make_dir_recursive_absolute(_frame_dir)
	print("P005-R05 GPU: %s / %s" % [Engine.get_version_info().string, RenderingServer.get_video_adapter_name()])

	# 1. Full CombatScreen 1080p and 720p baseline renders with 7 cards at rest
	for dimensions: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var vp: SubViewport = _viewport(dimensions)
		var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
		screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
		screen.size = Vector2(dimensions)
		vp.add_child(screen)
		var orbs: Array[LiquidResourceOrb] = [
			screen.get_player_health_orb(), screen.get_player_mana_orb(),
			screen.get_opponent_health_orb(), screen.get_opponent_mana_orb()
		]
		for orb: LiquidResourceOrb in orbs:
			orb.set_animation_enabled(false)

		var rendered: Image = await _render(vp)
		_save(rendered, OUT + "combat_screen_%dp.png" % dimensions.y)

		if dimensions.y == 1080:
			# Crop resting 7-card hand region
			var hand_crop_7: Image = rendered.get_region(Rect2i(0, 680, 1920, 400))
			_save(hand_crop_7, OUT + "hand_7_rest.png")

		vp.queue_free()

	# 2. 10-card hand at rest and hover inspection poses
	var vp1080: SubViewport = _viewport(Vector2i(1920, 1080))
	var screen10: CombatScreen = SCREEN.instantiate() as CombatScreen
	screen10.set_anchors_preset(Control.PRESET_TOP_LEFT)
	screen10.size = Vector2(1920, 1080)
	vp1080.add_child(screen10)
	for orb: LiquidResourceOrb in [screen10.get_player_health_orb(), screen10.get_player_mana_orb(), screen10.get_opponent_health_orb(), screen10.get_opponent_mana_orb()]:
		orb.set_animation_enabled(false)

	var fan10: CombatPreviewCards = screen10.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
	fan10.display_count = 10
	fan10.rebuild()

	# Hand 10 at rest
	var img_10_rest: Image = await _render(vp1080)
	_save(img_10_rest.get_region(Rect2i(0, 680, 1920, 400)), OUT + "hand_10_rest.png")

	# Hand 10 hover left (Card 0)
	fan10.set_inspected_card(0, 1.0)
	var img_hover_left: Image = await _render(vp1080)
	_save(img_hover_left, OUT + "hand_10_hover_left.png")
	_verify_inspected_bounds(fan10.get_child(0) as Control, Vector2(1920, 1080))

	# Hand 10 hover center (Card 4)
	fan10.set_inspected_card(4, 1.0)
	var img_hover_center: Image = await _render(vp1080)
	_save(img_hover_center, OUT + "hand_10_hover_center.png")
	_verify_inspected_bounds(fan10.get_child(4) as Control, Vector2(1920, 1080))

	# Hand 10 hover right (Card 9)
	fan10.set_inspected_card(9, 1.0)
	var img_hover_right: Image = await _render(vp1080)
	_save(img_hover_right, OUT + "hand_10_hover_right.png")
	_verify_inspected_bounds(fan10.get_child(9) as Control, Vector2(1920, 1080))

	# 3. Size Comparison Sheet (420 px, 460 px, 500 px)
	var comparison: Image = Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	var heights: Array[float] = [420.0, 460.0, 500.0]
	for idx: int in range(heights.size()):
		fan10.inspection_height = heights[idx]
		fan10.set_inspected_card(4, 1.0)
		var cmp_img: Image = await _render(vp1080)
		# Crop bottom 360 px
		comparison.blit_rect(cmp_img, Rect2i(0, 520, 1920, 360), Vector2i(0, idx * 360))
	_save(comparison, OUT + "hand_hover_size_comparison.png")
	fan10.inspection_height = 440.0

	# 4. Transition frames filmstrip and PNG sequence
	var transition_sheet: Image = Image.create(1920, 360 * 2, false, Image.FORMAT_RGBA8)
	var blend_steps: Array[float] = [0.0, 0.25, 0.5, 0.75, 1.0]
	for step_idx: int in range(blend_steps.size()):
		var b: float = blend_steps[step_idx]
		fan10.set_inspected_card(4, b)
		var frame_img: Image = await _render(vp1080)
		var sub_crop: Image = frame_img.get_region(Rect2i(320, 560, 1280, 520))
		sub_crop.resize(384, 156, Image.INTERPOLATE_LANCZOS)
		transition_sheet.blit_rect(frame_img, Rect2i(640, 540, 640, 360), Vector2i(step_idx * 384, 0))
		_save(frame_img, _frame_dir.path_join("hover_frame_%02d.png" % step_idx), false)

	# Return sequence
	var return_steps: Array[float] = [0.8, 0.6, 0.4, 0.2, 0.0]
	for ret_idx: int in range(return_steps.size()):
		var b_ret: float = return_steps[ret_idx]
		fan10.set_inspected_card(4, b_ret)
		var ret_img: Image = await _render(vp1080)
		transition_sheet.blit_rect(ret_img, Rect2i(640, 540, 640, 360), Vector2i(ret_idx * 384, 360))
		_save(ret_img, _frame_dir.path_join("hover_frame_%02d.png" % (blend_steps.size() + ret_idx)), false)
	_save(transition_sheet, OUT + "hand_hover_transition_frames.png")

	vp1080.queue_free()

	# 5. Hand hover 720p capture
	var vp720: SubViewport = _viewport(Vector2i(1280, 720))
	var screen720: CombatScreen = SCREEN.instantiate() as CombatScreen
	screen720.set_anchors_preset(Control.PRESET_TOP_LEFT)
	screen720.size = Vector2(1280, 720)
	vp720.add_child(screen720)
	for orb: LiquidResourceOrb in [screen720.get_player_health_orb(), screen720.get_player_mana_orb(), screen720.get_opponent_health_orb(), screen720.get_opponent_mana_orb()]:
		orb.set_animation_enabled(false)
	var fan720: CombatPreviewCards = screen720.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
	fan720.display_count = 10
	fan720.rebuild()
	fan720.set_inspected_card(4, 1.0)
	var img_720_hover: Image = await _render(vp720)
	_save(img_720_hover, OUT + "hand_hover_720p.png")
	vp720.queue_free()

	print("P005-R05 GPU RESULT: %s" % ("FAILED" if _failed else "PASS"))
	quit(1 if _failed else 0)

func _verify_inspected_bounds(card: Control, viewport_dims: Vector2) -> void:
	var bounds: Rect2 = Rect2(Vector2.ZERO, viewport_dims)
	for pt: Vector2 in [Vector2.ZERO, Vector2(card.size.x, 0), card.size, Vector2(0, card.size.y)]:
		var global_pt: Vector2 = card.get_global_transform() * pt
		_check(bounds.has_point(global_pt), "Inspected card corner inside viewport: %s in %s" % [global_pt, viewport_dims])

func _viewport(dimensions: Vector2i) -> SubViewport:
	var vp: SubViewport = SubViewport.new()
	vp.size = dimensions
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	return vp

func _render(vp: SubViewport) -> Image:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	return vp.get_texture().get_image()

func _save(img: Image, path: String, verbose: bool = true) -> void:
	var result: Error = img.save_png(ProjectSettings.globalize_path(path))
	if result != OK:
		_failed = true
	if verbose:
		print("CAPTURE %s %dx%d save=%d" % [path, img.get_width(), img.get_height(), result])

func _check(condition: bool, message: String) -> void:
	if not condition:
		print("FAIL: %s" % message)
		_failed = true
	else:
		print("PASS: %s" % message)
