class_name DeckStackView
extends Control
## Visual count only. No draw-pile state or card identity is accepted.
const CARD_BACK: Texture2D = CombatPreviewCards.CARD_BACK
const OPACITY: Shader = CombatPreviewCards.CARD_BACK_SHADER
@export var visual_count: int = 34:
	set(value):
		visual_count = maxi(0, value)
		refresh()
@export var caption: String = "DECK"

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(refresh)
	refresh()

static func layer_count(count: int) -> int:
	if count <= 0:
		return 0
	if count == 1:
		return 1
	if count <= 5:
		return 2
	if count <= 15:
		return 3
	return 5

func refresh() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	var height: float = maxf(1.0, minf(size.y - 66.0, (size.x - 8.0) / 0.75))
	var card_size: Vector2 = Vector2(height * 0.75, height)
	var origin: Vector2 = Vector2((size.x - card_size.x) * 0.5 - 3.0, 5.0)
	for index: int in range(layer_count(visual_count)):
		var back: TextureRect = TextureRect.new()
		back.name = "Layer%d" % index
		back.texture = CARD_BACK
		back.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		back.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		back.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		back.mouse_filter = Control.MOUSE_FILTER_IGNORE
		back.size = card_size
		back.position = origin + Vector2(index * 1.5, -index * 1.0)
		var opacity: ShaderMaterial = ShaderMaterial.new()
		opacity.shader = OPACITY
		back.material = opacity
		add_child(back)
	add_labels(self, caption, visual_count)

## Shared typography for the paired utility views; counts stay separate from art.
static func add_labels(parent: Control, title: String, count: int) -> void:
	for index: int in range(2):
		var label: Label = Label.new()
		label.name = "Caption" if index == 0 else "Count"
		label.text = title if index == 0 else str(count)
		label.position = Vector2(0, parent.size.y - (58.0 if index == 0 else 34.0))
		label.size = Vector2(parent.size.x, 24 if index == 0 else 34)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 15 if index == 0 else 25)
		label.add_theme_color_override("font_color", UIDesignTokens.color_token(&"secondary" if index == 0 else &"text_bright"))
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(label)
