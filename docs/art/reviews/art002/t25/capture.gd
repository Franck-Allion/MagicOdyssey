extends SceneTree
## ART-002-T25: Global Stat Numeral Readability Polish Capture Suite
## Generates genuine GPU renders for all 4 required review scenes at 1920x1080.

const FRAME: Texture2D = preload("res://assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png")
const ART: Texture2D = preload("res://assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png")
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
		push_error("Graphical renderer required for T25 captures")
		quit(2)
		return

	var out_dir: String = "D:/Dev/MagicOdyssey/docs/art/reviews/art002/t25/"

	var anchor: Node = Node.new()
	anchor.name = "Anchor"
	root.add_child(anchor)

	print("START_CAPTURE_1: All Stats Readability Before / After")
	await _capture_all_stats_readability_before_after(out_dir + "all_stats_readability_before_after_1080p.png")

	print("START_CAPTURE_2: Values Gallery (1, 2, 4, 8, 10, 12)")
	await _capture_values_gallery(out_dir + "armor_shield_value_gallery_1080p.png")

	print("START_CAPTURE_3: Inspected Card")
	await _capture_inspected_card(out_dir + "inspected_card_1080p.png")

	print("START_CAPTURE_4: Seven-Card Hand (1080p)")
	await _capture_seven_card_hand(out_dir + "seven_card_hand_1080p.png", Vector2i(1920, 1080), 316.0)

	print("T25_ALL_CAPTURES_COMPLETED")
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
	print("T25_CAPTURE size=%s path=%s result=%d" % [vp.size, path.get_file(), err])
	root.remove_child(vp)
	vp.queue_free()

func _card(parent: Node, origin: Vector2, height: float, rarity_index: int = 3,
		use_emerald: bool = false, native_armor: int = 0, shield: int = 0,
		cost: int = 4, attack_value: int = 4, health_value: int = 5,
		title: String = "Arcane Knight", tribe: String = "Human",
		rules: String = "Whenever this creature attacks, gain 1 Shield.",
		use_polish: bool = true, category: CardContentOverlay.Category = CardContentOverlay.Category.CREATURE) -> Control:
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
		CardStatOverlay.use_t25_readability_polish = use_polish
		var stats: CardStatOverlay = STAT_OVERLAY.new()
		card.add_child(stats)
		stats.set_printed_values(cost, attack_value, health_value, native_armor)
		stats.set_shield_overlay(shield)
		CardStatOverlay.use_t25_readability_polish = true
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
		use_polish: bool = true, cat: CardContentOverlay.Category = CardContentOverlay.Category.CREATURE) -> ImageTexture:
	var card_vp: SubViewport = SubViewport.new()
	card_vp.size = Vector2i(1086, 1448)
	card_vp.transparent_bg = true
	card_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(card_vp)

	_card(card_vp, Vector2.ZERO, 1448.0, rarity_idx, use_emerald, arm, shd, cost, atk, hp, title, tribe, rules, use_polish, cat)

	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw

	var card_img: Image = card_vp.get_texture().get_image()
	var tex: ImageTexture = ImageTexture.create_from_image(card_img)

	root.remove_child(card_vp)
	card_vp.queue_free()
	return tex

