extends SceneTree
## Automated technical validation for ART-002-T24:
## Refined Armor & Shield Numeral Vertical Breathing Room and Optical Centering Suite.

const STAT_OVERLAY: GDScript = preload("res://scripts/presentation/card_stat_overlay.gd")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")

func _initialize() -> void:
	var failures: int = 0
	var passes: int = 0

	print("=== ART-002-T24 Breathing Room Regression Suite ===")

	# 1. Verify Refined T24 Font Size Constant
	if STAT_OVERLAY.BADGE_PLAQUE_NUMBER_FONT_SIZE != 62:
		print("FAIL: BADGE_PLAQUE_NUMBER_FONT_SIZE should be 62, got %d" % STAT_OVERLAY.BADGE_PLAQUE_NUMBER_FONT_SIZE)
		failures += 1
	else:
		print("PASS: BADGE_PLAQUE_NUMBER_FONT_SIZE refined to 62 pt")
		passes += 1

	# 2. Verify Preserved T23 Font Size Constant for Rollback
	if STAT_OVERLAY.BADGE_PLAQUE_NUMBER_FONT_SIZE_T23 != 76:
		print("FAIL: BADGE_PLAQUE_NUMBER_FONT_SIZE_T23 should be 76, got %d" % STAT_OVERLAY.BADGE_PLAQUE_NUMBER_FONT_SIZE_T23)
		failures += 1
	else:
		print("PASS: BADGE_PLAQUE_NUMBER_FONT_SIZE_T23 preserved at 76 pt")
		passes += 1

	# 3. Verify Dedicated Badge Optical Offsets (Vertical Y offset strictly 0)
	var expected_badge_offsets: Dictionary = {
		1: Vector2(0, 0),
		2: Vector2(0, 0),
		4: Vector2(-1, 0),
		5: Vector2(0, 0),
		7: Vector2(1, 0),
		8: Vector2(0, 0),
		10: Vector2(-2, 0),
		12: Vector2(-2, 0),
		14: Vector2(-2, 0),
	}

	for val: int in expected_badge_offsets:
		var actual: Vector2 = STAT_OVERLAY.get_badge_plaque_numeral_optical_offset(val)
		var expected: Vector2 = expected_badge_offsets[val]
		if actual != expected:
			print("FAIL: Badge optical offset for %d should be %s, got %s" % [val, expected, actual])
			failures += 1
		else:
			print("PASS: Badge optical offset for %d verified: %s (Y=0.0)" % [val, actual])
			passes += 1

	# 4. Verify Preserved Circular Socket Optical Offsets (Attack/Health T21 untouched)
	if STAT_OVERLAY.get_numeral_optical_offset(4) != Vector2(-4, -4):
		print("FAIL: Circular socket optical offset for 4 should remain Vector2(-4, -4)")
		failures += 1
	else:
		print("PASS: Circular socket optical offset for 4 preserved: Vector2(-4, -4)")
		passes += 1

	# 5. Measure Vertical Breathing Room Across Representative Values
	var font: Font = TOKENS.THEME.get_font(&"font", &"TacticalNumber")
	var server: TextServer = TextServerManager.get_primary_interface()
	var font_rid: RID = font.get_rids()[0]
	var test_values: Array[int] = [1, 2, 4, 8, 10, 12, 14, 99]

	for val: int in test_values:
		var text: String = str(val)
		var bounds: Rect2 = Rect2()
		var cursor: float = 0.0

		for index: int in range(text.length()):
			var glyph: int = server.font_get_glyph_index(font_rid, 62, text.unicode_at(index), 0)
			server.font_render_glyph(font_rid, Vector2i(62, 0), glyph)
			var glyph_bounds: Rect2 = Rect2(
				server.font_get_glyph_offset(font_rid, Vector2i(62, 0), glyph) + Vector2(cursor, 0),
				server.font_get_glyph_size(font_rid, Vector2i(62, 0), glyph))
			bounds = glyph_bounds if index == 0 else bounds.merge(glyph_bounds)
			cursor += server.font_get_glyph_advance(font_rid, 62, glyph).x

		var total_h_with_outline: float = bounds.size.y + 6.0 # 3px outline top and bottom
		var armor_h: float = STAT_OVERLAY.ARMOR_PLAQUE_SIZE.y # 62.0
		var shield_h: float = STAT_OVERLAY.SHIELD_PLAQUE_SIZE.y # 69.0

		var armor_margin: float = (armor_h - total_h_with_outline) * 0.5
		var shield_margin: float = (shield_h - total_h_with_outline) * 0.5

		# In T23 at 76 pt, Armor margin was 0.0 - 1.0 px.
		# In T24 at 62 pt, Armor margin must be >= 5.0 px.
		if armor_margin < 4.8:
			print("FAIL: Value %d has insufficient Armor vertical breathing room: %.1f px" % [val, armor_margin])
			failures += 1
		else:
			print("PASS: Value %2d Armor vertical margin = %.1f px (comfortable breathing room, zero border crowding)" % [val, armor_margin])
			passes += 1

		# In T23 at 76 pt, Shield margin was 3.5 - 4.5 px.
		# In T24 at 62 pt, Shield margin must be >= 8.0 px.
		if shield_margin < 7.8:
			print("FAIL: Value %d has insufficient Shield vertical breathing room: %.1f px" % [val, shield_margin])
			failures += 1
		else:
			print("PASS: Value %2d Shield vertical margin = %.1f px (comfortable breathing room, zero border crowding)" % [val, shield_margin])
			passes += 1

	# 6. Verify Diagnostic Rollback Toggles
	if STAT_OVERLAY.use_t23_badge_font_size:
		print("FAIL: use_t23_badge_font_size should default to false")
		failures += 1
	else:
		print("PASS: use_t23_badge_font_size defaults to false")
		passes += 1

	if not STAT_OVERLAY.use_plaque_inlays:
		print("FAIL: use_plaque_inlays should default to true")
		failures += 1
	else:
		print("PASS: use_plaque_inlays defaults to true")
		passes += 1

	# 7. Verify Preserved Historical Plaque Dimensions and Centers
	if STAT_OVERLAY.ARMOR_PLAQUE_SIZE != Vector2(180, 62):
		print("FAIL: ARMOR_PLAQUE_SIZE modified")
		failures += 1
	else:
		print("PASS: ARMOR_PLAQUE_SIZE preserved at Vector2(180, 62)")
		passes += 1

	if STAT_OVERLAY.SHIELD_PLAQUE_SIZE != Vector2(180, 69):
		print("FAIL: SHIELD_PLAQUE_SIZE modified")
		failures += 1
	else:
		print("PASS: SHIELD_PLAQUE_SIZE preserved at Vector2(180, 69)")
		passes += 1

	if STAT_OVERLAY.BADGE_PLAQUE_NUMBER_LOCAL_CENTER != Vector2(99, 50):
		print("FAIL: BADGE_PLAQUE_NUMBER_LOCAL_CENTER modified")
		failures += 1
	else:
		print("PASS: BADGE_PLAQUE_NUMBER_LOCAL_CENTER preserved at Vector2(99, 50)")
		passes += 1

	print("--------------------------------------------------")
	print("T24 Regression Summary: %d Passed, %d Failed" % [passes, failures])
	print("==================================================")
	if failures > 0:
		quit(1)
	else:
		print("RESULT: ALL T24 REGRESSION CHECKS PASSED")
		quit(0)
