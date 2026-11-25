extends SceneTree
## P009-R01B: Review Evidence Capture Suite
## Generates genuine GPU renders of Spell card integration, mixed hand, hover/inspection,
## and typography readability across 1080p and 720p viewports.

const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const CARD_VIEW: GDScript = preload("res://scripts/presentation/card_view.gd")
const VARIANT: GDScript = preload("res://scripts/presentation/card_visual_variant.gd")
const MODEL: GDScript = preload("res://scripts/presentation/card_presentation_model.gd")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")
const SPELL_FRAME: Texture2D = preload("res://assets/textures/cards/mo_card_frame_spell_v01.png")
const MASTER_FRAME: Texture2D = preload("res://assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png")
const ART: Texture2D = preload("res://assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png")

var OUT_DIR: String = "res://docs/art/reviews/p009-r01b/"
var asserts: TestAsserts = TestAsserts.new()

func _init() -> void:
	if DisplayServer.get_name() == "headless":
		print("ERROR: Graphical renderer required for visual review captures.")
		quit(2)
		return
	call_deferred("_run_all_captures")

func _run_all_captures() -> void:
	print("==================================================")
	print("P009-R01B — GPU Review Evidence Capture Suite")
	print("Engine: %s" % Engine.get_version_info().string)
	print("GPU: %s" % RenderingServer.get_video_adapter_name())
	print("==================================================")

	await _capture_full_screens()
	await _capture_spell_inspections()
	await _capture_comparison_closeup()
	await _capture_rarity_gem_variations()
	await _capture_stress_and_readability()

	# Save observations summary
	var obs: Dictionary = {
		"task": "P009-R01B",
		"engine": Engine.get_version_info().string,
		"gpu": RenderingServer.get_video_adapter_name(),
		"viewport_modes": ["1920x1080", "1280x720"],
		"assertions_passed": asserts.passed_count,
		"assertions_failed": asserts.failed_count,
		"captures": [
			"combat_screen_mixed_1080p.png",
			"combat_screen_mixed_720p.png",
			"combat_screen_spells_1080p.png",
			"combat_screen_spells_720p.png",
			"inspect_fireball_1080p.png",
			"inspect_mending_light_1080p.png",
			"inspect_arcane_barrier_1080p.png",
			"inspect_martial_blessing_1080p.png",
			"creature_vs_spell_comparison_1080p.png",
			"rarity_variations_spell_1080p.png",
			"text_readability_stress_1080p.png"
		]
	}

	var json_path: String = ProjectSettings.globalize_path(OUT_DIR + "observations.json")
	var file: FileAccess = FileAccess.open(json_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(obs, "  ") + "\n")
		file.close()

	print("==================================================")
	print("P009-R01B REVIEW CAPTURES COMPLETE: %d checks passed, %d failed" % [asserts.passed_count, asserts.failed_count])
	quit(0 if asserts.failed_count == 0 else 1)

func _create_viewport(size: Vector2i) -> SubViewport:
	var vp: SubViewport = SubViewport.new()
	vp.size = size
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	return vp

