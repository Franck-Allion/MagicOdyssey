extends SceneTree
## ART-002-T23: Integrated Armor & Shield Plaque Inlays Capture Suite
## Generates genuine GPU renders for all 6 required review scenes at 1920x1080 (plus optional 720p).

const FRAME: Texture2D = preload("res://assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png")
const ART: Texture2D = preload("res://assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png")
const BATTLEFIELD: Texture2D = preload("res://assets/_source/lot1/battlefield/wip/mo_battlefield_sundered_observatory_bg_wip_v03.png")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")
const GEM_TREATMENT: GDScript = preload("res://scripts/presentation/rarity_gem_treatment.gd")
const STAT_OVERLAY: GDScript = preload("res://scripts/presentation/card_stat_overlay.gd")
const CONTENT_OVERLAY: GDScript = preload("res://scripts/presentation/card_content_overlay.gd")
const CATEGORY_OVERLAY: GDScript = preload("res://scripts/presentation/card_category_overlay.gd")
const CARD_SIZE: Vector2 = Vector2(1086, 1448)

func _initialize() -> void:
	call_deferred("_run_captures")

func _run_captures() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Graphical renderer required for T23 captures")
		quit(2)
		return

	var out_dir: String = "D:/Dev/MagicOdyssey/docs/art/reviews/art002/t23/"

	# Keep persistent dummy node on root to prevent SceneTree auto-exit
	var anchor: Node = Node.new()
	anchor.name = "Anchor"
	root.add_child(anchor)

	print("START_CAPTURE_1: Armor & Shield Plaques Closeup")
	await _capture_armor_shield_plaques_closeup(out_dir + "armor_shield_plaques_closeup_1080p.png")

	print("START_CAPTURE_2: Before / After Comparison")
	await _capture_before_after_armor_shield(out_dir + "before_after_armor_shield_1080p.png")

	print("START_CAPTURE_3: Inspected Card")
	await _capture_inspected_card(out_dir + "inspected_card_1080p.png")

	print("START_CAPTURE_4: Seven-Card Hand (1080p)")
	await _capture_seven_card_hand(out_dir + "seven_card_hand_1080p.png", Vector2i(1920, 1080), 316.0)

	print("START_CAPTURE_4_OPTIONAL: Seven-Card Hand (720p)")
	await _capture_seven_card_hand(out_dir + "seven_card_hand_720p.png", Vector2i(1280, 720), 210.0)

	print("START_CAPTURE_5: Full Combat Interface")
	await _capture_full_combat(out_dir + "full_combat_1080p.png")

	print("START_CAPTURE_6: Mixed Stats Examples")
	await _capture_mixed_stats_examples(out_dir + "mixed_stats_examples_1080p.png")

	print("T23_ALL_CAPTURES_COMPLETED")
	quit(0)

func _create_viewport(vp_size: Vector2i) -> SubViewport:
	var vp: SubViewport = SubViewport.new()
	vp.size = vp_size
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var bg: Panel = Panel.new()
	bg.size = Vector2(vp_size)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = TOKENS.color_token(&"background")
	bg.add_theme_stylebox_override("panel", style)
	vp.add_child(bg)
	return vp

