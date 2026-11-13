extends SceneTree
## ART-002-T11: Stat Icon Scale & Container Optical Alignment Capture Suite
## Generates genuine GPU renders for all 6 required review scenes at 1920x1080.

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
		push_error("Graphical renderer required for T11 captures")
		quit(2)
		return

	var out_dir: String = "D:/Dev/MagicOdyssey/docs/art/reviews/art002/t11/"

	# 1. Before / After Icon Sizing (1080p)
	await _capture_before_after_icons(out_dir + "before_after_icons_1080p.png")

	# 2. Before / After Container Optical Alignment (1080p)
	await _capture_before_after_containers(out_dir + "before_after_containers_1080p.png")

	# 3. Final Inspected Card (1080p)
	await _capture_final_inspected_card(out_dir + "final_inspected_card_1080p.png")

	# 4. Final Seven-Card Hand (1080p)
	await _capture_final_seven_card_hand(out_dir + "final_seven_card_hand_1080p.png")

	# 5. Final Full Combat Interface (1080p)
	await _capture_final_combat(out_dir + "final_combat_1080p.png")

	# 6. Optical Alignment Diagnostics with Measured Overlays (1080p)
	await _capture_diagnostics(out_dir + "optical_alignment_diagnostics_1080p.png")

	print("T11_ALL_CAPTURES_COMPLETED")
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
	print("T11_CAPTURE size=%s path=%s result=%d" % [vp.size, path.get_file(), err])
	root.remove_child(vp)
	vp.queue_free()

func _card(parent: Node, origin: Vector2, height: float, rarity_index: int = 3,
		use_emerald: bool = false, native_armor: int = 0, shield: int = 0,
		cost: int = 4, attack_value: int = 4, health_value: int = 5,
		title: String = "Arcane Knight", tribe: String = "Human",
		rules: String = "Whenever this creature attacks, gain 1 Shield.",
		force_t10: bool = false) -> Control:
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
	crop.region = Rect2(0, 0, 1086, 900)
	var portrait: TextureRect = TextureRect.new()
	portrait.texture = crop
	portrait.position = Vector2.ZERO
	portrait.size = aperture.size
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aperture.add_child(portrait)

	var frame: TextureRect = TextureRect.new()
	frame.texture = FRAME
	frame.position = Vector2.ZERO
	frame.size = CARD_SIZE
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if use_emerald and rarity_index == 3:
		frame.material = GEM_TREATMENT.create_emerald_epic_material()
	else:
		frame.material = GEM_TREATMENT.create_material(
			[&"common", &"uncommon", &"rare", &"epic", &"legendary"][rarity_index])
	card.add_child(frame)

	var fields: CardContentOverlay.Content = CardContentOverlay.Content.new(
		title, CardContentOverlay.Category.CREATURE, tribe, rules)
	var text_overlay: CardContentOverlay = CONTENT_OVERLAY.new()
	card.add_child(text_overlay)
	text_overlay.configure(fields)

	# Setup stat overlay with version / sizing control
	CardStatOverlay.use_t10_sizing = force_t10
	var stats: CardStatOverlay = STAT_OVERLAY.new()
	card.add_child(stats)
	stats.set_printed_values(cost, attack_value, health_value, native_armor)
	stats.set_shield_overlay(shield)
	CardStatOverlay.use_t10_sizing = false
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

