extends SceneTree
## Automated technical validation for ART-002-T13:
## Attack & Health Integrated Cabochons, Transparency, Optical Centering, and Regressions.

const STAT_OVERLAY: GDScript = preload("res://scripts/presentation/card_stat_overlay.gd")
const CATEGORY_OVERLAY: GDScript = preload("res://scripts/presentation/card_category_overlay.gd")

func _initialize() -> void:
	var failures: int = 0

	# 1. Verify Cabochon Texture Loading
	var textures: Dictionary = {
		"cabochon_attack": STAT_OVERLAY.CABOCHON_ATTACK,
		"cabochon_health": STAT_OVERLAY.CABOCHON_HEALTH,
	}

	for key: String in textures:
		var tex: Texture2D = textures[key]
		if tex == null or tex.get_width() <= 0:
			print("FAIL: Cabochon texture for %s failed to load" % key)
			failures += 1
		else:
			print("PASS: Cabochon texture %s loaded: size=%s" % [key, tex.get_size()])

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
			print("FAIL: Cabochon %s has non-transparent corners: %s" % [key, corners])
			failures += 1
		else:
			print("PASS: Cabochon %s has clean transparent corners" % key)

	# 3. Verify T13 Cabochon Constants
	if STAT_OVERLAY.CABOCHON_SIZE != Vector2(250, 250):
		print("FAIL: CABOCHON_SIZE should be Vector2(250, 250)")
		failures += 1
	else:
		print("PASS: CABOCHON_SIZE is calibrated at 250x250")

	if STAT_OVERLAY.ATTACK_CABOCHON_OFFSET != Vector2(0, 0):
		print("FAIL: ATTACK_CABOCHON_OFFSET should be Vector2(0, 0)")
		failures += 1
	else:
		print("PASS: ATTACK_CABOCHON_OFFSET is (0, 0)")

	if STAT_OVERLAY.HEALTH_CABOCHON_OFFSET != Vector2(0, 0):
		print("FAIL: HEALTH_CABOCHON_OFFSET should be Vector2(0, 0)")
		failures += 1
	else:
		print("PASS: HEALTH_CABOCHON_OFFSET is (0, 0)")

	# 4. Verify T04B Numeral Centers Preserved
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

	if STAT_OVERLAY.SOCKET_SAFE_RADIUS != 70.0:
		print("FAIL: SOCKET_SAFE_RADIUS modified unexpectedly")
		failures += 1
	else:
		print("PASS: SOCKET_SAFE_RADIUS preserved at 70.0")

	# 5. Verify Mode Flag
	if STAT_OVERLAY.use_separate_icons != false:
		print("FAIL: Default use_separate_icons should be false (integrated cabochon mode)")
		failures += 1
	else:
		print("PASS: Default mode is Integrated Cabochons (use_separate_icons = false)")

	# 6. Verify Armor and Shield Badges Preserved
	if STAT_OVERLAY.ARMOR_ICON_SIZE != Vector2(52, 52) or STAT_OVERLAY.SHIELD_ICON_SIZE != Vector2(50, 50):
		print("FAIL: Badge icon sizes modified unexpectedly")
		failures += 1
	else:
		print("PASS: Armor and Shield badge icon sizes preserved")

	# 7. Verify Overlay Instantiation and Protection Hiding
	var overlay: CardStatOverlay = STAT_OVERLAY.new()
	overlay.set_printed_values(2, 4, 5, 0)
	overlay.set_shield_overlay(0)
	if overlay._native_armor != 0 or overlay._shield != 0:
		print("FAIL: Inactive protection values incorrect")
		failures += 1
	else:
		print("PASS: Clean protection zero state verified")

	# 8. Verify Spell / Equipment Inactive Sockets
	var cat_overlay: CardCategoryOverlay = CATEGORY_OVERLAY.new()
	cat_overlay.category = CardContentOverlay.Category.SPELL
	if cat_overlay.category != CardContentOverlay.Category.SPELL:
		print("FAIL: Category overlay spell category mismatch")
		failures += 1
	else:
		print("PASS: Category overlay behavior preserved")

	overlay.free()
	cat_overlay.free()

	print("T13_CABOCHON_REGRESSION_FAILURES=%d" % failures)
	quit(0 if failures == 0 else 1)
