extends CreatureToken
var value: int = 0
var primary: bool = false
func _draw() -> void:
	draw_number(Vector2(233,800) if primary else Vector2(581,845),value,260 if primary else 170,260.0 if primary else 260.0,UIDesignTokens.color_token(&"text_bright"),116.0 if primary else 0.0,Vector2.ZERO)
