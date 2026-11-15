extends SceneTree
## Genuine GPU captures plus timed animation assertions. Never updates P005/goldens.
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const DEMO: PackedScene = preload("res://scenes/hud/liquid_orbs_demo.tscn")
const ORB: PackedScene = preload("res://scenes/hud/liquid_resource_orb.tscn")
const OUT: String = "res://docs/art/reviews/p005-r04/"
var _failed: bool = false
var _frame_dir: String = OS.get_environment("TEMP").path_join("magicodyssey-p005-r04-frames")

func _init() -> void:
	if DisplayServer.get_name() == "headless":
		print("GPU renderer required")
		quit(2)
		return
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	DirAccess.make_dir_recursive_absolute(_frame_dir)
	print("Animation PNG frames: %s" % _frame_dir)
	print("P005-R04 GPU: %s / %s" % [Engine.get_version_info().string, RenderingServer.get_video_adapter_name()])
	for dimensions: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var vp: SubViewport = _viewport(dimensions)
		var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
		screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
		screen.size = Vector2(dimensions)
		vp.add_child(screen)
		var orbs: Array[LiquidResourceOrb] = [screen.get_player_health_orb(), screen.get_player_mana_orb(), screen.get_opponent_health_orb(), screen.get_opponent_mana_orb()]
		for orb: LiquidResourceOrb in orbs:
			orb.set_animation_enabled(false)
		_save(await _render(vp), OUT + "combat_screen_%dp.png" % dimensions.y)
		for orb: LiquidResourceOrb in orbs:
			_check(orb.is_node_ready(), "Integrated orb ready: %s" % orb.name)
			_check(orb.get_global_rect().size.x > 0.0, "Integrated orb has visible bounds")
		vp.queue_free()
	await _hand_evidence()
	var gallery_vp: SubViewport = _viewport(Vector2i(1400, 900))
	var demo: Control = DEMO.instantiate() as Control
	gallery_vp.add_child(demo)
	demo.set_process(false)
	for child: Node in demo.get_children():
		if child is LiquidResourceOrb:
			(child as LiquidResourceOrb).set_animation_enabled(false)
	_save(await _render(gallery_vp), OUT + "liquid_orbs_states.png")
	gallery_vp.queue_free()
	await _animation_evidence()
	print("GPU / ANIMATION RESULT: %s" % ("FAILED" if _failed else "PASS"))
	quit(1 if _failed else 0)

