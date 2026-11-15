extends Control
## Static presentation samples only; replace with P009 HandView later.
@export var face_down: bool = false
const FRAME: Texture2D = preload("res://assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png")
const ART: Texture2D = preload("res://assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png")

func _ready() -> void:
	for index: int in range(6 if face_down else 7):
		var card: Control = Control.new()
		card.name = "Card%02d" % index
		card.size = Vector2(1086, 1448)
		var height: float = 140.0 if face_down else 220.0
		card.scale = Vector2.ONE * height / 1448.0
		card.pivot_offset = card.size * 0.5
		var spread: float = float(index) - (2.5 if face_down else 3.0)
		var center: Vector2 = Vector2(size.x * 0.5 + spread * (65.0 if face_down else 96.0), height * 0.5 + absf(spread) * 5.0)
		card.position = center - card.pivot_offset
		card.rotation = deg_to_rad(spread * 3.0)
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(card)
		if face_down:
			var back: Panel = Panel.new()
			back.name = "CardBack"
			back.size = card.size
			back.theme_type_variation = &"HeroFrame"
			var housing: StyleBoxFlat = UIDesignTokens.THEME.get_stylebox("panel", &"HeroFrame").duplicate() as StyleBoxFlat
			housing.set_border_width_all(16)
			housing.set_corner_radius_all(65)
			housing.shadow_size = 32
			back.add_theme_stylebox_override("panel", housing)
			back.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card.add_child(back)
			var emblem: Label = Label.new()
			emblem.text = "◇\nM O\n◇"
			emblem.size = card.size
			emblem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			emblem.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			emblem.add_theme_font_size_override("font_size", 180)
			emblem.add_theme_color_override("font_color", UIDesignTokens.color_token(&"accent"))
			card.add_child(emblem)
		else:
			var aperture: Control = Control.new()
			aperture.position = CardViewLayout.APERTURE_BOUNDS.position
			aperture.size = CardViewLayout.APERTURE_BOUNDS.size
			aperture.clip_contents = true
			card.add_child(aperture)
			var crop: AtlasTexture = AtlasTexture.new()
			crop.atlas = ART
			crop.region = CardViewLayout.PORTRAIT_CROP_REGION
			_texture(aperture, crop, aperture.size)
			_texture(card, FRAME, card.size)
			var content: CardContentOverlay = CardContentOverlay.new()
			card.add_child(content)
			content.configure(CardContentOverlay.Content.new("Arcane Knight", CardContentOverlay.Category.CREATURE, "Human", "Whenever this creature attacks, gain 1 Shield."))
			var stats: CardStatOverlay = CardStatOverlay.new()
			card.add_child(stats)
			stats.set_printed_values(4, 4, 5, 0)

func _texture(parent: Control, texture: Texture2D, dimensions: Vector2) -> void:
	var image: TextureRect = TextureRect.new()
	image.texture = texture
	image.size = dimensions
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
