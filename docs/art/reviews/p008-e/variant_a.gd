extends CreatureToken
const BASE_LAYOUT: GDScript = preload("res://docs/art/reviews/p008-e/baseline_layout.gd")
const BASE_FRAME: Texture2D = preload("res://assets/textures/tokens/mo_creature_token_frame_v02.png")
func _draw() -> void:
	if _model == null:
		return
	_draw_portrait()
	# Materials behind the frame: its existing bronze masks the disk edges.
	draw_texture_rect(CardStatOverlay.INLAY_ATTACK, Rect2(BASE_LAYOUT.ATTACK - BASE_LAYOUT.INLAY_SIZE * 0.5, BASE_LAYOUT.INLAY_SIZE), false)
	draw_texture_rect(CardStatOverlay.INLAY_HEALTH, Rect2(BASE_LAYOUT.HEALTH - BASE_LAYOUT.INLAY_SIZE * 0.5, BASE_LAYOUT.INLAY_SIZE), false)
	draw_texture_rect(BASE_FRAME, Rect2(Vector2.ZERO, BASE_LAYOUT.SOURCE_SIZE), false)
	var ink: Color = TOKENS.color_token(&"text_bright")
	draw_number(BASE_LAYOUT.ATTACK, _model.effective_attack, BASE_LAYOUT.PRIMARY_POINTS, BASE_LAYOUT.PRIMARY_WIDTH, ink, BASE_LAYOUT.PRIMARY_RADIUS, Vector2.ZERO)
	draw_number(BASE_LAYOUT.HEALTH, _model.current_health, BASE_LAYOUT.PRIMARY_POINTS, BASE_LAYOUT.PRIMARY_WIDTH, ink, BASE_LAYOUT.PRIMARY_RADIUS, Vector2.ZERO)
	_draw_plaque(BASE_LAYOUT.ARMOR, CardStatOverlay.PLATE_ARMOR, _model.armor)
	_draw_plaque(BASE_LAYOUT.SHIELD, CardStatOverlay.PLATE_SHIELD, _model.shield)
	for index: int in range(get_visible_status_count()):
		var status: CreatureStatusViewModel = _model.statuses[index]
		var at: Vector2 = BASE_LAYOUT.STATUS_ORIGIN + Vector2(index * BASE_LAYOUT.INDICATOR_STEP, 0)
		if status.icon != null:
			draw_texture_rect(status.icon, Rect2(at, BASE_LAYOUT.INDICATOR_SIZE), false)
		elif diagnostic_indicators_enabled:
			_draw_diagnostic(at, status.diagnostic_label)
	if get_status_overflow() > 0:
		_draw_diagnostic(BASE_LAYOUT.STATUS_ORIGIN + Vector2(3 * BASE_LAYOUT.INDICATOR_STEP, 0), "+%d" % get_status_overflow())
	if _model.weapon_attached and diagnostic_indicators_enabled:
		_draw_diagnostic(BASE_LAYOUT.WEAPON, "W")
	if _model.protection_attached and diagnostic_indicators_enabled:
		_draw_diagnostic(BASE_LAYOUT.PROTECTION, "P")


func _draw_portrait() -> void:
	var crop: Rect2 = BASE_LAYOUT.portrait_region(_model.portrait.get_size())
	var uvs: PackedVector2Array = PackedVector2Array()
	for point: Vector2 in BASE_LAYOUT.PORTRAIT_POLYGON:
		uvs.append((crop.position + (point - BASE_LAYOUT.PORTRAIT_BOUNDS.position) / BASE_LAYOUT.PORTRAIT_BOUNDS.size * crop.size) / _model.portrait.get_size())
	draw_polygon(PackedVector2Array(BASE_LAYOUT.PORTRAIT_POLYGON), PackedColorArray([Color.WHITE]), uvs, _model.portrait)


func _draw_plaque(rect: Rect2, texture: Texture2D, value: int) -> void:
	if value <= 0:
		return
	if value > 0:
		draw_texture_rect(texture, rect, false)
	draw_number(rect.get_center(), value, BASE_LAYOUT.SECONDARY_POINTS, BASE_LAYOUT.SECONDARY_WIDTH, TOKENS.color_token(&"text_bright"), 0.0, Vector2.ZERO)

## Token-only condensed primary fit. Printed ART-002 cards keep their renderer.
## Fit the transformed glyph rectangle plus stroke inside the measured aperture.

func get_primary_fit(value: int) -> Vector3:
	var font: Font = TOKENS.THEME.get_font(&"font", &"TacticalNumber")
	var ts: TextServer = TextServerManager.get_primary_interface()
	var rid: RID = font.get_rids()[0]
	var points: int = BASE_LAYOUT.PRIMARY_POINTS
	var squeeze: float = 0.80 if value >= 10 else 1.0
	var bounds: Rect2 = Rect2()
	while points > 1:
		var cursor: float = 0.0
		for index: int in range(str(value).length()):
			var glyph: int = ts.font_get_glyph_index(rid, points, str(value).unicode_at(index), 0)
			ts.font_render_glyph(rid, Vector2i(points,0), glyph)
			var rect: Rect2 = Rect2(ts.font_get_glyph_offset(rid,Vector2i(points,0),glyph)+Vector2(cursor,0),ts.font_get_glyph_size(rid,Vector2i(points,0),glyph))
			bounds = rect if index == 0 else bounds.merge(rect)
			cursor += ts.font_get_glyph_advance(rid,points,glyph).x
		if Vector2(bounds.size.x*squeeze,bounds.size.y).length()*0.5 + 6.0 <= BASE_LAYOUT.PRIMARY_RADIUS:
			break
		points -= 1
	return Vector3(points,squeeze,Vector2(bounds.size.x*squeeze,bounds.size.y).length()*0.5+6.0)


func draw_number(center: Vector2, value: int, points: int, max_width: float, ink: Color,
		safe_radius: float = 0.0, custom_optical_offset: Variant = null) -> void:
	if safe_radius <= 0.0:
		super.draw_number(center,value,points,max_width,ink,safe_radius,custom_optical_offset)
		return
	var fit: Vector3 = get_primary_fit(value)
	draw_set_transform(center,0.0,Vector2(fit.y,1.0))
	super.draw_number(Vector2.ZERO,value,int(fit.x),1024.0,ink,0.0,Vector2.ZERO)
	draw_set_transform(Vector2.ZERO)

## Temporary diagnostic fixtures only; injected approved icons replace them.
