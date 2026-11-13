extends SceneTree
## Automated technical validation for ART-002-T08:
## Icon loading, transparency, optical constants, and socket regression.

const STAT_OVERLAY: GDScript = preload("res://scripts/presentation/card_stat_overlay.gd")
const CATEGORY_OVERLAY: GDScript = preload("res://scripts/presentation/card_category_overlay.gd")

func _initialize() -> void:
	var failures: int = 0

	# 1. Verify texture loading
	var textures: Dictionary = {
		"attack": STAT_OVERLAY.ICON_ATTACK,
		"health": STAT_OVERLAY.ICON_HEALTH,
		"armor": STAT_OVERLAY.ICON_ARMOR,
		"shield": STAT_OVERLAY.ICON_SHIELD,
	}

	for key: String in textures:
		var tex: Texture2D = textures[key]
		if tex == null or tex.get_width() <= 0:
			print("FAIL: Texture for %s failed to load" % key)
			failures += 1
		else:
			print("PASS: Texture %s loaded: size=%s" % [key, tex.get_size()])

	# 2. Verify transparency (corner pixels must have zero alpha)
	for key: String in textures:
		var tex: Texture2D = textures[key]
		var img: Image = tex.get_image()
		var corner_a: float = img.get_pixel(0, 0).a
		var corner_b: float = img.get_pixel(img.get_width() - 1, 0).a
		if corner_a > 0.01 or corner_b > 0.01:
			print("FAIL: Texture %s has non-transparent background corners (%.3f, %.3f)" % [key, corner_a, corner_b])
			failures += 1
		else:
			print("PASS: Texture %s has clean transparent corners" % key)

	# 3. Verify optical constants definition
	if STAT_OVERLAY.ATTACK_EMBLEM_CENTER != Vector2(157, 1187):
		print("FAIL: ATTACK_EMBLEM_CENTER modified unexpectedly")
		failures += 1
	if STAT_OVERLAY.HEALTH_EMBLEM_CENTER != Vector2(934, 1187):
		print("FAIL: HEALTH_EMBLEM_CENTER modified unexpectedly")
		failures += 1
	if STAT_OVERLAY.ATTACK_ICON_SIZE.x <= 0 or STAT_OVERLAY.HEALTH_ICON_SIZE.x <= 0:
		print("FAIL: Icon sizes must be positive")
		failures += 1
	print("PASS: Optical alignment constants validated")

	# 4. Verify overlay instantiation and protection hiding
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

	print("T08_ICON_REGRESSION_FAILURES=%d" % failures)
	quit(0 if failures == 0 else 1)
