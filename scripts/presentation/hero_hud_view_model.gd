class_name HeroHudViewModel
extends RefCounted
## Presentation view-model representing a single hero's HUD state (P007).
## Pure presentation data container: no domain logic or game rules.

var hero_name: String = "Hero"
var current_health: int = 30
var max_health: int = 30
var current_mana: int = 1
var max_mana: int = 1
var deck_count: int = 30
var graveyard_count: int = 0
var top_graveyard_card: GraveyardView.PreviewCard = null

func _init(
	p_hero_name: String = "Hero",
	p_current_health: int = 30,
	p_max_health: int = 30,
	p_current_mana: int = 1,
	p_max_mana: int = 1,
	p_deck_count: int = 30,
	p_graveyard_count: int = 0,
	p_top_graveyard_card: GraveyardView.PreviewCard = null
) -> void:
	hero_name = p_hero_name
	current_health = p_current_health
	max_health = p_max_health
	current_mana = p_current_mana
	max_mana = p_max_mana
	deck_count = p_deck_count
	graveyard_count = p_graveyard_count
	top_graveyard_card = p_top_graveyard_card

func is_valid() -> bool:
	return (
		not hero_name.strip_edges().is_empty() and
		current_health >= 0 and
		max_health >= 0 and
		current_mana >= 0 and
		max_mana >= 0 and
		deck_count >= 0 and
		graveyard_count >= 0
	)

func duplicate_model() -> HeroHudViewModel:
	var copy: HeroHudViewModel = HeroHudViewModel.new(
		hero_name,
		current_health,
		max_health,
		current_mana,
		max_mana,
		deck_count,
		graveyard_count,
		top_graveyard_card
	)
	return copy
