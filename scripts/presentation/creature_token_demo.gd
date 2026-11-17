class_name CreatureTokenDemo
extends RefCounted
## Explicit review fixture; never automatically installed in CombatScreen.
const MODELS: Array[CreatureTokenViewModel] = [
	preload("res://resources/fixtures/p008/token_0.tres"),
	preload("res://resources/fixtures/p008/token_1.tres"),
	preload("res://resources/fixtures/p008/token_2.tres"),
	preload("res://resources/fixtures/p008/token_3.tres"),
	preload("res://resources/fixtures/p008/token_4.tres"),
	preload("res://resources/fixtures/p008/token_5.tres")]

static func populate(screen: CombatScreen, scenario: String) -> void:
	screen.clear_creature_tokens()
	screen.clear_slot_selection()
	if scenario == "empty":
		return
	var count: int = 24 if scenario == "full_board" or scenario == "selected" else 1
	var fixture_index: int = 0
	match scenario:
		"armor_shield": fixture_index = 1
		"equipment": fixture_index = 2
		"status_overflow": fixture_index = 3
		"zero_stats": fixture_index = 4
		"stats": fixture_index = 5
	var slots: Array[BattlefieldSlot] = screen.get_slots()
	for index: int in range(count):
		var model: CreatureTokenViewModel = MODELS[index % MODELS.size() if count == 24 else fixture_index].duplicate_model()
		model.instance_id = StringName("review_%02d" % index)
		screen.add_creature_token(slots[index].get_slot_identity(), model)
	if scenario == "selected":
		screen.select_slot(slots[8].camp, slots[8].column, slots[8].row)
