class_name CardPresentationModel
extends RefCounted
## Typed presentation model separating shared card presentation data from creature-specific stats.
## Adheres to Interface Segregation Principle: Spells do not require dummy combat stats or sockets.

const CONTENT: GDScript = preload("res://scripts/presentation/card_content_overlay.gd")

## Shared card presentation properties
var card_id: String = ""
var title: String = ""
var category: CardContentOverlay.Category = CardContentOverlay.Category.CREATURE
var cost: int = 0
var rarity: StringName = &"common"
var rules: String = ""
var keywords: Array[CardContentOverlay.KeywordSpan] = []
var illustration: Texture2D = null

## Creature-only presentation properties (ignored for Spells and Equipment)
var tribe: String = ""
var attack: int = 0
var max_health: int = 0
var native_armor: int = 0
var shield: int = 0

func _init(p_title: String = "", p_category: CardContentOverlay.Category = CardContentOverlay.Category.CREATURE,
		p_cost: int = 0, p_rarity: StringName = &"common", p_rules: String = "",
		p_illustration: Texture2D = null) -> void:
	title = p_title
	category = p_category
	cost = p_cost
	rarity = p_rarity
	rules = p_rules
	illustration = p_illustration

static func create_creature(p_title: String, p_cost: int, p_rarity: StringName,
		p_attack: int, p_health: int, p_tribe: String = "", p_rules: String = "",
		p_armor: int = 0, p_shield: int = 0, p_illustration: Texture2D = null,
		p_id: String = "") -> RefCounted:
	var m: RefCounted = (load("res://scripts/presentation/card_presentation_model.gd") as GDScript).new(p_title, CardContentOverlay.Category.CREATURE, p_cost, p_rarity, p_rules, p_illustration)
	m.card_id = p_id
	m.tribe = p_tribe
	m.attack = p_attack
	m.max_health = p_health
	m.native_armor = p_armor
	m.shield = p_shield
	return m

static func create_spell(p_title: String, p_cost: int, p_rarity: StringName,
		p_rules: String, p_illustration: Texture2D = null,
		p_id: String = "") -> RefCounted:
	var m: RefCounted = (load("res://scripts/presentation/card_presentation_model.gd") as GDScript).new(p_title, CardContentOverlay.Category.SPELL, p_cost, p_rarity, p_rules, p_illustration)
	m.card_id = p_id
	return m

static func create_equipment(p_title: String, p_cost: int, p_rarity: StringName,
		p_rules: String, p_illustration: Texture2D = null,
		p_id: String = "") -> RefCounted:
	var m: RefCounted = (load("res://scripts/presentation/card_presentation_model.gd") as GDScript).new(p_title, CardContentOverlay.Category.EQUIPMENT, p_cost, p_rarity, p_rules, p_illustration)
	m.card_id = p_id
	return m
