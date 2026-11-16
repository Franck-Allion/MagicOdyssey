extends SceneTree
## P005-R09B: Premium Card Hover Readability & Inspection Polish GPU Capture Script
## Generates genuine GPU renders at 1920x1080 and 1280x720 for candidate comparisons and final evidence.

const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const OUT: String = "res://docs/art/reviews/p005-r09b/"

var observations: Dictionary[String, Variant] = {}

func _init() -> void:
	if DisplayServer.get_name() == "headless":
		print("ERROR: Graphical display server required for GPU captures.")
		quit(2)
		return
	_run.call_deferred()

func _run() -> void:
	print("P005-R09B GPU Capture Suite")
	print("Engine: %s | GPU: %s" % [Engine.get_version_info().string, RenderingServer.get_video_adapter_name()])

	observations["engine"] = Engine.get_version_info().string
	observations["adapter"] = RenderingServer.get_video_adapter_name()
	observations["timestamp"] = Time.get_datetime_string_from_system()

	# 1. Candidate Comparison Captures at 720p (440 px baseline, 500 px candidate, 540 px candidate)
	await _capture_candidate_comparisons()

	# 2. Production Final Captures across 1080p and 720p
	await _capture_production_scenarios()

	# 3. Generate side-by-side before/after comparison
	_generate_before_after_comparison()

	# Save observations
	var file: FileAccess = FileAccess.open(OUT + "observations.json", FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(observations, "  "))
		file.close()

	print("P005-R09B GPU Captures completed successfully.")
	quit(0)

func _create_viewport(dim: Vector2i) -> SubViewport:
	var vp: SubViewport = SubViewport.new()
	vp.size = dim
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
	screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
	screen.size = Vector2(dim)
	vp.add_child(screen)
	# Disable orb liquid animation during static captures for bit-stable frames
	screen.get_player_health_orb().set_animation_enabled(false)
	screen.get_player_mana_orb().set_animation_enabled(false)
	screen.get_opponent_health_orb().set_animation_enabled(false)
	screen.get_opponent_mana_orb().set_animation_enabled(false)
	return vp

func _render_image(vp: SubViewport) -> Image:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	return vp.get_texture().get_image()

func _save_png(img: Image, filename: String) -> void:
	var path: String = ProjectSettings.globalize_path(OUT + filename)
	var err: Error = img.save_png(path)
	print("  [SAVED] %s (%d×%d px, err=%d)" % [filename, img.get_width(), img.get_height(), err])

func _capture_candidate_comparisons() -> void:
	print("--- Running Candidate Size Comparison Captures (720p) ---")
	var dim: Vector2i = Vector2i(1280, 720)
	var candidates: Array[Dictionary] = [
		{"height": 440.0, "file": "baseline_hover_720p.png", "label": "Candidate A: 440 px (Baseline)"},
		{"height": 500.0, "file": "candidate_500_720p.png", "label": "Candidate B: 500 px"},
		{"height": 540.0, "file": "candidate_540_720p.png", "label": "Candidate C: 540 px (Selected)"}
	]

	var candidate_metrics: Array[Dictionary] = []

	for c: Dictionary in candidates:
		var vp: SubViewport = _create_viewport(dim)
		var screen: CombatScreen = vp.get_child(0) as CombatScreen
		var fan: CombatPreviewCards = screen.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
		fan.display_count = 10
		fan.inspection_height = c["height"]
		fan.rebuild()
		fan.set_inspected_card(9, 1.0) # Inspect Archon of the Sundered Sphere

		var img: Image = await _render_image(vp)
		_save_png(img, c["file"])

		# Record metrics
		var inspected_card: Control = fan.get_child(9) as Control
		var card_global_rect: Rect2 = inspected_card.get_global_rect()
		var scale_factor: float = (c["height"] as float / 1448.0) * (2.0 / 3.0)
		var long_title_pt: int = 48
		var rules_pt: int = 48
		var short_title_pt: int = 68

		candidate_metrics.append({
			"height_ref": c["height"],
			"height_physical_720p": c["height"] * (2.0 / 3.0),
			"width_physical_720p": c["height"] * 0.75 * (2.0 / 3.0),
			"card_screen_rect_720p": [card_global_rect.position.x, card_global_rect.position.y, card_global_rect.size.x, card_global_rect.size.y],
			"long_title_physical_px": float(long_title_pt) * scale_factor,
			"rules_physical_px": float(rules_pt) * scale_factor,
			"short_title_physical_px": float(short_title_pt) * scale_factor
		})

		root.remove_child(vp)
		vp.queue_free()
		await process_frame

	observations["candidates_720p"] = candidate_metrics