func _animation_evidence() -> void:
	var vp: SubViewport = _viewport(Vector2i(640, 360))
	var background: ColorRect = ColorRect.new()
	background.color = Color(0.047, 0.063, 0.094)
	background.size = Vector2(640, 360)
	vp.add_child(background)
	var health: LiquidResourceOrb = ORB.instantiate() as LiquidResourceOrb
	health.position = Vector2(55, 60)
	health.size = Vector2(240, 240)
	vp.add_child(health)
	var mana: LiquidResourceOrb = ORB.instantiate() as LiquidResourceOrb
	mana.position = Vector2(345, 60)
	mana.size = Vector2(240, 240)
	mana.set_resource_kind(LiquidResourceOrb.ResourceKind.MANA)
	vp.add_child(mana)
	var caption: Label = Label.new()
	caption.position = Vector2(45, 15)
	caption.add_theme_font_size_override("font_size", 20)
	vp.add_child(caption)
	health.set_resource_values(30, 30, false)
	mana.set_resource_values(5, 5, false)
	var sheet: Image = Image.create(640 * 4, 360 * 2, false, Image.FORMAT_RGBA8)
	var sample_frame: int = 0
	var csv: String = "step,frame,health_visible,mana_visible\n"
	var health_steps: Array[int] = [30, 21, 8, 0]
	var mana_steps: Array[int] = [5, 3, 0, 5]
	for step: int in range(4):
		var previous_health: float = health.get_visible_fill_ratio()
		var previous_mana: float = mana.get_visible_fill_ratio()
		health.set_resource_values(health_steps[step], 30)
		mana.set_resource_values(mana_steps[step], 5)
		_check((health.get_node("Values") as Label).text == "%d / 30" % health_steps[step], "Exact Health label updates before animation")
		if step > 0:
			_check(is_equal_approx(previous_health, health.get_visible_fill_ratio()), "Transition starts from previous visible level")
		for frame: int in range(12):
			caption.text = "HP %d / 30     MANA %d / 5     •     frame %02d" % [health_steps[step], mana_steps[step], sample_frame]
			await create_timer(0.06).timeout
			var rendered: Image = await _render(vp)
			_save(rendered, _frame_dir.path_join("frame_%03d.png" % sample_frame), false)
			csv += "%d,%d,%.6f,%.6f\n" % [step, sample_frame, health.get_visible_fill_ratio(), mana.get_visible_fill_ratio()]
			if frame == 0:
				sheet.blit_rect(rendered, Rect2i(0, 0, 640, 360), Vector2i(step * 640, 0))
				if step > 0:
					_check(health.get_visible_fill_ratio() < previous_health and health.get_visible_fill_ratio() > float(health_steps[step]) / 30.0, "Health intermediate liquid level")
					_check(not is_equal_approx(mana.get_visible_fill_ratio(), previous_mana), "Mana fill moves promptly")
			if frame == 11:
				sheet.blit_rect(rendered, Rect2i(0, 0, 640, 360), Vector2i(step * 640, 360))
			sample_frame += 1
		_check(is_equal_approx(health.get_visible_fill_ratio(), float(health_steps[step]) / 30.0), "Health settles")
		_check(is_equal_approx(mana.get_visible_fill_ratio(), float(mana_steps[step]) / 5.0), "Mana settles")
	_save(sheet, OUT + "liquid_orbs_motion_frames.png")
	var log_file: FileAccess = FileAccess.open(OUT + "animation_samples.csv", FileAccess.WRITE)
	log_file.store_string(csv)
	log_file.close()
	# Sample the actual damped surface after the level reaches its target.
	var settling: Image = Image.create(640 * 6, 360, false, Image.FORMAT_RGBA8)
	var settling_csv: String = "sample,elapsed,fill,tilt\n"
	var elapsed: float = 0.0
	await process_frame
	health.set_resource_values(30, 30, false)
	health.set_resource_values(18, 30)
	var started_usec: int = Time.get_ticks_usec()
	for index: int in range(6):
		await create_timer(0.13 if index < 3 else 0.4).timeout
		caption.text = "LOSS 30 -> 18 / 30 | settling sample %d" % index
		var frame_image: Image = await _render(vp)
		elapsed = float(Time.get_ticks_usec() - started_usec) / 1000000.0
		settling.blit_rect(frame_image, Rect2i(0, 0, 640, 360), Vector2i(index * 640, 0))
		settling_csv += "%d,%.4f,%.6f,%.7f\n" % [index, elapsed, health.get_visible_fill_ratio(), float(health._orb_material.get_shader_parameter("surface_tilt"))]
		if index == 3:
			_check(is_equal_approx(health.get_visible_fill_ratio(), 0.6), "Fill settled before residual surface motion ends")
	_check(absf(float(health._orb_material.get_shader_parameter("surface_tilt"))) < 0.0002, "Residual slosh damps to rest")
	_save(settling, OUT + "liquid_settling.png")
	var settling_file: FileAccess = FileAccess.open(OUT + "settling_samples.csv", FileAccess.WRITE)
	settling_file.store_string(settling_csv)
	settling_file.close()
	# Constant fill, changing clock: actual GPU pixels must change without level changes.
	health.set_resource_values(18, 30, false)
	caption.text = "CONSTANT FILL  •  HP 18 / 30  •  WAVES / BUBBLES"
	var moving_a: Image = await _render(vp)
	await create_timer(0.35).timeout
	var moving_b: Image = await _render(vp)
	var liquid_rect: Rect2i = Rect2i(95, 100, 155, 155)
	_check(moving_a.get_region(liquid_rect).get_data() != moving_b.get_region(liquid_rect).get_data(), "GPU waves/bubbles move at fixed fill")
	_save(moving_a, OUT + "motion_a.png")
	_save(moving_b, OUT + "motion_b.png")
	# Rapid interruption and identical target must not restart or accumulate transitions.
	health.set_resource_values(6, 30)
	await create_timer(0.08).timeout
	var interrupted: float = health.get_visible_fill_ratio()
	health.set_resource_values(24, 30)
	_check(is_equal_approx(interrupted, health.get_visible_fill_ratio()), "Rapid retarget is continuous")
	for update: int in range(8):
		health.set_resource_values(24, 30)
		await create_timer(0.05).timeout
	_check(is_equal_approx(health.get_visible_fill_ratio(), 0.8), "Repeated identical updates do not restart animation")
	_check(is_equal_approx(mana.get_visible_fill_ratio(), 1.0), "Health updates leave Mana full")
	health.set_animation_enabled(false)
	mana.set_animation_enabled(false)
	var frozen_a: Image = await _render(vp)
	await create_timer(0.1).timeout
	var frozen_b: Image = await _render(vp)
	_check(frozen_a.get_data() == frozen_b.get_data(), "Static capture is bit exact across time")
	# Endpoint and circular clipping verification samples, away from labels/reflections.
	health.set_resource_values(0, 30, false)
	var empty: Image = await _render(vp)
	health.set_resource_values(30, 30, false)
	var full: Image = await _render(vp)
	_check(full.get_pixel(175, 235).r > empty.get_pixel(175, 235).r + 0.03, "GPU bottom fills at 100% and empties at 0%")
	_check(full.get_pixel(175, 105).r > empty.get_pixel(175, 105).r + 0.03, "GPU top fills at 100% and empties at 0%")
	_check(full.get_pixel(60, 65) == empty.get_pixel(60, 65), "No liquid outside circular housing")
	vp.queue_free()

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
	print("%s: %s" % ["PASS" if condition else "FAIL", message])
	if not condition:
		_failed = true

