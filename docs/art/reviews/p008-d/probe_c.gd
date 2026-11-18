extends CreatureToken
var value: int = 0
var primary: bool = false
func _draw() -> void:
	draw_number(Vector2(220,802) if primary else Vector2(568,860),value,240 if primary else 170,260.0 if primary else 260.0,UIDesignTokens.color_token(&"text_bright"),106.0 if primary else 0.0,Vector2.ZERO)