func _capture_production_scenarios() -> void:
	print("--- Running Production Final Captures (1080p & 720p) ---")

	for dim: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var res_str: String = "%dp" % dim.y
		var vp: SubViewport = _create_viewport(dim)
		var screen: CombatScreen = vp.get_child(0) as CombatScreen
		var fan: CombatPreviewCards = screen.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards

		# Full resting hand (10 cards stress)
		fan.display_count = 10
		fan.rebuild()
		var img_full: Image = await _render_image(vp)
		_save_png(img_full, "final_full_hand_%s.png" % res_str)

		# Leftmost card (index 0: Arcane Knight)
		fan.set_inspected_card(0, 1.0)
		var img_left: Image = await _render_image(vp)
		_save_png(img_left, "final_hover_left_%s.png" % res_str)

		# Center card (index 4: Pyretic Inscription)
		fan.set_inspected_card(4, 1.0)
		var img_center: Image = await _render_image(vp)
		_save_png(img_center, "final_hover_center_%s.png" % res_str)

		# Rightmost card (index 9: Archon of the Sundered Sphere)
		fan.set_inspected_card(9, 1.0)
		var img_right: Image = await _render_image(vp)
		_save_png(img_right, "final_hover_right_%s.png" % res_str)

		if dim.y == 720:
			# Long title capture (index 9)
			_save_png(img_right, "final_hover_long_title_720p.png")

			# Rules text capture (index 1: Arcane Study)
			fan.set_inspected_card(1, 1.0)
			var img_rules: Image = await _render_image(vp)
			_save_png(img_rules, "final_hover_rules_720p.png")

			# Spell preview capture (index 1)
			_save_png(img_rules, "final_hover_spell_720p.png")

			# Equipment preview capture (index 2: Runic Relic)
			fan.set_inspected_card(2, 1.0)
			var img_equip: Image = await _render_image(vp)
			_save_png(img_equip, "final_hover_equipment_720p.png")

		root.remove_child(vp)
		vp.queue_free()
		await process_frame

func _generate_before_after_comparison() -> void:
	print("--- Generating Side-by-Side Before/After Readability Comparison (720p) ---")
	var path_base: String = ProjectSettings.globalize_path(OUT + "baseline_hover_720p.png")
	var path_final: String = ProjectSettings.globalize_path(OUT + "final_hover_right_720p.png")

	var img_base: Image = Image.load_from_file(path_base)
	var img_final: Image = Image.load_from_file(path_final)

	if img_base == null or img_final == null:
		push_error("Could not load baseline or final images for comparison.")
		return

	# Crop the card inspection region at 720p (card is around center/right)
	# Screen is 1280x720. Focus on the hand inspection area (x=600..1200, y=280..720)
	var crop_rect: Rect2i = Rect2i(600, 280, 640, 440)
	var crop_base: Image = img_base.get_region(crop_rect)
	var crop_final: Image = img_final.get_region(crop_rect)

	# Create side-by-side image: 1280 x 440
	var comp: Image = Image.create(1280, 440, false, Image.FORMAT_RGBA8)
	comp.blit_rect(crop_base, Rect2i(0, 0, 640, 440), Vector2i(0, 0))
	comp.blit_rect(crop_final, Rect2i(0, 0, 640, 440), Vector2i(640, 0))

	_save_png(comp, "before_after_readability_720p.png")
