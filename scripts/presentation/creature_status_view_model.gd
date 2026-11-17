class_name CreatureStatusViewModel
extends Resource
## Ordered by the injecting presenter; no priority or duration calculation here.
@export var status_id: StringName = &""
@export var icon: Texture2D
@export var diagnostic_label: String = "?"

func is_valid() -> bool:
	return not status_id.is_empty() and (icon != null or diagnostic_label.length() == 1)

func duplicate_model() -> CreatureStatusViewModel:
	return duplicate() as CreatureStatusViewModel