func _save_and_free(vp: SubViewport, path: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var err: Error = vp.get_texture().get_image().save_png(path)
	print("T23_CAPTURE size=%s path=%s result=%d" % [vp.size, path.get_file(), err])
	root.remove_child(vp)
	vp.queue_free()

func _card(parent: Node, origin: Vector2, height: float, rarity_index: int = 3,
		use_emerald: bool = false, native_armor: int = 0, shield: int = 0,
		cost: int = 4, attack_value: int = 4, health_value: int = 5,
		title: String = "Arcane Knight", tribe: String = "Human",
		rules: String = "Whenever this creature attacks, gain 1 Shield.",
		use_plaques: bool = true, category: CardContentOverlay.Category = CardContentOverlay.Category.CREATURE) -> Control:
	var card: Control = Control.new()
	card.position = origin
	card.size = CARD_SIZE
	card.scale = Vector2.ONE * height / CARD_SIZE.y
	parent.add_child(card)

	var aperture: Control = Control.new()
	aperture.position = Vector2(124, 207)
	aperture.size = Vector2(838, 642)
	aperture.clip_contents = true
	card.add_child(aperture)

	var crop: AtlasTexture = AtlasTexture.new()
	crop.atlas = ART
	crop.region = Rect2(0, 34, 1086, 832)
	var portrait: TextureRect = TextureRect.new()
	portrait.texture = crop
	portrait.position = Vector2.ZERO
	portrait.size = aperture.size
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait.texture_filter = Control.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aperture.add_child(portrait)

	var frame: TextureRect = TextureRect.new()
	frame.texture = FRAME
	frame.position = Vector2.ZERO
	frame.size = CARD_SIZE
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.texture_filter = Control.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if use_emerald and rarity_index == 3:
		frame.material = GEM_TREATMENT.create_emerald_epic_material()
	else:
		frame.material = GEM_TREATMENT.create_material(
			[&"common", &"uncommon", &"rare", &"epic", &"legendary"][rarity_index])
	card.add_child(frame)

	var fields: CardContentOverlay.Content = CardContentOverlay.Content.new(
		title, category, tribe, rules)
	var text_overlay: CardContentOverlay = CONTENT_OVERLAY.new()
	card.add_child(text_overlay)
	text_overlay.configure(fields)

	if category == CardContentOverlay.Category.CREATURE:
		CardStatOverlay.use_plaque_inlays = use_plaques
		var stats: CardStatOverlay = STAT_OVERLAY.new()
		card.add_child(stats)
		stats.set_printed_values(cost, attack_value, health_value, native_armor)
		stats.set_shield_overlay(shield)
		CardStatOverlay.use_plaque_inlays = true
	else:
		var cat_overlay: CardCategoryOverlay = CATEGORY_OVERLAY.new()
		cat_overlay.category = category
		card.add_child(cat_overlay)
		cat_overlay.set_printed_values(cost, 0, 0, 0)

	return card

func _add_label(parent: Node, value: String, bounds: Rect2, font_size: int,
		color: Color, variant: StringName = &"BodyText",
		align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label: Label = Label.new()
	label.text = value
	label.position = bounds.position
	label.size = bounds.size
	label.theme_type_variation = variant
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _render_card_texture(rarity_idx: int, use_emerald: bool, arm: int, shd: int,
		cost: int, atk: int, hp: int, title: String, tribe: String, rules: String,
		use_plaques: bool = true, cat: CardContentOverlay.Category = CardContentOverlay.Category.CREATURE) -> ImageTexture:
	var card_vp: SubViewport = SubViewport.new()
	card_vp.size = Vector2i(1086, 1448)
	card_vp.transparent_bg = true
	card_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(card_vp)

	_card(card_vp, Vector2.ZERO, 1448.0, rarity_idx, use_emerald, arm, shd, cost, atk, hp, title, tribe, rules, use_plaques, cat)

	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw

	var card_img: Image = card_vp.get_texture().get_image()
	var tex: ImageTexture = ImageTexture.create_from_image(card_img)

	root.remove_child(card_vp)
	card_vp.queue_free()
	return tex

# -----------------------------------------------------------------------------
# 1. Armor & Shield Plaques Closeup (1080p)
# -----------------------------------------------------------------------------
func _capture_armor_shield_plaques_closeup(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))

	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T23", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "INTEGRATED STAT PLAQUE INLAYS · Armor (Steel) & Shield (Arcane Ward) Closeup",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	var tex_card: ImageTexture = await _render_card_texture(3, true, 2, 1, 4, 4, 5,
		"Arcane Knight", "Human", "Whenever this creature attacks, gain 1 Shield.", true)

	# Full Card Preview on Left (height 720 px)
	var card_rect: TextureRect = TextureRect.new()
	card_rect.texture = tex_card
	card_rect.position = Vector2(80, 160)
	card_rect.size = Vector2(1086, 1448) * (720.0 / 1448.0)
	card_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card_rect.stretch_mode = TextureRect.STRETCH_SCALE
	vp.add_child(card_rect)

	# Armor Plaque Zoom Macro (bounds: (280, 1280, 198, 100), crop span: 260x160 -> region: (249, 1250, 260, 160))
	var armor_panel: Panel = Panel.new()
	armor_panel.position = Vector2(660, 160)
	armor_panel.size = Vector2(420, 320)
	armor_panel.theme_type_variation = &"InspectorFrame"
	vp.add_child(armor_panel)

	var armor_crop: Control = Control.new()
	armor_crop.position = Vector2(12, 12)
	armor_crop.size = Vector2(396, 296)
	armor_crop.clip_contents = true
	armor_panel.add_child(armor_crop)

	var atlas_arm: AtlasTexture = AtlasTexture.new()
	atlas_arm.atlas = tex_card
	atlas_arm.region = Rect2(249, 1250, 260, 160)
	var img_arm: TextureRect = TextureRect.new()
	img_arm.texture = atlas_arm
	img_arm.size = armor_crop.size
	img_arm.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img_arm.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	armor_crop.add_child(img_arm)

	_add_label(vp, "ARMOR PLAQUE · STEEL MATERIAL INLAY", Rect2(660, 490, 420, 32), 20,
		TOKENS.color_token(&"accent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	var desc_arm: String = "• Inset steel/dark metal protective plaque (180×62 px)\n• Slot bounds: Rect2(280, 1280, 198, 100)\n• Usable inner area: 192×94 px, corner radius 20 px\n• Clean breathing room: 6 px X margin, 16 px Y margin\n• Zero bronze border spill; centered white numeral '2'"
	_add_label(vp, desc_arm, Rect2(660, 525, 420, 140), 16, TOKENS.color_token(&"text"))

	# Shield Plaque Zoom Macro (bounds: (608, 1280, 198, 100), crop span: 260x160 -> region: (577, 1250, 260, 160))
	var shield_panel: Panel = Panel.new()
	shield_panel.position = Vector2(1120, 160)
	shield_panel.size = Vector2(420, 320)
	shield_panel.theme_type_variation = &"InspectorFrame"
	vp.add_child(shield_panel)

	var shield_crop: Control = Control.new()
	shield_crop.position = Vector2(12, 12)
	shield_crop.size = Vector2(396, 296)
	shield_crop.clip_contents = true
	shield_panel.add_child(shield_crop)

	var atlas_shd: AtlasTexture = AtlasTexture.new()
	atlas_shd.atlas = tex_card
	atlas_shd.region = Rect2(577, 1250, 260, 160)
	var img_shd: TextureRect = TextureRect.new()
	img_shd.texture = atlas_shd
	img_shd.size = shield_crop.size
	img_shd.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img_shd.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	shield_crop.add_child(img_shd)

	_add_label(vp, "SHIELD PLAQUE · ARCANE WARD INLAY", Rect2(1120, 490, 420, 32), 20,
		TOKENS.color_token(&"shield"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	var desc_shd: String = "• Inset arcane blue ward plaque (180×69 px)\n• Slot bounds: Rect2(608, 1280, 198, 100)\n• Usable inner area: 192×94 px, corner radius 20 px\n• Clean breathing room: 6 px X margin, 12.5 px Y margin\n• Zero bronze border spill; centered white numeral '1'"
	_add_label(vp, desc_shd, Rect2(1120, 525, 420, 140), 16, TOKENS.color_token(&"text"))

	# Architecture Callout Panel
	var sum_panel: Panel = Panel.new()
	sum_panel.position = Vector2(660, 680)
	sum_panel.size = Vector2(880, 200)
	sum_panel.theme_type_variation = &"InspectorFrame"
	vp.add_child(sum_panel)

	_add_label(sum_panel, "T23 4-LAYER PRESENTATION ARCHITECTURE", Rect2(20, 15, 840, 28), 20,
		TOKENS.color_token(&"valid"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	var arch_desc: String = "Layer 4: White Stat Numerals (TacticalNumber 76 pt, max width 83, centered at local (99, 50))\nLayer 3: Bronze Frame & Highlights (StyleBoxFlat 3 px bronze border, top accent line at y=+3 px)\nLayer 2: Plaque Inlay Material (mo_plate_armor.png & mo_plate_shield.png, 180 px calibrated width)\nLayer 1: Slot Base & Shadow (StyleBoxFlat dark background Color(12,16,24), 6 px drop shadow)"
	_add_label(sum_panel, arch_desc, Rect2(20, 48, 840, 140), 16, TOKENS.color_token(&"text"))

	# Summary Specs (Right)
	var specs_panel: Panel = Panel.new()
	specs_panel.position = Vector2(1580, 160)
	specs_panel.size = Vector2(280, 720)
	specs_panel.theme_type_variation = &"InspectorFrame"
	vp.add_child(specs_panel)

	_add_label(specs_panel, "CALIBRATION", Rect2(20, 20, 240, 28), 20,
		TOKENS.color_token(&"accent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	var specs_text: String = "Slot Geometry:\n• Armor: (280, 1280)\n• Shield: (608, 1280)\n• Outer Box: 198×100 px\n• Inner Area: 192×94 px\n• Corner Radius: 23 px\n\nRuntime Textures:\n• mo_plate_armor.png\n  (512×177 px, Lanczos)\n• mo_plate_shield.png\n  (512×197 px, Lanczos)\n• Anisotropic Mipmaps\n\nScale Calibration:\n• Width: 180 px unified\n• Armor: 180×62 px\n• Shield: 180×69 px\n• Zero Border Spill"
	_add_label(specs_panel, specs_text, Rect2(20, 55, 240, 640), 15, TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)

# -----------------------------------------------------------------------------
# 2. Before / After Armor & Shield Comparison (1080p)
# -----------------------------------------------------------------------------
func _capture_before_after_armor_shield(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))

	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T23", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "BEFORE VS AFTER · Floating Mini-Icons (T11) vs Integrated Plaque Inlays (T23)",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	var tex_before: ImageTexture = await _render_card_texture(3, true, 2, 1, 4, 4, 5,
		"Arcane Knight", "Human", "Whenever this creature attacks, gain 1 Shield.", false)
	var tex_after: ImageTexture = await _render_card_texture(3, true, 2, 1, 4, 4, 5,
		"Arcane Knight", "Human", "Whenever this creature attacks, gain 1 Shield.", true)

	var card_h: float = 640.0
	var card_w: float = card_h * (1086.0 / 1448.0)

	# Left Card: Before (Floating Icons)
	var rect_before: TextureRect = TextureRect.new()
	rect_before.texture = tex_before
	rect_before.position = Vector2(80, 160)
	rect_before.size = Vector2(card_w, card_h)
	rect_before.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect_before.stretch_mode = TextureRect.STRETCH_SCALE
	vp.add_child(rect_before)

	_add_label(vp, "BEFORE: FLOATING MINI-ICONS (ART-002-T11)", Rect2(80, 810, card_w, 30), 18,
		TOKENS.color_token(&"opponent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(vp, "• Small floating icon on left (52×52 px)\n• Numeral pushed to right (x=140)\n• Flat dark cavity without material identity\n• Less consistent with Attack/Health inlays",
		Rect2(80, 845, card_w, 120), 15, TOKENS.color_token(&"text"))

	# Right Card: After (Plaque Inlays)
	var rect_after: TextureRect = TextureRect.new()
	rect_after.texture = tex_after
	rect_after.position = Vector2(600, 160)
	rect_after.size = Vector2(card_w, card_h)
	rect_after.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect_after.stretch_mode = TextureRect.STRETCH_SCALE
	vp.add_child(rect_after)

	_add_label(vp, "AFTER: INTEGRATED PLAQUE INLAYS (ART-002-T23)", Rect2(600, 810, card_w, 30), 18,
		TOKENS.color_token(&"valid"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(vp, "• Dedicated plaque inlay fills internal slot face\n• White numeral centered over plaque (x=99)\n• Distinct material motifs (steel vs arcane ward)\n• Perfect visual consistency with Attack/Health inlays",
		Rect2(600, 845, card_w, 120), 15, TOKENS.color_token(&"text"))

	# Macro Zooms of Footer Stat Plate Region
	var zoom_before: Panel = Panel.new()
	zoom_before.position = Vector2(1120, 160)
	zoom_before.size = Vector2(740, 220)
	zoom_before.theme_type_variation = &"InspectorFrame"
	vp.add_child(zoom_before)

	var crop_b: Control = Control.new()
	crop_b.position = Vector2(10, 10)
	crop_b.size = Vector2(720, 200)
	crop_b.clip_contents = true
	zoom_before.add_child(crop_b)

	var atlas_b: AtlasTexture = AtlasTexture.new()
	atlas_b.atlas = tex_before
	atlas_b.region = Rect2(260, 1260, 566, 140)
	var img_b: TextureRect = TextureRect.new()
	img_b.texture = atlas_b
	img_b.size = crop_b.size
	img_b.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img_b.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	crop_b.add_child(img_b)

	_add_label(vp, "BEFORE (T11) · Separate Mini-Icons (Armor Left, Numeral Right)", Rect2(1120, 390, 740, 28), 18,
		TOKENS.color_token(&"opponent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)

	var zoom_after: Panel = Panel.new()
	zoom_after.position = Vector2(1120, 430)
	zoom_after.size = Vector2(740, 220)
	zoom_after.theme_type_variation = &"InspectorFrame"
	vp.add_child(zoom_after)

	var crop_a: Control = Control.new()
	crop_a.position = Vector2(10, 10)
	crop_a.size = Vector2(720, 200)
	crop_a.clip_contents = true
	zoom_after.add_child(crop_a)

	var atlas_a: AtlasTexture = AtlasTexture.new()
	atlas_a.atlas = tex_after
	atlas_a.region = Rect2(260, 1260, 566, 140)
	var img_a: TextureRect = TextureRect.new()
	img_a.texture = atlas_a
	img_a.size = crop_a.size
	img_a.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img_a.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	crop_a.add_child(img_a)

	_add_label(vp, "AFTER (T23) · Integrated Plaque Inlays (Unified Face, Centered Numeral)", Rect2(1120, 660, 740, 28), 18,
		TOKENS.color_token(&"valid"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)

	# Key Differences Comparison Table
	var diff_panel: Panel = Panel.new()
	diff_panel.position = Vector2(1120, 700)
	diff_panel.size = Vector2(740, 260)
	diff_panel.theme_type_variation = &"InspectorFrame"
	vp.add_child(diff_panel)

	_add_label(diff_panel, "KEY REFINEMENT ADVANTAGES", Rect2(20, 15, 700, 26), 20,
		TOKENS.color_token(&"accent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	var diff_text: String = "1. Material Consistency: Extends the approved T20 Attack/Health inlay direction to Armor & Shield.\n2. Unified Hierarchy: Attack/Health sockets remain primary circular collets; Armor/Shield remain subordinate.\n3. Centered Focus: Numerals sit centrally in the plaque slot rather than offset to the right edge.\n4. Zero Border Spill: Plaques strictly respect the 192×94 px inner cavity with clean breathing room.\n5. Rollback Preservation: Toggling use_plaque_inlays = false instantly restores the T11 icon layout."
	_add_label(diff_panel, diff_text, Rect2(20, 48, 700, 195), 15, TOKENS.color_token(&"text"))

	await _save_and_free(vp, path)

# -----------------------------------------------------------------------------
# 3. Inspected Card (1080p)
# -----------------------------------------------------------------------------
func _capture_inspected_card(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))

	_add_label(vp, "MAGIC ODYSSEY  /  INSPECTION VIEW", Rect2(64, 30, 900, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "CARD INSPECTION · Emerald Epic Arcane Knight · Integrated Plaque Inlays (1080p)",
		Rect2(64, 85, 1200, 35), 24, TOKENS.color_token(&"accent"))

	var card_h: float = 880.0
	_card(vp, Vector2(80, 140), card_h, 3, true, 2, 1, 4, 4, 5,
		"Arcane Knight", "Human", "Whenever this creature attacks, gain 1 Shield.", true)

	var info_panel: Panel = Panel.new()
	info_panel.position = Vector2(780, 140)
	info_panel.size = Vector2(1060, card_h)
	info_panel.theme_type_variation = &"InspectorFrame"
	vp.add_child(info_panel)

	_add_label(info_panel, "CARD SPECIFICATION & STAT INTEGRATION", Rect2(30, 25, 1000, 40), 28,
		TOKENS.color_token(&"accent"), &"CardTitle")

	var details: String = "Card Identity:\n  • Title: Arcane Knight\n  • Category: Creature  |  Tribe: Human\n  • Rarity: Epic (Emerald Gemstones verified per ART-002-T03C)\n  • Mana Cost: 4 (Master Frame Blue Socket)\n\nCombat Stats & Layered Protections:\n  • Attack: 4  (Graphite Steel Inlay, Master Bronze Socket r=71.5 px)\n  • Health: 5  (Crimson Ruby Inlay, Master Bronze Socket r=71.5 px)\n  • Armor: 2   (Integrated Steel Plaque Inlay, 180×62 px, Rect2(280, 1280, 198, 100))\n  • Shield: 1  (Integrated Arcane Ward Plaque Inlay, 180×69 px, Rect2(608, 1280, 198, 100))\n\nT23 Integrated Plaque Inlays:\n  • Runtime Textures: mo_plate_armor.png & mo_plate_shield.png (512 px width, Lanczos)\n  • Plaque Scale: Unified 180 px width; Armor 180×62 px, Shield 180×69 px\n  • Breathing Room: 6 px X margin, 12.5–16 px Y margin inside 192×94 px usable cavity\n  • Zero Spill: 100% of plaque pixels contained within inner bronze frame border\n  • Typography: TacticalNumber 76 pt, max width 83, centered at local (99, 50)\n  • Subordination: Secondary stats remain cleanly subordinate to primary Attack/Health"
	_add_label(info_panel, details, Rect2(30, 75, 1000, 520), 18, TOKENS.color_token(&"text"))

	# Close-up Crops inside Info Panel
	var tex_card: ImageTexture = await _render_card_texture(3, true, 2, 1, 4, 4, 5,
		"Arcane Knight", "Human", "Whenever this creature attacks, gain 1 Shield.", true)

	var in_arm: Panel = Panel.new()
	in_arm.position = Vector2(30, 620)
	in_arm.size = Vector2(300, 180)
	in_arm.theme_type_variation = &"InspectorFrame"
	info_panel.add_child(in_arm)

	var in_arm_crop: Control = Control.new()
	in_arm_crop.position = Vector2(8, 8)
	in_arm_crop.size = Vector2(284, 164)
	in_arm_crop.clip_contents = true
	in_arm.add_child(in_arm_crop)

	var atlas_ia: AtlasTexture = AtlasTexture.new()
	atlas_ia.atlas = tex_card
	atlas_ia.region = Rect2(260, 1260, 238, 140)
	var img_ia: TextureRect = TextureRect.new()
	img_ia.texture = atlas_ia
	img_ia.size = in_arm_crop.size
	img_ia.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img_ia.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	in_arm_crop.add_child(img_ia)

	_add_label(info_panel, "Armor Plaque (280, 1280)", Rect2(30, 810, 300, 24), 16,
		TOKENS.color_token(&"secondary"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	var in_shd: Panel = Panel.new()
	in_shd.position = Vector2(360, 620)
	in_shd.size = Vector2(300, 180)
	in_shd.theme_type_variation = &"InspectorFrame"
	info_panel.add_child(in_shd)

	var in_shd_crop: Control = Control.new()
	in_shd_crop.position = Vector2(8, 8)
	in_shd_crop.size = Vector2(284, 164)
	in_shd_crop.clip_contents = true
	in_shd.add_child(in_shd_crop)

	var atlas_is: AtlasTexture = AtlasTexture.new()
	atlas_is.atlas = tex_card
	atlas_is.region = Rect2(588, 1260, 238, 140)
	var img_is: TextureRect = TextureRect.new()
	img_is.texture = atlas_is
	img_is.size = in_shd_crop.size
	img_is.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img_is.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	in_shd_crop.add_child(img_is)

	_add_label(info_panel, "Shield Plaque (608, 1280)", Rect2(360, 810, 300, 24), 16,
		TOKENS.color_token(&"secondary"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	_add_label(info_panel, "UNIFIED INTEGRATED STAT TREATMENT", Rect2(690, 640, 340, 50), 20,
		TOKENS.color_token(&"valid"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(info_panel, "• Primary stats: Circular bronze sockets\n• Secondary stats: Bronze plate slots\n• Zero floating icons across all stats\n• Production-ready visual coherence", Rect2(690, 700, 340, 120), 16,
		TOKENS.color_token(&"text"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	await _save_and_free(vp, path)

# -----------------------------------------------------------------------------
# 4. Seven-Card Hand at Actual Play Scale (1080p / 720p)
# -----------------------------------------------------------------------------
func _capture_seven_card_hand(path: String, vp_size: Vector2i, card_h: float) -> void:
	var vp: SubViewport = _create_viewport(vp_size)
	var scale_factor: float = float(vp_size.y) / 1080.0

	_add_label(vp, "MAGIC ODYSSEY  /  IN-GAME HAND DISPLAY",
		Rect2(40 * scale_factor, 20 * scale_factor, 900 * scale_factor, 40 * scale_factor),
		int(28 * scale_factor), TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "SEVEN-CARD MIXED HAND · Actual Play Scale · Creatures, Spell & Equipment · T23 Plaques",
		Rect2(40 * scale_factor, 60 * scale_factor, 1400 * scale_factor, 30 * scale_factor),
		int(20 * scale_factor), TOKENS.color_token(&"accent"))

	var hand_specs: Array[Dictionary] = [
		{"rarity": 0, "emerald": false, "arm": 0, "shd": 0, "cost": 1, "atk": 1, "hp": 1, "title": "Scout", "tribe": "Elf", "rules": "Quick step.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 1, "emerald": false, "arm": 1, "shd": 0, "cost": 2, "atk": 3, "hp": 4, "title": "Rampart Guard", "tribe": "Dwarf", "rules": "Armor 1.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 3, "emerald": true, "arm": 2, "shd": 1, "cost": 4, "atk": 4, "hp": 5, "title": "Arcane Knight", "tribe": "Human", "rules": "Gain 1 Shield on attack.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 2, "emerald": false, "arm": 0, "shd": 2, "cost": 3, "atk": 2, "hp": 3, "title": "Rune Crafter", "tribe": "Human", "rules": "Grant 2 Shield to self.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 2, "emerald": false, "arm": 0, "shd": 0, "cost": 4, "atk": 0, "hp": 0, "title": "Fireball", "tribe": "Arcane", "rules": "Deal 4 damage to target creature.", "cat": CardContentOverlay.Category.SPELL},
		{"rarity": 1, "emerald": false, "arm": 2, "shd": 0, "cost": 2, "atk": 0, "hp": 0, "title": "Bastion Armor", "tribe": "Relic", "rules": "Equipped creature gains Armor 2.", "cat": CardContentOverlay.Category.EQUIPMENT},
		{"rarity": 4, "emerald": false, "arm": 3, "shd": 2, "cost": 6, "atk": 6, "hp": 8, "title": "Iron Guardian", "tribe": "Golem", "rules": "Taunt. Dual protection test.", "cat": CardContentOverlay.Category.CREATURE},
	]

	var card_w: float = card_h * (1086.0 / 1448.0)
	var spacing: float = (vp_size.x - 80 * scale_factor - 7 * card_w) / 6.0
	var y_pos: float = vp_size.y - card_h - 60 * scale_factor

	for i: int in range(7):
		var spec: Dictionary = hand_specs[i]
		var x_pos: float = 40 * scale_factor + i * (card_w + spacing)
		_card(vp, Vector2(x_pos, y_pos), card_h, spec["rarity"], spec["emerald"],
			spec["arm"], spec["shd"], spec["cost"], spec["atk"], spec["hp"],
			spec["title"], spec["tribe"], spec["rules"], true, spec["cat"])

	_add_label(vp, "5 Creatures with Integrated Inlays & Plaques   •   1 Spell & 1 Equipment with Inactive Sockets Preserved",
		Rect2(40 * scale_factor, vp_size.y - 40 * scale_factor, vp_size.x - 80 * scale_factor, 24 * scale_factor),
		int(16 * scale_factor), TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)

# -----------------------------------------------------------------------------
# 5. Full Combat Interface (1080p)
# -----------------------------------------------------------------------------
func _capture_full_combat(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))

	# Battlefield background artwork
	var bg: TextureRect = TextureRect.new()
	bg.texture = BATTLEFIELD
	bg.size = Vector2(1920, 1080)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vp.add_child(bg)

	# Scrim
	var scrim: ColorRect = ColorRect.new()
	scrim.position = Vector2(260, 220)
	scrim.size = Vector2(1400, 530)
	var scrim_color: Color = TOKENS.color_token(&"background")
	scrim_color.a = 0.35
	scrim.color = scrim_color
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vp.add_child(scrim)

	# Header HUD
	var header_panel: Panel = Panel.new()
	header_panel.position = Vector2(42, 20)
	header_panel.size = Vector2(510, 80)
	header_panel.theme_type_variation = &"InspectorFrame"
	vp.add_child(header_panel)
	_add_label(vp, "THE SUNDERED OBSERVATORY", Rect2(62, 30, 480, 32), 24, TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "ART-002-T23 · INTEGRATED PLAQUE INLAYS · 1080p", Rect2(62, 64, 480, 24), 18, TOKENS.color_token(&"secondary"))

	# Opponent Hero Banner
	var opp_panel: Panel = Panel.new()
	opp_panel.position = Vector2(650, 20)
	opp_panel.size = Vector2(620, 90)
	opp_panel.theme_type_variation = &"HeroFrame"
	vp.add_child(opp_panel)
	_add_label(vp, "OPPONENT  /  THE ASHEN WATCH", Rect2(670, 28, 400, 24), 18, TOKENS.color_token(&"opponent"))
	_add_label(vp, "24 HP     4 / 5 MANA", Rect2(670, 52, 400, 30), 24, TOKENS.color_token(&"text_bright"))
	_add_label(vp, "DECK 28  ·  HAND 4", Rect2(1080, 48, 170, 24), 18, TOKENS.color_token(&"secondary"))

	# Turn / End Turn Action Panel (Right)
	var turn_panel: Panel = Panel.new()
	turn_panel.position = Vector2(1680, 300)
	turn_panel.size = Vector2(198, 220)
	turn_panel.theme_type_variation = &"InspectorFrame"
	vp.add_child(turn_panel)
	_add_label(vp, "YOUR TURN", Rect2(1699, 315, 160, 26), 20, TOKENS.color_token(&"accent"), &"SectionHeading", HORIZONTAL_ALIGNMENT_CENTER)
	var end_btn: Button = Button.new()
	end_btn.position = Vector2(1695, 380)
	end_btn.size = Vector2(168, 54)
	end_btn.text = "End Turn"
	end_btn.theme_type_variation = &"PrimaryButton"
	turn_panel.add_child(end_btn)
	_add_label(vp, "ROUND 3  ·  PHASE 1", Rect2(1699, 455, 160, 22), 14, TOKENS.color_token(&"secondary"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	# Battlefield Grid (4x3)
	var grid_ctrl: Control = Control.new()
	grid_ctrl.position = Vector2(280, 230)
	grid_ctrl.size = Vector2(1360, 510)
	vp.add_child(grid_ctrl)

	var cell_w: float = 320.0
	var cell_h: float = 155.0
	var gap_x: float = 20.0
	var gap_y: float = 15.0

	for r in range(3):
		for c in range(4):
			var cell: Panel = Panel.new()
			cell.position = Vector2(c * (cell_w + gap_x), r * (cell_h + gap_y))
			cell.size = Vector2(cell_w, cell_h)
			var cell_style: StyleBoxFlat = StyleBoxFlat.new()
			cell_style.bg_color = Color(0.047, 0.063, 0.094, 0.45)
			cell_style.border_color = Color(0.471, 0.388, 0.247, 0.5)
			cell_style.set_border_width_all(2)
			cell_style.set_corner_radius_all(8)
			cell.add_theme_stylebox_override("panel", cell_style)
			grid_ctrl.add_child(cell)

	_add_label(grid_ctrl, "BATTLEFIELD GRID · 4×3 LANES", Rect2(20, 20, 400, 30), 18, TOKENS.color_token(&"secondary"))

	# Player Hand at Bottom
	var hand_h: float = 280.0
	var hand_w: float = hand_h * (1086.0 / 1448.0)
	var h_spacing: float = (1840.0 - 7 * hand_w) / 6.0
	var h_y: float = 1080.0 - hand_h - 20.0

	var combat_specs: Array[Dictionary] = [
		{"rarity": 0, "emerald": false, "arm": 0, "shd": 0, "cost": 1, "atk": 1, "hp": 1, "title": "Scout", "tribe": "Elf", "rules": "Quick step.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 1, "emerald": false, "arm": 1, "shd": 0, "cost": 2, "atk": 3, "hp": 4, "title": "Rampart Guard", "tribe": "Dwarf", "rules": "Armor 1.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 3, "emerald": true, "arm": 2, "shd": 1, "cost": 4, "atk": 4, "hp": 5, "title": "Arcane Knight", "tribe": "Human", "rules": "Gain 1 Shield on attack.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 2, "emerald": false, "arm": 0, "shd": 2, "cost": 3, "atk": 2, "hp": 3, "title": "Rune Crafter", "tribe": "Human", "rules": "Grant 2 Shield to self.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 2, "emerald": false, "arm": 0, "shd": 0, "cost": 4, "atk": 0, "hp": 0, "title": "Fireball", "tribe": "Arcane", "rules": "Deal 4 damage.", "cat": CardContentOverlay.Category.SPELL},
		{"rarity": 1, "emerald": false, "arm": 2, "shd": 0, "cost": 2, "atk": 0, "hp": 0, "title": "Bastion Armor", "tribe": "Relic", "rules": "Equipped +2 Armor.", "cat": CardContentOverlay.Category.EQUIPMENT},
		{"rarity": 4, "emerald": false, "arm": 3, "shd": 2, "cost": 6, "atk": 6, "hp": 8, "title": "Iron Guardian", "tribe": "Golem", "rules": "Taunt.", "cat": CardContentOverlay.Category.CREATURE},
	]

	for i in range(7):
		var sp: Dictionary = combat_specs[i]
		var h_x: float = 40.0 + i * (hand_w + h_spacing)
		_card(vp, Vector2(h_x, h_y), hand_h, sp["rarity"], sp["emerald"],
			sp["arm"], sp["shd"], sp["cost"], sp["atk"], sp["hp"],
			sp["title"], sp["tribe"], sp["rules"], true, sp["cat"])

	await _save_and_free(vp, path)

# -----------------------------------------------------------------------------
# 6. Mixed Stats Examples (1080p)
# -----------------------------------------------------------------------------
func _capture_mixed_stats_examples(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))

	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T23", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "MIXED PROTECTION EXAMPLES · Single Digits, Double Digits & Zero Badge Hiding",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	# 8 test cards covering all protection scenarios:
	var matrix_specs: Array[Dictionary] = [
		{"arm": 0, "shd": 0, "atk": 4, "hp": 5, "title": "No Protection (0/0)", "desc": "Both badges cleanly hidden"},
		{"arm": 1, "shd": 0, "atk": 3, "hp": 4, "title": "Armor 1 (Single)", "desc": "Single-digit steel plaque"},
		{"arm": 12, "shd": 0, "atk": 8, "hp": 10, "title": "Armor 12 (Double)", "desc": "Double-digit optical center"},
		{"arm": 0, "shd": 3, "atk": 2, "hp": 3, "title": "Shield 3 (Single)", "desc": "Single-digit azure ward"},
		{"arm": 0, "shd": 14, "atk": 5, "hp": 6, "title": "Shield 14 (Double)", "desc": "Double-digit optical center"},
		{"arm": 2, "shd": 1, "atk": 4, "hp": 5, "title": "Dual (2 Arm / 1 Shd)", "desc": "Balanced dual plaques"},
		{"arm": 10, "shd": 10, "atk": 10, "hp": 10, "title": "Dual 10/10 (Double)", "desc": "Dual double-digit symmetry"},
		{"arm": 99, "shd": 99, "atk": 99, "hp": 99, "title": "Stress Test (99/99)", "desc": "Maximum width fit inside 83 px"},
	]

	var cols: int = 4
	var rows: int = 2
	var card_h: float = 360.0
	var card_w: float = card_h * (1086.0 / 1448.0)
	var start_x: float = 80.0
	var start_y: float = 160.0
	var col_spacing: float = (1920.0 - 2.0 * start_x - cols * card_w) / (cols - 1)
	var row_spacing: float = 60.0

	for idx in range(matrix_specs.size()):
		var sp = matrix_specs[idx]
		var c = idx % cols
		var r = idx / cols
		var x = start_x + c * (card_w + col_spacing)
		var y = start_y + r * (card_h + row_spacing + 40.0)

		_card(vp, Vector2(x, y), card_h, 3, true, sp["arm"], sp["shd"], 4, sp["atk"], sp["hp"],
			sp["title"], "Test", "Protection matrix validation.", true)

		_add_label(vp, sp["title"], Rect2(x, y + card_h + 8, card_w, 24), 16,
			TOKENS.color_token(&"accent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
		_add_label(vp, sp["desc"], Rect2(x, y + card_h + 30, card_w, 20), 13,
			TOKENS.color_token(&"secondary"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	await _save_and_free(vp, path)
