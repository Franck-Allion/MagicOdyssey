extends Control
## Isolated visual fixture. No catalog, engine, input commands or production CardView.
## Master v03 with native alpha and reusable, precisely masked rarity crystals.

const FRAME: Texture2D = preload("res://assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png")
const ART: Texture2D = preload("res://assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")
const GEM_TREATMENT: GDScript = preload("res://scripts/presentation/rarity_gem_treatment.gd")
const STAT_OVERLAY: GDScript = preload("res://scripts/presentation/card_stat_overlay.gd")
const CONTENT_OVERLAY: GDScript = preload("res://scripts/presentation/card_content_overlay.gd")
const CATEGORY_OVERLAY: GDScript = preload("res://scripts/presentation/card_category_overlay.gd")
const LAYOUT: GDScript = preload("res://scripts/presentation/card_view_layout.gd")

const RARITIES: Array[StringName] = [&"common", &"uncommon", &"rare", &"epic", &"legendary"]
const NAMES: PackedStringArray = ["Common", "Uncommon", "Rare", "Epic", "Legendary"]

var _stage: Control
var _mode: int = 0
var _gem_materials: Array[ShaderMaterial] = []

func _ready() -> void:
	theme = TOKENS.THEME
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--mode="):
			_mode = clampi(argument.trim_prefix("--mode=").to_int(), 0, 5)
	for rarity: StringName in RARITIES:
		_gem_materials.append(GEM_TREATMENT.create_material(rarity))
	resized.connect(_rebuild)
	_rebuild()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var key: InputEventKey = event as InputEventKey
		if key.keycode >= KEY_1 and key.keycode <= KEY_6:
			_mode = key.keycode - KEY_1
			_rebuild()

func _label(parent: Control, value: String, bounds: Rect2, font_size: int,
		color: Color, variant: StringName = &"BodyText") -> Label:
	var label: Label = Label.new()
	label.text = value
	label.position = bounds.position
	label.size = bounds.size
	label.theme_type_variation = variant
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _texture(parent: Control, tex: Texture2D, bounds: Rect2) -> TextureRect:
	var rect: TextureRect = TextureRect.new()
	rect.texture = tex
	rect.position = bounds.position
	rect.size = bounds.size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	parent.add_child(rect)
	return rect

