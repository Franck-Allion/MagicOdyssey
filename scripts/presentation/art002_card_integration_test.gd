extends Control
## Isolated visual fixture. No catalog, engine, input commands or production CardView.
## Master v03 with native alpha and reusable, precisely masked rarity crystals.

const FRAME: Texture2D = preload("res://assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png")
const ART: Texture2D = preload("res://assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")
const GEM_TREATMENT: GDScript = preload("res://scripts/presentation/rarity_gem_treatment.gd")
const CARD_SIZE: Vector2 = Vector2(1086, 1448)
const RARITIES: Array[StringName] = [&"common", &"uncommon", &"rare", &"epic", &"legendary"]
const NAMES: PackedStringArray = ["Common", "Uncommon", "Rare", "Epic", "Legendary"]

var _stage: Control
var _mode: int = 0
var _gem_materials: Array[ShaderMaterial] = []

func _ready() -> void:
	theme = TOKENS.THEME
	for rarity: StringName in RARITIES:
		_gem_materials.append(GEM_TREATMENT.create_material(rarity))
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--mode="):
			_mode = clampi(argument.trim_prefix("--mode=").to_int(), 0, 2)
	resized.connect(_rebuild)
	_rebuild()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var key: InputEventKey = event as InputEventKey
		if key.keycode >= KEY_1 and key.keycode <= KEY_3:
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

func _card(parent: Control, origin: Vector2, height: float, rarity_index: int) -> void:
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
	frame.material = _gem_materials[rarity_index]
	var ink: Color = TOKENS.color_token(&"text_bright")
	var title: Label = _label(card, "Arcane Knight", Rect2(280, 90, 645, 94), 68, ink, &"CardTitle")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var mana: Label = _label(card, "4", Rect2(70, 85, 168, 142), 110, ink, &"TacticalNumber")
	mana.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var tribe: Label = _label(card, "Creature  ·  Human", Rect2(155, 929, 776, 60), 49,
		TOKENS.color_token(&"accent"), &"CardTitle")
	tribe.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var rule: Label = _label(card, "Whenever this creature\nattacks, gain 1 Shield.",
		Rect2(170, 1010, 746, 150), 54, ink)
	rule.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var attack: Label = _label(card, "4", Rect2(75, 1210, 164, 132), 108, ink, &"TacticalNumber")
	attack.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var health: Label = _label(card, "5", Rect2(852, 1210, 164, 132), 108, ink, &"TacticalNumber")
	health.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var atk_caption: Label = _label(card, "ATK", Rect2(80, 1330, 154, 45), 32, ink)
	atk_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var hp_caption: Label = _label(card, "HP", Rect2(857, 1330, 154, 45), 32, ink)
	hp_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

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
	_label(_stage, "ART–002–T03B · MASTER FRAME v03 · Three faceted rarity gemstones",
		Rect2(64, 97, 1800, 40), 24, TOKENS.color_token(&"accent"))
	var modes: PackedStringArray = ["01  /  Full-size inspection", "02  /  Seven-card hand", "03  /  Five rarity identities"]
	_label(_stage, modes[_mode], Rect2(64, 157, 1600, 50), 30, TOKENS.color_token(&"text"), &"SectionHeading")
	if _mode == 0:
		_card(_stage, Vector2(460, 225), 760, 3)
		_label(_stage, "ARCANE KNIGHT\n\nPresentation fixture only\nMana 4   /   ATK 4   /   HP 5\n\nThree amethyst crystals\nPainted facets and white speculars\n\nNeutral bronze and midnight-blue\nNative frame transparency preserved.",
			Rect2(1130, 330, 690, 500), 28, TOKENS.color_token(&"secondary"))
	elif _mode == 1:
		var height: float = 316.0
		var width: float = height * CARD_SIZE.x / CARD_SIZE.y
		var gap: float = 16.0
		var left: float = (1920.0 - width * 7.0 - gap * 6.0) * 0.5
		for index: int in range(7):
			_card(_stage, Vector2(left + index * (width + gap), 586), height, index % RARITIES.size())
		_label(_stage, "LINEAR HAND  /  Entire silhouettes · 16 px gaps · no overlap",
			Rect2(84, 360, 1752, 50), 28, TOKENS.color_token(&"accent"), &"SectionHeading")
		_label(_stage, "Small rules text requires inspection at hand scale. Titles, mana and base statistics remain the primary scan targets.",
			Rect2(84, 420, 1752, 50), 24, TOKENS.color_token(&"secondary"))
	else:
		for index: int in range(5):
			_card(_stage, Vector2(104 + index * 350, 340), 426, index)
			var sample: Label = _label(_stage, NAMES[index], Rect2(104 + index * 350, 794, 320, 60),
				28, TOKENS.color_token(RARITIES[index]), &"CardTitle")
			sample.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label(_stage, "White crystal · Sapphire · Ruby · Amethyst · Gold  /  Identical bronze frame, rarity carried by the three stones.",
			Rect2(104, 910, 1750, 50), 26, TOKENS.color_token(&"secondary"))
	_label(_stage, "[1] Inspection     [2] Seven cards     [3] Rarities       •       Visual experiment only / no gameplay / P009 unchanged",
		Rect2(64, 1010, 1800, 44), 23, TOKENS.color_token(&"secondary"))
