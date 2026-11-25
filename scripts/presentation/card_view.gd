class_name CardView
extends Control
## Unified, extensible card presentation view adhering to SOLID principles.
## Composes CardVisualVariant, CardPresentationModel, CardContentOverlay,
## RarityGemTreatment, and category-appropriate stat/mana overlays.
## Supports CREATURE, SPELL, and future EQUIPMENT variants without duplicating renderers.

const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")
const LAYOUT: GDScript = preload("res://scripts/presentation/card_view_layout.gd")
const VARIANT: GDScript = preload("res://scripts/presentation/card_visual_variant.gd")
const MODEL: GDScript = preload("res://scripts/presentation/card_presentation_model.gd")
const CONTENT: GDScript = preload("res://scripts/presentation/card_content_overlay.gd")
const GEM_TREATMENT: GDScript = preload("res://scripts/presentation/rarity_gem_treatment.gd")
const STAT_OVERLAY: GDScript = preload("res://scripts/presentation/card_stat_overlay.gd")
const MANA_OVERLAY: GDScript = preload("res://scripts/presentation/card_mana_overlay.gd")
const CATEGORY_OVERLAY: GDScript = preload("res://scripts/presentation/card_category_overlay.gd")

const DEFAULT_ART: Texture2D = preload("res://assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png")

var _model: RefCounted = null
var _variant: RefCounted = null

var aperture_node: Control = null
var portrait_node: TextureRect = null
var frame_node: TextureRect = null
var content_overlay: CardContentOverlay = null
var stat_overlay: CardStatOverlay = null
var mana_overlay: Control = null
var category_overlay: CardCategoryOverlay = null

func _init() -> void:
	size = CardViewLayout.CARD_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func apply_model(p_model: RefCounted, p_variant: RefCounted = null) -> Error:
	if p_model == null:
		return ERR_INVALID_DATA

	_model = p_model
	if p_variant != null:
		_variant = p_variant
	else:
		_variant = VARIANT.for_category(_model.category)

	_clear_children()

	# 1. Aperture and illustration
	aperture_node = Control.new()
	aperture_node.name = "Aperture"
	aperture_node.position = _variant.illustration_bounds.position
	aperture_node.size = _variant.illustration_bounds.size
	aperture_node.clip_contents = true
	aperture_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(aperture_node)

	var illustration_tex: Texture2D = _model.illustration if _model.illustration != null else DEFAULT_ART
	var crop: AtlasTexture = AtlasTexture.new()
	crop.atlas = illustration_tex
	crop.region = _variant.portrait_crop_region

	portrait_node = TextureRect.new()
	portrait_node.name = "Illustration"
	portrait_node.texture = crop
	portrait_node.position = Vector2.ZERO
	portrait_node.size = aperture_node.size
	portrait_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait_node.texture_filter = Control.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	portrait_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aperture_node.add_child(portrait_node)

	# 2. Frame texture and rarity shader treatment
	frame_node = TextureRect.new()
	frame_node.name = "Frame"
	frame_node.texture = _variant.frame_texture
	frame_node.position = Vector2.ZERO
	frame_node.size = _variant.card_size
	frame_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame_node.stretch_mode = TextureRect.STRETCH_SCALE
	frame_node.texture_filter = Control.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	frame_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame_node.material = RarityGemTreatment.create_material(_model.rarity, true, _variant.rarity_mask)
	add_child(frame_node)

	# 3. Dynamic text content overlay
	content_overlay = CardContentOverlay.new()
	content_overlay.name = "Content"
	add_child(content_overlay)

	var content_data: CardContentOverlay.Content = CardContentOverlay.Content.new(
		_model.title,
		_model.category,
		_model.tribe if _model.category == CardContentOverlay.Category.CREATURE else "",
		_model.rules
	)
	content_data.keywords = _model.keywords

	var content_err: Error = content_overlay.configure(
		content_data, _variant.rules_bounds, _variant.category_bounds,
		_variant.category_size, _variant.category_glyph_spacing
	)
	if content_err != OK:
		return content_err

	# 4. Sockets & Stats / Mana overlay based on category
	if _variant.supports_creature_stats and _model.category == CardContentOverlay.Category.CREATURE:
		stat_overlay = CardStatOverlay.new()
		stat_overlay.name = "Stats"
		add_child(stat_overlay)
		stat_overlay.set_printed_values(_model.cost, _model.attack, _model.max_health, _model.native_armor)
		if _model.shield > 0:
			stat_overlay.set_shield_overlay(_model.shield)
	elif _model.category == CardContentOverlay.Category.SPELL:
		var mana: Control = (MANA_OVERLAY as GDScript).new()
		mana.name = "Mana"
		mana_overlay = mana
		add_child(mana_overlay)
		mana_overlay.call(&"set_mana", _model.cost)
	else:
		# Equipment (backward-compatible fallback until P009-R02B)
		category_overlay = CardCategoryOverlay.new()
		category_overlay.name = "CategoryOverlay"
		category_overlay.category = _model.category
		category_overlay.set("_mana", _model.cost)
		add_child(category_overlay)

	return OK

func get_model() -> RefCounted:
	return _model

func get_variant() -> RefCounted:
	return _variant

func get_content_overlay() -> CardContentOverlay:
	return content_overlay

func get_stat_overlay() -> CardStatOverlay:
	return stat_overlay

func get_mana_overlay() -> Control:
	return mana_overlay

func _clear_children() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	aperture_node = null
	portrait_node = null
	frame_node = null
	content_overlay = null
	stat_overlay = null
	mana_overlay = null
	category_overlay = null
