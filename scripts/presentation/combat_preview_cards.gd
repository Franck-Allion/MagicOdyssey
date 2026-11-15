class_name CombatPreviewCards
extends Control
## Static presentation samples only; replace with P009 HandView later.
@export var face_down: bool = false
@export_range(0, 10) var display_count: int = 7
@export var preferred_height: float = 270.0
var selected_index: int = -1

const FRAME: Texture2D = preload("res://assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png")
const ART: Texture2D = preload("res://assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png")

func _ready() -> void:
	rebuild()

func rebuild() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	for index: int in range(6 if face_down else clampi(display_count, 0, 10)):
		var card: Control = Control.new()
		card.name = "Card%02d" % index
		card.size = Vector2(1086, 1448)
		var height: float = 144.0 if face_down else preferred_height
		card.scale = Vector2.ONE * height / 1448.0
		card.pivot_offset = card.size * 0.5
		if face_down:
			var spread: float = float(index) - 2.5
			var center: Vector2 = Vector2(size.x * 0.5 + spread * 72.0, height * 0.5 + absf(spread) * 3.0)
			card.position = center - card.pivot_offset
			card.rotation = deg_to_rad(spread * 3.5)
		else:
			var pose: Transform2D = layout_pose(index, display_count, size.x, preferred_height)
			card.position = pose.origin - card.pivot_offset
			card.rotation = pose.get_rotation()
			card.z_index = mini(index, display_count - 1 - index)
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
			var frame: TextureRect = _texture(card, FRAME, card.size)
			var rarities: Array[StringName] = [&"common", &"uncommon", &"rare", &"epic", &"legendary"]
			frame.material = RarityGemTreatment.create_material(rarities[index % rarities.size()])
			var content: CardContentOverlay = CardContentOverlay.new()
			card.add_child(content)
			var category: CardContentOverlay.Category = (index % 3) as CardContentOverlay.Category
			var titles: Array[String] = ["Arcane Knight", "Arcane Study", "Runic Relic"]
			var bodies: Array[String] = ["Whenever this creature attacks, gain 1 Shield.", "Presentation spell sample.", "Presentation equipment sample."]
			content.configure(CardContentOverlay.Content.new(titles[index % 3], category, "Human" if index % 3 == 0 else "", bodies[index % 3]))
			if category == CardContentOverlay.Category.CREATURE:
				var stats: CardStatOverlay = CardStatOverlay.new()
				card.add_child(stats)
				stats.set_printed_values(index % 8 + 1, 4, 5, 0)
			else:
				var seal: CardCategoryOverlay = CardCategoryOverlay.new()
				seal.category = category
				seal.set("_mana", index % 8 + 1)
				card.add_child(seal)

## Deterministic compressed circular arc; position is the visual center.
## Horizontal overlap preserves scale. Vertical compression reserves the tactical area.
static func layout_pose(index: int, count: int, width: float, height: float, maximum_spread: float = 9.0, curvature: float = 0.2, minimum_overlap: float = 0.36) -> Transform2D:
	var half_count: float = float(count - 1) * 0.5
	var angular_limit: float = deg_to_rad(minf(maximum_spread, maxf(0.0, float(count - 1)) * 1.6))
	var step: float = minf(height * (1.0 - minimum_overlap), maxf(0.0, width - height * 0.95 - 24.0) / maxf(1.0, float(count - 1)))
	var radius: float = step * maxf(half_count, 1.0) / maxf(sin(angular_limit), 0.001)
	var angle: float = (float(index) - half_count) / maxf(half_count, 1.0) * angular_limit
	var drop: float = radius * (1.0 - cos(angle)) * curvature
	var outer_drop: float = radius * (1.0 - cos(angular_limit)) * curvature
	var outer_half_height: float = height * (cos(angular_limit) + 0.75 * sin(angular_limit)) * 0.5
	var center_y: float = 270.0 - outer_half_height - outer_drop
	return Transform2D(angle, Vector2(width * 0.5 + radius * sin(angle), center_y + drop))

## Presentation-only inspection contract; no input, commands, or drag handling.
func set_inspected_card(index: int, blend: float = 1.0) -> void:
	selected_index = index
	for i: int in range(get_child_count()):
		var card: Control = get_child(i) as Control
		var pose: Transform2D = layout_pose(i, display_count, size.x, preferred_height)
		card.rotation = lerpf(pose.get_rotation(), 0.0, blend if i == index else 0.0)
		var center: Vector2 = pose.origin
		var height: float = preferred_height
		if i == index:
			height = lerpf(preferred_height, 420.0, blend)
			center.y = lerpf(center.y, 30.0, blend)
			center.x = clampf(center.x, height * 0.375 + 8.0, size.x - height * 0.375 - 8.0)
		card.position = center - card.pivot_offset
		card.scale = Vector2.ONE * height / CardViewLayout.CARD_SIZE.y
		card.z_index = 100 if i == index else mini(i, display_count - 1 - i)

func _texture(parent: Control, texture: Texture2D, dimensions: Vector2) -> TextureRect:
	var image: TextureRect = TextureRect.new()
	image.texture = texture
	image.size = dimensions
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	return image
