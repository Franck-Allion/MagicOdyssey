class_name CardVisualVariant
extends RefCounted
## Typed visual variant configuration representing category-specific card presentation geometry and assets.
## Follows SOLID (Open/Closed, Single Responsibility, Dependency Inversion).
## Adding future categories (e.g. Equipment in P009-R02B) requires registering a new variant without duplicating renderers.

const LAYOUT: GDScript = preload("res://scripts/presentation/card_view_layout.gd")
const CONTENT: GDScript = preload("res://scripts/presentation/card_content_overlay.gd")
const GEM_TREATMENT: GDScript = preload("res://scripts/presentation/rarity_gem_treatment.gd")

const MASTER_CREATURE_FRAME: Texture2D = preload("res://assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png")
const PRODUCTION_SPELL_FRAME: Texture2D = preload("res://assets/textures/cards/mo_card_frame_spell_v01.png")

var category: CardContentOverlay.Category = CardContentOverlay.Category.CREATURE
var frame_texture: Texture2D = MASTER_CREATURE_FRAME
var card_size: Vector2 = CardViewLayout.CARD_SIZE
var illustration_bounds: Rect2 = CardViewLayout.APERTURE_BOUNDS
var portrait_crop_region: Rect2 = CardViewLayout.PORTRAIT_CROP_REGION
var title_bounds: Rect2 = CardViewLayout.TITLE_BOUNDS
var category_bounds: Rect2 = CardViewLayout.TYPE_BOUNDS
var category_size: int = CardViewLayout.TYPE_SIZE
var category_glyph_spacing: int = 0
var rules_bounds: Rect2 = CardViewLayout.RULES_BOUNDS
var mana_center: Vector2 = CardViewLayout.MANA_CENTER
var socket_safe_radius: float = CardViewLayout.SOCKET_SAFE_RADIUS
var rarity_mask: Texture2D = RarityGemTreatment.MASK

## Creature-specific feature flag and layout properties
var supports_creature_stats: bool = true
var attack_center: Vector2 = CardViewLayout.ATTACK_CENTER
var health_center: Vector2 = CardViewLayout.HEALTH_CENTER
var armor_bounds: Rect2 = CardViewLayout.ARMOR_SLOT_BOUNDS
var shield_bounds: Rect2 = CardViewLayout.SHIELD_SLOT_BOUNDS

static func create_creature_variant() -> RefCounted:
	var v: RefCounted = (load("res://scripts/presentation/card_visual_variant.gd") as GDScript).new()
	v.category = CardContentOverlay.Category.CREATURE
	v.frame_texture = MASTER_CREATURE_FRAME
	v.category_bounds = CardViewLayout.TYPE_BOUNDS
	v.category_size = CardViewLayout.TYPE_SIZE
	v.rules_bounds = CardViewLayout.RULES_BOUNDS
	v.rarity_mask = RarityGemTreatment.MASK
	v.supports_creature_stats = true
	return v

static func create_spell_variant() -> RefCounted:
	var v: RefCounted = (load("res://scripts/presentation/card_visual_variant.gd") as GDScript).new()
	v.category = CardContentOverlay.Category.SPELL
	v.frame_texture = PRODUCTION_SPELL_FRAME
	v.category_bounds = CardViewLayout.SPELL_TYPE_BOUNDS
	v.category_size = CardViewLayout.SPELL_TYPE_SIZE
	v.category_glyph_spacing = CardViewLayout.SPELL_TYPE_GLYPH_SPACING
	v.rules_bounds = CardViewLayout.SPELL_RULES_BOUNDS
	v.rarity_mask = RarityGemTreatment.SPELL_MASK
	v.supports_creature_stats = false
	return v

static func create_equipment_variant() -> RefCounted:
	var v: RefCounted = (load("res://scripts/presentation/card_visual_variant.gd") as GDScript).new()
	v.category = CardContentOverlay.Category.EQUIPMENT
	v.frame_texture = MASTER_CREATURE_FRAME
	v.category_bounds = CardViewLayout.TYPE_BOUNDS
	v.category_size = CardViewLayout.TYPE_SIZE
	v.rules_bounds = CardViewLayout.RULES_BOUNDS
	v.rarity_mask = RarityGemTreatment.MASK
	v.supports_creature_stats = false
	return v

static func for_category(cat: CardContentOverlay.Category) -> RefCounted:
	match cat:
		CardContentOverlay.Category.SPELL:
			return create_spell_variant()
		CardContentOverlay.Category.EQUIPMENT:
			return create_equipment_variant()
		_:
			return create_creature_variant()
