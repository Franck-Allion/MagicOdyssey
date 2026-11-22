class_name NumeralStyle
extends Resource
## Optional typography for the shared numeral renderer. Null retains ART-002.
@export var font: Font
@export var fill: Color = Color.WHITE
@export var outline_color: Color = Color.BLACK
@export_range(0, 32) var outline_size: int = 10
@export var shadow_enabled: bool = false
@export_range(0.8, 1.0) var primary_width_scale: float = 1.0
@export var secondary_points: int = 190
