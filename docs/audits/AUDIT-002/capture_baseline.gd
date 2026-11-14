extends SceneTree
## AUDIT-002-T01: Permanent ART-002 Baseline Reference Capture Suite
## Generates genuine GPU renders at 1920x1080 using the active production rendering path.

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
		push_error("Graphical renderer required for baseline captures")
		quit(2)
		return

	var out_dir: String = "D:/Dev/MagicOdyssey/docs/audits/AUDIT-002/"

	var anchor: Node = Node.new()
	anchor.name = "Anchor"
	root.add_child(anchor)

	print("START_CAPTURE_1: Card Production Baseline (1080p)")
	await _capture_card_production_baseline(out_dir + "card_production_baseline_1080p.png")

	print("START_CAPTURE_2: Seven-Card Hand Baseline (1080p)")
	await _capture_seven_card_hand_baseline(out_dir + "seven_card_hand_baseline_1080p.png")

	print("START_CAPTURE_3: Four Stats Closeup Baseline (1080p)")
	await _capture_four_stats_closeup_baseline(out_dir + "four_stats_closeup_baseline_1080p.png")

	print("AUDIT_002_ALL_CAPTURES_COMPLETED")
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
	print("BASELINE_CAPTURE size=%s path=%s result=%d" % [vp.size, path.get_file(), err])
	root.remove_child(vp)
	vp.queue_free()

func _card(parent: Node, origin: Vector2, height: float, rarity_index: int = 3,
		use_emerald: bool = false, native_armor: int = 0, shield: int = 0,
		cost: int = 4, attack_value: int = 4, health_value: int = 5,
		title: String = "Arcane Knight", tribe: String = "Human",
		rules: String = "Whenever this creature attacks, gain 1 Shield.",
		category: CardContentOverlay.Category = CardContentOverlay.Category.CREATURE) -> Control:
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
		var stats: CardStatOverlay = STAT_OVERLAY.new()
		card.add_child(stats)
		stats.set_printed_values(cost, attack_value, health_value, native_armor)
		stats.set_shield_overlay(shield)
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
		cat: CardContentOverlay.Category = CardContentOverlay.Category.CREATURE) -> ImageTexture:
	var card_vp: SubViewport = SubViewport.new()
	card_vp.size = Vector2i(1086, 1448)
	card_vp.transparent_bg = true
	card_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(card_vp)

	_card(card_vp, Vector2.ZERO, 1448.0, rarity_idx, use_emerald, arm, shd, cost, atk, hp, title, tribe, rules, cat)

	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw

	var card_img: Image = card_vp.get_texture().get_image()
	var tex: ImageTexture = ImageTexture.create_from_image(card_img)

	root.remove_child(card_vp)
	card_vp.queue_free()
	return tex

