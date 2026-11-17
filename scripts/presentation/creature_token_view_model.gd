class_name CreatureTokenViewModel
extends Resource
## Resolved presentation values. Never references or changes a printed card.
@export var instance_id: StringName = &""
@export var portrait: Texture2D
@export var effective_attack: int = 0
@export var current_health: int = 0
@export var maximum_health: int = 0
@export var armor: int = 0
@export var shield: int = 0
@export var statuses: Array[CreatureStatusViewModel] = []
@export var weapon_attached: bool = false
@export var protection_attached: bool = false

func is_valid() -> bool:
	if instance_id.is_empty() or portrait == null or effective_attack < 0 or current_health < 0 or maximum_health < current_health or armor < 0 or shield < 0:
		return false
	for status: CreatureStatusViewModel in statuses:
		if status == null or not status.is_valid():
			return false
	return true

func duplicate_model() -> CreatureTokenViewModel:
	var result: CreatureTokenViewModel = duplicate() as CreatureTokenViewModel
	result.statuses = []
	for status: CreatureStatusViewModel in statuses:
		result.statuses.append(status.duplicate_model())
	return result
