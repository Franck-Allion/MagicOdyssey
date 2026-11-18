extends "res://docs/art/reviews/p008-d/variant_a.gd"
func _draw() -> void:
	if _model == null:
		return
	_draw_portrait()
	# Materials behind the frame: its existing bronze masks the disk edges.
	draw_texture_rect(CardStatOverlay.INLAY_ATTACK, Rect2(BASE_LAYOUT.ATTACK - BASE_LAYOUT.INLAY_SIZE * 0.5, BASE_LAYOUT.INLAY_SIZE), false)
	draw_texture_rect(CardStatOverlay.INLAY_HEALTH, Rect2(BASE_LAYOUT.HEALTH - BASE_LAYOUT.INLAY_SIZE * 0.5, BASE_LAYOUT.INLAY_SIZE), false)
	draw_texture_rect(FRAME, Rect2(Vector2.ZERO, BASE_LAYOUT.SOURCE_SIZE), false)
	var ink: Color = TOKENS.color_token(&"text_bright")
	draw_number(BASE_LAYOUT.ATTACK, _model.effective_attack, BASE_LAYOUT.PRIMARY_POINTS, BASE_LAYOUT.PRIMARY_WIDTH, ink, BASE_LAYOUT.PRIMARY_RADIUS, Vector2.ZERO)
	draw_number(BASE_LAYOUT.HEALTH, _model.current_health, BASE_LAYOUT.PRIMARY_POINTS, BASE_LAYOUT.PRIMARY_WIDTH, ink, BASE_LAYOUT.PRIMARY_RADIUS, Vector2.ZERO)
	_draw_plaque(BASE_LAYOUT.ARMOR, CardStatOverlay.PLATE_ARMOR, _model.armor)
	_draw_plaque(BASE_LAYOUT.SHIELD, CardStatOverlay.PLATE_SHIELD, _model.shield)
	for index: int in range(get_visible_status_count()):
		var status: CreatureStatusViewModel = _model.statuses[index]
		var at: Vector2 = Vector2(410,120) + Vector2(index * BASE_LAYOUT.INDICATOR_STEP, 0)
		if status.icon != null:
			draw_texture_rect(status.icon, Rect2(at, BASE_LAYOUT.INDICATOR_SIZE), false)
		else:
			_draw_diagnostic(at, status.diagnostic_label)
	if get_status_overflow() > 0:
		_draw_diagnostic(Vector2(410,120) + Vector2(3 * BASE_LAYOUT.INDICATOR_STEP, 0), "+%d" % get_status_overflow())
	if _model.weapon_attached:
		_draw_diagnostic(Vector2(260,140), "W")
	if _model.protection_attached:
		_draw_diagnostic(Vector2(1140,140), "P")


func _draw_plaque(rect: Rect2, texture: Texture2D, value: int) -> void:
	if value <= 0:
		return
	if value > 0:
		draw_texture_rect(texture, rect, false)
	draw_number(rect.get_center(), value, BASE_LAYOUT.SECONDARY_POINTS, BASE_LAYOUT.SECONDARY_WIDTH, TOKENS.color_token(&"text_bright"), 0.0, Vector2.ZERO)