func _capture_card_production_baseline(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))

	_add_label(vp, "MAGIC ODYSSEY  /  AUDIT–002 BASELINE", Rect2(64, 25, 1000, 45), 34,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "PRODUCTION CARD PRESENTATION BASELINE · Active ART-002-T25 Pipeline (1080p)",
		Rect2(64, 75, 1400, 32), 22, TOKENS.color_token(&"accent"))

	var card_h: float = 880.0
	_card(vp, Vector2(80, 130), card_h, 3, true, 2, 1, 4, 4, 5,
		"Arcane Knight", "Human", "Whenever this creature attacks, gain 1 Shield.")

	var info_panel: Panel = Panel.new()
	info_panel.position = Vector2(780, 130)
	info_panel.size = Vector2(1060, card_h)
	info_panel.theme_type_variation = &"InspectorFrame"
	vp.add_child(info_panel)

	_add_label(info_panel, "PERMANENT PRODUCTION BASELINE SPECIFICATION", Rect2(30, 25, 1000, 40), 28,
		TOKENS.color_token(&"accent"), &"CardTitle")

	var desc: String = "Validated Architecture (T20–T25):\n  • Master Frame: v03 with native alpha (1086×1448 px)\n  • Rarity Crystals: Emerald Epic shader treatment (hue ~0.415, saturation 0.90)\n  • Primary Sockets: Attack graphite steel & Health crimson ruby inlays (r=95 px)\n  • Socket Bezels: Original sculpted bronze rings (220×220 px) on Layer 3\n  • Secondary Sockets: Armor steel & Shield azure ward plaque inlays (180 px unified width)\n  • Numeral Styling: Coherent 4 px stroke + (0, 2) depth shadow across all 4 stats (T25)\n  • Secondary Stat Font Size: Refined 62 pt, providing >= 5.0 px vertical breathing room (T24)\n  • Symmetrical Vertical Placement: Strictly Y=0.0 px optical offset in plaque slots\n\nActive Production Assets:\n  • mo_card_frame_master_v03.png\n  • mo_inlay_attack.png  &  mo_inlay_health.png\n  • mo_socket_bezel_attack.png  &  mo_socket_bezel_health.png\n  • mo_plate_armor.png  &  mo_plate_shield.png\n  • frame_v03_gem_mask.svg  &  card_rarity_gems.gdshader\n  • TacticalNumber, CardTitle, and BodyText typography in fantasy_theme.tres"
	_add_label(info_panel, desc, Rect2(30, 75, 1000, 480), 18, TOKENS.color_token(&"text"))

	# Macro Crops of All 4 Sockets
	var tex_card: ImageTexture = await _render_card_texture(3, true, 2, 1, 4, 4, 5,
		"Arcane Knight", "Human", "Whenever this creature attacks, gain 1 Shield.")

	var crops_info: Array[Dictionary] = [
		{"name": "Attack (4, Graphite)", "rect": Rect2(42, 1160, 240, 240)},
		{"name": "Armor (2, Steel)", "rect": Rect2(260, 1260, 238, 140)},
		{"name": "Shield (1, Azure)", "rect": Rect2(588, 1260, 238, 140)},
		{"name": "Health (5, Ruby)", "rect": Rect2(799, 1160, 240, 240)},
	]

	for i in range(4):
		var cinfo = crops_info[i]
		var px: float = 30.0 + i * 250.0

		var p: Panel = Panel.new()
		p.position = Vector2(px, 580)
		p.size = Vector2(230, 210)
		p.theme_type_variation = &"InspectorFrame"
		info_panel.add_child(p)

		var c: Control = Control.new()
		c.position = Vector2(6, 6)
		c.size = Vector2(218, 168)
		c.clip_contents = true
		p.add_child(c)

		var at: AtlasTexture = AtlasTexture.new()
		at.atlas = tex_card
		at.region = cinfo["rect"]
		var tr: TextureRect = TextureRect.new()
		tr.texture = at
		tr.size = c.size
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		c.add_child(tr)

		_add_label(p, cinfo["name"], Rect2(5, 180, 220, 24), 14,
			TOKENS.color_token(&"secondary"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	await _save_and_free(vp, path)

func _capture_seven_card_hand_baseline(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))

	_add_label(vp, "MAGIC ODYSSEY  /  AUDIT–002 BASELINE", Rect2(40, 20, 900, 40), 28,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "SEVEN-CARD HAND PRODUCTION BASELINE · Actual Play Scale (Card Height 316 px)",
		Rect2(40, 60, 1400, 30), 20, TOKENS.color_token(&"accent"))

	var hand_specs: Array[Dictionary] = [
		{"rarity": 0, "emerald": false, "arm": 0, "shd": 0, "cost": 1, "atk": 1, "hp": 1, "title": "Scout", "tribe": "Elf", "rules": "Quick step.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 1, "emerald": false, "arm": 1, "shd": 0, "cost": 2, "atk": 3, "hp": 4, "title": "Rampart Guard", "tribe": "Dwarf", "rules": "Armor 1.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 3, "emerald": true, "arm": 2, "shd": 1, "cost": 4, "atk": 4, "hp": 5, "title": "Arcane Knight", "tribe": "Human", "rules": "Gain 1 Shield on attack.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 2, "emerald": false, "arm": 0, "shd": 2, "cost": 3, "atk": 2, "hp": 3, "title": "Rune Crafter", "tribe": "Human", "rules": "Grant 2 Shield to self.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 2, "emerald": false, "arm": 0, "shd": 0, "cost": 4, "atk": 0, "hp": 0, "title": "Fireball", "tribe": "Arcane", "rules": "Deal 4 damage to target creature.", "cat": CardContentOverlay.Category.SPELL},
		{"rarity": 1, "emerald": false, "arm": 2, "shd": 0, "cost": 2, "atk": 0, "hp": 0, "title": "Bastion Armor", "tribe": "Relic", "rules": "Equipped creature gains Armor 2.", "cat": CardContentOverlay.Category.EQUIPMENT},
		{"rarity": 4, "emerald": false, "arm": 3, "shd": 2, "cost": 6, "atk": 6, "hp": 8, "title": "Iron Guardian", "tribe": "Golem", "rules": "Taunt. Dual protection test.", "cat": CardContentOverlay.Category.CREATURE},
	]

	var card_h: float = 316.0
	var card_w: float = card_h * (1086.0 / 1448.0)
	var spacing: float = (1920.0 - 80.0 - 7.0 * card_w) / 6.0
	var y_pos: float = 1080.0 - card_h - 60.0

	for i in range(7):
		var spec: Dictionary = hand_specs[i]
		var x_pos: float = 40.0 + i * (card_w + spacing)
		_card(vp, Vector2(x_pos, y_pos), card_h, spec["rarity"], spec["emerald"],
			spec["arm"], spec["shd"], spec["cost"], spec["atk"], spec["hp"],
			spec["title"], spec["tribe"], spec["rules"], spec["cat"])

	_add_label(vp, "Production Baseline: 5 Creatures with Inlays & Plaques  •  1 Spell & 1 Equipment with Inactive Sockets",
		Rect2(40, 1080 - 40, 1840, 24), 16, TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)

func _capture_four_stats_closeup_baseline(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))

	_add_label(vp, "MAGIC ODYSSEY  /  AUDIT–002 BASELINE", Rect2(64, 25, 1000, 45), 34,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "FOUR STATS DETAILED MACRO BASELINE · 1080p Reference Comparison",
		Rect2(64, 75, 1400, 32), 22, TOKENS.color_token(&"accent"))

	var tex_card: ImageTexture = await _render_card_texture(3, true, 2, 1, 4, 4, 5,
		"Arcane Knight", "Human", "Whenever this creature attacks, gain 1 Shield.")

	var stats_data: Array[Dictionary] = [
		{
			"title": "ATTACK · GRAPHITE INLAY",
			"sub": "Master frame bronze socket (r=71.5 px) + Graphite steel inlay (r=95 px)\nTacticalNumber 126 pt, 4 px outline, (0, 2) depth shadow",
			"rect": Rect2(42, 1160, 240, 240)
		},
		{
			"title": "ARMOR · STEEL PLAQUE",
			"sub": "Master bronze slot (198×100 px) + Inset steel plaque (180×62 px)\nTacticalNumber 62 pt, 4 px outline, (0, 2) depth shadow, air=6.0 px",
			"rect": Rect2(260, 1260, 238, 140)
		},
		{
			"title": "SHIELD · AZURE WARD",
			"sub": "Master bronze slot (198×100 px) + Inset azure ward plaque (180×69 px)\nTacticalNumber 62 pt, 4 px outline, (0, 2) depth shadow, air=9.0 px",
			"rect": Rect2(588, 1260, 238, 140)
		},
		{
			"title": "HEALTH · CRIMSON RUBY",
			"sub": "Master frame bronze socket (r=71.5 px) + Crimson ruby inlay (r=95 px)\nTacticalNumber 126 pt, 4 px outline, (0, 2) depth shadow",
			"rect": Rect2(799, 1160, 240, 240)
		},
	]

	var col_w: float = 410.0
	var col_gap: float = 30.0
	var start_x: float = 80.0

	for i in range(4):
		var sdata = stats_data[i]
		var x_pos: float = start_x + i * (col_w + col_gap)

		var panel: Panel = Panel.new()
		panel.position = Vector2(x_pos, 150)
		panel.size = Vector2(col_w, 800)
		panel.theme_type_variation = &"InspectorFrame"
		vp.add_child(panel)

		_add_label(panel, sdata["title"], Rect2(15, 20, col_w - 30, 30), 20,
			TOKENS.color_token(&"accent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)

		var crop_ctrl: Control = Control.new()
		crop_ctrl.position = Vector2(20, 65)
		crop_ctrl.size = Vector2(col_w - 40, 420)
		crop_ctrl.clip_contents = true
		panel.add_child(crop_ctrl)

		var atlas: AtlasTexture = AtlasTexture.new()
		atlas.atlas = tex_card
		atlas.region = sdata["rect"]
		var tr: TextureRect = TextureRect.new()
		tr.texture = atlas
		tr.size = crop_ctrl.size
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		crop_ctrl.add_child(tr)

		_add_label(panel, sdata["sub"], Rect2(20, 520, col_w - 40, 240), 16,
			TOKENS.color_token(&"text"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	await _save_and_free(vp, path)
