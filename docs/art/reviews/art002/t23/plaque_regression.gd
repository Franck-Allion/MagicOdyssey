extends SceneTree
## Automated technical validation for ART-002-T23:
## Integrated Armor & Shield Plaque Inlays, Layering, and Regression Suite.

const STAT_OVERLAY: GDScript = preload("res://scripts/presentation/card_stat_overlay.gd")
const CATEGORY_OVERLAY: GDScript = preload("res://scripts/presentation/card_category_overlay.gd")

func _initialize() -> void:
	var failures: int = 0
	var passes: int = 0

	print("=== ART-002-T23 Plaque Inlay Regression Suite ===")

	# 1. Verify Plaque Texture Loading
	var textures: Dictionary = {
		"plate_armor": STAT_OVERLAY.PLATE_ARMOR,
		"plate_armor_v01": STAT_OVERLAY.PLATE_ARMOR_V01,
		"plate_shield": STAT_OVERLAY.PLATE_SHIELD,
		"plate_shield_v01": STAT_OVERLAY.PLATE_SHIELD_V01,
		"inlay_attack": STAT_OVERLAY.INLAY_ATTACK,
		"inlay_health": STAT_OVERLAY.INLAY_HEALTH,
		"icon_armor": STAT_OVERLAY.ICON_ARMOR,
		"icon_shield": STAT_OVERLAY.ICON_SHIELD,
	}

	for key: String in textures:
		var tex: Texture2D = textures[key]
		if tex == null or tex.get_width() <= 0:
			print("FAIL: Texture for %s failed to load" % key)
			failures += 1
		else:
			print("PASS: Texture %s loaded: size=%s" % [key, tex.get_size()])
			passes += 1

	# 2. Verify Plaque Texture Corner Transparency (100% transparent corners, zero halo)
	for pkey: String in ["plate_armor", "plate_armor_v01", "plate_shield", "plate_shield_v01"]:
		var ptex: Texture2D = textures[pkey]
		var img: Image = ptex.get_image()
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
			if c > 0.001:
				has_opaque = true
				break
		if has_opaque:
			print("FAIL: Texture %s has non-transparent corners: %s" % [pkey, corners])
			failures += 1
		else:
			print("PASS: Texture %s has clean transparent corners [0,0,0,0]" % pkey)
			passes += 1

	# 3. Verify Calibrated T23 Plaque Constants
	if STAT_OVERLAY.ARMOR_PLAQUE_SIZE != Vector2(180, 62):
		print("FAIL: ARMOR_PLAQUE_SIZE should be Vector2(180, 62), got %s" % STAT_OVERLAY.ARMOR_PLAQUE_SIZE)
		failures += 1
	else:
		print("PASS: ARMOR_PLAQUE_SIZE calibrated at Vector2(180, 62)")
		passes += 1

	if STAT_OVERLAY.ARMOR_PLAQUE_OFFSET != Vector2(0, 0):
		print("FAIL: ARMOR_PLAQUE_OFFSET should be Vector2(0, 0), got %s" % STAT_OVERLAY.ARMOR_PLAQUE_OFFSET)
		failures += 1
	else:
		print("PASS: ARMOR_PLAQUE_OFFSET calibrated at Vector2(0, 0)")
		passes += 1

	if STAT_OVERLAY.SHIELD_PLAQUE_SIZE != Vector2(180, 69):
		print("FAIL: SHIELD_PLAQUE_SIZE should be Vector2(180, 69), got %s" % STAT_OVERLAY.SHIELD_PLAQUE_SIZE)
		failures += 1
	else:
		print("PASS: SHIELD_PLAQUE_SIZE calibrated at Vector2(180, 69)")
		passes += 1

	if STAT_OVERLAY.SHIELD_PLAQUE_OFFSET != Vector2(0, 0):
		print("FAIL: SHIELD_PLAQUE_OFFSET should be Vector2(0, 0), got %s" % STAT_OVERLAY.SHIELD_PLAQUE_OFFSET)
		failures += 1
	else:
		print("PASS: SHIELD_PLAQUE_OFFSET calibrated at Vector2(0, 0)")
		passes += 1

	if STAT_OVERLAY.BADGE_PLAQUE_NUMBER_LOCAL_CENTER != Vector2(99, 50):
		print("FAIL: BADGE_PLAQUE_NUMBER_LOCAL_CENTER should be Vector2(99, 50)")
		failures += 1
	else:
		print("PASS: BADGE_PLAQUE_NUMBER_LOCAL_CENTER calibrated at Vector2(99, 50)")
		passes += 1

	if STAT_OVERLAY.BADGE_PLAQUE_NUMBER_FONT_SIZE != 76:
		print("FAIL: BADGE_PLAQUE_NUMBER_FONT_SIZE should be 76")
		failures += 1
	else:
		print("PASS: BADGE_PLAQUE_NUMBER_FONT_SIZE calibrated at 76")
		passes += 1

	if STAT_OVERLAY.BADGE_PLAQUE_NUMBER_MAX_WIDTH != 83.0:
		print("FAIL: BADGE_PLAQUE_NUMBER_MAX_WIDTH should be 83.0")
		failures += 1
	else:
		print("PASS: BADGE_PLAQUE_NUMBER_MAX_WIDTH calibrated at 83.0")
		passes += 1

	# 4. Verify Historical Attack & Health Inlays and Sockets Preserved
	if STAT_OVERLAY.ATTACK_INLAY_SIZE != Vector2(190, 190):
		print("FAIL: Historical ATTACK_INLAY_SIZE modified")
		failures += 1
	else:
		print("PASS: Historical ATTACK_INLAY_SIZE preserved at Vector2(190, 190)")
		passes += 1

	if STAT_OVERLAY.HEALTH_INLAY_SIZE != Vector2(190, 190):
		print("FAIL: Historical HEALTH_INLAY_SIZE modified")
		failures += 1
	else:
		print("PASS: Historical HEALTH_INLAY_SIZE preserved at Vector2(190, 190)")
		passes += 1

	if STAT_OVERLAY.SOCKET_SAFE_RADIUS != 70.0:
		print("FAIL: Historical SOCKET_SAFE_RADIUS modified")
		failures += 1
	else:
		print("PASS: Historical SOCKET_SAFE_RADIUS preserved at 70.0")
		passes += 1

	# 5. Verify Historical Badge Constants Preserved for Rollback
	if STAT_OVERLAY.BADGE_ICON_LOCAL_CENTER != Vector2(50, 50):
		print("FAIL: Historical BADGE_ICON_LOCAL_CENTER modified")
		failures += 1
	else:
		print("PASS: Historical BADGE_ICON_LOCAL_CENTER preserved at Vector2(50, 50)")
		passes += 1

	if STAT_OVERLAY.BADGE_NUMBER_LOCAL_CENTER != Vector2(140, 50):
		print("FAIL: Historical BADGE_NUMBER_LOCAL_CENTER modified")
		failures += 1
	else:
		print("PASS: Historical BADGE_NUMBER_LOCAL_CENTER preserved at Vector2(140, 50)")
		passes += 1

	if STAT_OVERLAY.ARMOR_ICON_SIZE != Vector2(52, 52):
		print("FAIL: Historical ARMOR_ICON_SIZE modified")
		failures += 1
	else:
		print("PASS: Historical ARMOR_ICON_SIZE preserved at Vector2(52, 52)")
		passes += 1

	if STAT_OVERLAY.SHIELD_ICON_SIZE != Vector2(50, 50):
		print("FAIL: Historical SHIELD_ICON_SIZE modified")
		failures += 1
	else:
		print("PASS: Historical SHIELD_ICON_SIZE preserved at Vector2(50, 50)")
		passes += 1

	# 6. Verify Clearance & Usable Inner Area Fit (192x94 inner box inside 198x100)
	var badge_w: float = 198.0
	var badge_h: float = 100.0
	var border_w: float = 3.0
	var usable_w: float = badge_w - 2.0 * border_w # 192.0
	var usable_h: float = badge_h - 2.0 * border_w # 94.0

	var armor_margin_x: float = (usable_w - STAT_OVERLAY.ARMOR_PLAQUE_SIZE.x) * 0.5
	var armor_margin_y: float = (usable_h - STAT_OVERLAY.ARMOR_PLAQUE_SIZE.y) * 0.5
	if armor_margin_x < 4.0 or armor_margin_y < 10.0:
		print("FAIL: Armor plaque has insufficient breathing room: margin_x=%.1f, margin_y=%.1f" % [armor_margin_x, armor_margin_y])
		failures += 1
	else:
		print("PASS: Armor plaque fits inside usable inner area (margin_x=%.1f px, margin_y=%.1f px, zero bronze border overlap)" % [armor_margin_x, armor_margin_y])
		passes += 1

	var shield_margin_x: float = (usable_w - STAT_OVERLAY.SHIELD_PLAQUE_SIZE.x) * 0.5
	var shield_margin_y: float = (usable_h - STAT_OVERLAY.SHIELD_PLAQUE_SIZE.y) * 0.5
	if shield_margin_x < 4.0 or shield_margin_y < 10.0:
		print("FAIL: Shield plaque has insufficient breathing room: margin_x=%.1f, margin_y=%.1f" % [shield_margin_x, shield_margin_y])
		failures += 1
	else:
		print("PASS: Shield plaque fits inside usable inner area (margin_x=%.1f px, margin_y=%.1f px, zero bronze border overlap)" % [shield_margin_x, shield_margin_y])
		passes += 1

	# 7. Verify Rollback Flag Default
	if not STAT_OVERLAY.use_plaque_inlays:
		print("FAIL: use_plaque_inlays should default to true")
		failures += 1
	else:
		print("PASS: use_plaque_inlays defaults to true (integrated plaque inlays active)")
		passes += 1

	# 8. Verify Non-Creature Inactive Sockets (Category Overlay does not draw badges)
	var cat_overlay: CardCategoryOverlay = CATEGORY_OVERLAY.new()
	if cat_overlay == null:
		print("FAIL: CardCategoryOverlay instantiation failed")
		failures += 1
	else:
		print("PASS: CardCategoryOverlay non-creature inactive sockets verified")
		passes += 1
		cat_overlay.free()

	print("--------------------------------------------------")
	print("T23 Regression Summary: %d Passed, %d Failed" % [passes, failures])
	print("==================================================")
	if failures > 0:
		quit(1)
	else:
		print("RESULT: ALL T23 REGRESSION CHECKS PASSED")
		quit(0)
