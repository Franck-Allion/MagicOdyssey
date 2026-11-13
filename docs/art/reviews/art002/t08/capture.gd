extends SceneTree
## ART-002-T08: Premium Stat Icon Integration & Optical Alignment Capture Suite
## Generates genuine GPU renders for all required review scenes.

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
		push_error("Graphical renderer required for T08 captures")
		quit(2)
		return

	var out_dir: String = "D:/Dev/MagicOdyssey/docs/art/reviews/art002/t08/"

	# 1. Procedural vs Premium Comparison (1080p)
	await _capture_comparison(out_dir + "procedural_vs_premium_comparison_1080p.png")

	# 2. Inspected Card (1080p)
	await _capture_inspected_card(out_dir + "inspected_card_1080p.png")

	# 3. Seven-card hand (1080p)
	await _capture_hand(out_dir + "seven_card_hand_1080p.png", Vector2i(1920, 1080))

	# 4. Seven-card hand (720p)
	await _capture_hand(out_dir + "seven_card_hand_720p.png", Vector2i(1280, 720))

	# 5. Icons Close-up (1080p)
	await _capture_closeup(out_dir + "icons_closeup_1080p.png")

	# 6. Single vs Double Digit Comparison (1080p)
	await _capture_digit_comparison(out_dir + "single_and_double_digit_comparison_1080p.png")

	# 7. Protection Combinations (1080p)
	await _capture_protection_combinations(out_dir + "protection_combinations_1080p.png")

	print("T08_ALL_CAPTURES_COMPLETED")
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
	print("T08_CAPTURE size=%s path=%s result=%d" % [vp.size, path.get_file(), err])
	root.remove_child(vp)
	vp.queue_free()

func _card(parent: Node, origin: Vector2, height: float, rarity_index: int = 3,
		use_emerald: bool = false, native_armor: int = 0, shield: int = 0,
		cost: int = 4, attack_value: int = 4, health_value: int = 5,
		title: String = "Arcane Knight", tribe: String = "Human",
		rules: String = "Whenever this creature attacks, gain 1 Shield.") -> Control:
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
		frame.material = GEM_TREATMENT.create_material(GEM_TREATMENT.TOKENS.color_token(&"epic") if false else [&"common", &"uncommon", &"rare", &"epic", &"legendary"][rarity_index])
	card.add_child(frame)

	var fields: CardContentOverlay.Content = CardContentOverlay.Content.new(
		title, CardContentOverlay.Category.CREATURE, tribe, rules)
	var text_overlay: CardContentOverlay = CONTENT_OVERLAY.new()
	card.add_child(text_overlay)
	text_overlay.configure(fields)

	var stats: CardStatOverlay = STAT_OVERLAY.new()
	card.add_child(stats)
	stats.set_printed_values(cost, attack_value, health_value, native_armor)
	stats.set_shield_overlay(shield)
	return card

