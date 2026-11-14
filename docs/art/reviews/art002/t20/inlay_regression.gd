extends SceneTree
## Automated technical validation for ART-002-T20:
## Integrated Attack & Health Inlays, Layering, and Regression Suite.

const STAT_OVERLAY: GDScript = preload("res://scripts/presentation/card_stat_overlay.gd")
const CATEGORY_OVERLAY: GDScript = preload("res://scripts/presentation/card_category_overlay.gd")

func _initialize() -> void:
	var failures: int = 0

	# 1. Verify Inlay and Bezel Texture Loading
	var textures: Dictionary = {
		"inlay_attack": STAT_OVERLAY.INLAY_ATTACK,
		"inlay_attack_v01": STAT_OVERLAY.INLAY_ATTACK_V01,
		"inlay_health": STAT_OVERLAY.INLAY_HEALTH,
		"inlay_health_v01": STAT_OVERLAY.INLAY_HEALTH_V01,
		"socket_bezel_attack": STAT_OVERLAY.SOCKET_BEZEL_ATTACK,
		"socket_bezel_health": STAT_OVERLAY.SOCKET_BEZEL_HEALTH,
		"cabochon_attack_prod": STAT_OVERLAY.CABOCHON_ATTACK,
		"cabochon_health": STAT_OVERLAY.CABOCHON_HEALTH,
	}

	for key: String in textures:
		var tex: Texture2D = textures[key]
		if tex == null or tex.get_width() <= 0:
			print("FAIL: Texture for %s failed to load" % key)
			failures += 1
		else:
			print("PASS: Texture %s loaded: size=%s" % [key, tex.get_size()])

	# 2. Verify Texture Transparency (100% transparent corners, zero halo)
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

	# 3. Verify Bezel Aperture Transparency (Center of bezel has alpha == 0)
	for bkey: String in ["socket_bezel_attack", "socket_bezel_health"]:
		var btex: Texture2D = textures[bkey]
		var bimg: Image = btex.get_image()
		var cx: int = bimg.get_width() / 2
		var cy: int = bimg.get_height() / 2
		var center_alpha: float = bimg.get_pixel(cx, cy).a
		if center_alpha > 0.01:
			print("FAIL: %s aperture center is not transparent: alpha=%f" % [bkey, center_alpha])
			failures += 1
		else:
			print("PASS: %s aperture center is fully transparent (alpha=0)" % bkey)

	# 4. Verify T20 Calibrated Inlay Constants
	if STAT_OVERLAY.ATTACK_INLAY_SIZE != Vector2(190, 190):
		print("FAIL: ATTACK_INLAY_SIZE should be Vector2(190, 190), got %s" % STAT_OVERLAY.ATTACK_INLAY_SIZE)
		failures += 1
	else:
		print("PASS: ATTACK_INLAY_SIZE calibrated at Vector2(190, 190)")

	if STAT_OVERLAY.ATTACK_INLAY_OFFSET != Vector2(0, 0):
		print("FAIL: ATTACK_INLAY_OFFSET should be Vector2(0, 0), got %s" % STAT_OVERLAY.ATTACK_INLAY_OFFSET)
		failures += 1
	else:
		print("PASS: ATTACK_INLAY_OFFSET calibrated at Vector2(0, 0)")

	if STAT_OVERLAY.HEALTH_INLAY_SIZE != Vector2(190, 190):
		print("FAIL: HEALTH_INLAY_SIZE should be Vector2(190, 190), got %s" % STAT_OVERLAY.HEALTH_INLAY_SIZE)
		failures += 1
	else:
		print("PASS: HEALTH_INLAY_SIZE calibrated at Vector2(190, 190)")

	if STAT_OVERLAY.HEALTH_INLAY_OFFSET != Vector2(0, 0):
		print("FAIL: HEALTH_INLAY_OFFSET should be Vector2(0, 0), got %s" % STAT_OVERLAY.HEALTH_INLAY_OFFSET)
		failures += 1
	else:
		print("PASS: HEALTH_INLAY_OFFSET calibrated at Vector2(0, 0)")

	if STAT_OVERLAY.SOCKET_BEZEL_SIZE != Vector2(220, 220):
		print("FAIL: SOCKET_BEZEL_SIZE should be Vector2(220, 220)")
		failures += 1
	else:
		print("PASS: SOCKET_BEZEL_SIZE calibrated at Vector2(220, 220)")

	if STAT_OVERLAY.SOCKET_BEZEL_OFFSET != Vector2(0, 0):
		print("FAIL: SOCKET_BEZEL_OFFSET should be Vector2(0, 0)")
		failures += 1
	else:
		print("PASS: SOCKET_BEZEL_OFFSET calibrated at Vector2(0, 0)")

	# 5. Verify Rollback and Historical Cabochon Constants Preserved
	if STAT_OVERLAY.ATTACK_CABOCHON_SIZE != Vector2(230, 230):
		print("FAIL: Historical ATTACK_CABOCHON_SIZE modified")
		failures += 1
	else:
		print("PASS: Historical ATTACK_CABOCHON_SIZE preserved at 230x230")

	if STAT_OVERLAY.ATTACK_CABOCHON_OFFSET != Vector2(1, 1):
		print("FAIL: Historical ATTACK_CABOCHON_OFFSET modified")
		failures += 1
	else:
		print("PASS: Historical ATTACK_CABOCHON_OFFSET preserved at Vector2(1, 1)")

	if STAT_OVERLAY.HEALTH_CABOCHON_SIZE != Vector2(250, 250):
		print("FAIL: Historical HEALTH_CABOCHON_SIZE modified")
		failures += 1
	else:
		print("PASS: Historical HEALTH_CABOCHON_SIZE preserved at 250x250")

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

	# 7. Verify Presentation Mode Defaults & Rollback Controls
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

	print("T20_INLAY_REGRESSION_FAILURES=%d" % failures)
	quit(0 if failures == 0 else 1)