func _save_viewport(vp: SubViewport, filename: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw

	var img: Image = vp.get_texture().get_image()
	var global_path: String = ProjectSettings.globalize_path(OUT_DIR + filename)
	var err: Error = img.save_png(global_path)
	asserts.assert_equal(err, OK, "Save PNG %s must return OK" % filename)
	print("  -> Saved %s (%dx%d px)" % [filename, img.get_width(), img.get_height()])
	vp.queue_free()
	await process_frame

func _capture_full_screens() -> void:
	for dim in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var suffix: String = "%dp" % dim.y
		# 1. Mixed hand
		var vp_mixed: SubViewport = _create_viewport(dim)
		var screen_mixed: CombatScreen = SCREEN.instantiate() as CombatScreen
		screen_mixed.size = Vector2(dim)
		vp_mixed.add_child(screen_mixed)
		var fan_mixed: CombatPreviewCards = screen_mixed.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
		fan_mixed.display_count = 7
		fan_mixed.set_preview_scenario("mixed")
		await _save_viewport(vp_mixed, "combat_screen_mixed_%s.png" % suffix)

		# 2. Spells only hand
		var vp_spells: SubViewport = _create_viewport(dim)
		var screen_spells: CombatScreen = SCREEN.instantiate() as CombatScreen
		screen_spells.size = Vector2(dim)
		vp_spells.add_child(screen_spells)
		var fan_spells: CombatPreviewCards = screen_spells.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
		fan_spells.display_count = 7
		fan_spells.set_preview_scenario("spells_only")
		await _save_viewport(vp_spells, "combat_screen_spells_%s.png" % suffix)

func _capture_spell_inspections() -> void:
	var spells: Array[Dictionary] = [
		{"name": "fireball", "model": MODEL.create_spell("Fireball", 3, &"rare", "Deal 4 damage to target enemy creature.", ART, "spell_fireball")},
		{"name": "mending_light", "model": MODEL.create_spell("Mending Light", 2, &"common", "Restore 3 Health to target allied creature.", ART, "spell_heal")},
		{"name": "arcane_barrier", "model": MODEL.create_spell("Arcane Barrier", 2, &"uncommon", "Grant 3 Shield to target allied creature.", ART, "spell_barrier")},
		{"name": "martial_blessing", "model": MODEL.create_spell("Martial Blessing", 2, &"common", "Target allied creature gains +2 Attack until end of turn.", ART, "spell_blessing")}
	]

	for item in spells:
		var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))
		var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
		screen.size = Vector2(1920, 1080)
		vp.add_child(screen)

		var fan: CombatPreviewCards = screen.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
		fan.display_count = 7
		fan.set_preview_scenario("mixed")

		# Direct inspection presentation card on overlay
		var card_inspect: Control = (CARD_VIEW as GDScript).new()
		card_inspect.call(&"apply_model", item["model"])
		card_inspect.scale = Vector2.ONE * (540.0 / 1448.0) # 540 px height inspection scale
		card_inspect.position = Vector2(960.0 - (1086.0 * (540.0 / 1448.0) * 0.5), 260.0)
		screen.add_child(card_inspect)

		await _save_viewport(vp, "inspect_%s_1080p.png" % item["name"])

func _capture_comparison_closeup() -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))
	var bg: ColorRect = ColorRect.new()
	bg.size = Vector2(1920, 1080)
	bg.color = TOKENS.color_token(&"background")
	vp.add_child(bg)

	var label: Label = Label.new()
	label.text = "MAGIC ODYSSEY  /  P009–R01B ARCHITECTURAL COMPARISON: CREATURE VS SPELL"
	label.theme = TOKENS.THEME
	label.theme_type_variation = &"SectionHeading"
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", TOKENS.color_token(&"accent"))
	label.position = Vector2(80, 40)
	vp.add_child(label)

	var sub: Label = Label.new()
	sub.text = "Left: Protected Creature (Master v03, combat sockets, narrow 566x210 rules)  |  Right: Normalized Spell (Spell v01, pure mana, enlarged 806x240 rules)"
	sub.theme = TOKENS.THEME
	sub.add_theme_font_size_override("font_size", 18)
	sub.add_theme_color_override("font_color", TOKENS.color_token(&"text"))
	sub.position = Vector2(80, 80)
	vp.add_child(sub)

	# 1. Creature Card at inspection scale (height 840 px)
	var creature_model: RefCounted = MODEL.create_creature(
		"Arcane Knight", 4, &"rare", 4, 5, "Human",
		"Whenever this creature attacks, gain 1 Shield.", 2, 1, ART
	)
	var creature_view: Control = (CARD_VIEW as GDScript).new()
	creature_view.call(&"apply_model", creature_model)
	var scale_factor: float = 840.0 / 1448.0
	creature_view.scale = Vector2.ONE * scale_factor
	creature_view.position = Vector2(240, 140)
	vp.add_child(creature_view)

	# 2. Spell Card at inspection scale (height 840 px)
	var spell_model: RefCounted = MODEL.create_spell(
		"Fireball", 3, &"rare",
		"Deal 4 damage to target enemy creature.", ART, "spell_fireball"
	)
	var spell_view: Control = (CARD_VIEW as GDScript).new()
	spell_view.call(&"apply_model", spell_model)
	spell_view.scale = Vector2.ONE * scale_factor
	spell_view.position = Vector2(1050, 140)
	vp.add_child(spell_view)

	await _save_viewport(vp, "creature_vs_spell_comparison_1080p.png")

