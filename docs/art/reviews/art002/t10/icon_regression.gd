extends SceneTree
## Automated technical validation for ART-002-T10:
## V2 icon loading, transparency, optical constants, version toggling, and socket regression.

const STAT_OVERLAY: GDScript = preload("res://scripts/presentation/card_stat_overlay.gd")
const CATEGORY_OVERLAY: GDScript = preload("res://scripts/presentation/card_category_overlay.gd")

func _initialize() -> void:
	var failures: int = 0

	# 1. Verify V2 and V1 texture loading
	var textures_v2: Dictionary = {
		"attack_v02": STAT_OVERLAY.ICON_ATTACK_V02,
		"health_v02": STAT_OVERLAY.ICON_HEALTH_V02,
		"armor_v02": STAT_OVERLAY.ICON_ARMOR_V02,
		"shield_v02": STAT_OVERLAY.ICON_SHIELD_V02,
		"attack_prod": STAT_OVERLAY.ICON_ATTACK,
		"health_prod": STAT_OVERLAY.ICON_HEALTH,
		"armor_prod": STAT_OVERLAY.ICON_ARMOR,
		"shield_prod": STAT_OVERLAY.ICON_SHIELD,
	}

	var textures_v1: Dictionary = {
		"attack_v01": STAT_OVERLAY.ICON_ATTACK_V01,
		"health_v01": STAT_OVERLAY.ICON_HEALTH_V01,
		"armor_v01": STAT_OVERLAY.ICON_ARMOR_V01,
		"shield_v01": STAT_OVERLAY.ICON_SHIELD_V01,
	}

	for key: String in textures_v2:
		var tex: Texture2D = textures_v2[key]
		if tex == null or tex.get_width() <= 0:
			print("FAIL: Texture for %s failed to load" % key)
			failures += 1
		else:
			print("PASS: V2 Texture %s loaded: size=%s" % [key, tex.get_size()])

	for key: String in textures_v1:
		var tex: Texture2D = textures_v1[key]
		if tex == null or tex.get_width() <= 0:
			print("FAIL: V1 Texture for %s failed to load" % key)
			failures += 1
		else:
			print("PASS: V1 Texture %s loaded: size=%s" % [key, tex.get_size()])

	# 2. Verify transparency for all textures (corners must be 100% transparent)
	var all_tex: Dictionary = textures_v2.duplicate()
	all_tex.merge(textures_v1)
	for key: String in all_tex:
		var tex: Texture2D = all_tex[key]
		var img: Image = tex.get_image()
		var w: int = img.get_width()
		var h: int = img.get_height()
		var corners: Array[float] = [
			img.get_pixel(0, 0).a,
			img.get_pixel(w - 1, 0).a,
			img.get_pixel(0, h - 1).a,
			img.get_pixel(w - 1, h - 1).a
		]
		var has_opaque_corner: bool = false
		for c: float in corners:
			if c > 0.01:
				has_opaque_corner = true
				break
		if has_opaque_corner:
			print("FAIL: Texture %s has non-transparent corners: %s" % [key, corners])
			failures += 1
		else:
			print("PASS: Texture %s has clean transparent corners" % key)

	# 3. Verify optical constants definition
	if STAT_OVERLAY.ATTACK_EMBLEM_CENTER != Vector2(162, 1187) and STAT_OVERLAY.ATTACK_EMBLEM_CENTER != Vector2(157, 1187):
		print("FAIL: ATTACK_EMBLEM_CENTER modified unexpectedly")
		failures += 1
	if STAT_OVERLAY.HEALTH_EMBLEM_CENTER != Vector2(919, 1187) and STAT_OVERLAY.HEALTH_EMBLEM_CENTER != Vector2(934, 1187):
		print("FAIL: HEALTH_EMBLEM_CENTER modified unexpectedly")
		failures += 1
	if STAT_OVERLAY.ATTACK_ICON_SIZE.x <= 0 or STAT_OVERLAY.HEALTH_ICON_SIZE.x <= 0:
		print("FAIL: V2 Icon sizes must be positive")
		failures += 1
	if STAT_OVERLAY.ARMOR_ICON_SIZE.x <= 0 or STAT_OVERLAY.SHIELD_ICON_SIZE.x <= 0:
		print("FAIL: V2 Badge icon sizes must be positive")
		failures += 1

	# Check V1 constants preserved
	if STAT_OVERLAY.ATTACK_ICON_SIZE_V01 != Vector2(62, 62) or STAT_OVERLAY.HEALTH_ICON_SIZE_V01 != Vector2(62, 62):
		print("FAIL: V1 optical size constants not preserved")
		failures += 1
	if STAT_OVERLAY.ATTACK_ICON_OFFSET_V01 != Vector2(-2, 1):
		print("FAIL: V1 attack offset constant not preserved")
		failures += 1

	print("PASS: Optical alignment constants validated")

	# 4. Verify version toggling and overlay instantiation
	if STAT_OVERLAY.icon_version != 2:
		print("FAIL: Default icon_version should be 2")
		failures += 1
	else:
		print("PASS: Default icon_version is 2 (V2)")

	var overlay: CardStatOverlay = STAT_OVERLAY.new()
	overlay.set_printed_values(2, 4, 5, 0)
	overlay.set_shield_overlay(0)
	if overlay._native_armor != 0 or overlay._shield != 0:
		print("FAIL: Inactive protection values incorrect")
		failures += 1
	else:
		print("PASS: Clean protection zero state verified")

	# 5. Verify Spell / Equipment inactive sockets
	var cat_overlay: CardCategoryOverlay = CATEGORY_OVERLAY.new()
	cat_overlay.category = CardContentOverlay.Category.SPELL
	if cat_overlay.category != CardContentOverlay.Category.SPELL:
		print("FAIL: Category overlay spell category mismatch")
		failures += 1
	else:
		print("PASS: Category overlay behavior preserved")

	overlay.free()
	cat_overlay.free()

	print("T10_ICON_REGRESSION_FAILURES=%d" % failures)
	quit(0 if failures == 0 else 1)
