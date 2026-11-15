extends SceneTree
## Real GPU review evidence; never substitutes headless rendering for screenshots.
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const OUT: String = "res://docs/art/reviews/p005-r06b/"
var _failed: bool = false

func _init() -> void:
	if DisplayServer.get_name() == "headless":
		quit(2)
		return
	_run.call_deferred()

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var before: bool = "--before" in OS.get_cmdline_user_args()
	print("R06B GPU: %s / %s" % [Engine.get_version_info().string, RenderingServer.get_video_adapter_name()])
	for dimensions: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var vp: SubViewport = SubViewport.new()
		vp.size = dimensions
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(vp)
		var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
		screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
		screen.size = Vector2(dimensions)
		vp.add_child(screen)
		var hp: LiquidResourceOrb = screen.get_player_health_orb()
		var mana: LiquidResourceOrb = screen.get_player_mana_orb()
		for orb: LiquidResourceOrb in [hp, mana, screen.get_opponent_health_orb(), screen.get_opponent_mana_orb()]:
			orb.set_animation_enabled(false)
		var full: Image = await _render(vp)
		var prefix: String = "before_r05_" if before else "combat_screen_"
		_save(full, prefix + "%dp.png" % dimensions.y)
		if not before:
			_save(_hud(full), "player_hud_closeup_%dp.png" % dimensions.y)
			# Outside the player column, the original R05 render must be exact.
			var baseline: Image = Image.load_from_file(OUT + "before_r05_%dp.png" % dimensions.y)
			# Include the old panel's shadow in the intentionally replaced region.
			var unaffected: Rect2i = Rect2i(roundi(320.0 * dimensions.x / 1920.0), 0, dimensions.x - roundi(320.0 * dimensions.x / 1920.0), dimensions.y)
			_check(baseline != null and baseline.get_region(unaffected).get_data() == full.get_region(unaffected).get_data(), "R05 pixels outside player HUD unchanged at %dp" % dimensions.y)
			var health_values: Array[Vector2i] = [Vector2i(30, 30), Vector2i(18, 30), Vector2i(0, 30), Vector2i(100, 100)]
			var mana_values: Array[Vector2i] = [Vector2i(1, 1), Vector2i(5, 5), Vector2i(0, 5), Vector2i(10, 10)]
			for i: int in range(health_values.size()):
				hp.set_resource_values(health_values[i].x, health_values[i].y, false)
				mana.set_resource_values(mana_values[i].x, mana_values[i].y, false)
				_save(_hud(await _render(vp)), "values_%dp_%d.png" % [dimensions.y, i])
			for state: Vector2i in [Vector2i(30, 5), Vector2i(15, 3), Vector2i(0, 0)]:
				hp.set_resource_values(state.x, 30, false)
				mana.set_resource_values(state.y, 5, false)
				_save(_hud(await _render(vp)), "state_%dp_hp%d.png" % [dimensions.y, state.x])
			# Sample the actual process clock and damage/refill transitions with GPU frames.
			hp.set_resource_values(30, 30, false)
			mana.set_resource_values(0, 5, false)
			hp.set_animation_enabled(true)
			mana.set_animation_enabled(true)
			hp.set_resource_values(15, 30)
			mana.set_resource_values(5, 5)
			var start_time: int = Time.get_ticks_msec()
			var early: Image
			for i: int in range(8):
				await create_timer(0.055).timeout
				var motion: Image = await _render(vp)
				_save(_hud(motion), "transition_%dp_%02d.png" % [dimensions.y, i])
				print("TRANSITION %dp frame=%d elapsed_ms=%d hp=%.5f mana=%.5f" % [dimensions.y, i, Time.get_ticks_msec() - start_time, hp.get_visible_fill_ratio(), mana.get_visible_fill_ratio()])
				if i == 0:
					early = motion
				if i == 7:
					_check(_hud(early).get_data() != _hud(motion).get_data(), "GPU damage/refill changes")
			_check(is_equal_approx(hp.get_visible_fill_ratio(), 0.5) and is_equal_approx(mana.get_visible_fill_ratio(), 1.0), "Animated resources settle independently")
			var wave_a: Image = _hud(await _render(vp))
			await create_timer(0.45).timeout
			var wave_b: Image = _hud(await _render(vp))
			_save(wave_a, "wave_%dp_a.png" % dimensions.y)
			_save(wave_b, "wave_%dp_b.png" % dimensions.y)
			_check(wave_a.get_data() != wave_b.get_data(), "GPU liquid motion continues after settling")
		vp.queue_free()
	print("R06B GPU RESULT: %s" % ("FAIL" if _failed else "PASS"))
	quit(1 if _failed else 0)

func _render(vp: SubViewport) -> Image:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	return vp.get_texture().get_image()

func _hud(img: Image) -> Image:
	var factor: float = img.get_width() / 1920.0
	return img.get_region(Rect2i(roundi(16 * factor), roundi(210 * factor), roundi(288 * factor), roundi(720 * factor)))

func _save(img: Image, name: String) -> void:
	_check(img.save_png(ProjectSettings.globalize_path(OUT + name)) == OK, "CAPTURE " + name)

func _check(condition: bool, message: String) -> void:
	print("%s: %s" % ["PASS" if condition else "FAIL", message])
	_failed = _failed or not condition
