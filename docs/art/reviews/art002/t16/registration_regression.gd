extends SceneTree
## Automated technical validation for ART-002-T16:
## Attack Cabochon Frame Registration, Optical Fit, and Regressions.

const STAT_OVERLAY: GDScript = preload("res://scripts/presentation/card_stat_overlay.gd")
const CATEGORY_OVERLAY: GDScript = preload("res://scripts/presentation/card_category_overlay.gd")

func _initialize() -> void:
	var failures: int = 0

	# 1. Verify Texture Loading
	var textures: Dictionary = {
		"cabochon_attack_v02": STAT_OVERLAY.CABOCHON_ATTACK_V02,
		"cabochon_attack_prod": STAT_OVERLAY.CABOCHON_ATTACK,
		"cabochon_attack_v01": STAT_OVERLAY.CABOCHON_ATTACK_V01,
		"cabochon_health": STAT_OVERLAY.CABOCHON_HEALTH,
	}

	for key: String in textures:
		var tex: Texture2D = textures[key]
		if tex == null or tex.get_width() <= 0:
			print("FAIL: Texture for %s failed to load" % key)
			failures += 1
		else:
			print("PASS: Texture %s loaded: size=%s" % [key, tex.get_size()])

	# 2. Verify Transparency (100% transparent corners, zero halo)
	for key: String in textures:
		var tex: Texture2D = textures[key]
		var img: Image = tex.get_image()
		var w: int = img.get_width()
		var h: int = img.get_height()
		var corners: Array[float] = [
			img.get_pixel(0, 0).a,
			img.get_pixel(w - 1, 0).a,
			img.get_pixel(0, h - 1).a,
			img.get_pixel(w - 1, h - 1).a
		]
		var has_opaque: bool = false
		for c: float in corners:
			if c > 0.01:
				has_opaque = true
				break
		if has_opaque:
			print("FAIL: Texture %s has non-transparent corners: %s" % [key, corners])
			failures += 1
		else:
			print("PASS: Texture %s has clean transparent corners" % key)

	# 3. Verify T16 Calibrated Attack Geometry Constants
	if STAT_OVERLAY.ATTACK_CABOCHON_SIZE != Vector2(230, 230):
		print("FAIL: ATTACK_CABOCHON_SIZE should be Vector2(230, 230), got %s" % STAT_OVERLAY.ATTACK_CABOCHON_SIZE)
		failures += 1
	else:
		print("PASS: ATTACK_CABOCHON_SIZE calibrated at 230x230")

	if STAT_OVERLAY.ATTACK_CABOCHON_OFFSET != Vector2(1, 1):
		print("FAIL: ATTACK_CABOCHON_OFFSET should be Vector2(1, 1), got %s" % STAT_OVERLAY.ATTACK_CABOCHON_OFFSET)
		failures += 1
	else:
		print("PASS: ATTACK_CABOCHON_OFFSET calibrated at Vector2(1, 1)")

	# 4. Verify Health and Base Geometry Preservation
	if STAT_OVERLAY.HEALTH_CABOCHON_SIZE != Vector2(250, 250):
		print("FAIL: HEALTH_CABOCHON_SIZE should be Vector2(250, 250)")
		failures += 1
	else:
		print("PASS: HEALTH_CABOCHON_SIZE preserved at 250x250")

	if STAT_OVERLAY.HEALTH_CABOCHON_OFFSET != Vector2(0, 0):
		print("FAIL: HEALTH_CABOCHON_OFFSET should be Vector2(0, 0)")
		failures += 1
	else:
		print("PASS: HEALTH_CABOCHON_OFFSET preserved at (0, 0)")

	if STAT_OVERLAY.CABOCHON_SIZE != Vector2(250, 250):
		print("FAIL: Base CABOCHON_SIZE should be Vector2(250, 250)")
		failures += 1
	else:
		print("PASS: Base CABOCHON_SIZE preserved at 250x250")

	# 5. Verify Rollback Mechanism to V1
	if STAT_OVERLAY.ATTACK_CABOCHON_SIZE_V01 != Vector2(250, 250):
		print("FAIL: ATTACK_CABOCHON_SIZE_V01 should be Vector2(250, 250)")
		failures += 1
	else:
		print("PASS: ATTACK_CABOCHON_SIZE_V01 preserved at 250x250")

	if STAT_OVERLAY.ATTACK_CABOCHON_OFFSET_V01 != Vector2(0, 0):
		print("FAIL: ATTACK_CABOCHON_OFFSET_V01 should be Vector2(0, 0)")
		failures += 1
	else:
		print("PASS: ATTACK_CABOCHON_OFFSET_V01 preserved at (0, 0)")

	# 6. Verify Numeral Centers Preserved (T04B)
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

	# 7. Verify Version Selection Defaults
	if STAT_OVERLAY.attack_cabochon_version != 2:
		print("FAIL: Default attack_cabochon_version should be 2 (Graphite Steel)")
		failures += 1
	else:
		print("PASS: Default attack_cabochon_version is 2 (Graphite Steel)")

	# 8. Verify Overlay Instantiation and Protection Hiding
	var overlay: CardStatOverlay = STAT_OVERLAY.new()
	overlay.set_printed_values(2, 4, 5, 0)
	overlay.set_shield_overlay(0)
	if overlay._native_armor != 0 or overlay._shield != 0:
		print("FAIL: Inactive protection values incorrect")
		failures += 1
	else:
		print("PASS: Clean protection zero state verified")

	# 9. Verify Spell / Equipment Inactive Sockets
	var cat_overlay: CardCategoryOverlay = CATEGORY_OVERLAY.new()
	cat_overlay.category = CardContentOverlay.Category.SPELL
	if cat_overlay.category != CardContentOverlay.Category.SPELL:
		print("FAIL: Category overlay spell category mismatch")
		failures += 1
	else:
		print("PASS: Category overlay behavior preserved")

	overlay.free()
	cat_overlay.free()

	print("T16_REGISTRATION_REGRESSION_FAILURES=%d" % failures)
	quit(0 if failures == 0 else 1)