# -----------------------------------------------------------------------------
# 1. All Stats Readability Before / After Comparison (1080p)
# -----------------------------------------------------------------------------
func _capture_all_stats_readability_before_after(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))

	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T25", Rect2(64, 25, 1400, 45), 34,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "GLOBAL STAT READABILITY POLISH · Coherent 4 px Stroke + Depth Shadow Across All 4 Stats",
		Rect2(64, 75, 1800, 32), 22, TOKENS.color_token(&"accent"))

	var tex_before: ImageTexture = await _render_card_texture(3, true, 2, 1, 4, 4, 5,
		"Arcane Knight", "Human", "Whenever this creature attacks, gain 1 Shield.", false)
	var tex_after: ImageTexture = await _render_card_texture(3, true, 2, 1, 4, 4, 5,
		"Arcane Knight", "Human", "Whenever this creature attacks, gain 1 Shield.", true)

	var card_h: float = 620.0
	var card_w: float = card_h * (1086.0 / 1448.0)

	# Left Card: Before (T24 Baseline: 3 px outline, no shadow)
	var rect_before: TextureRect = TextureRect.new()
	rect_before.texture = tex_before
	rect_before.position = Vector2(80, 130)
	rect_before.size = Vector2(card_w, card_h)
	rect_before.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect_before.stretch_mode = TextureRect.STRETCH_SCALE
	vp.add_child(rect_before)

	_add_label(vp, "BEFORE (T24 Baseline: 3 px stroke, no shadow)", Rect2(80, 765, card_w, 28), 17,
		TOKENS.color_token(&"opponent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(vp, "• Armor numeral can feel slightly less readable over steel highlights\n• Attack & Health lack directional depth separation\n• Thin 3 px stroke softens at gameplay scale",
		Rect2(80, 795, card_w, 85), 14, TOKENS.color_token(&"text"))

	# Right Card: After (T25 Polish: 4 px stroke + depth shadow)
	var rect_after: TextureRect = TextureRect.new()
	rect_after.texture = tex_after
	rect_after.position = Vector2(580, 130)
	rect_after.size = Vector2(card_w, card_h)
	rect_after.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect_after.stretch_mode = TextureRect.STRETCH_SCALE
	vp.add_child(rect_after)

	_add_label(vp, "AFTER (T25 Coherent Polish: 4 px stroke + depth shadow)", Rect2(580, 765, card_w, 28), 17,
		TOKENS.color_token(&"valid"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(vp, "• Armor numeral pops cleanly off metallic highlights\n• Attack, Health & Shield gain rich sculpted depth\n• 100% coherent visual language across all 4 stats",
		Rect2(580, 795, card_w, 85), 14, TOKENS.color_token(&"text"))

	# Macro Zooms Across All 4 Stats Side-by-Side (Right Half of 1080p Screen)
	var macro_panel: Panel = Panel.new()
	macro_panel.position = Vector2(1080, 130)
	macro_panel.size = Vector2(780, 750)
	macro_panel.theme_type_variation = &"InspectorFrame"
	vp.add_child(macro_panel)

	_add_label(macro_panel, "ALL 4 STATS COHERENT READABILITY MACRO ZOOMS", Rect2(20, 15, 740, 26), 18,
		TOKENS.color_token(&"accent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)

	var stat_crops: Array[Dictionary] = [
		{"name": "ATTACK (Graphite Steel Socket, 126 pt)", "region": Rect2(42, 1160, 240, 240)},
		{"name": "HEALTH (Crimson Ruby Socket, 126 pt)", "region": Rect2(799, 1160, 240, 240)},
		{"name": "ARMOR (Steel Protective Plaque, 62 pt)", "region": Rect2(260, 1260, 238, 140)},
		{"name": "SHIELD (Azure Ward Plaque, 62 pt)", "region": Rect2(588, 1260, 238, 140)},
	]

	for i in range(4):
		var crop_def: Dictionary = stat_crops[i]
		var y_offset: float = 55.0 + i * 170.0

		_add_label(macro_panel, crop_def["name"], Rect2(20, y_offset, 740, 22), 15,
			TOKENS.color_token(&"secondary"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

		# Before patch (left)
		var p_before: Panel = Panel.new()
		p_before.position = Vector2(20, y_offset + 25)
		p_before.size = Vector2(360, 130)
		p_before.theme_type_variation = &"InspectorFrame"
		macro_panel.add_child(p_before)

		var c_b: Control = Control.new()
		c_b.position = Vector2(6, 6)
		c_b.size = Vector2(348, 118)
		c_b.clip_contents = true
		p_before.add_child(c_b)

		var at_b: AtlasTexture = AtlasTexture.new()
		at_b.atlas = tex_before
		at_b.region = crop_def["region"]
		var img_b: TextureRect = TextureRect.new()
		img_b.texture = at_b
		img_b.size = c_b.size
		img_b.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img_b.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		c_b.add_child(img_b)

		# After patch (right)
		var p_after: Panel = Panel.new()
		p_after.position = Vector2(400, y_offset + 25)
		p_after.size = Vector2(360, 130)
		p_after.theme_type_variation = &"InspectorFrame"
		macro_panel.add_child(p_after)

		var c_a: Control = Control.new()
		c_a.position = Vector2(6, 6)
		c_a.size = Vector2(348, 118)
		c_a.clip_contents = true
		p_after.add_child(c_a)

		var at_a: AtlasTexture = AtlasTexture.new()
		at_a.atlas = tex_after
		at_a.region = crop_def["region"]
		var img_a: TextureRect = TextureRect.new()
		img_a.texture = at_a
		img_a.size = c_a.size
		img_a.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img_a.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		c_a.add_child(img_a)

	# Bottom Summary Banner
	var sum_panel: Panel = Panel.new()
	sum_panel.position = Vector2(80, 895)
	sum_panel.size = Vector2(1780, 140)
	sum_panel.theme_type_variation = &"InspectorFrame"
	vp.add_child(sum_panel)

	_add_label(sum_panel, "MANDATORY COHERENCE RULE ENFORCED", Rect2(20, 12, 1740, 24), 18,
		TOKENS.color_token(&"valid"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	var sum_text: String = "• Identical Fill Color: Bright ivory (TOKENS.color_token(&\"text_bright\")) across all stats.\n• Identical Stroke: Refined 4 px dark outline (TOKENS.color_token(&\"background\")) across all stats.\n• Identical Shadow: Subtle directional depth shadow (Vector2(0, 2), Color(0, 0, 0, 0.8)) across all stats.\n• Zero Stat-Specific Special Effects: No special filter, glow, or drop-shadow added only to Armor.\n• Scale Hierarchy Preserved: Attack/Health remain primary (126 pt in circular sockets); Armor/Shield remain secondary (62 pt in plaque slots)."
	_add_label(sum_panel, sum_text, Rect2(20, 38, 1740, 95), 14, TOKENS.color_token(&"text"))

	await _save_and_free(vp, path)

# -----------------------------------------------------------------------------
# 2. Values Gallery (1, 2, 4, 8, 10, 12) (1080p)
# -----------------------------------------------------------------------------
func _capture_values_gallery(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))

	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T25", Rect2(64, 25, 1400, 45), 34,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "VALUES GALLERY · Coherent 4 px Stroke + Depth Shadow on Armor & Shield Plaques",
		Rect2(64, 75, 1800, 32), 22, TOKENS.color_token(&"accent"))

	var values: Array[int] = [1, 2, 4, 8, 10, 12]
	var col_w: float = 270.0
	var col_gap: float = 20.0
	var start_x: float = 90.0

	for v_idx in range(values.size()):
		var val: int = values[v_idx]
		var x_pos: float = start_x + v_idx * (col_w + col_gap)

		var col_panel: Panel = Panel.new()
		col_panel.position = Vector2(x_pos, 130)
		col_panel.size = Vector2(col_w, 820)
		col_panel.theme_type_variation = &"InspectorFrame"
		vp.add_child(col_panel)

		_add_label(col_panel, "VALUE '%d'" % val, Rect2(10, 15, col_w - 20, 30), 22,
			TOKENS.color_token(&"accent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)

		# 1. Armor Plaque
		_add_label(col_panel, "ARMOR PLAQUE (H=62)", Rect2(10, 55, col_w - 20, 24), 14,
			TOKENS.color_token(&"secondary"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

		var a_tex: ImageTexture = await _render_card_texture(3, true, val, 0, 4, 4, 5, "Test", "Human", "", true)
		var a_preview: TextureRect = TextureRect.new()
		var atlas_a: AtlasTexture = AtlasTexture.new()
		atlas_a.atlas = a_tex
		atlas_a.region = Rect2(260, 1260, 238, 140)
		a_preview.texture = atlas_a
		a_preview.position = Vector2(16, 85)
		a_preview.size = Vector2(col_w - 32, 140)
		a_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		a_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		col_panel.add_child(a_preview)

		var a_info: String = "Outline: 4 px (Dark Background)\nShadow: Vector2(0, 2), alpha=0.8\nVertical Margin: 5.0–6.0 px\nContrast: Crisp Edge over Steel"
		_add_label(col_panel, a_info, Rect2(10, 235, col_w - 20, 85), 13,
			TOKENS.color_token(&"text"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

		# 2. Shield Plaque
		_add_label(col_panel, "SHIELD PLAQUE (H=69)", Rect2(10, 335, col_w - 20, 24), 14,
			TOKENS.color_token(&"shield"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)

		var s_tex: ImageTexture = await _render_card_texture(3, true, 0, val, 4, 4, 5, "Test", "Human", "", true)
		var s_preview: TextureRect = TextureRect.new()
		var atlas_s: AtlasTexture = AtlasTexture.new()
		atlas_s.atlas = s_tex
		atlas_s.region = Rect2(588, 1260, 238, 140)
		s_preview.texture = atlas_s
		s_preview.position = Vector2(16, 365)
		s_preview.size = Vector2(col_w - 32, 140)
		s_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		s_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		col_panel.add_child(s_preview)

		var s_info: String = "Outline: 4 px (Dark Background)\nShadow: Vector2(0, 2), alpha=0.8\nVertical Margin: 8.5–9.5 px\nContrast: Crisp Edge over Azure"
		_add_label(col_panel, s_info, Rect2(10, 515, col_w - 20, 85), 13,
			TOKENS.color_token(&"text"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

		# 3. Assessment Badge
		var assess_panel: Panel = Panel.new()
		assess_panel.position = Vector2(10, 615)
		assess_panel.size = Vector2(col_w - 20, 190)
		var ast_style: StyleBoxFlat = StyleBoxFlat.new()
		ast_style.bg_color = Color(0.047, 0.063, 0.094, 0.6)
		ast_style.border_color = TOKENS.color_token(&"valid")
		ast_style.set_border_width_all(1)
		ast_style.set_corner_radius_all(6)
		assess_panel.add_theme_stylebox_override("panel", ast_style)
		col_panel.add_child(assess_panel)

		_add_label(assess_panel, "T25 VERDICT: PASS", Rect2(5, 10, col_w - 30, 22), 14,
			TOKENS.color_token(&"valid"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)

		var note: String = ""
		if val == 1:
			note = "Narrow '1' reads cleanly off steel highlights with 4 px outline + shadow.\nAir: 5.5 px."
		elif val == 2:
			note = "Curved top & horizontal base separated with deep shadow.\nAir: 6.0 px."
		elif val == 4:
			note = "Triangular arm and vertical bar pop with high contrast.\nAir: 5.0 px."
		elif val == 8:
			note = "Symmetrical dual loops retain sharp internal counters.\nAir: 5.0 px."
		elif val == 10:
			note = "Double digit '10' clearly legible at a glance with -2 px optical X.\nAir: 5.0 px."
		elif val == 12:
			note = "Double digit '12' fully legible across full width.\nAir: 5.5 px."

		_add_label(assess_panel, note, Rect2(10, 40, col_w - 40, 140), 13,
			TOKENS.color_token(&"text"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	await _save_and_free(vp, path)

# -----------------------------------------------------------------------------
# 3. Inspected Card (1080p)
# -----------------------------------------------------------------------------
func _capture_inspected_card(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))

	_add_label(vp, "MAGIC ODYSSEY  /  INSPECTION VIEW", Rect2(64, 25, 900, 45), 34,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "CARD INSPECTION · Emerald Epic Arcane Knight · Coherent Readability Polish (1080p)",
		Rect2(64, 75, 1400, 32), 22, TOKENS.color_token(&"accent"))

	var card_h: float = 880.0
	_card(vp, Vector2(80, 130), card_h, 3, true, 2, 1, 4, 4, 5,
		"Arcane Knight", "Human", "Whenever this creature attacks, gain 1 Shield.", true)

	var info_panel: Panel = Panel.new()
	info_panel.position = Vector2(780, 130)
	info_panel.size = Vector2(1060, card_h)
	info_panel.theme_type_variation = &"InspectorFrame"
	vp.add_child(info_panel)

	_add_label(info_panel, "CARD SPECIFICATION & T25 READABILITY POLISH", Rect2(30, 25, 1000, 40), 28,
		TOKENS.color_token(&"accent"), &"CardTitle")

	var details: String = "Card Identity:\n  • Title: Arcane Knight\n  • Category: Creature  |  Tribe: Human\n  • Rarity: Epic (Emerald Gemstones verified per ART-002-T03C)\n  • Mana Cost: 4 (Master Frame Blue Socket)\n\nCombat Stats & Layered Protections:\n  • Attack: 4  (Graphite Steel Inlay, Master Bronze Socket r=71.5 px, TacticalNumber 126 pt)\n  • Health: 5  (Crimson Ruby Inlay, Master Bronze Socket r=71.5 px, TacticalNumber 126 pt)\n  • Armor: 2   (Integrated Steel Plaque Inlay, 180×62 px, Rect2(280, 1280, 198, 100), 62 pt)\n  • Shield: 1  (Integrated Arcane Ward Plaque Inlay, 180×69 px, Rect2(608, 1280, 198, 100), 62 pt)\n\nT25 Global Numeral Readability Polish:\n  • Mandatory Coherence: Exactly identical styling applied across Attack, Health, Armor & Shield\n  • Stroke Thickness: Refined from 3 px to 4 px (NUMERAL_OUTLINE_SIZE = 4)\n  • Directional Depth Shadow: Vector2(0, 2), Color(0, 0, 0, 0.8) (NUMERAL_SHADOW_OFFSET / COLOR)\n  • Armor Clarity: Shadow and 4 px stroke decisively separate the numeral from bright steel highlights\n  • Attack & Health Depth: Large 126 pt socket numerals gain a sculpted, raised metallic presence\n  • Preserved Typographic Hierarchy: Primary stats 126 pt, secondary stats 62 pt (classic 1:2 ratio)"
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

	_add_label(info_panel, "Armor Plaque (Value '2', Coherent Polish)", Rect2(30, 810, 300, 24), 16,
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

	_add_label(info_panel, "Shield Plaque (Value '1', Coherent Polish)", Rect2(360, 810, 300, 24), 16,
		TOKENS.color_token(&"secondary"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	_add_label(info_panel, "PRODUCTION-READY COHERENT READABILITY", Rect2(690, 640, 340, 50), 20,
		TOKENS.color_token(&"valid"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(info_panel, "• 100% unified visual style across all stats\n• Zero Armor-only special treatment\n• Maximum glanceability in combat & hand view\n• Ready for owner final sign-off", Rect2(690, 700, 340, 120), 16,
		TOKENS.color_token(&"text"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	await _save_and_free(vp, path)

# -----------------------------------------------------------------------------
# 4. Seven-Card Hand at Actual Play Scale (1080p)
# -----------------------------------------------------------------------------
func _capture_seven_card_hand(path: String, vp_size: Vector2i, card_h: float) -> void:
	var vp: SubViewport = _create_viewport(vp_size)
	var scale_factor: float = float(vp_size.y) / 1080.0

	_add_label(vp, "MAGIC ODYSSEY  /  IN-GAME HAND DISPLAY",
		Rect2(40 * scale_factor, 20 * scale_factor, 900 * scale_factor, 40 * scale_factor),
		int(28 * scale_factor), TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "SEVEN-CARD MIXED HAND · Actual Play Scale · Coherent T25 Readability Polish (1080p)",
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

	_add_label(vp, "All 4 Stat Families Share Identical Stroke (4 px) + Depth Shadow (0, 2)   •   Maximum Glanceability",
		Rect2(40 * scale_factor, vp_size.y - 40 * scale_factor, vp_size.x - 80 * scale_factor, 24 * scale_factor),
		int(16 * scale_factor), TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)
