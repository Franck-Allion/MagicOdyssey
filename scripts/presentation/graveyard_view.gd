class_name GraveyardView
extends Control
## A snapshot of the last card ENTERING a graveyard, supplied by presentation.
## This fixture is independent of the last played card and has no domain binding.
class PreviewCard extends RefCounted:
	var title: String = "Arcane Knight"
	var illustration: Texture2D = CombatPreviewCards.ART
	var rarity: StringName = &"rare"
	var mana: int = 1
	var attack: int = 2
	var health: int = 3
	var category: CardContentOverlay.Category = CardContentOverlay.Category.CREATURE
	var subtype: String = "Human"
	var rules_text: String = "Whenever this creature attacks, gain 1 Shield."

const EMPTY: Texture2D = preload("res://assets/_source/lot1/hud/utility/mo_hud_graveyard_empty_v01.png")
var visual_count: int = 0
var last_card: PreviewCard

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(refresh)
	refresh()

## Reject an incomplete nonempty snapshot, preserving the previous accepted view.
func set_preview(count: int, entering_card: PreviewCard = null) -> bool:
	if count > 0 and (entering_card == null or entering_card.illustration == null):
		return false
	visual_count = maxi(0, count)
	last_card = entering_card if visual_count > 0 else null
	refresh()
	return true

## Sets or updates the visual graveyard card count independently of top card identity.
## If new_top_card is supplied, updates the top miniature. If count <= 0, resets to empty.
## If count > 0 and new_top_card is null, preserves any previously accepted top card.
func set_card_count(count: int, new_top_card: PreviewCard = null) -> bool:
	if count <= 0:
		return set_preview(0, null)
	if new_top_card != null:
		return set_preview(count, new_top_card)
	visual_count = count
	refresh()
	return true

func refresh() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	var height: float = maxf(1.0, size.y - 66.0)
	var mini_size: Vector2 = Vector2(height * 0.75, height)
	var origin: Vector2 = Vector2((size.x - mini_size.x) * 0.5, 2)
	if visual_count == 0:
		texture(self, EMPTY, origin, mini_size).name = "Empty"
	elif last_card != null:
		var card: Control = Control.new()
		card.name = "LastEnteringCard"
		card.size = CardViewLayout.CARD_SIZE
		card.scale = Vector2.ONE * height / card.size.y
		card.position = origin
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(card)
		var art: AtlasTexture = AtlasTexture.new()
		art.atlas = last_card.illustration
		art.region = CardViewLayout.PORTRAIT_CROP_REGION
		texture(card, art, CardViewLayout.APERTURE_BOUNDS.position, CardViewLayout.APERTURE_BOUNDS.size).name = "Illustration"
		var frame: TextureRect = texture(card, CombatPreviewCards.FRAME, Vector2.ZERO, card.size)
		frame.name = "Frame"
		frame.material = RarityGemTreatment.create_material(last_card.rarity)
		var content: CardContentOverlay = CardContentOverlay.new()
		card.add_child(content)
		content.configure(CardContentOverlay.Content.new(last_card.title, last_card.category, last_card.subtype, last_card.rules_text))
		if last_card.category == CardContentOverlay.Category.CREATURE:
			var stats: CardStatOverlay = CardStatOverlay.new()
			card.add_child(stats)
			stats.set_printed_values(last_card.mana, last_card.attack, last_card.health, 0)
		else:
			var seal: CardCategoryOverlay = CardCategoryOverlay.new()
			seal.category = last_card.category
			seal.set("_mana", last_card.mana)
			card.add_child(seal)
	else:
		texture(self, EMPTY, origin, mini_size).name = "Empty"
	DeckStackView.add_labels(self, "GRAVEYARD", visual_count)

static func texture(parent: Control, source: Texture2D, origin: Vector2, dimensions: Vector2) -> TextureRect:
	var image: TextureRect = TextureRect.new()
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.texture = source
	image.position = origin
	image.size = dimensions
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	return image