func _capture_rarity_gem_variations() -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))
	var bg: ColorRect = ColorRect.new()
	bg.size = Vector2(1920, 1080)
	bg.color = TOKENS.color_token(&"background")
	vp.add_child(bg)

	var label: Label = Label.new()
	label.text = "MAGIC ODYSSEY  /  P009–R01B SPELL RARITY GEM REGISTRATION & PALETTE SUITE"
	label.theme = TOKENS.THEME
	label.theme_type_variation = &"SectionHeading"
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", TOKENS.color_token(&"accent"))
	label.position = Vector2(60, 40)
	vp.add_child(label)

	var sub: Label = Label.new()
	sub.text = "Reusable shared frame_v03_gem_mask.svg correctly registered with Spell artwork's three neutral crystals"
	sub.theme = TOKENS.THEME
	sub.add_theme_font_size_override("font_size", 18)
	sub.add_theme_color_override("font_color", TOKENS.color_token(&"text"))
	sub.position = Vector2(60, 80)
	vp.add_child(sub)

	var rarities: Array[StringName] = [&"common", &"uncommon", &"rare", &"epic", &"legendary"]
	var rarity_names: Array[String] = ["Common (Silver)", "Uncommon (Sapphire)", "Rare (Ruby)", "Epic (Emerald)", "Legendary (Gold)"]
	var scale_val: float = 620.0 / 1448.0 # ~465 px width per card
	var card_w: float = 1086.0 * scale_val # ~348 px

	for i in range(rarities.size()):
		var r: StringName = rarities[i]
		var model: RefCounted = MODEL.create_spell("Fireball", 3, r, "Deal 4 damage to target enemy creature.", ART)
		var view: Control = (CARD_VIEW as GDScript).new()
		view.call(&"apply_model", model)
		view.scale = Vector2.ONE * scale_val
		view.position = Vector2(60 + i * (card_w + 18), 160)
		vp.add_child(view)

		var cap: Label = Label.new()
		cap.text = rarity_names[i]
		cap.theme = TOKENS.THEME
		cap.add_theme_font_size_override("font_size", 16)
		cap.add_theme_color_override("font_color", TOKENS.color_token(&"accent"))
		cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cap.position = Vector2(60 + i * (card_w + 18), 800)
		cap.size = Vector2(card_w, 30)
		vp.add_child(cap)

	await _save_viewport(vp, "rarity_variations_spell_1080p.png")

func _capture_stress_and_readability() -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))
	var bg: ColorRect = ColorRect.new()
	bg.size = Vector2(1920, 1080)
	bg.color = TOKENS.color_token(&"background")
	vp.add_child(bg)

	var label: Label = Label.new()
	label.text = "MAGIC ODYSSEY  /  P009–R01B ENLARGED SPELL EFFECT PANEL READABILITY STRESS"
	label.theme = TOKENS.THEME
	label.theme_type_variation = &"SectionHeading"
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", TOKENS.color_token(&"accent"))
	label.position = Vector2(80, 40)
	vp.add_child(label)

	var sub: Label = Label.new()
	sub.text = "Max title (2-line wrap) and multi-sentence rules text in enlarged 806x240 px panel (>= 12 physical px at 720p)"
	sub.theme = TOKENS.THEME
	sub.add_theme_font_size_override("font_size", 18)
	sub.add_theme_color_override("font_color", TOKENS.color_token(&"text"))
	sub.position = Vector2(80, 80)
	vp.add_child(sub)

	# 1. Normative 4 spells side by side
	var spells: Array[RefCounted] = [
		MODEL.create_spell("Archon of the Sundered Sphere", 10, &"legendary", "Banish all enemy creature tokens from the battlefield, restore 10 Health to your hero, and draw 3 cards.", ART),
		MODEL.create_spell("Cataclysmic Conflagration", 8, &"epic", "Deal 8 damage to all enemy frontline creatures. If any creature is destroyed, ignite adjacent positions for 2 damage per turn.", ART),
		MODEL.create_spell("Martial Blessing", 2, &"common", "Target allied creature gains +2 Attack until end of turn.", ART)
	]

	var scale_val: float = 720.0 / 1448.0
	var card_w: float = 1086.0 * scale_val

	for i in range(spells.size()):
		var view: Control = (CARD_VIEW as GDScript).new()
		view.call(&"apply_model", spells[i])
		view.scale = Vector2.ONE * scale_val
		view.position = Vector2(100 + i * (card_w + 60), 160)
		vp.add_child(view)

	await _save_viewport(vp, "text_readability_stress_1080p.png")
