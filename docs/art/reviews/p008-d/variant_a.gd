extends CreatureToken
const BASE_LAYOUT: GDScript = preload("res://docs/art/reviews/p008-d/baseline_layout.gd")
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
		var at: Vector2 = BASE_LAYOUT.STATUS_ORIGIN + Vector2(index * BASE_LAYOUT.INDICATOR_STEP, 0)
		if status.icon != null:
			draw_texture_rect(status.icon, Rect2(at, BASE_LAYOUT.INDICATOR_SIZE), false)
		else:
			_draw_diagnostic(at, status.diagnostic_label)
	if get_status_overflow() > 0:
		_draw_diagnostic(BASE_LAYOUT.STATUS_ORIGIN + Vector2(3 * BASE_LAYOUT.INDICATOR_STEP, 0), "+%d" % get_status_overflow())
	if _model.weapon_attached:
		_draw_diagnostic(BASE_LAYOUT.WEAPON, "W")
	if _model.protection_attached:
		_draw_diagnostic(BASE_LAYOUT.PROTECTION, "P")


func _draw_plaque(rect: Rect2, texture: Texture2D, value: int) -> void:
	if value > 0:
		draw_texture_rect(texture, rect, false)
	draw_number(rect.get_center(), value, BASE_LAYOUT.SECONDARY_POINTS, BASE_LAYOUT.SECONDARY_WIDTH, TOKENS.color_token(&"text_bright"), 0.0, Vector2.ZERO)


func draw_number(center: Vector2, value: int, points: int, max_width: float, ink: Color,
		safe_radius: float = 0.0, custom_optical_offset: Variant = null) -> void:
	var text: String = str(value)
	var font: Font = TOKENS.THEME.get_font(&"font", &"TacticalNumber")
	var measured: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, points)
	var font_size: int = mini(points, maxi(1, int(points * max_width / maxf(measured.x, 1.0))))
	var server: TextServer = TextServerManager.get_primary_interface()
	var font_rid: RID = font.get_rids()[0]
	var glyphs: PackedInt32Array = PackedInt32Array()
	var offsets: PackedFloat32Array = PackedFloat32Array()
	var bounds: Rect2 = Rect2()
	while true:
		glyphs.clear()
		offsets.clear()
		var cursor: float = 0.0
		for index: int in range(text.length()):
			var glyph: int = server.font_get_glyph_index(font_rid, font_size, text.unicode_at(index), 0)
			server.font_render_glyph(font_rid, Vector2i(font_size, 0), glyph)
			var glyph_bounds: Rect2 = Rect2(
				server.font_get_glyph_offset(font_rid, Vector2i(font_size, 0), glyph) + Vector2(cursor, 0),
				server.font_get_glyph_size(font_rid, Vector2i(font_size, 0), glyph))
			bounds = glyph_bounds if index == 0 else bounds.merge(glyph_bounds)
			glyphs.append(glyph)
			offsets.append(cursor)
			cursor += server.font_get_glyph_advance(font_rid, font_size, glyph).x
		# A width-only fit cannot protect a circular socket's diagonal corners.
		# Keep the existing glyph-bounds centering; fit its enclosing rectangle in
		# the safe disk, including 3 px outline + 1 px baseline rounding allowance.
		if safe_radius <= 0.0 or bounds.size.length() * 0.5 + 4.0 <= safe_radius or font_size <= 1:
			break
		font_size -= 1

	var opt_offset: Vector2 = Vector2.ZERO
	if use_optical_numeral_centering:
		opt_offset = custom_optical_offset if custom_optical_offset != null else get_numeral_optical_offset(value)
	var baseline: Vector2 = (center + opt_offset - bounds.get_center()).round()

	for index: int in range(glyphs.size()):
		var at: Vector2 = baseline + Vector2(offsets[index], 0)

		# Layer A: Coherent directional depth shadow across all stat numerals (ART-002-T25)
		server.font_draw_glyph_outline(font_rid, get_canvas_item(), font_size, NUMERAL_OUTLINE_SIZE, at + NUMERAL_SHADOW_OFFSET, glyphs[index], NUMERAL_SHADOW_COLOR)
		server.font_draw_glyph(font_rid, get_canvas_item(), font_size, at + NUMERAL_SHADOW_OFFSET, glyphs[index], NUMERAL_SHADOW_COLOR)

		# Layer B: Crisp boundary stroke
		server.font_draw_glyph_outline(font_rid, get_canvas_item(), font_size, NUMERAL_OUTLINE_SIZE, at, glyphs[index], TOKENS.color_token(&"background"))

		# Layer C: Bright ivory numeral fill
		server.font_draw_glyph(font_rid, get_canvas_item(), font_size, at, glyphs[index], ink)

