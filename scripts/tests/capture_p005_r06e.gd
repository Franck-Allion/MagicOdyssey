extends SceneTree
## Actual GPU captures; before is the same scene with only the old parent position.
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const OUT: String = "res://docs/art/reviews/p005-r06e/"
var _failed: bool = false

func _init() -> void:
	if DisplayServer.get_name() == "headless":
		quit(2)
		return
	_run.call_deferred()

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	print("R06E GPU: %s / %s" % [Engine.get_version_info().string, RenderingServer.get_video_adapter_name()])
	for dimensions: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var vp: SubViewport = SubViewport.new()
		vp.size = dimensions
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(vp)
		var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
		screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
		screen.size = Vector2(dimensions)
		vp.add_child(screen)
		for orb: LiquidResourceOrb in [screen.get_player_health_orb(), screen.get_player_mana_orb(), screen.get_opponent_health_orb(), screen.get_opponent_mana_orb()]:
			orb.set_animation_enabled(false)
		var after: Image = await _render(vp)
		var hud_bounds: Rect2 = screen.get_player_hero_zone().get_global_rect()
		_check(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(hud_bounds), "Live HUD fully inside viewport")
		_check(is_equal_approx(Vector2(dimensions).y - hud_bounds.end.y, 36.0 * float(dimensions.y) / 1080.0), "Live scaled bottom margin")
		_check_containment(screen.get_player_hero_zone(), hud_bounds)
		_save(after, "combat_screen_%dp.png" % dimensions.y)
		var factor: float = float(dimensions.y) / 1080.0
		_save(after.get_region(Rect2i(roundi(16 * factor), roundi(330 * factor), roundi(288 * factor), roundi(738 * factor))), "player_hud_bottom_left_%dp.png" % dimensions.y)
		screen.get_player_hero_zone().position.y = 220.0
		var before: Image = await _render(vp)
		_save(before, "before_%dp.png" % dimensions.y)
		# Full-screen comparison retains the bottom edge and upper-left free space.
		if dimensions.y == 1080:
			var comparison: Image = Image.create_empty(3840, 1080, false, after.get_format())
			comparison.blit_rect(before, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
			comparison.blit_rect(after, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
			_save(comparison, "before_after_comparison_1080p.png")
		_check(before.get_region(Rect2i(roundi(320 * factor), 0, dimensions.x - roundi(320 * factor), dimensions.y)).get_data() == after.get_region(Rect2i(roundi(320 * factor), 0, dimensions.x - roundi(320 * factor), dimensions.y)).get_data(), "Outside left column bit-exact at %dp" % dimensions.y)
		screen.get_player_hero_zone().position.y = 344.0
		var hp: LiquidResourceOrb = screen.get_player_health_orb()
		var mana: LiquidResourceOrb = screen.get_player_mana_orb()
		for orb: LiquidResourceOrb in [hp, mana]:
			orb.set_animation_enabled(true)
		hp.set_resource_values(18, 30, false)
		mana.set_resource_values(3, 5, false)
		var first: Image = await _render(vp)
		_save(first, "animation_%dp_0.png" % dimensions.y)
		await create_timer(0.3).timeout
		var second: Image = await _render(vp)
		_save(second, "animation_%dp_1.png" % dimensions.y)
		for orb: LiquidResourceOrb in [hp, mana]:
			var rect: Rect2 = orb.get_global_rect()
			var region: Rect2i = Rect2i(rect)
			_check(first.get_region(region).get_data() != second.get_region(region).get_data(), "%s GPU waves animate at %dp" % [orb.name, dimensions.y])
		vp.queue_free()
		await process_frame
	print("R06E GPU RESULT: %s" % ("FAIL" if _failed else "PASS"))
	quit(1 if _failed else 0)

func _render(vp: SubViewport) -> Image:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	return vp.get_texture().get_image()

func _save(img: Image, filename: String) -> void:
	_check(img.save_png(ProjectSettings.globalize_path(OUT + filename)) == OK, "CAPTURE " + filename)

func _check(condition: bool, message: String) -> void:
	print("%s: %s" % ["PASS" if condition else "FAIL", message])
	_failed = _failed or not condition

func _check_containment(parent: Control, bounds: Rect2) -> void:
	for node: Node in parent.get_children():
		var child: Control = node as Control
		if child == null or not child.is_visible_in_tree():
			continue
		_check(bounds.encloses(child.get_global_rect()), "Live child contained: " + str(child.name))
		_check_containment(child, bounds)
