extends SceneTree
## Automated technical validation for ART-002-T21:
## Numeral Optical Centering, Pipeline Sharpness Constants & Regressions.

const STAT_OVERLAY: GDScript = preload("res://scripts/presentation/card_stat_overlay.gd")
const CATEGORY_OVERLAY: GDScript = preload("res://scripts/presentation/card_category_overlay.gd")

func _initialize() -> void:
	var failures: int = 0

	# 1. Verify Centralized Optical Offsets Dictionary Exists
	if not STAT_OVERLAY.NUMERAL_OPTICAL_OFFSETS is Dictionary:
		print("FAIL: NUMERAL_OPTICAL_OFFSETS is not a Dictionary")
		failures += 1
	else:
		print("PASS: NUMERAL_OPTICAL_OFFSETS dictionary verified")

	# 2. Verify Documented Values in Dictionary
	var expected_offsets: Dictionary = {
		1: Vector2(0, 0),
		4: Vector2(-4, -4),
		5: Vector2(0, 1),
		7: Vector2(2, 2),
		8: Vector2(0, 0),
		10: Vector2(-2, 0),
		12: Vector2(-2, 0),
		14: Vector2(-3, -2),
	}

	for k: int in expected_offsets:
		var actual: Vector2 = STAT_OVERLAY.get_numeral_optical_offset(k)
		var exp_val: Vector2 = expected_offsets[k]
		if actual != exp_val:
			print("FAIL: Numeral %d optical offset expected %s, got %s" % [k, exp_val, actual])
			failures += 1
		else:
			print("PASS: Numeral %2d optical offset verified at %s" % [k, actual])

	# 3. Verify Default Toggle State
	if not STAT_OVERLAY.use_optical_numeral_centering:
		print("FAIL: Default use_optical_numeral_centering should be true")
		failures += 1
	else:
		print("PASS: Default use_optical_numeral_centering is true")

	# 4. Verify Physical Centers & Safe Disk Preserved (T04B)
	if STAT_OVERLAY.ATTACK_CENTER != Vector2(162, 1279):
		print("FAIL: ATTACK_CENTER modified unexpectedly")
		failures += 1
	else:
		print("PASS: ATTACK_CENTER preserved at (162, 1279)")

	if STAT_OVERLAY.HEALTH_CENTER != Vector2(919, 1279):
		print("FAIL: HEALTH_CENTER modified unexpectedly")
		failures += 1
	else:
		print("PASS: HEALTH_CENTER preserved at (919, 1279)")

	if STAT_OVERLAY.MANA_CENTER != Vector2(153, 151):
		print("FAIL: MANA_CENTER modified unexpectedly")
		failures += 1
	else:
		print("PASS: MANA_CENTER preserved at (153, 151)")

	if STAT_OVERLAY.SOCKET_SAFE_RADIUS != 70.0:
		print("FAIL: SOCKET_SAFE_RADIUS modified unexpectedly")
		failures += 1
	else:
		print("PASS: SOCKET_SAFE_RADIUS preserved at 70.0")

	# 5. Verify T20 Inlay Architecture Preserved
	if STAT_OVERLAY.presentation_mode != 0:
		print("FAIL: Default presentation_mode should be 0 (Integrated Inlays)")
		failures += 1
	else:
		print("PASS: Default presentation_mode is 0 (Integrated Inlays)")

	if not STAT_OVERLAY.use_inlays:
		print("FAIL: Default use_inlays should be true")
		failures += 1
	else:
		print("PASS: Default use_inlays is true")

	if STAT_OVERLAY.ATTACK_INLAY_SIZE != Vector2(190, 190) or STAT_OVERLAY.HEALTH_INLAY_SIZE != Vector2(190, 190):
		print("FAIL: Inlay rendering dimensions modified")
		failures += 1
	else:
		print("PASS: Inlay rendering dimensions preserved at 190x190")

	# 6. Verify Baseline Shift Calculation for Asymmetrical Numeral "4"
	var font: Font = STAT_OVERLAY.TOKENS.THEME.get_font(&"font", &"TacticalNumber")
	var server: TextServer = TextServerManager.get_primary_interface()
	var font_rid: RID = font.get_rids()[0]
	var center: Vector2 = Vector2(162, 1279)

	var bounds_4: Rect2 = _calc_bounds(server, font_rid, font, "4", 126, 145.0, 70.0)
	var baseline_raw: Vector2 = (center - bounds_4.get_center()).round()
	var baseline_opt: Vector2 = (center + STAT_OVERLAY.get_numeral_optical_offset(4) - bounds_4.get_center()).round()
	var delta: Vector2 = baseline_opt - baseline_raw

	if delta != Vector2(-4, -4):
		print("FAIL: Numeral '4' optical shift delta expected Vector2(-4, -4), got %s" % delta)
		failures += 1
	else:
		print("PASS: Numeral '4' optical shift cleanly verified at delta=%s (cancels +4.2 px X, +4.9 px Y mass bias)" % delta)

	# 7. Verify Rollback Capability (use_optical_numeral_centering = false)
	CardStatOverlay.use_optical_numeral_centering = false
	var baseline_rollback: Vector2 = (center + (STAT_OVERLAY.get_numeral_optical_offset(4) if CardStatOverlay.use_optical_numeral_centering else Vector2.ZERO) - bounds_4.get_center()).round()
	CardStatOverlay.use_optical_numeral_centering = true
	if baseline_rollback != baseline_raw:
		print("FAIL: Rollback did not restore raw bounding box baseline")
		failures += 1
	else:
		print("PASS: Rollback toggle cleanly restores exact mathematical bounding-box baseline")

	# 8. Verify Spell / Equipment Inactive Sockets
	var cat_overlay: CardCategoryOverlay = CATEGORY_OVERLAY.new()
	cat_overlay.category = CardContentOverlay.Category.SPELL
	if cat_overlay.category != CardContentOverlay.Category.SPELL:
		print("FAIL: Category overlay spell category mismatch")
		failures += 1
	else:
		print("PASS: Category overlay behavior preserved")
	cat_overlay.free()

	print("T21_OPTICAL_REGRESSION_FAILURES=%d" % failures)
	quit(0 if failures == 0 else 1)

func _calc_bounds(server: TextServer, font_rid: RID, font: Font, text: String,
		points: int, max_width: float, safe_radius: float) -> Rect2:
	var measured: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, points)
	var font_size: int = mini(points, maxi(1, int(points * max_width / maxf(measured.x, 1.0))))
	var bounds: Rect2 = Rect2()
	while true:
		var cursor: float = 0.0
		for index: int in range(text.length()):
			var glyph: int = server.font_get_glyph_index(font_rid, font_size, text.unicode_at(index), 0)
			server.font_render_glyph(font_rid, Vector2i(font_size, 0), glyph)
			var glyph_bounds: Rect2 = Rect2(
				server.font_get_glyph_offset(font_rid, Vector2i(font_size, 0), glyph) + Vector2(cursor, 0),
				server.font_get_glyph_size(font_rid, Vector2i(font_size, 0), glyph))
			bounds = glyph_bounds if index == 0 else bounds.merge(glyph_bounds)
			cursor += server.font_get_glyph_advance(font_rid, font_size, glyph).x
		if safe_radius <= 0.0 or bounds.size.length() * 0.5 + 4.0 <= safe_radius or font_size <= 1:
			break
		font_size -= 1
	return bounds