func _add_label(parent: Node, value: String, bounds: Rect2, font_size: int,
		color: Color, variant: StringName = &"BodyText", align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
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

# 1. Comparison: Procedural vs Premium
func _capture_comparison(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))
	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T08", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "STAT ICON INTEGRATION · Prior Procedural Silhouettes vs Dedicated Premium Textures",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	# Left: Procedural
	CardStatOverlay.use_procedural_icons = true
	_card(vp, Vector2(250, 180), 750, 3, false, 1, 3, 2, 4, 5, "Rampart Guard", "Human", "Armor 1. Whenever this creature attacks, gain 1 Shield.")
	_add_label(vp, "PRIOR PROCEDURAL SILHOUETTES (T04B/T06)", Rect2(200, 955, 650, 40), 22,
		TOKENS.color_token(&"secondary"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(vp, "Flat vector polygons & polylines · Top-lit tinting", Rect2(200, 990, 650, 30), 18,
		TOKENS.color_token(&"secondary"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	# Right: Premium
	CardStatOverlay.use_procedural_icons = false
	_card(vp, Vector2(1090, 180), 750, 3, false, 1, 3, 2, 4, 5, "Rampart Guard", "Human", "Armor 1. Whenever this creature attacks, gain 1 Shield.")
	_add_label(vp, "PREMIUM DEDICATED TEXTURES (ART-002-T08)", Rect2(1040, 955, 650, 40), 22,
		TOKENS.color_token(&"accent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(vp, "Ornate bronze & steel artwork · Ruby heart & sapphire gems · Optical alignment", Rect2(1040, 990, 650, 30), 18,
		TOKENS.color_token(&"secondary"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	_add_label(vp, "[1] Identical numerical positions and multi-digit safe disks   •   [2] Clean alpha transparency with zero halo",
		Rect2(64, 1035, 1800, 30), 18, TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)

# 2. Inspected Card (1080p)
func _capture_inspected_card(path: String) -> void:
	CardStatOverlay.use_procedural_icons = false
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))
	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T08", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "INSPECTION VIEW · Premium Stat Icons & Optical Socket Alignment",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	_card(vp, Vector2(400, 180), 760, 3, true, 1, 3, 2, 4, 5, "Rampart Guard", "Human", "Armor 1. Whenever this creature attacks, gain 1 Shield.")

	var desc: String = "RAMPART GUARD\n\nPrinted stats: Mana 2  /  ATK 4  /  HP 5\nNative Armor 1  ·  Live Shield 3\n\nFour Dedicated Premium Icons:\n• Attack: Ornate bronze/steel sword (collet rim)\n• Health: Ruby faceted heart (collet rim)\n• Armor: Bronze-trimmed steel cuirass badge\n• Shield: Cross-embossed kite shield badge\n\nOptical Alignment:\n• Centralized typed presentation constants\n• Sized 66–70 px to balance visual weight\n• Independent socket safe disk (T04B) preserved\n• Zero numerical overlap or bezel clipping"
	_add_label(vp, desc, Rect2(1080, 260, 780, 560), 24, TOKENS.color_token(&"secondary"))

	_add_label(vp, "Master frame v03 native alpha preserved   •   Epic = Emerald green (T03C)   •   No gameplay changes",
		Rect2(64, 1030, 1800, 30), 20, TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)

# 3 & 4. Hand at 1080p and 720p
func _capture_hand(path: String, vp_size: Vector2i) -> void:
	CardStatOverlay.use_procedural_icons = false
	var vp: SubViewport = _create_viewport(vp_size)
	var stage: Control = Control.new()
	stage.size = Vector2(1920, 1080)
	var ratio: float = minf(float(vp_size.x) / 1920.0, float(vp_size.y) / 1080.0)
	stage.scale = Vector2.ONE * ratio
	stage.position = (Vector2(vp_size) - stage.size * ratio) * 0.5
	vp.add_child(stage)

	_add_label(stage, "MAGIC ODYSSEY  /  ART–002–T08", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(stage, "SEVEN-CARD HAND (%dp) · Premium Stat Icons at Actual Play Scale" % vp_size.y,
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	var height: float = 316.0
	var width: float = height * CARD_SIZE.x / CARD_SIZE.y
	var gap: float = 16.0
	var left: float = (1920.0 - width * 7.0 - gap * 6.0) * 0.5

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
		_card(stage, Vector2(left + i * (width + gap), 586), height, d["rarity"], d["emerald"],
			d["armor"], d["shield"], d["mana"], d["atk"], d["hp"], d["title"], d["tribe"])

	_add_label(stage, "LINEAR HAND  /  Entire silhouettes · 16 px gaps · no overlap",
		Rect2(84, 360, 1752, 50), 28, TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(stage, "Sword, Ruby Heart, Steel Cuirass and Kite Shield icons retain distinct silhouettes and readability at hand scale.",
		Rect2(84, 420, 1752, 50), 24, TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)

# 5. Icons Close-Up (1080p)
func _capture_closeup(path: String) -> void:
	CardStatOverlay.use_procedural_icons = false
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))
	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T08", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "MACRO CLOSE-UP · All Four Integrated Stat Icons and Card Sockets",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	# Create a card with all 4 stats active
	var card_vp: SubViewport = SubViewport.new()
	card_vp.size = Vector2i(1086, 1448)
	card_vp.transparent_bg = true
	card_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(card_vp)
	_card(card_vp, Vector2.ZERO, 1448, 3, true, 2, 4, 3, 4, 5, "Arcane Knight", "Human", "Armor 2. Shield 4.")
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw

	var card_tex: ImageTexture = ImageTexture.create_from_image(card_vp.get_texture().get_image())
	root.remove_child(card_vp)
	card_vp.queue_free()

	# Macro crop of footer area: bounds on card (40, 1140, 1006, 290)
	var footer_crop: Control = Control.new()
	footer_crop.position = Vector2(80, 200)
	footer_crop.size = Vector2(1760, 510)
	footer_crop.clip_contents = true
	vp.add_child(footer_crop)

	var footer_atlas: AtlasTexture = AtlasTexture.new()
	footer_atlas.atlas = card_tex
	footer_atlas.region = Rect2(40, 1140, 1006, 290)

	var footer_img: TextureRect = TextureRect.new()
	footer_img.texture = footer_atlas
	footer_img.position = Vector2.ZERO
	footer_img.size = footer_crop.size
	footer_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	footer_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	footer_crop.add_child(footer_img)

	# Descriptions for each icon
	var labels_x: Array[int] = [120, 520, 1020, 1450]
	var headers: Array[String] = [
		"ATTACK SWORD\nCenter: (157, 1187)\nSize: 62×62 px\nDiagonal bronze/steel blade\nSapphire crossguard gem",
		"ARMOR CUIRASS\nBadge: (280, 1280)\nSize: 66×66 px\nSculpted steel plate\nSapphire collar jewel",
		"SHIELD WARD\nBadge: (608, 1280)\nSize: 66×66 px\nEmbossed kite shield\nCentral sapphire diamond",
		"HEALTH HEART\nCenter: (934, 1187)\nSize: 62×62 px\nFaceted ruby gemstone\nFiligree bronze crest"
	]
	for i: int in range(4):
		_add_label(vp, headers[i], Rect2(labels_x[i], 750, 360, 200), 20, TOKENS.color_token(&"text"))

	_add_label(vp, "Native 1086×1448 frame crop scaled 1.75×   •   Preserves socket safe disks (T04B) and multi-digit typography clearance.",
		Rect2(80, 1020, 1760, 30), 20, TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)

# 6. Single vs Double Digit Comparison
func _capture_digit_comparison(path: String) -> void:
	CardStatOverlay.use_procedural_icons = false
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))
	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T08", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "DIGIT COMPARISON · Single vs Double Digit Numbers & Emblem Clearance",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	var test_cases: Array[Dictionary] = [
		{"cost": 2, "atk": 1, "hp": 5, "arm": 1, "shd": 0, "lbl": "Standard (1 Digit)\nATK 1   HP 5"},
		{"cost": 4, "atk": 7, "hp": 8, "arm": 2, "shd": 1, "lbl": "High (1 Digit)\nATK 7   HP 8"},
		{"cost": 5, "atk": 12, "hp": 10, "arm": 3, "shd": 4, "lbl": "Double Digit (T04B)\nATK 12   HP 10"},
		{"cost": 6, "atk": 25, "hp": 99, "arm": 5, "shd": 10, "lbl": "Stress Double Digit\nATK 25   HP 99"},
	]

	for i: int in range(4):
		var tc: Dictionary = test_cases[i]
		_card(vp, Vector2(60 + i * 460, 220), 680, 3, false, tc["arm"], tc["shd"], tc["cost"], tc["atk"], tc["hp"])
		_add_label(vp, tc["lbl"], Rect2(60 + i * 460, 930, 420, 70), 22,
			TOKENS.color_token(&"accent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)

	_add_label(vp, "T04B circular safe disk constraint automatically scales numerals to guarantee zero overlap with Attack and Health emblems.",
		Rect2(64, 1025, 1800, 30), 20, TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)

# 7. Protection Combinations
func _capture_protection_combinations(path: String) -> void:
	CardStatOverlay.use_procedural_icons = false
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))
	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T08", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "PROTECTION COMBINATIONS · Clean Footer / Armor Only / Shield Only / Both Active",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	var combos: Array[Dictionary] = [
		{"arm": 0, "shd": 0, "lbl": "No Protection\nClean Frame Footer"},
		{"arm": 2, "shd": 0, "lbl": "Armor Only\nCuirass Badge [2]"},
		{"arm": 0, "shd": 3, "lbl": "Shield Only\nKite Shield Badge [3]"},
		{"arm": 1, "shd": 4, "lbl": "Armor & Shield\nBoth Badges Active [1] [4]"},
	]

	for i: int in range(4):
		var c: Dictionary = combos[i]
		_card(vp, Vector2(60 + i * 460, 220), 680, 3, false, c["arm"], c["shd"], 3, 4, 5)
		_add_label(vp, c["lbl"], Rect2(60 + i * 460, 930, 420, 70), 22,
			TOKENS.color_token(&"accent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)

	_add_label(vp, "Zero protection values hide their badges; neither badges nor emblems obscure rules text or rarity gemstones.",
		Rect2(64, 1025, 1800, 30), 20, TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)
