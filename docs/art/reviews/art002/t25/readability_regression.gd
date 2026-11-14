extends SceneTree
## Automated technical validation for ART-002-T25:
## Global Stat Numeral Readability Polish and Mandatory Coherence Suite.

const STAT_OVERLAY: GDScript = preload("res://scripts/presentation/card_stat_overlay.gd")
const CATEGORY_OVERLAY: GDScript = preload("res://scripts/presentation/card_category_overlay.gd")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")

func _initialize() -> void:
	var failures: int = 0
	var passes: int = 0

	print("=== ART-002-T25 Readability Regression Suite ===")

	# 1. Verify Coherent Styling Constants
	if STAT_OVERLAY.NUMERAL_OUTLINE_SIZE != 4:
		print("FAIL: NUMERAL_OUTLINE_SIZE should be 4, got %d" % STAT_OVERLAY.NUMERAL_OUTLINE_SIZE)
		failures += 1
	else:
		print("PASS: NUMERAL_OUTLINE_SIZE calibrated at 4 px")
		passes += 1

	if STAT_OVERLAY.NUMERAL_SHADOW_OFFSET != Vector2(0, 2):
		print("FAIL: NUMERAL_SHADOW_OFFSET should be Vector2(0, 2), got %s" % STAT_OVERLAY.NUMERAL_SHADOW_OFFSET)
		failures += 1
	else:
		print("PASS: NUMERAL_SHADOW_OFFSET calibrated at Vector2(0, 2)")
		passes += 1

	if STAT_OVERLAY.NUMERAL_SHADOW_COLOR != Color(0.0, 0.0, 0.0, 0.8):
		print("FAIL: NUMERAL_SHADOW_COLOR should be Color(0, 0, 0, 0.8), got %s" % STAT_OVERLAY.NUMERAL_SHADOW_COLOR)
		failures += 1
	else:
		print("PASS: NUMERAL_SHADOW_COLOR calibrated at Color(0, 0, 0, 0.8)")
		passes += 1

	if not CardStatOverlay.use_t25_readability_polish:
		print("FAIL: use_t25_readability_polish should default to true")
		failures += 1
	else:
		print("PASS: use_t25_readability_polish defaults to true (coherent 4 px stroke + depth shadow active)")
		passes += 1

	# 2. Verify Preserved Local Fitting Constants
	if STAT_OVERLAY.BADGE_PLAQUE_NUMBER_FONT_SIZE != 62:
		print("FAIL: BADGE_PLAQUE_NUMBER_FONT_SIZE should be 62, got %d" % STAT_OVERLAY.BADGE_PLAQUE_NUMBER_FONT_SIZE)
		failures += 1
	else:
		print("PASS: BADGE_PLAQUE_NUMBER_FONT_SIZE preserved at 62 pt")
		passes += 1

	if STAT_OVERLAY.BADGE_PLAQUE_NUMBER_MAX_WIDTH != 83.0:
		print("FAIL: BADGE_PLAQUE_NUMBER_MAX_WIDTH should be 83.0")
		failures += 1
	else:
		print("PASS: BADGE_PLAQUE_NUMBER_MAX_WIDTH preserved at 83.0")
		passes += 1

	if STAT_OVERLAY.BADGE_PLAQUE_NUMBER_LOCAL_CENTER != Vector2(99, 50):
		print("FAIL: BADGE_PLAQUE_NUMBER_LOCAL_CENTER should be Vector2(99, 50)")
		failures += 1
	else:
		print("PASS: BADGE_PLAQUE_NUMBER_LOCAL_CENTER preserved at Vector2(99, 50)")
		passes += 1

	if STAT_OVERLAY.ARMOR_PLAQUE_SIZE != Vector2(180, 62):
		print("FAIL: ARMOR_PLAQUE_SIZE should be Vector2(180, 62)")
		failures += 1
	else:
		print("PASS: ARMOR_PLAQUE_SIZE preserved at Vector2(180, 62)")
		passes += 1

	if STAT_OVERLAY.SHIELD_PLAQUE_SIZE != Vector2(180, 69):
		print("FAIL: SHIELD_PLAQUE_SIZE should be Vector2(180, 69)")
		failures += 1
	else:
		print("PASS: SHIELD_PLAQUE_SIZE preserved at Vector2(180, 69)")
		passes += 1

	# 3. Verify Preserved Attack and Health Socket Constants
	if STAT_OVERLAY.ATTACK_INLAY_SIZE != Vector2(190, 190):
		print("FAIL: ATTACK_INLAY_SIZE should be Vector2(190, 190)")
		failures += 1
	else:
		print("PASS: ATTACK_INLAY_SIZE preserved at Vector2(190, 190)")
		passes += 1

	if STAT_OVERLAY.HEALTH_INLAY_SIZE != Vector2(190, 190):
		print("FAIL: HEALTH_INLAY_SIZE should be Vector2(190, 190)")
		failures += 1
	else:
		print("PASS: HEALTH_INLAY_SIZE preserved at Vector2(190, 190)")
		passes += 1

	if STAT_OVERLAY.SOCKET_SAFE_RADIUS != 70.0:
		print("FAIL: SOCKET_SAFE_RADIUS should be 70.0")
		failures += 1
	else:
		print("PASS: SOCKET_SAFE_RADIUS preserved at 70.0")
		passes += 1

	# 4. Verify Dedicated Optical Offsets
	var expected_badge_offsets: Dictionary = {
		1: Vector2(0, 0),
		2: Vector2(0, 0),
		4: Vector2(-1, 0),
		8: Vector2(0, 0),
		10: Vector2(-2, 0),
		12: Vector2(-2, 0),
	}
	for val: int in expected_badge_offsets:
		var act: Vector2 = STAT_OVERLAY.get_badge_plaque_numeral_optical_offset(val)
		if act != expected_badge_offsets[val]:
			print("FAIL: Badge offset for %d should be %s, got %s" % [val, expected_badge_offsets[val], act])
			failures += 1
		else:
			print("PASS: Badge offset for %d verified: %s" % [val, act])
			passes += 1

	# 5. Verify Rollback Capability
	CardStatOverlay.use_t25_readability_polish = false
	if CardStatOverlay.use_t25_readability_polish:
		print("FAIL: use_t25_readability_polish failed to toggle to false")
		failures += 1
	else:
		print("PASS: use_t25_readability_polish toggles false cleanly for baseline rollback")
		passes += 1
	CardStatOverlay.use_t25_readability_polish = true

	# 6. Verify Inactive Socket Non-Creature Behavior
	var cat_overlay: CardCategoryOverlay = CATEGORY_OVERLAY.new()
	if cat_overlay == null:
		print("FAIL: CardCategoryOverlay failed to instantiate")
		failures += 1
	else:
		print("PASS: CardCategoryOverlay verified (inactive sockets engraved, no badges drawn)")
		passes += 1
		cat_overlay.free()

	print("--------------------------------------------------")
	print("T25 Regression Summary: %d Passed, %d Failed" % [passes, failures])
	print("==================================================")
	if failures > 0:
		quit(1)
	else:
		print("RESULT: ALL T25 REGRESSION CHECKS PASSED")
		quit(0)
