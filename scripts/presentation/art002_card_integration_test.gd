extends Control
## Isolated visual fixture. No catalog, engine, input commands or production CardView.
## Master v03 with native alpha and reusable, precisely masked rarity crystals.

const FRAME: Texture2D = preload("res://assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png")
const ART: Texture2D = preload("res://assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")
const GEM_TREATMENT: GDScript = preload("res://scripts/presentation/rarity_gem_treatment.gd")
const STAT_OVERLAY: GDScript = preload("res://scripts/presentation/card_stat_overlay.gd")
const CONTENT_OVERLAY: GDScript = preload("res://scripts/presentation/card_content_overlay.gd")
const CARD_SIZE: Vector2 = Vector2(1086, 1448)
const RARITIES: Array[StringName] = [&"common", &"uncommon", &"rare", &"epic", &"legendary"]
const NAMES: PackedStringArray = ["Common", "Uncommon", "Rare", "Epic", "Legendary"]

var _stage: Control
var _mode: int = 0
var _use_emerald: bool = false
var _gem_materials: Array[ShaderMaterial] = []
var _emerald_epic_material: ShaderMaterial

class ManaOnlyOverlay extends CardStatOverlay:
	## Non-creatures leave the original midnight-enamel footer sockets dormant.
	## Uses the approved cost renderer unchanged; no invented Attack/HP values.
	func _draw() -> void:
		draw_number(MANA_CENTER, _mana, 126, 145, TOKENS.color_token(&"text_bright"), SOCKET_SAFE_RADIUS)

func _ready() -> void:
	theme = TOKENS.THEME
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--mode="):
			_mode = clampi(argument.trim_prefix("--mode=").to_int(), 0, 5)
		elif argument == "--emerald":
			_use_emerald = true
	for rarity: StringName in RARITIES:
		if rarity == &"epic" and _use_emerald:
			_gem_materials.append(GEM_TREATMENT.create_emerald_epic_material())
		else:
			_gem_materials.append(GEM_TREATMENT.create_material(rarity))
	_emerald_epic_material = GEM_TREATMENT.create_emerald_epic_material()
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
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _texture(parent: Control, source: Texture2D, bounds: Rect2) -> TextureRect:
	var image: TextureRect = TextureRect.new()
	image.texture = source
	image.position = bounds.position
	image.size = bounds.size
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_SCALE
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	return image

func _card(parent: Control, origin: Vector2, height: float, rarity_index: int,
		material_override: ShaderMaterial = null, native_armor: int = 0,
		shield: int = 0, cost: int = 4, attack_value: int = 4, health_value: int = 5,
		content: CardContentOverlay.Content = null) -> Control:
	var card: Control = Control.new()
	card.position = origin
	card.size = CARD_SIZE
	card.scale = Vector2.ONE * height / CARD_SIZE.y
	parent.add_child(card)
	# Fixed source-space aperture; crop shows face, shoulder and spell hand.
	var aperture: Control = Control.new()
	aperture.position = Vector2(124, 207)
	aperture.size = Vector2(838, 642)
	aperture.clip_contents = true
	card.add_child(aperture)
	var crop: AtlasTexture = AtlasTexture.new()
	crop.atlas = ART
	crop.region = Rect2(0, 0, 1086, 900)
	var portrait: TextureRect = _texture(aperture, crop, Rect2(Vector2.ZERO, aperture.size))
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	var frame: TextureRect = _texture(card, FRAME, Rect2(Vector2.ZERO, CARD_SIZE))
	frame.material = material_override if material_override != null else _gem_materials[rarity_index]
	var fields: CardContentOverlay.Content = content if content != null else CardContentOverlay.Content.new(
		"Arcane Knight", CardContentOverlay.Category.CREATURE, "Human", "Whenever this creature attacks, gain 1 Shield.")
	var text_overlay: CardContentOverlay = CONTENT_OVERLAY.new()
	text_overlay.name = "CardContent"
	card.add_child(text_overlay)
	var text_result: Error = text_overlay.configure(fields)
	if text_result != OK:
		push_error("ART002 content rejected: %s" % text_overlay.overflow_reason)
	var stats: CardStatOverlay = STAT_OVERLAY.new() if fields.category == CardContentOverlay.Category.CREATURE else ManaOnlyOverlay.new()
	card.add_child(stats)
	stats.set_printed_values(cost, attack_value, health_value, native_armor)
	stats.set_shield_overlay(shield)
	return card

