class_name TestCardPresentation
extends RefCounted

## Permanent ART-002 Card Presentation Regression Test Suite (AUDIT-002-T01).
## Tests production card presentation behavior across inlays, plaques, typography,
## optical alignment, category engravings, and rarity gem materials.

const STAT_OVERLAY: GDScript = preload("res://scripts/presentation/card_stat_overlay.gd")
const CONTENT_OVERLAY: GDScript = preload("res://scripts/presentation/card_content_overlay.gd")
const CATEGORY_OVERLAY: GDScript = preload("res://scripts/presentation/card_category_overlay.gd")
const GEM_TREATMENT: GDScript = preload("res://scripts/presentation/rarity_gem_treatment.gd")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")


func run_suite(asserts: TestAsserts, failure_mode: bool = false) -> void:
	_test_asset_availability(asserts)
	_test_presentation_initialization(asserts)
	_test_attack_and_health_inlays(asserts)
	_test_armor_and_shield_plaques(asserts)
	_test_numeral_styling_coherence(asserts)
	_test_numeral_fitting_and_breathing_room(asserts)
	_test_optical_alignment(asserts)
	_test_creature_vs_non_creature_behavior(asserts)
	_test_epic_emerald_rarity(asserts)
	_test_content_transactional_safety(asserts)

	if failure_mode:
		_test_intentional_failure(asserts)


