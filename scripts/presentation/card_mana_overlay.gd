class_name CardManaOverlay
extends CardSocketOverlay
## Dedicated lightweight overlay for non-creature cards displaying only Mana (Spells).
## Adheres to Single Responsibility and Interface Segregation principles.
## Renders the mana numeral in the upper-left socket at MANA_CENTER using the coherent shared numeral styling.
## Zero creature combat stats, zero Attack/Health bezels/inlays, zero empty rosette engravings.

func _draw() -> void:
	draw_number(MANA_CENTER, _mana, 126, 145, TOKENS.color_token(&"text_bright"), SOCKET_SAFE_RADIUS)

func set_mana(value: int) -> void:
	_mana = maxi(0, value)
	queue_redraw()