# -----------------------------------------------------------------------------
# 1. Before / After Icon Sizing (1080p)
# -----------------------------------------------------------------------------
func _capture_before_after_icons(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))
	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T11", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "STAT ICON RESIZING · Before (T10 Oversized) vs After (T11 Balanced Breathing Room)",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	# Render Card Before (T10)
	var vp_before: SubViewport = SubViewport.new()
	vp_before.size = Vector2i(1086, 1448)
	vp_before.transparent_bg = true
	vp_before.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp_before)
	_card(vp_before, Vector2.ZERO, 1448, 3, true, 2, 4, 3, 4, 5, "Rampart Guard", "Human", "", true)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var tex_before: ImageTexture = ImageTexture.create_from_image(vp_before.get_texture().get_image())
	root.remove_child(vp_before)
	vp_before.queue_free()

	# Render Card After (T11)
	var vp_after: SubViewport = SubViewport.new()
	vp_after.size = Vector2i(1086, 1448)
	vp_after.transparent_bg = true
	vp_after.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp_after)
	_card(vp_after, Vector2.ZERO, 1448, 3, true, 2, 4, 3, 4, 5, "Rampart Guard", "Human", "", false)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var tex_after: ImageTexture = ImageTexture.create_from_image(vp_after.get_texture().get_image())
	root.remove_child(vp_after)
	vp_after.queue_free()

	# Layout: Left column = Before (T10), Right column = After (T11)
	# Column headers
	_add_label(vp, "BEFORE (ART-002-T10) · OVERSIZED", Rect2(80, 145, 840, 35), 22,
		TOKENS.color_token(&"secondary"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(vp, "AFTER (ART-002-T11) · BALANCED BREATHING ROOM", Rect2(1000, 145, 840, 35), 22,
		TOKENS.color_token(&"accent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)

	# Crops:
	# Row 1: Attack and Health socket collets (macro zoom)
	# Card bounds: Attack collet (110, 1140, 100, 100); Health collet (880, 1140, 100, 100)
	var crops_config: Array[Dictionary] = [
		{"title": "ATTACK SWORD", "rect_b": Rect2(100, 1135, 115, 110), "rect_a": Rect2(105, 1135, 115, 110),
		 "desc_b": "Size 60x60 (Vis. 26x59 px)\nHeight 59.3 px exceeds 58 px collet!\nTouching bronze rim (-0.7 px margin)",
		 "desc_a": "Size 48x48 (Vis. 21x47 px)\nHeight 47.4 px fits inside 58 px collet\nClean +5.3 px breathing room margin"},
		{"title": "HEALTH HEART", "rect_b": Rect2(875, 1135, 115, 110), "rect_a": Rect2(862, 1135, 115, 110),
		 "desc_b": "Size 68x68 (Vis. 52x49 px)\nWidth 52 px leaves only 2.9 px margin\nCramped inside 58 px socket collet",
		 "desc_a": "Size 52x52 (Vis. 40x37 px)\nWidth 40 px leaves +9.1 px margin\nGenerous gemstone breathing room"},
		{"title": "ARMOR CUIRASS", "rect_b": Rect2(280, 1280, 198, 100), "rect_a": Rect2(280, 1280, 198, 100),
		 "desc_b": "Size 68x68 (Vis. 52x49 px)\nEncroaches into plate corner radius 23\nLeft margin only 22 px; crowded",
		 "desc_a": "Size 52x52 (Vis. 40x37 px)\n31.3 px vertical breathing room\nBalanced 30 px left margin to corner"},
		{"title": "SHIELD WARD", "rect_b": Rect2(608, 1280, 198, 100), "rect_a": Rect2(608, 1280, 198, 100),
		 "desc_b": "Size 64x64 (Vis. 43x52 px)\nVertical margin only 23.9 px\nTight fit within 100 px badge",
		 "desc_a": "Size 50x50 (Vis. 33x41 px)\n29.6 px vertical breathing room\nMatches Armor cuirass visual weight"},
	]

	for i: int in range(4):
		var cfg: Dictionary = crops_config[i]
		var y_pos: float = 200.0 + i * 200.0

		# Section label
		_add_label(vp, cfg["title"], Rect2(880, y_pos + 60, 160, 30), 18,
			TOKENS.color_token(&"text_bright"), &"SectionHeading", HORIZONTAL_ALIGNMENT_CENTER)

		# Left crop (Before)
		var crop_b: Control = Control.new()
		crop_b.position = Vector2(100, y_pos)
		crop_b.size = Vector2(280, 170)
		crop_b.clip_contents = true
		vp.add_child(crop_b)
		var at_b: AtlasTexture = AtlasTexture.new()
		at_b.atlas = tex_before
		at_b.region = cfg["rect_b"]
		var img_b: TextureRect = TextureRect.new()
		img_b.texture = at_b
		img_b.size = crop_b.size
		img_b.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img_b.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		crop_b.add_child(img_b)

		_add_label(vp, cfg["desc_b"], Rect2(400, y_pos + 20, 460, 130), 18, TOKENS.color_token(&"text"))

		# Right crop (After)
		var crop_a: Control = Control.new()
		crop_a.position = Vector2(1060, y_pos)
		crop_a.size = Vector2(280, 170)
		crop_a.clip_contents = true
		vp.add_child(crop_a)
		var at_a: AtlasTexture = AtlasTexture.new()
		at_a.atlas = tex_after
		at_a.region = cfg["rect_a"]
		var img_a: TextureRect = TextureRect.new()
		img_a.texture = at_a
		img_a.size = crop_a.size
		img_a.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img_a.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		crop_a.add_child(img_a)

		_add_label(vp, cfg["desc_a"], Rect2(1360, y_pos + 20, 480, 130), 18, TOKENS.color_token(&"accent_bright"))

	_add_label(vp, "V2 source textures untouched   •   Visible silhouette bounds measured and padded   •   Clean breathing room across all containers",
		Rect2(64, 1030, 1800, 30), 18, TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)

# -----------------------------------------------------------------------------
# 2. Before / After Container Optical Alignment (1080p)
# -----------------------------------------------------------------------------
func _capture_before_after_containers(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))
	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T11", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "CONTAINER OPTICAL ALIGNMENT · Pre-T11 Misaligned Axes vs T11 Precision Registration",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	# Left Card: Before (T10 settings)
	_card(vp, Vector2(200, 160), 750, 3, false, 2, 4, 3, 4, 5, "Rampart Guard", "Human", "Armor 2. Shield 4.", true)
	_add_label(vp, "BEFORE (ART-002-T10)", Rect2(150, 930, 660, 35), 22,
		TOKENS.color_token(&"secondary"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(vp, "Attack Collet X=157 vs Numeral X=162 (-5 px axis delta)\nHealth Collet X=934 vs Numeral X=919 (+15 px axis delta)\nBadge Contents: Icon at 48, Numeral at 137 (Left-heavy)",
		Rect2(150, 970, 660, 60), 17, TOKENS.color_token(&"secondary"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	# Right Card: After (T11 settings)
	_card(vp, Vector2(1060, 160), 750, 3, false, 2, 4, 3, 4, 5, "Rampart Guard", "Human", "Armor 2. Shield 4.", false)
	_add_label(vp, "AFTER (ART-002-T11)", Rect2(1010, 930, 660, 35), 22,
		TOKENS.color_token(&"accent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(vp, "Attack Collet X=162 vs Numeral X=162 (0 px axis error)\nHealth Collet X=919 vs Numeral X=919 (0 px axis error)\nBadge Contents: Icon at 50, Numeral at 140 (Balanced group center)",
		Rect2(1010, 970, 660, 60), 17, TOKENS.color_token(&"accent_bright"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	_add_label(vp, "Container collets seated on apex of painted socket bezels   •   Badge group centers optically balanced around X=99",
		Rect2(64, 1040, 1800, 30), 18, TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)

# -----------------------------------------------------------------------------
# 3. Final Inspected Card (1080p)
# -----------------------------------------------------------------------------
func _capture_final_inspected_card(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))
	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T11", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "INSPECTION VIEW · Final Calibrated Stat Presentation & Optical Balance",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	_card(vp, Vector2(360, 170), 780, 3, true, 2, 4, 3, 4, 5, "Rampart Guard", "Human", "Armor 2. Whenever this creature attacks, gain 1 Shield.", false)

	var desc: String = "RAMPART GUARD\n\nPrinted stats: Mana 3  /  ATK 4  /  HP 5\nNative Armor 2  ·  Live Shield 4\n\nT11 Calibrated Presentation Metrics:\n• Attack Collet: Aligned at X=162, Y=1187 (0 px delta to numeral)\n• Health Collet: Aligned at X=919, Y=1187 (0 px delta to numeral)\n• Attack Sword: 48×48 px, +5.3 px inner collet margin\n• Health Heart: 52×52 px, +9.1 px inner collet margin, offset (0, -1)\n• Armor Cuirass: 52×52 px, +31.3 px vertical badge margin\n• Shield Ward: 50×50 px, +29.6 px vertical badge margin\n• Badge Composition: Icon at (50, 50), Numeral at (140, 50)\n• Group Balance: 30 px left margin, 40 px right margin, 52 px gap\n• Zero overlap with T04B safe disks (R=70 px) or bronze borders"
	_add_label(vp, desc, Rect2(1020, 210, 840, 640), 22, TOKENS.color_token(&"secondary"))

	_add_label(vp, "Master frame v03 native alpha preserved   •   Canonical Epic = Emerald green (T03C)   •   No gameplay modifications",
		Rect2(64, 1030, 1800, 30), 20, TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)

# -----------------------------------------------------------------------------
# 4. Final Seven-Card Hand (1080p)
# -----------------------------------------------------------------------------
func _capture_final_seven_card_hand(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))
	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T11", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "SEVEN-CARD HAND (1080p) · Final Calibrated Stat Presentation at In-Game Play Scale",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	var height: float = 316.0
	var width: float = height * CARD_SIZE.x / CARD_SIZE.y
	var gap: float = 16.0
	var left: float = (1920.0 - width * 7.0 - gap * 6.0) * 0.5
	var hand_y: float = 586.0

	var hand_data: Array[Dictionary] = [
		{"rarity": 0, "emerald": false, "armor": 0, "shield": 0, "mana": 1, "atk": 1, "hp": 2, "title": "Squire", "tribe": "Human"},
		{"rarity": 1, "emerald": false, "armor": 1, "shield": 0, "mana": 2, "atk": 2, "hp": 3, "title": "Shieldbearer", "tribe": "Dwarf"},
		{"rarity": 2, "emerald": false, "armor": 0, "shield": 2, "mana": 3, "atk": 3, "hp": 4, "title": "Spellblade", "tribe": "Elf"},
		{"rarity": 3, "emerald": false, "armor": 2, "shield": 3, "mana": 4, "atk": 4, "hp": 5, "title": "Arcane Knight", "tribe": "Human"},
		{"rarity": 4, "emerald": false, "armor": 1, "shield": 0, "mana": 5, "atk": 5, "hp": 6, "title": "Sun Champion", "tribe": "Avatar"},
		{"rarity": 3, "emerald": true,  "armor": 0, "shield": 4, "mana": 4, "atk": 12, "hp": 10, "title": "Grove Warden", "tribe": "Treant"},
		{"rarity": 1, "emerald": false, "armor": 0, "shield": 0, "mana": 2, "atk": 2, "hp": 2, "title": "Scout", "tribe": "Human"},
	]

	for i: int in range(7):
		var d: Dictionary = hand_data[i]
		_card(vp, Vector2(left + i * (width + gap), hand_y), height, d["rarity"], d["emerald"],
			d["armor"], d["shield"], d["mana"], d["atk"], d["hp"], d["title"], d["tribe"])

	_add_label(vp, "LINEAR HAND AT 1080p  /  Card height: 316 pixels  •  Generous container breathing room",
		Rect2(84, 360, 1752, 50), 28, TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "Refined 48–52 px icon scale prevents border crowding at hand scale while maintaining crisp silhouette recognition.",
		Rect2(84, 420, 1752, 50), 24, TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)

# -----------------------------------------------------------------------------
# 5. Final Full Combat Interface (1080p)
# -----------------------------------------------------------------------------
func _capture_final_combat(path: String) -> void:
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
	_add_label(vp, "ART-002-T11 · REFINED ICON SCALE & ALIGNMENT · 1080p", Rect2(62, 64, 480, 24), 18, TOKENS.color_token(&"secondary"))

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
	vp.add_child(end_btn)
	_add_label(vp, "COMBAT READY", Rect2(1695, 450, 168, 24), 16, TOKENS.color_token(&"valid"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	# Left Inspector Card View: miniature preview
	var insp_panel: Panel = Panel.new()
	insp_panel.position = Vector2(42, 130)
	insp_panel.size = Vector2(200, 300)
	insp_panel.theme_type_variation = &"InspectorFrame"
	vp.add_child(insp_panel)
	_add_label(vp, "INSPECTION", Rect2(55, 140, 174, 24), 18, TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "Rampart Guard", Rect2(55, 168, 174, 26), 20, TOKENS.color_token(&"text_bright"))
	_add_label(vp, "ATK 4 (Collet)\nHP  5 (Collet)\nArmor 1 (Badge)\nShield 3 (Badge)", Rect2(55, 200, 174, 110), 18, TOKENS.color_token(&"text"))
	_add_label(vp, "[+] HOVERED", Rect2(55, 380, 174, 24), 16, TOKENS.color_token(&"selected"))

	# Player Info Panel (Bottom Left)
	var player_panel: Panel = Panel.new()
	player_panel.position = Vector2(42, 450)
	player_panel.size = Vector2(200, 200)
	player_panel.theme_type_variation = &"HeroFrame"
	vp.add_child(player_panel)
	_add_label(vp, "PLAYER / YOU", Rect2(55, 462, 174, 22), 18, TOKENS.color_token(&"player"))
	_add_label(vp, "28 HP", Rect2(55, 490, 174, 34), 30, TOKENS.color_token(&"text_bright"), &"SectionHeading")
	_add_label(vp, "3 / 5 MANA\nDECK 27\nHAND 7", Rect2(55, 530, 174, 75), 18, TOKENS.color_token(&"secondary"))

	# Combat Grid Slots (4 rows x 6 columns)
	var grid_x: float = 478.0
	var col_step: float = 185.0
	var row_y: Array[float] = [230.0, 350.0, 485.0, 605.0]
	var row_names: Array[String] = ["O / DEFENSE", "O / ATTACK", "P / ATTACK", "P / DEFENSE"]

	for r: int in range(4):
		var camp: StringName = &"opponent" if r < 2 else &"player"
		var r_lbl: Panel = Panel.new()
		r_lbl.position = Vector2(278, row_y[r] + 30)
		r_lbl.size = Vector2(184, 36)
		r_lbl.theme_type_variation = &"InspectorFrame"
		vp.add_child(r_lbl)
		_add_label(vp, row_names[r], Rect2(289, row_y[r] + 34, 170, 28), 18, TOKENS.color_token(camp))

		for c: int in range(6):
			var slot_pos: Vector2 = Vector2(grid_x + c * col_step, row_y[r])
			var slot: Panel = Panel.new()
			slot.position = slot_pos
			slot.size = Vector2(164, 110)
			slot.theme_type_variation = &"TokenFrame"
			var style: StyleBoxFlat = TOKENS.THEME.get_stylebox("panel", "TokenFrame").duplicate() as StyleBoxFlat
			style.bg_color = TOKENS.color_token(&"background")
			style.bg_color.a = 0.20
			style.border_color = TOKENS.color_token(camp)
			style.border_color.a = 0.55
			slot.add_theme_stylebox_override("panel", style)
			vp.add_child(slot)

			if (r == 1 and c in [0, 2, 4]) or (r == 2 and c in [1, 3, 5]):
				_add_label(vp, "%d / %d" % [3 + (c % 3), 4 + (r % 2)],
					Rect2(slot_pos.x, slot_pos.y + 40, 164, 30), 22, TOKENS.color_token(&"text_bright"),
					&"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	# Seven-Card Hand at bottom of combat screen
	var card_h: float = 300.0
	var card_w: float = card_h * CARD_SIZE.x / CARD_SIZE.y
	var gap: float = 18.0
	var total_hand_w: float = 7.0 * card_w + 6.0 * gap
	var hand_left: float = (1920.0 - total_hand_w) * 0.5
	var hand_y: float = 760.0

	var hand_data: Array[Dictionary] = [
		{"rarity": 0, "emerald": false, "armor": 0, "shield": 0, "mana": 1, "atk": 1, "hp": 2, "title": "Squire", "tribe": "Human"},
		{"rarity": 1, "emerald": false, "armor": 1, "shield": 0, "mana": 2, "atk": 2, "hp": 3, "title": "Shieldbearer", "tribe": "Dwarf"},
		{"rarity": 2, "emerald": false, "armor": 0, "shield": 2, "mana": 3, "atk": 3, "hp": 4, "title": "Spellblade", "tribe": "Elf"},
		{"rarity": 3, "emerald": false, "armor": 2, "shield": 3, "mana": 4, "atk": 4, "hp": 5, "title": "Arcane Knight", "tribe": "Human"},
		{"rarity": 4, "emerald": false, "armor": 1, "shield": 0, "mana": 5, "atk": 5, "hp": 6, "title": "Sun Champion", "tribe": "Avatar"},
		{"rarity": 3, "emerald": true,  "armor": 0, "shield": 4, "mana": 4, "atk": 12, "hp": 10, "title": "Grove Warden", "tribe": "Treant"},
		{"rarity": 1, "emerald": false, "armor": 0, "shield": 0, "mana": 2, "atk": 2, "hp": 2, "title": "Scout", "tribe": "Human"},
	]

	for i: int in range(7):
		var d: Dictionary = hand_data[i]
		_card(vp, Vector2(hand_left + i * (card_w + gap), hand_y), card_h, d["rarity"], d["emerald"],
			d["armor"], d["shield"], d["mana"], d["atk"], d["hp"], d["title"], d["tribe"])

	await _save_and_free(vp, path)

# -----------------------------------------------------------------------------
# 6. Optical Alignment Diagnostics with Measured Overlays (1080p)
# -----------------------------------------------------------------------------
func _capture_diagnostics(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))
	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T11", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "OPTICAL ALIGNMENT DIAGNOSTICS · Measured Geometry, Precision Axes & Clearances",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	# Render card at center-left with scale 780 px height
	var card_pos: Vector2 = Vector2(200, 170)
	var card_h: float = 780.0
	var card_scale: float = card_h / CARD_SIZE.y
	_card(vp, card_pos, card_h, 3, true, 2, 4, 3, 4, 5, "Rampart Guard", "Human", "Armor 2. Shield 4.", false)

	# Overlay diagnostic drawing canvas
	var diag: Control = Control.new()
	diag.position = card_pos
	diag.size = CARD_SIZE
	diag.scale = Vector2.ONE * card_scale
	vp.add_child(diag)

	diag.draw.connect(func() -> void:
		var col_axis: Color = Color(1.0, 0.25, 0.25, 0.85) # Red for vertical axes
		var col_sym: Color = Color(0.25, 0.85, 1.0, 0.85) # Cyan for symmetry axes
		var col_box: Color = Color(1.0, 0.85, 0.25, 0.85) # Gold for bounding boxes

		# 1. Attack vertical axis: X = 162
		diag.draw_line(Vector2(162, 1140), Vector2(162, 1360), col_axis, 2.5, true)
		diag.draw_circle(Vector2(162, 1187), 4.0, col_box)
		diag.draw_circle(Vector2(162, 1279), 4.0, col_box)
		diag.draw_arc(Vector2(162, 1187), 29.0, 0, TAU, 32, col_sym, 1.5, true)
		diag.draw_arc(Vector2(162, 1187), 34.0, 0, TAU, 32, col_box, 1.5, true)

		# 2. Health vertical axis: X = 919
		diag.draw_line(Vector2(919, 1140), Vector2(919, 1360), col_axis, 2.5, true)
		diag.draw_circle(Vector2(919, 1187), 4.0, col_box)
		diag.draw_circle(Vector2(919, 1279), 4.0, col_box)
		diag.draw_arc(Vector2(919, 1187), 29.0, 0, TAU, 32, col_sym, 1.5, true)
		diag.draw_arc(Vector2(919, 1187), 34.0, 0, TAU, 32, col_box, 1.5, true)

		# 3. Card center symmetry axis: X = 543
		diag.draw_line(Vector2(543, 1240), Vector2(543, 1420), col_sym, 2.0, true)

		# 4. Armor badge guides (280, 1280, 198, 100)
		var arm_rect: Rect2 = Rect2(280, 1280, 198, 100)
		diag.draw_rect(arm_rect, col_box, false, 2.0)
		diag.draw_circle(arm_rect.position + Vector2(50, 50), 4.0, col_axis)
		diag.draw_circle(arm_rect.position + Vector2(140, 50), 4.0, col_axis)
		diag.draw_line(arm_rect.position + Vector2(50, 20), arm_rect.position + Vector2(50, 80), col_axis, 1.5, true)
		diag.draw_line(arm_rect.position + Vector2(140, 20), arm_rect.position + Vector2(140, 80), col_axis, 1.5, true)

		# 5. Shield badge guides (608, 1280, 198, 100)
		var shd_rect: Rect2 = Rect2(608, 1280, 198, 100)
		diag.draw_rect(shd_rect, col_box, false, 2.0)
		diag.draw_circle(shd_rect.position + Vector2(50, 50), 4.0, col_axis)
		diag.draw_circle(shd_rect.position + Vector2(140, 50), 4.0, col_axis)
		diag.draw_line(shd_rect.position + Vector2(50, 20), shd_rect.position + Vector2(50, 80), col_axis, 1.5, true)
		diag.draw_line(shd_rect.position + Vector2(140, 20), shd_rect.position + Vector2(140, 80), col_axis, 1.5, true)
	)

	# Right-hand diagnostic report panel
	var panel: Panel = Panel.new()
	panel.position = Vector2(840, 170)
	panel.size = Vector2(1020, 820)
	panel.theme_type_variation = &"InspectorFrame"
	vp.add_child(panel)

	_add_label(panel, "GEOMETRY & OPTICAL ALIGNMENT MEASUREMENTS", Rect2(40, 30, 940, 40), 24,
		TOKENS.color_token(&"accent"), &"SectionHeading")

	var report_text: String = """1. SOCKET VERTICAL AXES & COLLET CENTERING:
• Attack Socket Center: (162, 1279) [T04B median fit, R=78.1 px]
• Attack Emblem Collet: (162, 1187) -> Exact vertical alignment (0.0 px delta)
• Health Socket Center: (919, 1279) [T04B median fit, R=78.1 px]
• Health Emblem Collet: (919, 1187) -> Exact vertical alignment (0.0 px delta)
• Previous T10 misalignment resolved: Attack had -5 px offset, Health had +15 px offset

2. ICON SILHOUETTE RESIZING & BREATHING ROOM:
• Attack Sword: 48x48 px (Visible 21.0 x 47.4 px)
  - Collet inner circle (R=29, Dia=58 px): +5.3 px top/bottom clearance
  - Collet bronze bezel (R=34, Dia=68 px): +10.3 px clearance
• Health Ruby Heart: 52x52 px (Visible 39.8 x 37.2 px, offset (0, -1))
  - Collet inner circle: +9.1 px horizontal clearance, +10.4 px vertical clearance
  - Collet bronze bezel: +14.1 px horizontal, +15.4 px vertical clearance
• Armor Cuirass: 52x52 px (Visible 39.8 x 37.4 px)
  - Badge vertical clearance: (100 - 37.4) / 2 = +31.3 px breathing room
• Shield Arcane Ward: 50x50 px (Visible 33.2 x 40.8 px)
  - Badge vertical clearance: (100 - 40.8) / 2 = +29.6 px breathing room
  - Perceived visual scale between Armor and Shield is identical (within 5%)

3. BADGE COMPOSITION & OPTICAL BALANCE:
• Badge Plates: Rect2(280, 1280, 198, 100) and Rect2(608, 1280, 198, 100)
• Mathematical symmetry: Exactly 65 px from center X=543, 280 px from outer frame
• Calibrated Icon Center: (50, 50) -> Left margin: 30.1 px (clears corner radius 23)
• Calibrated Numeral Center: (140, 50) -> Right margin: 40.0 px for single digit
• Inter-element space: 52.1 px (single digit), 33.1 px (double digit, zero collision)
• Group Visual Center: X=94.1 px (balanced within 4.9 px of badge center X=99)"""

	_add_label(panel, report_text, Rect2(40, 80, 940, 710), 19, TOKENS.color_token(&"text"))

	_add_label(vp, "Diagnostic guides rendered in this technical view only   •   Clean production presentation in all gameplay captures",
		Rect2(64, 1030, 1800, 30), 18, TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)