func _rebuild() -> void:
	if not is_inside_tree():
		return
	if is_instance_valid(_stage):
		remove_child(_stage)
		_stage.queue_free()
	_stage = Control.new()
	_stage.size = Vector2(1920, 1080)
	var ratio: float = minf(size.x / 1920.0, size.y / 1080.0)
	_stage.scale = Vector2.ONE * ratio
	_stage.position = (size - Vector2(1920, 1080) * ratio) * 0.5
	add_child(_stage)

	var bg: Panel = Panel.new()
	bg.size = Vector2(1920, 1080)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = TOKENS.color_token(&"background")
	bg.add_theme_stylebox_override("panel", style)
	_stage.add_child(bg)

	_label(_stage, "MAGIC ODYSSEY  /  ART–002", Rect2(64, 40, 900, 50), 38,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_label(_stage, "CARD PRESENTATION · MASTER v03 WITH INTEGRATED INLAYS & PLAQUES", Rect2(64, 98, 1400, 40), 24,
		TOKENS.color_token(&"accent"))

	if _mode == 0:
		_show_inspection()
	elif _mode == 1:
		_show_hand()
	elif _mode == 2:
		_show_rarities()
	elif _mode == 3:
		_show_epic_showcase()
	elif _mode == 4:
		_show_sockets()
	else:
		_show_protections()

	_label(_stage, "[1] Inspection   [2] Hand   [3] Rarities   [4] Epic showcase   [5] Sockets   [6] Protections   •   Presentation review",
		Rect2(64, 1025, 1800, 35), 21, TOKENS.color_token(&"secondary"))

func _card(parent: Control, origin: Vector2, height: float, rarity_index: int = 3,
		material_override: ShaderMaterial = null, native_armor: int = 0, shield: int = 0,
		cost: int = 4, attack_value: int = 4, health_value: int = 5,
		content: CardContentOverlay.Content = null) -> Control:
	var card: Control = Control.new()
	card.position = origin
	card.size = CardViewLayout.CARD_SIZE
	card.scale = Vector2.ONE * height / CardViewLayout.CARD_SIZE.y
	parent.add_child(card)

	var aperture: Control = Control.new()
	aperture.position = CardViewLayout.APERTURE_BOUNDS.position
	aperture.size = CardViewLayout.APERTURE_BOUNDS.size
	aperture.clip_contents = true
	card.add_child(aperture)

	var crop: AtlasTexture = AtlasTexture.new()
	crop.atlas = ART
	crop.region = CardViewLayout.PORTRAIT_CROP_REGION
	var portrait: TextureRect = _texture(aperture, crop, Rect2(Vector2.ZERO, aperture.size))
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait.texture_filter = Control.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC

	var frame: TextureRect = _texture(card, FRAME, Rect2(Vector2.ZERO, CardViewLayout.CARD_SIZE))
	frame.texture_filter = Control.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	frame.material = material_override if material_override != null else _gem_materials[rarity_index]

	var fields: CardContentOverlay.Content = content if content != null else CardContentOverlay.Content.new(
		"Arcane Knight", CardContentOverlay.Category.CREATURE, "Human", "Whenever this creature attacks, gain 1 Shield.")
	var text_overlay: CardContentOverlay = CONTENT_OVERLAY.new()
	text_overlay.name = "CardContent"
	card.add_child(text_overlay)
	var text_result: Error = text_overlay.configure(fields)
	if text_result != OK:
		push_error("ART002 content rejected: %s" % text_overlay.overflow_reason)

	var stats: CardSocketOverlay = STAT_OVERLAY.new() if fields.category == CardContentOverlay.Category.CREATURE else CATEGORY_OVERLAY.new()
	if stats is CardCategoryOverlay:
		(stats as CardCategoryOverlay).category = fields.category
	card.add_child(stats)
	stats.set_printed_values(cost, attack_value, health_value, native_armor)
	stats.set_shield_overlay(shield)
	return card

func _show_inspection() -> void:
	var card_h: float = 880.0
	_card(_stage, Vector2(110, 140), card_h, 3, null, 2, 1)

	var info: Panel = Panel.new()
	info.position = Vector2(810, 140)
	info.size = Vector2(1000, card_h)
	info.theme_type_variation = &"InspectorFrame"
	_stage.add_child(info)

	_label(info, "MASTER v03 · CANONICAL EMERALD EPIC", Rect2(40, 30, 920, 45), 30,
		TOKENS.color_token(&"accent"), &"CardTitle")
	var desc: String = "Authoritative Architecture (AUDIT-002-T03):\n  • Master Frame: v03 native alpha with CardViewLayout definitions\n  • Canonical Epic: Colombian emerald green in UI Theme & ShaderMaterial\n  • Primary Sockets: Attack graphite steel & Health ruby inlays on Layer 2\n  • Socket Bezels: Original sculpted bronze rings on Layer 3\n  • Secondary Badges: Armor steel plaque (180×62) & Shield azure plaque (180×69)\n  • Coherent Numerals: 4 px dark outline + (0, 2) depth shadow across all 4 stats\n  • Typography: TacticalNumber 62 pt secondary font with >= 5 px vertical air\n  • Decoupled Architecture: CardCategoryOverlay decoupled from creature inlays"
	_label(info, desc, Rect2(40, 85, 920, 440), 18, TOKENS.color_token(&"text"))

func _show_hand() -> void:
	var hand_specs: Array[Dictionary] = [
		{"rarity": 0, "arm": 0, "shd": 0, "cost": 1, "atk": 1, "hp": 1, "title": "Scout", "tribe": "Elf", "rules": "Quick step.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 1, "arm": 1, "shd": 0, "cost": 2, "atk": 3, "hp": 4, "title": "Rampart Guard", "tribe": "Dwarf", "rules": "Armor 1.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 3, "arm": 2, "shd": 1, "cost": 4, "atk": 4, "hp": 5, "title": "Arcane Knight", "tribe": "Human", "rules": "Gain 1 Shield on attack.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 2, "arm": 0, "shd": 2, "cost": 3, "atk": 2, "hp": 3, "title": "Rune Crafter", "tribe": "Human", "rules": "Grant 2 Shield to self.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 2, "arm": 0, "shd": 0, "cost": 4, "atk": 0, "hp": 0, "title": "Fireball", "tribe": "Arcane", "rules": "Deal 4 damage.", "cat": CardContentOverlay.Category.SPELL},
		{"rarity": 1, "arm": 2, "shd": 0, "cost": 2, "atk": 0, "hp": 0, "title": "Bastion Armor", "tribe": "Relic", "rules": "Equipped +2 Armor.", "cat": CardContentOverlay.Category.EQUIPMENT},
		{"rarity": 4, "arm": 3, "shd": 2, "cost": 6, "atk": 6, "hp": 8, "title": "Iron Guardian", "tribe": "Golem", "rules": "Taunt.", "cat": CardContentOverlay.Category.CREATURE},
	]
	var card_h: float = 316.0
	var card_w: float = card_h * (1086.0 / 1448.0)
	var spacing: float = (1840.0 - 7.0 * card_w) / 6.0
	var y_pos: float = 1080.0 - card_h - 70.0

	for i in range(7):
		var sp = hand_specs[i]
		var content = CardContentOverlay.Content.new(sp["title"], sp["cat"], sp["tribe"], sp["rules"])
		_card(_stage, Vector2(40.0 + i * (card_w + spacing), y_pos), card_h, sp["rarity"],
			null, sp["arm"], sp["shd"], sp["cost"], sp["atk"], sp["hp"], content)

	_label(_stage, "Seven-card hand at 1080p gameplay scale · 5 creatures with inlays & plaques · 1 spell & 1 equipment with dormant sockets",
		Rect2(40, 1080 - 45, 1840, 24), 16, TOKENS.color_token(&"secondary"))

func _show_rarities() -> void:
	for index: int in range(5):
		_card(_stage, Vector2(104 + index * 350, 340), 426, index)
		var label_text: String = NAMES[index]
		var label_color: Color = TOKENS.color_token(RARITIES[index])
		var sample: Label = _label(_stage, label_text, Rect2(104 + index * 350, 794, 320, 60),
			28, label_color, &"CardTitle")
		sample.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var list_desc: String = "White crystal · Sapphire · Ruby · Emerald · Gold  /  Canonical 5-tier rarity system."
	_label(_stage, list_desc, Rect2(104, 910, 1750, 50), 26, TOKENS.color_token(&"secondary"))

func _show_epic_showcase() -> void:
	var epic_mat: ShaderMaterial = _gem_materials[3]
	var c_creature = CardContentOverlay.Content.new("Arcane Knight", CardContentOverlay.Category.CREATURE, "Human", "Whenever this creature attacks, gain 1 Shield.")
	var c_spell = CardContentOverlay.Content.new("Arcane Flare", CardContentOverlay.Category.SPELL, "Arcane", "Deal 4 damage to target creature.")
	_card(_stage, Vector2(250, 200), 740, 3, epic_mat, 2, 1, 4, 4, 5, c_creature)
	_card(_stage, Vector2(1090, 200), 740, 3, epic_mat, 0, 0, 4, 0, 0, c_spell)
	var left_lbl: Label = _label(_stage, "EPIC CREATURE  /  Emerald Green (Canonical)", Rect2(200, 960, 650, 45), 24,
		TOKENS.color_token(&"epic"), &"CardTitle")
	left_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var right_lbl: Label = _label(_stage, "EPIC SPELL  /  Dormant Sockets & Category Cue", Rect2(1040, 960, 650, 45), 24,
		TOKENS.color_token(&"epic"), &"CardTitle")
	right_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _show_sockets() -> void:
	_card(_stage, Vector2(200, 200), 760, 3, null, 2, 1)
	_card(_stage, Vector2(1040, 200), 760, 3, null, 0, 0, 4, 0, 0,
		CardContentOverlay.Content.new("Arcane Tome", CardContentOverlay.Category.EQUIPMENT, "Relic", "Equipped creature gains +1 Mana."))
	_label(_stage, "Left: Creature with Inlays & Plaque Badges   •   Right: Equipment with Dormant Engraved Sockets",
		Rect2(100, 980, 1750, 35), 22, TOKENS.color_token(&"secondary"))

func _show_protections() -> void:
	var captions: PackedStringArray = ["No protections", "Native Armor 2", "Shield overlay 3", "Armor 2 + Shield 3"]
	for index: int in range(4):
		_card(_stage, Vector2(120 + index * 445, 270), 550, index,
			null, 2 if index in [1, 3] else 0, 3 if index in [2, 3] else 0)
		var caption: Label = _label(_stage, captions[index], Rect2(100 + index * 445, 860, 445, 60),
			28, TOKENS.color_token(&"text"), &"CardTitle")
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label(_stage, "Zero values hide badge. Steel plaque = Armor. Azure ward = Shield. 62 pt font with comfortable breathing room.",
		Rect2(100, 950, 1750, 45), 24, TOKENS.color_token(&"secondary"))