func _hand_evidence() -> void:
	for dimensions: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var vp: SubViewport = _viewport(dimensions)
		var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
		screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
		screen.size = Vector2(dimensions)
		vp.add_child(screen)
		var fan: CombatPreviewCards = screen.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
		for orb: LiquidResourceOrb in [screen.get_player_health_orb(), screen.get_player_mana_orb(), screen.get_opponent_health_orb(), screen.get_opponent_mana_orb()]:
			orb.set_animation_enabled(false)
		for count: int in [1, 3, 5, 7, 10]:
			fan.display_count = count
			fan.rebuild()
			var filename: String = "hand_%d_card%s%s.png" % [count, "" if count == 1 else "s", "_720p" if dimensions.y == 720 else ""]
			_save(await _render(vp), OUT + filename)
			for child: Node in fan.get_children():
				var card: Control = child as Control
				for point: Vector2 in [Vector2.ZERO, Vector2(card.size.x, 0), card.size, Vector2(0, card.size.y)]:
					_check(Rect2(Vector2.ZERO, Vector2(dimensions) + Vector2.ONE).has_point(card.get_global_transform() * point), "GPU fan corners enclosed")
		if dimensions.y == 1080:
			var comparison: Image = Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
			for index: int in range(3):
				fan.preferred_height = float(270 + 30 * index)
				fan.rebuild()
				var image: Image = await _render(vp)
				_save(image, OUT + "candidate_%d.png" % int(fan.preferred_height))
				comparison.blit_rect(image, Rect2i(0, 720, 1920, 360), Vector2i(0, index * 360))
			_save(comparison, OUT + "hand_card_size_comparison.png")
			fan.preferred_height = 270.0
			fan.rebuild()
			for index: int in [0, 4, 9]:
				for frame: int in range(8):
					fan.set_inspected_card(index, float(frame) / 7.0)
					await _render(vp)
				var raised: Control = fan.get_child(index) as Control
				for point: Vector2 in [Vector2.ZERO, Vector2(raised.size.x, 0), raised.size, Vector2(0, raised.size.y)]:
					_check(Rect2(Vector2.ZERO, Vector2(dimensions)).has_point(raised.get_global_transform() * point), "Inspected card contained")
				_save(await _render(vp), OUT + "hand_hover_%d.png" % index)
			fan.set_inspected_card(4)
			_save(await _render(vp), OUT + "hand_hover_preview.png")
			fan.set_inspected_card(-1)
			var hud: Image = await _render(vp)
			_save(hud.get_region(Rect2i(24, 220, 272, 700)), OUT + "player_hud_closeup.png")
		vp.queue_free()
