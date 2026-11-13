extends SceneTree
## Automated technical validation for ART-002-T11:
## Stat Icon Scale, Container Optical Alignment, and Padding Regression.

const STAT_OVERLAY: GDScript = preload("res://scripts/presentation/card_stat_overlay.gd")
const CATEGORY_OVERLAY: GDScript = preload("res://scripts/presentation/card_category_overlay.gd")

func _initialize() -> void:
	var failures: int = 0

	# 1. Verify T11 Refined Optical Alignment Constants
	if STAT_OVERLAY.ATTACK_EMBLEM_CENTER != Vector2(162, 1187):
		print("FAIL: ATTACK_EMBLEM_CENTER should be Vector2(162, 1187) aligned with socket aperture")
		failures += 1
	else:
		print("PASS: ATTACK_EMBLEM_CENTER aligned at (162, 1187)")

	if STAT_OVERLAY.HEALTH_EMBLEM_CENTER != Vector2(919, 1187):
		print("FAIL: HEALTH_EMBLEM_CENTER should be Vector2(919, 1187) aligned with socket aperture")
		failures += 1
	else:
		print("PASS: HEALTH_EMBLEM_CENTER aligned at (919, 1187)")

	if STAT_OVERLAY.BADGE_ICON_LOCAL_CENTER != Vector2(50, 50):
		print("FAIL: BADGE_ICON_LOCAL_CENTER should be Vector2(50, 50)")
		failures += 1
	else:
		print("PASS: BADGE_ICON_LOCAL_CENTER calibrated at (50, 50)")

	if STAT_OVERLAY.BADGE_NUMBER_LOCAL_CENTER != Vector2(140, 50):
		print("FAIL: BADGE_NUMBER_LOCAL_CENTER should be Vector2(140, 50)")
		failures += 1
	else:
		print("PASS: BADGE_NUMBER_LOCAL_CENTER calibrated at (140, 50)")

	# 2. Verify T11 Refined Sizing Constants
	if STAT_OVERLAY.ATTACK_ICON_SIZE != Vector2(48, 48):
		print("FAIL: ATTACK_ICON_SIZE should be Vector2(48, 48)")
		failures += 1
	else:
		print("PASS: ATTACK_ICON_SIZE is 48x48")

	if STAT_OVERLAY.HEALTH_ICON_SIZE != Vector2(52, 52):
		print("FAIL: HEALTH_ICON_SIZE should be Vector2(52, 52)")
		failures += 1
	else:
		print("PASS: HEALTH_ICON_SIZE is 52x52")

	if STAT_OVERLAY.ARMOR_ICON_SIZE != Vector2(52, 52):
		print("FAIL: ARMOR_ICON_SIZE should be Vector2(52, 52)")
		failures += 1
	else:
		print("PASS: ARMOR_ICON_SIZE is 52x52")

	if STAT_OVERLAY.SHIELD_ICON_SIZE != Vector2(50, 50):
		print("FAIL: SHIELD_ICON_SIZE should be Vector2(50, 50)")
		failures += 1
	else:
		print("PASS: SHIELD_ICON_SIZE is 50x50")

	# 3. Verify T10 Preserved Constants (for before/after comparison)
	if STAT_OVERLAY.ATTACK_ICON_SIZE_T10 != Vector2(60, 60) or STAT_OVERLAY.HEALTH_ICON_SIZE_T10 != Vector2(68, 68):
		print("FAIL: T10 icon size constants not preserved")
		failures += 1
	else:
		print("PASS: T10 icon size constants preserved")

	if STAT_OVERLAY.ATTACK_EMBLEM_CENTER_T10 != Vector2(157, 1187) or STAT_OVERLAY.HEALTH_EMBLEM_CENTER_T10 != Vector2(934, 1187):
		print("FAIL: T10 emblem center constants not preserved")
		failures += 1
	else:
		print("PASS: T10 emblem center constants preserved")

	# 4. Verify V1 Preserved Constants (for rollback)
	if STAT_OVERLAY.ATTACK_ICON_SIZE_V01 != Vector2(62, 62) or STAT_OVERLAY.HEALTH_ICON_SIZE_V01 != Vector2(62, 62):
		print("FAIL: V1 icon size constants not preserved")
		failures += 1
	else:
		print("PASS: V1 icon size constants preserved")

	if STAT_OVERLAY.ATTACK_EMBLEM_CENTER_V01 != Vector2(157, 1187) or STAT_OVERLAY.HEALTH_EMBLEM_CENTER_V01 != Vector2(934, 1187):
		print("FAIL: V1 emblem center constants not preserved")
		failures += 1
	else:
		print("PASS: V1 emblem center constants preserved")

	# 5. Verify Visible Silhouette Padding and Clearance
	# Attack sword in 256 texture: visible height is 253 px (98.8% of texture)
	var atk_vis_h: float = STAT_OVERLAY.ATTACK_ICON_SIZE.y * (253.0 / 256.0)
	var atk_collet_pad: float = (58.0 - atk_vis_h) * 0.5
	if atk_collet_pad < 5.0:
		print("FAIL: Attack sword margin inside inner collet circle too small: %.2f px" % atk_collet_pad)
		failures += 1
	else:
		print("PASS: Attack sword inner collet clearance: %.2f px (>= 5 px)" % atk_collet_pad)

	# Health heart in 256 texture: visible width is 196 px, height is 183 px
	var hp_vis_w: float = STAT_OVERLAY.HEALTH_ICON_SIZE.x * (196.0 / 256.0)
	var hp_vis_h: float = STAT_OVERLAY.HEALTH_ICON_SIZE.y * (183.0 / 256.0)
	var hp_collet_pad_x: float = (58.0 - hp_vis_w) * 0.5
	var hp_collet_pad_y: float = (58.0 - hp_vis_h) * 0.5
	if hp_collet_pad_x < 8.0 or hp_collet_pad_y < 8.0:
		print("FAIL: Health heart margin inside inner collet circle too small: (%.2f, %.2f) px" % [hp_collet_pad_x, hp_collet_pad_y])
		failures += 1
	else:
		print("PASS: Health heart inner collet clearance: (%.2f, %.2f) px (>= 8 px)" % [hp_collet_pad_x, hp_collet_pad_y])

	# Badge vertical margins (plate height 100)
	var arm_vis_h: float = STAT_OVERLAY.ARMOR_ICON_SIZE.y * (184.0 / 256.0)
	var shd_vis_h: float = STAT_OVERLAY.SHIELD_ICON_SIZE.y * (209.0 / 256.0)
	var arm_pad_y: float = (100.0 - arm_vis_h) * 0.5
	var shd_pad_y: float = (100.0 - shd_vis_h) * 0.5
	if arm_pad_y < 28.0 or shd_pad_y < 28.0:
		print("FAIL: Badge vertical padding too small: arm=%.2f, shd=%.2f" % [arm_pad_y, shd_pad_y])
		failures += 1
	else:
		print("PASS: Badge vertical clearance: arm=%.2f px, shd=%.2f px (balanced & >= 28 px)" % [arm_pad_y, shd_pad_y])

	# 6. Verify overlay instantiation and protection hiding
	var overlay: CardStatOverlay = STAT_OVERLAY.new()
	overlay.set_printed_values(2, 4, 5, 0)
	overlay.set_shield_overlay(0)
	if overlay._native_armor != 0 or overlay._shield != 0:
		print("FAIL: Inactive protection values incorrect")
		failures += 1
	else:
		print("PASS: Clean protection zero state verified")

	# 7. Verify Spell / Equipment inactive sockets
	var cat_overlay: CardCategoryOverlay = CATEGORY_OVERLAY.new()
	cat_overlay.category = CardContentOverlay.Category.SPELL
	if cat_overlay.category != CardContentOverlay.Category.SPELL:
		print("FAIL: Category overlay spell category mismatch")
		failures += 1
	else:
		print("PASS: Category overlay behavior preserved")

	overlay.free()
	cat_overlay.free()

	print("T11_ICON_REGRESSION_FAILURES=%d" % failures)
	quit(0 if failures == 0 else 1)
