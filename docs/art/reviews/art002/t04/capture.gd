extends SceneTree
## Reproduce all T04 review images and verify actual GPU pixels.
const OVERLAY: GDScript = preload("res://scripts/presentation/card_stat_overlay.gd")
const FIXTURE: PackedScene = preload("res://scenes/ui/art002_card_integration_test.tscn")
const OUTPUT: String = "res://docs/art/reviews/art002/t04/"
var _failures: int = 0

class NumberProbe extends CardStatOverlay:
	var value: int = 4
	func _draw() -> void:
		draw_number(Vector2(110, 110), value, 126, 145, Color.WHITE)

func _initialize() -> void:
	call_deferred("_run")

func _render(viewport: SubViewport) -> Image:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	return viewport.get_texture().get_image()

func _viewport(dimensions: Vector2i) -> SubViewport:
	var viewport: SubViewport = SubViewport.new()
	viewport.size = dimensions
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	return viewport

func _check(ok: bool, description: String) -> void:
	print("%s %s" % ["PASS" if ok else "FAIL", description])
	if not ok:
		_failures += 1

func _capture(filename: String, dimensions: Vector2i, mode: int) -> void:
	var viewport: SubViewport = _viewport(dimensions)
	var scene: Control = FIXTURE.instantiate() as Control
	scene.set_anchors_preset(Control.PRESET_TOP_LEFT)
	scene.size = Vector2(dimensions)
	viewport.add_child(scene)
	scene.set("_mode", mode)
	scene.call("_rebuild")
	var rendered: Image = await _render(viewport)
	var result: Error = rendered.save_png(OUTPUT + filename)
	_check(result == OK and rendered.get_size() == dimensions, "CAPTURE %s %s exit=%d" % [filename, dimensions, result])
	viewport.queue_free()
	await process_frame

func _check_number_pixels() -> void:
	var viewport: SubViewport = _viewport(Vector2i(220, 220))
	var probe: NumberProbe = NumberProbe.new()
	viewport.add_child(probe)
	var scales: Array[float] = [1.0, 316.0 / 1448.0, 316.0 / 1448.0 * 2.0 / 3.0]
	for factor: float in scales:
		probe.scale = Vector2.ONE * factor
		probe.position = Vector2.ONE * 110 * (1.0 - factor)
		for value: int in [0, 1, 4, 5, 10, 12, 99, 999]:
			probe.value = value
			probe.queue_redraw()
			var rendered: Image = await _render(viewport)
			var low: Vector2i = Vector2i(220, 220)
			var high: Vector2i = Vector2i(-1, -1)
			for y: int in range(220):
				for x: int in range(220):
					var pixel: Color = rendered.get_pixel(x, y)
					if pixel.a > 0.5 and pixel.r > 0.75 and pixel.g > 0.75 and pixel.b > 0.75:
						low = Vector2i(mini(low.x, x), mini(low.y, y))
						high = Vector2i(maxi(high.x, x), maxi(high.y, y))
			var center: Vector2 = (Vector2(low) + Vector2(high) + Vector2.ONE) * 0.5
			var error: Vector2 = (center - Vector2(110, 110)).abs()
			_check(high.x >= 0 and maxf(error.x, error.y) <= 1.5,
				"NUMERIC_INK value=%d scale=%.4f center=%s error=%s" % [value, factor, center, error])
	viewport.queue_free()
	await process_frame

func _check_status_isolation() -> void:
	var viewport: SubViewport = _viewport(Vector2i(1086, 1448))
	var stats: Control = OVERLAY.new()
	viewport.add_child(stats)
	stats.set_printed_values(4, 4, 5, 2)
	var before: Image = await _render(viewport)
	stats.set_shield_overlay(3)
	var during: Image = await _render(viewport)
	stats.set_shield_overlay(0)
	var after: Image = await _render(viewport)
	var outside_changes: int = 0
	var inside_changes: int = 0
	var restoration_changes: int = 0
	var shield_region: Rect2i = Rect2i(596, 1268, 222, 124)
	for y: int in range(1448):
		for x: int in range(1086):
			if before.get_pixel(x, y) != during.get_pixel(x, y):
				if shield_region.has_point(Vector2i(x, y)):
					inside_changes += 1
				else:
					outside_changes += 1
			if before.get_pixel(x, y) != after.get_pixel(x, y):
				restoration_changes += 1
	_check(inside_changes > 0 and outside_changes == 0 and restoration_changes == 0,
		"SHIELD_OVERLAY changed=%d outside=%d restore=%d" % [inside_changes, outside_changes, restoration_changes])
	stats.set_printed_values(4, 4, 5, 0)
	var no_armor: Image = await _render(viewport)
	_check(no_armor.get_pixel(417, 1330).a == 0.0 and before.get_pixel(417, 1330).a > 0.0,
		"ZERO_NATIVE_ARMOR badge hidden")
	viewport.queue_free()
	await process_frame

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("T04 capture requires a graphical renderer")
		quit(2)
		return
	await _capture("single_card_1080p.png", Vector2i(1920, 1080), 0)
	await _capture("hand_7_cards_1080p.png", Vector2i(1920, 1080), 1)
	await _capture("hand_7_cards_720p.png", Vector2i(1280, 720), 1)
	await _capture("stats_closeup_1080p.png", Vector2i(1920, 1080), 4)
	await _capture("armor_shield_samples_1080p.png", Vector2i(1920, 1080), 5)
	await _check_number_pixels()
	await _check_status_isolation()
	print("T04_VISUAL_CHECK_FAILURES=%d" % _failures)
	quit(0 if _failures == 0 else 1)
