extends "res://docs/art/reviews/p008-d/variant_a.gd"
var value: int = 0
var primary: bool = false
func _draw() -> void:
	draw_number(Vector2(220,802) if primary else Vector2(568,860),value,220 if primary else 170,212.0 if primary else 260.0,UIDesignTokens.color_token(&"text_bright"),101.0 if primary else 0.0,Vector2.ZERO)
