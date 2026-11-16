extends SceneTree
## P005-R09C: Final CombatScreen Artistic Sign-off GPU Capture Script
## Generates definitive GPU review evidence at 1920x1080 and 1280x720.

const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const OUT: String = "res://docs/art/reviews/p005-r09c/"

var observations: Dictionary[String, Variant] = {}

func _init() -> void:
	if DisplayServer.get_name() == "headless":
		print("ERROR: Graphical display server required for GPU captures.")
		quit(2)
		return
	_run.call_deferred()

func _run() -> void:
	print("P005-R09C GPU Capture Suite: Final CombatScreen Artistic Sign-off")
	print("Engine: %s | GPU: %s" % [Engine.get_version_info().string, RenderingServer.get_video_adapter_name()])

	observations["engine"] = Engine.get_version_info().string
	observations["adapter"] = RenderingServer.get_video_adapter_name()
	observations["timestamp"] = Time.get_datetime_string_from_system()

	# A. Standard CombatScreen (1080p and 720p)
	await _capture_standard_combat()

	# B. Full Hand Stress (10 cards at 1080p and 720p)
	await _capture_full_hand_stress()

	# C. Card Inspection at 720p (left, center, right, long title, spell, equipment)
	await _capture_720p_hover_inspection()

	# D. Populated Utility HUD (1080p and 720p)
	await _capture_populated_utility()

	# E. Crowded Battlefield Compatibility Diagnostic (1080p and 720p)
	await _capture_crowded_board_diagnostic()

	# F. Timed Resource Animation Samples
	await _capture_resource_animation_samples()

	# Save observations
	var file: FileAccess = FileAccess.open(OUT + "observations.json", FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(observations, "  "))
		file.close()

	print("P005-R09C GPU Captures completed successfully.")
	quit(0)

func _create_viewport(dim: Vector2i, animate_orbs: bool = false) -> SubViewport:
	var vp: SubViewport = SubViewport.new()
	vp.size = dim
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
	screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
	screen.size = Vector2(dim)
	vp.add_child(screen)
	if not animate_orbs:
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

func _capture_standard_combat() -> void:
	print("--- A. Capturing Standard CombatScreen (1080p & 720p) ---")
	for dim: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var vp: SubViewport = _create_viewport(dim)
		var screen: CombatScreen = vp.get_child(0) as CombatScreen
		var fan: CombatPreviewCards = screen.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
		fan.display_count = 7
		fan.rebuild()

		var img: Image = await _render_image(vp)
		_save_png(img, "final_combat_%dp.png" % dim.y)

		root.remove_child(vp)
		vp.queue_free()
		await process_frame

func _capture_full_hand_stress() -> void:
	print("--- B. Capturing Full Hand Stress (10 cards at 1080p & 720p) ---")
	for dim: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var vp: SubViewport = _create_viewport(dim)
		var screen: CombatScreen = vp.get_child(0) as CombatScreen
		var fan: CombatPreviewCards = screen.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
		fan.display_count = 10
		fan.rebuild()

		var img: Image = await _render_image(vp)
		_save_png(img, "final_full_hand_%dp.png" % dim.y)

		root.remove_child(vp)
		vp.queue_free()
		await process_frame

func _capture_720p_hover_inspection() -> void:
	print("--- C. Capturing Card Inspection Scenarios at 720p ---")
	var dim: Vector2i = Vector2i(1280, 720)
	var vp: SubViewport = _create_viewport(dim)
	var screen: CombatScreen = vp.get_child(0) as CombatScreen
	var fan: CombatPreviewCards = screen.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
	fan.display_count = 10
	fan.rebuild()

	var targets: Array[Dictionary] = [
		{"index": 0, "file": "final_hover_left_720p.png", "desc": "Leftmost card (Arcane Knight)"},
		{"index": 4, "file": "final_hover_center_720p.png", "desc": "Center card (Pyretic Inscription)"},
		{"index": 9, "file": "final_hover_right_720p.png", "desc": "Rightmost card (Archon of the Sundered Sphere)"},
		{"index": 9, "file": "final_hover_long_title_720p.png", "desc": "Long title wrapped (Archon of the Sundered Sphere)"},
		{"index": 1, "file": "final_hover_spell_720p.png", "desc": "Spell preview (Arcane Study)"},
		{"index": 2, "file": "final_hover_equipment_720p.png", "desc": "Equipment preview (Runic Relic)"}
	]

	var font_measurements: Array[Dictionary] = []

	for t: Dictionary in targets:
		fan.set_inspected_card(t["index"], 1.0)
		var img: Image = await _render_image(vp)
		_save_png(img, t["file"])

		var card: Control = fan.get_child(t["index"]) as Control
		var content: CardContentOverlay = null
		for c: Node in card.get_children():
			if c is CardContentOverlay:
				content = c as CardContentOverlay
				break

		if content != null:
			var scale_720p: float = card.scale.y * (2.0 / 3.0)
			font_measurements.append({
				"index": t["index"],
				"file": t["file"],
				"title": content.accepted_content.title,
				"title_font_size_pt": content.title_font_size,
				"title_physical_px_720p": float(content.title_font_size) * scale_720p,
				"rules_font_size_pt": content.rules_font_size,
				"rules_physical_px_720p": float(content.rules_font_size) * scale_720p,
				"card_bounds_720p": [card.get_global_rect().position.x, card.get_global_rect().position.y, card.get_global_rect().size.x, card.get_global_rect().size.y]
			})

	observations["hover_measurements_720p"] = font_measurements

	root.remove_child(vp)
	vp.queue_free()
	await process_frame

