extends SceneTree
## P005-R06D GPU capture script for Player HUD Micro-Polish (Orb Fit & Breathing Room).
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const OUT: String = "res://docs/art/reviews/p005-r06d/"
const BEFORE_R06C_PATH: String = "res://docs/art/reviews/p005-r06c/player_hud_after_1080p.png"
var _failed: bool = false

func _init() -> void:
	if DisplayServer.get_name() == "headless":
		quit(2)
		return
	_run.call_deferred()

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	print("P005-R06D GPU: %s / %s" % [Engine.get_version_info().string, RenderingServer.get_video_adapter_name()])

	# 1. Establish player_hud_before_1080p.png from R06C approved baseline
	var before_img: Image = Image.load_from_file(ProjectSettings.globalize_path(BEFORE_R06C_PATH))
	if before_img != null:
		_save(before_img, "player_hud_before_1080p.png")
		print("PASS: Loaded R06C player_hud_before_1080p.png (%dx%d)" % [before_img.get_width(), before_img.get_height()])
	else:
		print("WARN: Could not load R06C baseline image from %s" % BEFORE_R06C_PATH)

	var after_hud_1080p: Image = null

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
		_save(full, "combat_screen_%dp.png" % dimensions.y)
		var hud: Image = _hud(full)
		_save(hud, "player_hud_after_%dp.png" % dimensions.y)

		if dimensions.y == 1080:
			after_hud_1080p = hud
			# Dedicated closeups for required states
			# 1. HP 30 / 30, Mana 1 / 1
			hp.set_resource_values(30, 30, false)
			mana.set_resource_values(1, 1, false)
			var img_30_1: Image = await _render(vp)
			_save(_crop_hp_orb(img_30_1), "closeup_hp_30_30.png")
			_save(_crop_mana_orb(img_30_1), "closeup_mana_1_1.png")

			# 2. HP 100 / 100, Mana 10 / 10
			hp.set_resource_values(100, 100, false)
			mana.set_resource_values(10, 10, false)
			var img_100_10: Image = await _render(vp)
			_save(_crop_hp_orb(img_100_10), "closeup_hp_100_100.png")
			_save(_crop_mana_orb(img_100_10), "closeup_mana_10_10.png")

		vp.queue_free()

	# Create side-by-side before/after comparison sheet for 1080p
	if before_img != null and after_hud_1080p != null:
		var w: int = before_img.get_width()
		var h: int = before_img.get_height()
		var comp: Image = Image.create_empty(w * 2 + 16, h, false, Image.FORMAT_RGBA8)
		comp.fill(Color(0.04, 0.05, 0.08, 1.0))
		comp.blit_rect(before_img, Rect2i(0, 0, w, h), Vector2i(0, 0))
		comp.blit_rect(after_hud_1080p, Rect2i(0, 0, w, h), Vector2i(w + 16, 0))
		_save(comp, "before_after_comparison_1080p.png")

	print("P005-R06D GPU RESULT: %s" % ("FAIL" if _failed else "PASS"))
	quit(1 if _failed else 0)

func _render(vp: SubViewport) -> Image:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	return vp.get_texture().get_image()

func _hud(img: Image) -> Image:
	var factor: float = img.get_width() / 1920.0
	return img.get_region(Rect2i(roundi(16 * factor), roundi(210 * factor), roundi(288 * factor), roundi(720 * factor)))

func _crop_hp_orb(img: Image) -> Image:
	# HP orb is at x=24+46=70, y=220+252=472, size 180x180 (with 10px margin around)
	return img.get_region(Rect2i(60, 462, 200, 200))

func _crop_mana_orb(img: Image) -> Image:
	# Mana orb is at x=24+46=70, y=220+452=672, size 180x180 (with 10px margin around)
	return img.get_region(Rect2i(60, 662, 200, 200))

func _save(img: Image, name: String) -> void:
	var path: String = ProjectSettings.globalize_path(OUT + name)
	var err: Error = img.save_png(path)
	_check(err == OK, "CAPTURE " + name)

func _check(condition: bool, message: String) -> void:
	print("%s: %s" % ["PASS" if condition else "FAIL", message])
	_failed = _failed or not condition