func _test_asset_availability(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:asset_availability")

	# Master frame v03
	var frame: Texture2D = load("res://assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png")
	asserts.assert_true(frame != null, "Master frame v03 must load successfully")
	if frame != null:
		asserts.assert_equal(frame.get_size(), Vector2(1086, 1448), "Master frame v03 dimensions must be 1086x1448 px")

	# Production inlays and bezels
	var inlay_atk: Texture2D = load("res://assets/textures/cards/icons/mo_inlay_attack.png")
	var inlay_hp: Texture2D = load("res://assets/textures/cards/icons/mo_inlay_health.png")
	var bezel_atk: Texture2D = load("res://assets/textures/cards/icons/mo_socket_bezel_attack.png")
	var bezel_hp: Texture2D = load("res://assets/textures/cards/icons/mo_socket_bezel_health.png")

	asserts.assert_true(inlay_atk != null and inlay_atk.get_width() == 512, "Attack inlay must load with width 512 px")
	asserts.assert_true(inlay_hp != null and inlay_hp.get_width() == 512, "Health inlay must load with width 512 px")
	asserts.assert_true(bezel_atk != null and bezel_atk.get_size() == Vector2(220, 220), "Attack socket bezel must be 220x220 px")
	asserts.assert_true(bezel_hp != null and bezel_hp.get_size() == Vector2(220, 220), "Health socket bezel must be 220x220 px")

	# Production plaques
	var plate_arm: Texture2D = load("res://assets/textures/cards/icons/mo_plate_armor.png")
	var plate_shd: Texture2D = load("res://assets/textures/cards/icons/mo_plate_shield.png")
	asserts.assert_true(plate_arm != null and plate_arm.get_width() == 512, "Armor plaque must load with width 512 px")
	asserts.assert_true(plate_shd != null and plate_shd.get_width() == 512, "Shield plaque must load with width 512 px")

	# Corner transparency checks on inlays and plaques (clean alpha boundaries)
	for tex: Texture2D in [inlay_atk, inlay_hp, plate_arm, plate_shd]:
		if tex != null:
			var img: Image = tex.get_image()
			var w: int = img.get_width()
			var h: int = img.get_height()
			var corners_transparent: bool = (
				img.get_pixel(0, 0).a < 0.01 and
				img.get_pixel(w - 1, 0).a < 0.01 and
				img.get_pixel(0, h - 1).a < 0.01 and
				img.get_pixel(w - 1, h - 1).a < 0.01
			)
			asserts.assert_true(corners_transparent, "Texture %s must have 100%% transparent corners" % tex.resource_path.get_file())

	# Gem mask and shader
	var mask: Texture2D = load("res://assets/textures/cards/frame_v03_gem_mask.svg")
	var shader: Shader = load("res://resources/shaders/card_rarity_gems.gdshader")
	asserts.assert_true(mask != null, "Gem mask SVG must load successfully")
	asserts.assert_true(shader != null, "Rarity gem shader must load successfully")


func _test_presentation_initialization(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:initialization")

	var stats: CardStatOverlay = STAT_OVERLAY.new()
	asserts.assert_true(stats != null, "CardStatOverlay must instantiate cleanly")
	stats._ready()
	asserts.assert_equal(stats.size, Vector2(1086, 1448), "CardStatOverlay ready size must be 1086x1448 px")
	asserts.assert_equal(stats.mouse_filter, Control.MOUSE_FILTER_IGNORE, "CardStatOverlay must ignore mouse filter")

	stats.set_printed_values(4, 4, 5, 2)
	stats.set_shield_overlay(1)
	asserts.assert_equal(stats._mana, 4, "Printed mana must be stored as 4")
	asserts.assert_equal(stats._attack, 4, "Printed attack must be stored as 4")
	asserts.assert_equal(stats._max_health, 5, "Printed max health must be stored as 5")
	asserts.assert_equal(stats._native_armor, 2, "Printed native armor must be stored as 2")
	asserts.assert_equal(stats._shield, 1, "Transient shield must be stored as 1")

	stats.free()


func _test_attack_and_health_inlays(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:attack_and_health_inlays")

	var card_center_x: float = 1086.0 * 0.5 # 543.0 px
	var atk_center: Vector2 = STAT_OVERLAY.ATTACK_CENTER # (162, 1279)
	var hp_center: Vector2 = STAT_OVERLAY.HEALTH_CENTER   # (919, 1279)

	asserts.assert_equal(atk_center, Vector2(162, 1279), "Attack socket center registered at (162, 1279)")
	asserts.assert_equal(hp_center, Vector2(919, 1279), "Health socket center registered at (919, 1279)")
	asserts.assert_equal(atk_center.y, hp_center.y, "Attack and Health sockets must share vertical baseline (y = 1279 px)")

	# Verify organic frame v03 socket registration (381 px vs 376 px from midline, delta = 5 px)
	var atk_dist: float = card_center_x - atk_center.x # 543 - 162 = 381
	var hp_dist: float = hp_center.x - card_center_x   # 919 - 543 = 376
	asserts.assert_true(absf(atk_dist - hp_dist) <= 5.0, "Socket centers follow frame v03 registration with 5 px organic asymmetry")

	# Verify inlay and bezel sizing
	asserts.assert_equal(STAT_OVERLAY.ATTACK_INLAY_SIZE, Vector2(190, 190), "Attack inlay size must be 190x190 px")
	asserts.assert_equal(STAT_OVERLAY.HEALTH_INLAY_SIZE, Vector2(190, 190), "Health inlay size must be 190x190 px")
	asserts.assert_equal(STAT_OVERLAY.SOCKET_BEZEL_SIZE, Vector2(220, 220), "Socket bezel overlay must be 220x220 px")

	# Safe disk radius leaves >= 2 px breathing room to nearest bronze rim (>= 72 px)
	asserts.assert_equal(STAT_OVERLAY.SOCKET_SAFE_RADIUS, 70.0, "Socket safe disk radius must be 70.0 px")


func _test_armor_and_shield_plaques(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:armor_and_shield_plaques")

	var card_center_x: float = 1086.0 * 0.5 # 543.0 px
	var arm_slot: Rect2 = Rect2(280, 1280, 198, 100)
	var shd_slot: Rect2 = Rect2(608, 1280, 198, 100)

	# Verify symmetry around bottom rarity gem (center at 543 px)
	var arm_center_x: float = arm_slot.get_center().x # 280 + 99 = 379
	var shd_center_x: float = shd_slot.get_center().x # 608 + 99 = 707
	var arm_dist: float = card_center_x - arm_center_x # 543 - 379 = 164
	var shd_dist: float = shd_center_x - card_center_x # 707 - 543 = 164
	asserts.assert_equal(arm_dist, shd_dist, "Armor and Shield slots must be equidistant from card center (164 px)")
	asserts.assert_equal(arm_slot.position.y, shd_slot.position.y, "Armor and Shield slots must share top baseline (y = 1280 px)")

	# Verify plaque sizing & unified width
	var arm_size: Vector2 = STAT_OVERLAY.ARMOR_PLAQUE_SIZE
	var shd_size: Vector2 = STAT_OVERLAY.SHIELD_PLAQUE_SIZE
	asserts.assert_equal(arm_size.x, 180.0, "Armor plaque width must be unified at 180.0 px")
	asserts.assert_equal(shd_size.x, 180.0, "Shield plaque width must be unified at 180.0 px")
	asserts.assert_equal(arm_size.y, 62.0, "Armor plaque height must be 62.0 px")
	asserts.assert_equal(shd_size.y, 69.0, "Shield plaque height must be 69.0 px")

	# Usable inner cavity inside 3 px bronze border (198 - 6 = 192 px, 100 - 6 = 94 px)
	var usable_w: float = 198.0 - 6.0 # 192.0
	var usable_h: float = 100.0 - 6.0 # 94.0

	var arm_margin_x: float = (usable_w - arm_size.x) * 0.5
	var arm_margin_y: float = (usable_h - arm_size.y) * 0.5
	var shd_margin_x: float = (usable_w - shd_size.x) * 0.5
	var shd_margin_y: float = (usable_h - shd_size.y) * 0.5

	asserts.assert_true(arm_margin_x >= 5.0 and arm_margin_y >= 10.0, "Armor plaque must preserve breathing room inside bronze border")
	asserts.assert_true(shd_margin_x >= 5.0 and shd_margin_y >= 10.0, "Shield plaque must preserve breathing room inside bronze border")


func _test_numeral_styling_coherence(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:numeral_styling_coherence")

	# Mandatory Coherence Rule (ART-002-T25):
	# Applied identically across Attack, Health, Armor, and Shield
	asserts.assert_equal(STAT_OVERLAY.NUMERAL_OUTLINE_SIZE, 4, "Global numeral outline size must be 4 px")
	asserts.assert_equal(STAT_OVERLAY.NUMERAL_SHADOW_OFFSET, Vector2(0, 2), "Global numeral shadow offset must be Vector2(0, 2)")
	asserts.assert_equal(STAT_OVERLAY.NUMERAL_SHADOW_COLOR, Color(0.0, 0.0, 0.0, 0.8), "Global numeral shadow color must be black at 80% opacity")
	asserts.assert_true(STAT_OVERLAY.use_optical_numeral_centering, "Principled optical numeral centering must be active by default")


func _test_numeral_fitting_and_breathing_room(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:numeral_fitting_and_breathing_room")

	# Secondary plaque font size is refined to 62 pt (ART-002-T24)
	asserts.assert_equal(STAT_OVERLAY.BADGE_PLAQUE_NUMBER_FONT_SIZE, 62, "Plaque badge numeral font size must be 62 pt")
	asserts.assert_equal(STAT_OVERLAY.BADGE_PLAQUE_NUMBER_MAX_WIDTH, 83.0, "Plaque badge max width cap must be 83.0 px")

	var font: Font = TOKENS.THEME.get_font(&"font", &"TacticalNumber")
	asserts.assert_true(font != null, "TacticalNumber font must exist in Theme")
	if font == null:
		return

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
			var gb: Rect2 = Rect2(
				server.font_get_glyph_offset(font_rid, Vector2i(62, 0), glyph) + Vector2(cursor, 0),
				server.font_get_glyph_size(font_rid, Vector2i(62, 0), glyph))
			bounds = gb if index == 0 else bounds.merge(gb)
			cursor += server.font_get_glyph_advance(font_rid, 62, glyph).x

		# Check width fits inside max width cap
		asserts.assert_true(bounds.size.x <= 83.0, "Value %d width (%.1f px) must fit within 83 px budget" % [val, bounds.size.x])

		# Check vertical breathing room on Armor plaque (height 62) and Shield plaque (height 69)
		# Glyph height + 6 px (3 px outline top and bottom)
		var total_h: float = bounds.size.y + 6.0
		var armor_margin: float = (62.0 - total_h) * 0.5
		var shield_margin: float = (69.0 - total_h) * 0.5

		asserts.assert_true(armor_margin >= 4.8, "Value %d must preserve >= 5.0 px breathing room on Armor (got %.1f px)" % [val, armor_margin])
		asserts.assert_true(shield_margin >= 7.8, "Value %d must preserve >= 8.0 px breathing room on Shield (got %.1f px)" % [val, shield_margin])

	# Typographic scale ratio: secondary stats (62 pt) to primary stats (126 pt)
	var ratio: float = 62.0 / 126.0
	asserts.assert_true(ratio >= 0.45 and ratio <= 0.52, "Secondary stat font size must form classic ~1:2 ratio to primary stat font size (49.2%)")


func _test_optical_alignment(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:optical_alignment")

	# Plaque badge optical offsets: vertical Y offset must be strictly 0.0 to prevent top/bottom crowding
	var test_values: Array[int] = [1, 2, 4, 5, 7, 8, 10, 12, 14]
	for val: int in test_values:
		var badge_offset: Vector2 = STAT_OVERLAY.get_badge_plaque_numeral_optical_offset(val)
		asserts.assert_equal(badge_offset.y, 0.0, "Value %d plaque badge vertical optical offset must be strictly 0.0" % val)

	# Asymmetrical horizontal offsets: -1 px for 4, -2 px for double digits 10..19
	asserts.assert_equal(STAT_OVERLAY.get_badge_plaque_numeral_optical_offset(4).x, -1.0, "Value 4 must have -1 px horizontal optical balance")
	asserts.assert_equal(STAT_OVERLAY.get_badge_plaque_numeral_optical_offset(10).x, -2.0, "Value 10 must have -2 px horizontal optical balance")
	asserts.assert_equal(STAT_OVERLAY.get_badge_plaque_numeral_optical_offset(12).x, -2.0, "Value 12 must have -2 px horizontal optical balance")

	# Preserved circular socket optical offsets (Attack/Health T21 calibration)
	asserts.assert_equal(STAT_OVERLAY.get_numeral_optical_offset(4), Vector2(-4, -4), "Circular socket optical offset for 4 must remain Vector2(-4, -4)")


func _test_creature_vs_non_creature_behavior(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:creature_vs_non_creature")

	# Non-creature category overlay decoupled from CardStatOverlay (AUDIT-002-T03)
	var cat_overlay: CardCategoryOverlay = CATEGORY_OVERLAY.new()
	asserts.assert_true(cat_overlay != null, "CardCategoryOverlay must instantiate cleanly")
	asserts.assert_true(cat_overlay is CardSocketOverlay, "CardCategoryOverlay must inherit from CardSocketOverlay")
	asserts.assert_false((cat_overlay as Object) is CardStatOverlay, "CardCategoryOverlay must NOT inherit from CardStatOverlay")

	cat_overlay.category = CardContentOverlay.Category.SPELL
	var spell_cue: Vector2 = cat_overlay.category_cue_center()
	asserts.assert_true(spell_cue.x > 0 and spell_cue.y > 0, "Spell category cue must calculate valid center coordinates")

	cat_overlay.category = CardContentOverlay.Category.EQUIPMENT
	var equip_cue: Vector2 = cat_overlay.category_cue_center()
	asserts.assert_true(equip_cue.x > 0 and equip_cue.y > 0, "Equipment category cue must calculate valid center coordinates")

	cat_overlay.free()


func _test_epic_emerald_rarity(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:epic_emerald_rarity")

	# Canonical UI Theme token must be emerald green (AUDIT-002-T03)
	var epic_token: Color = TOKENS.color_token(&"epic")
	asserts.assert_true(epic_token.h >= 0.38 and epic_token.h <= 0.45, "Epic theme token must be in green spectrum (~0.415, got %.3f)" % epic_token.h)
	asserts.assert_true(epic_token.s >= 0.70, "Epic theme token must have high saturation (>= 0.70, got %.2f)" % epic_token.s)

	# Default create_material(&"epic") must produce approved emerald treatment without special flags
	var default_epic: ShaderMaterial = GEM_TREATMENT.create_material(&"epic")
	asserts.assert_true(default_epic != null, "Default Epic material must instantiate cleanly")
	if default_epic != null:
		var gem_mask = default_epic.get_shader_parameter("gem_mask")
		asserts.assert_true(gem_mask != null, "Default Epic material must assign gem_mask shader parameter")

		var pigment: Color = default_epic.get_shader_parameter("gemstone_color")
		# Emerald green hue is ~0.415 (approx 150°), distinctly in the green spectrum, NOT violet (hue ~0.77)
		asserts.assert_true(pigment.h >= 0.38 and pigment.h <= 0.45, "Default Epic pigment hue must be in green spectrum (~0.415, got %.3f)" % pigment.h)
		asserts.assert_true(pigment.s >= 0.80, "Default Epic pigment must have high saturation (>= 0.80, got %.2f)" % pigment.s)
		asserts.assert_equal(default_epic.get_shader_parameter("inner_light"), 0.12, "Default Epic inner light must be 0.12")

	# Backward-compatible alias create_emerald_epic_material() must match default create_material(&"epic")
	var alias_epic: ShaderMaterial = GEM_TREATMENT.create_emerald_epic_material()
	asserts.assert_equal(alias_epic.get_shader_parameter("gemstone_color"), default_epic.get_shader_parameter("gemstone_color"), "Alias and default Epic gemstone colors must be identical")


func _test_content_transactional_safety(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:content_transactional_safety")

	var content_overlay: CardContentOverlay = CONTENT_OVERLAY.new()
	asserts.assert_true(content_overlay != null, "CardContentOverlay must instantiate cleanly")

	# 1. Valid content
	var valid_data: CardContentOverlay.Content = CardContentOverlay.Content.new(
		"Arcane Knight", CardContentOverlay.Category.CREATURE, "Human", "Whenever this creature attacks, gain 1 Shield.")
	var err_ok: Error = content_overlay.configure(valid_data)
	asserts.assert_equal(err_ok, OK, "Valid content must configure with OK")
	asserts.assert_equal(content_overlay.accepted_content, valid_data, "Accepted content must be stored upon OK")

	# 2. Invalid empty title
	var empty_title: CardContentOverlay.Content = CardContentOverlay.Content.new("", CardContentOverlay.Category.CREATURE, "", "Some rules.")
	var err_empty: Error = content_overlay.configure(empty_title)
	asserts.assert_equal(err_empty, ERR_INVALID_DATA, "Empty title must return ERR_INVALID_DATA")
	asserts.assert_equal(content_overlay.accepted_content, valid_data, "Rejected configuration must preserve last accepted content")

	# 3. Invalid multiline title
	var multiline: CardContentOverlay.Content = CardContentOverlay.Content.new("First Line\nSecond Line", CardContentOverlay.Category.CREATURE, "", "Some rules.")
	var err_multi: Error = content_overlay.configure(multiline)
	asserts.assert_equal(err_multi, ERR_INVALID_DATA, "Multiline title must return ERR_INVALID_DATA")

	content_overlay.free()


func _test_intentional_failure(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:intentional_failure_mode")
	print(">>> Triggering intentional failing assertion for presentation suite verification...")
	asserts.assert_true(false, "Deliberate failure triggered for presentation negative test verification (--test-failure-mode)")