func _rebuild() -> void:
	if not is_node_ready():
		return
	if is_instance_valid(_stage):
		remove_child(_stage)
		_stage.queue_free()
	_stage = Control.new()
	_stage.size = Vector2(1920, 1080)
	var ratio: float = minf(size.x / 1920.0, size.y / 1080.0)
	_stage.scale = Vector2.ONE * ratio
	_stage.position = (size - _stage.size * ratio) * 0.5
	add_child(_stage)
	var background: Panel = Panel.new()
	background.size = _stage.size
	var surface: StyleBoxFlat = StyleBoxFlat.new()
	surface.bg_color = TOKENS.color_token(&"background")
	background.add_theme_stylebox_override("panel", surface)
	_stage.add_child(background)
	_label(_stage, "MAGIC ODYSSEY  /  ART–002", Rect2(64, 30, 1400, 60), 38,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	var sub_title: String = "ART–002–T04 · MASTER FRAME v03 · Premium stat sockets and protection indicators"
	_label(_stage, sub_title, Rect2(64, 97, 1800, 40), 24, TOKENS.color_token(&"accent"))
	var modes: PackedStringArray = [
		"01  /  Full-size inspection",
		"02  /  Seven-card hand",
		"03  /  Five rarity identities",
		"04  /  Epic comparison: Canonical Violet vs Experimental Emerald",
		"05  /  Stat socket inspection",
		"06  /  Armor and Shield samples"
	]
	_label(_stage, modes[_mode], Rect2(64, 157, 1600, 50), 30, TOKENS.color_token(&"text"), &"SectionHeading")
	if _mode == 0:
		_card(_stage, Vector2(460, 225), 760, 3, null, 2, 3)
		_label(_stage, "ARCANE KNIGHT\n\nCentered ivory numerals\nSword / Attack     Heart / Max Health\n\nMetal crest / Native Armor\nAzure ward / Temporary Shield\n\nPrinted face values stay immutable.\nProtection values are visual samples.",
			Rect2(1130, 330, 690, 500), 28, TOKENS.color_token(&"secondary"))
	elif _mode == 1:
		var height: float = 316.0
		var width: float = height * CARD_SIZE.x / CARD_SIZE.y
		var gap: float = 16.0
		var left: float = (1920.0 - width * 7.0 - gap * 6.0) * 0.5
		for index: int in range(7):
			_card(_stage, Vector2(left + index * (width + gap), 586), height, index % RARITIES.size(),
				null, 2 if index in [1, 3, 5] else 0, 3 if index in [2, 3, 6] else 0,
				0 if index == 0 else 4, 12 if index == 5 else 4, 10 if index == 6 else 5)
		_label(_stage, "LINEAR HAND  /  Entire silhouettes · 16 px gaps · no overlap",
			Rect2(84, 360, 1752, 50), 28, TOKENS.color_token(&"accent"), &"SectionHeading")
		_label(_stage, "Small rules text requires inspection at hand scale. Titles, mana and base statistics remain the primary scan targets.",
			Rect2(84, 420, 1752, 50), 24, TOKENS.color_token(&"secondary"))
	elif _mode == 2:
		for index: int in range(5):
			_card(_stage, Vector2(104 + index * 350, 340), 426, index)
			var label_text: String = "Epic (Emerald)" if (index == 3 and _use_emerald) else NAMES[index]
			var label_color: Color = Color(0.2, 0.85, 0.45) if (index == 3 and _use_emerald) else TOKENS.color_token(RARITIES[index])
			var sample: Label = _label(_stage, label_text, Rect2(104 + index * 350, 794, 320, 60),
				28, label_color, &"CardTitle")
			sample.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var list_desc: String = "White crystal · Sapphire · Ruby · Emerald · Gold  /  Identical bronze frame, rarity carried by the three stones." if _use_emerald \
			else "White crystal · Sapphire · Ruby · Amethyst · Gold  /  Identical bronze frame, rarity carried by the three stones."
		_label(_stage, list_desc, Rect2(104, 910, 1750, 50), 26, TOKENS.color_token(&"secondary"))
	elif _mode == 3:
		# Mode 3: Side-by-side Epic comparison: Canonical Violet vs Experimental Emerald at full card size
		var canonical_violet: ShaderMaterial = GEM_TREATMENT.create_material(&"epic", false)
		var experimental_emerald: ShaderMaterial = GEM_TREATMENT.create_material(&"epic", true)
		_card(_stage, Vector2(250, 220), 740, 3, canonical_violet)
		_card(_stage, Vector2(1090, 220), 740, 3, experimental_emerald)
		var violet_lbl: Label = _label(_stage, "CANONICAL EPIC  /  Amethyst Violet (Q181)", Rect2(200, 975, 650, 45), 24,
			TOKENS.color_token(&"epic"), &"CardTitle")
		violet_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var emerald_lbl: Label = _label(_stage, "EXPERIMENTAL EPIC  /  Emerald Green (T03C)", Rect2(1040, 975, 650, 45), 24,
			Color(0.2, 0.85, 0.45), &"CardTitle")
		emerald_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	elif _mode == 4:
		# Crop actual integrated cards, not a second rendering of the sockets.
		var mana_crop: Control = Control.new()
		mana_crop.position = Vector2(100, 310)
		mana_crop.size = Vector2(410, 410)
		mana_crop.clip_contents = true
		_stage.add_child(mana_crop)
		_card(mana_crop, Vector2(-35, -35), 2000, 3, null, 2, 3, 10)
		var footer_crop: Control = Control.new()
		footer_crop.position = Vector2(590, 370)
		footer_crop.size = Vector2(1230, 400)
		footer_crop.clip_contents = true
		_stage.add_child(footer_crop)
		_card(footer_crop, Vector2(-40, -1340), 1800, 3, null, 2, 3, 10, 12, 10)
		_label(_stage, "MANA  /  10", Rect2(100, 790, 400, 50), 28, TOKENS.color_token(&"text"))
		_label(_stage, "ATTACK 12     /     NATIVE ARMOR 2     /     SHIELD 3     /     MAX HEALTH 10",
			Rect2(590, 790, 1240, 50), 24, TOKENS.color_token(&"text"))
		_label(_stage, "Glyph bounds centered in the original sockets. Two-digit values fit without touching the metal.",
			Rect2(100, 900, 1750, 50), 26, TOKENS.color_token(&"secondary"))
	else:
		var captions: PackedStringArray = ["No protections", "Native Armor 2", "Shield overlay 3", "Armor 2 + Shield 3"]
		for index: int in range(4):
			_card(_stage, Vector2(120 + index * 445, 270), 550, index,
				null, 2 if index in [1, 3] else 0, 3 if index in [2, 3] else 0)
			var caption: Label = _label(_stage, captions[index], Rect2(100 + index * 445, 860, 445, 60),
				28, TOKENS.color_token(&"text"), &"CardTitle")
			caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label(_stage, "Zero values hide their badge. Metal crest = Armor. Azure energy ward = Shield. Samples only.",
			Rect2(100, 950, 1750, 45), 26, TOKENS.color_token(&"secondary"))
	_label(_stage, "[1] Inspection   [2] Hand   [3] Rarities   [4] Epic comparison   [5] Sockets   [6] Protections   •   Presentation review",
		Rect2(64, 1025, 1800, 35), 21, TOKENS.color_token(&"secondary"))