func _capture_populated_utility() -> void:
	print("--- D. Capturing Populated Utility HUD (1080p & 720p) ---")
	for dim: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var vp: SubViewport = _create_viewport(dim)
		var screen: CombatScreen = vp.get_child(0) as CombatScreen

		# Populate recent actions
		screen.set_turn_preview("TURN 03", "PLAYER  /  ACTION")
		screen.set_recent_actions_preview([
			"Arcane Knight summoned in Col 2",
			"Arcane Study cast (-3 Mana)",
			"Rampart Guard attacked (-2 HP)"
		])

		# Populate player and opponent deck counts
		screen.get_player_deck().visual_count = 32
		screen.get_opponent_deck().visual_count = 28

		# Populate player and opponent graveyards
		var gy_card_player: GraveyardView.PreviewCard = GraveyardView.PreviewCard.new()
		gy_card_player.title = "Arcane Knight"
		screen.get_player_graveyard().set_preview(3, gy_card_player)

		var gy_card_opponent: GraveyardView.PreviewCard = GraveyardView.PreviewCard.new()
		gy_card_opponent.title = "Rampart Guard"
		screen.get_opponent_graveyard().set_preview(2, gy_card_opponent)

		var img: Image = await _render_image(vp)
		_save_png(img, "final_populated_utility_%dp.png" % dim.y)

		root.remove_child(vp)
		vp.queue_free()
		await process_frame

func _capture_crowded_board_diagnostic() -> void:
	print("--- E. Capturing Crowded Battlefield Diagnostic (1080p & 720p) ---")
	for dim: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var vp: SubViewport = _create_viewport(dim)
		var screen: CombatScreen = vp.get_child(0) as CombatScreen

		# Add diagnostic 24-slot geometry placeholders
		var group: Control = Control.new()
		group.name = "Diagnostic24SlotGeometry"
		screen.get_combat_layout().add_child(group)

		var tag: Label = Label.new()
		tag.text = "DIAGNOSTIC ONLY — 24 GEOMETRY PLACEHOLDERS — P008 TOKEN NOT IMPLEMENTED"
		tag.position = Vector2(480, 192)
		tag.size = Vector2(960, 26)
		tag.add_theme_font_size_override("font_size", 16)
		tag.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4, 0.95))
		group.add_child(tag)

		var rows: Array[Control] = [
			screen.get_opponent_defense_row(),
			screen.get_opponent_attack_row(),
			screen.get_player_attack_row(),
			screen.get_player_defense_row()
		]

		for r_idx: int in range(rows.size()):
			for col: int in range(6):
				var guide: Control = rows[r_idx].get_node("SlotGuide_%02d" % (col + 1)) as Control
				var origin: Vector2 = guide.get_global_rect().position
				origin = screen.get_combat_layout().get_global_transform().affine_inverse() * origin

				var box: Panel = Panel.new()
				box.position = origin + Vector2(8, 6)
				box.size = Vector2(146, 100)
				var style: StyleBoxFlat = StyleBoxFlat.new()
				style.bg_color = Color(0.02, 0.08, 0.12, 0.8)
				style.border_color = Color(0.15, 0.75, 0.85, 0.85)
				style.set_border_width_all(1)
				box.add_theme_stylebox_override("panel", style)
				group.add_child(box)

				var l_title: Label = Label.new()
				l_title.text = "TEMP C%d" % (col + 1)
				l_title.position = Vector2(10, 6)
				l_title.add_theme_font_size_override("font_size", 15)
				box.add_child(l_title)

				var l_equip: Label = Label.new()
				l_equip.text = "W                  P"
				l_equip.position = Vector2(8, 28)
				l_equip.add_theme_font_size_override("font_size", 13)
				l_equip.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 0.7))
				box.add_child(l_equip)

				var l_stats: Label = Label.new()
				l_stats.text = "A12 / H12"
				l_stats.position = Vector2(10, 48)
				l_stats.add_theme_font_size_override("font_size", 16)
				l_stats.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5, 1.0))
				box.add_child(l_stats)

				var l_status: Label = Label.new()
				l_status.text = "S1 S2 S3 +N"
				l_status.position = Vector2(8, 74)
				l_status.add_theme_font_size_override("font_size", 13)
				l_status.add_theme_color_override("font_color", Color(0.5, 0.9, 1.0, 0.8))
				box.add_child(l_status)

		var img: Image = await _render_image(vp)
		_save_png(img, "final_crowded_board_diagnostic_%dp.png" % dim.y)

		root.remove_child(vp)
		vp.queue_free()
		await process_frame

func _capture_resource_animation_samples() -> void:
	print("--- F. Capturing Timed Resource Animation Samples ---")
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080), true) # animate_orbs = true
	var screen: CombatScreen = vp.get_child(0) as CombatScreen

	# Sample frames across 1.2 seconds of fluid simulation
	var sample_times: Array[float] = [0.0, 0.4, 0.8, 1.2]
	var sample_names: Array[String] = ["resource_anim_t00.png", "resource_anim_t04.png", "resource_anim_t08.png", "resource_anim_t12.png"]

	# Crop to the player HUD liquid orb region (x=24..296, y=344..1044)
	var crop_rect: Rect2i = Rect2i(24, 344, 272, 700)

	for s: int in range(sample_times.size()):
		if s > 0:
			var delay: float = sample_times[s] - sample_times[s - 1]
			await create_timer(delay).timeout
		var full_img: Image = await _render_image(vp)
		var orb_crop: Image = full_img.get_region(crop_rect)
		_save_png(orb_crop, sample_names[s])

	root.remove_child(vp)
	vp.queue_free()
	await process_frame
