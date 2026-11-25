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
const CARD_VIEW: GDScript = preload("res://scripts/presentation/card_view.gd")
const VARIANT: GDScript = preload("res://scripts/presentation/card_visual_variant.gd")
const MODEL: GDScript = preload("res://scripts/presentation/card_presentation_model.gd")
const MANA_OVERLAY: GDScript = preload("res://scripts/presentation/card_mana_overlay.gd")
const SPELL_FRAME: Texture2D = preload("res://assets/textures/cards/mo_card_frame_spell_v01.png")


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
	_test_p005_r09b_title_and_rules_fitting(asserts)
	_test_p009_r01b_spell_frame_asset(asserts)
	_test_p009_r01b_solid_variants(asserts)
	_test_p009_r01b_spell_presentation_model(asserts)
	_test_p009_r01b_card_mana_overlay(asserts)
	_test_p009_r01b_card_view_composition(asserts)
	_test_p009_r01b_combat_preview_cards_integration(asserts)
	_test_p009_r01c_category_alignment(asserts)
	_test_p009_r01c_rarity_mask_registration(asserts)

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

	# Authoritative rendering contract (ART-002-T25):
	# 4 px stroke outline + directional depth shadow at offset (0, 2).
	var outline_size: float = float(STAT_OVERLAY.NUMERAL_OUTLINE_SIZE)
	var shadow_offset_y: float = STAT_OVERLAY.NUMERAL_SHADOW_OFFSET.y

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

		# 1. Source-space unadorned glyph bounds:
		asserts.assert_true(bounds.size.x <= 83.0, "Value %d width (%.1f px) must fit within 83 px budget" % [val, bounds.size.x])
		asserts.assert_true(bounds.size.y <= 46.0, "Value %d glyph height (%.1f px) must not exceed 46 px budget" % [val, bounds.size.y])

		# 2. Source-space drawn outline bounds (4 px stroke top and bottom):
		# Symmetrical outline height = glyph height + 2 * outline_size
		var outline_h: float = bounds.size.y + 2.0 * outline_size
		var armor_outline_margin: float = (62.0 - outline_h) * 0.5
		var shield_outline_margin: float = (69.0 - outline_h) * 0.5

		asserts.assert_true(armor_outline_margin >= 4.0, "Value %d must preserve >= 4.0 px outline margin on Armor (got %.1f px)" % [val, armor_outline_margin])
		asserts.assert_true(shield_outline_margin >= 7.5, "Value %d must preserve >= 7.5 px outline margin on Shield (got %.1f px)" % [val, shield_outline_margin])

		# 3. Directional shadow extent (offset (0, 2)):
		# Downward shadow shifts the bottom drawn extent by +2 px, leaving >= 2.0 px air on Armor and >= 5.5 px on Shield
		var armor_bottom_margin: float = armor_outline_margin - shadow_offset_y
		var shield_bottom_margin: float = shield_outline_margin - shadow_offset_y

		asserts.assert_true(armor_bottom_margin >= 2.0, "Value %d must preserve >= 2.0 px bottom shadow clearance on Armor (got %.1f px)" % [val, armor_bottom_margin])
		asserts.assert_true(shield_bottom_margin >= 5.5, "Value %d must preserve >= 5.5 px bottom shadow clearance on Shield (got %.1f px)" % [val, shield_bottom_margin])

		# 4. Bronze slot inner clearance:
		# Total drawn footprint (height <= 56 px) remains comfortably inset within 198x100 bronze slot (> 18 px margin)
		var slot_inner_h: float = 94.0 # inner usable height
		var slot_margin: float = (slot_inner_h - (outline_h + shadow_offset_y)) * 0.5
		asserts.assert_true(slot_margin >= 18.0, "Value %d drawn footprint must preserve >= 18.0 px clearance inside bronze slot (got %.1f px)" % [val, slot_margin])

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


func _test_p005_r09b_title_and_rules_fitting(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:p005_r09b_title_and_rules_fitting")

	var overlay: CardContentOverlay = CONTENT_OVERLAY.new()
	asserts.assert_true(overlay != null, "CardContentOverlay must instantiate cleanly")

	# 1. Short title retains preferred 68 pt font size without wrapping
	var short_data: CardContentOverlay.Content = CardContentOverlay.Content.new(
		"Arcane Knight", CardContentOverlay.Category.CREATURE, "Human", "Whenever this creature attacks, gain 1 Shield.")
	var err_short: Error = overlay.configure(short_data)
	asserts.assert_equal(err_short, OK, "Short title card must configure OK")
	asserts.assert_equal(overlay.title_font_size, 68, "Short title must remain at preferred 68 pt")
	asserts.assert_equal(overlay.rules_font_size, 48, "Short rules must use preferred 48 pt")

	# 2. Medium title fits single line cleanly
	var med_data: CardContentOverlay.Content = CardContentOverlay.Content.new(
		"Voidbound Talisman", CardContentOverlay.Category.EQUIPMENT, "", "At the start of your turn, add 1 Mana Crystal.")
	var err_med: Error = overlay.configure(med_data)
	asserts.assert_equal(err_med, OK, "Medium title card must configure OK")
	asserts.assert_equal(overlay.title_font_size, 62, "Medium title must scale cleanly on single line (62 pt)")
	asserts.assert_equal(overlay.rules_font_size, 48, "Medium rules must use preferred 48 pt")

	# 3. Long title (30 chars) adaptively wraps onto 2 lines at 48 pt instead of shrinking to 42 pt
	var long_data: CardContentOverlay.Content = CardContentOverlay.Content.new(
		"Archon of the Sundered Sphere", CardContentOverlay.Category.CREATURE, "Celestial",
		"Legendary creature. Battlecry: Banish all enemy tokens until end of turn.")
	var err_long: Error = overlay.configure(long_data)
	asserts.assert_equal(err_long, OK, "Long title card must configure OK")
	asserts.assert_equal(overlay.title_font_size, 48, "Long title must wrap onto 2 lines and use 48 pt (was 42 pt in R09A)")
	asserts.assert_equal(overlay.rules_font_size, 48, "Rules must fit at 48 pt")

	# 4. Physical font sizes at 720p with 540 px inspection height
	# Factor: (540.0 / 1448.0) * (2.0 / 3.0) = 0.2486188
	var scale_720p: float = (540.0 / 1448.0) * (2.0 / 3.0)
	var long_title_720p: float = float(overlay.title_font_size) * scale_720p
	var rules_720p: float = float(overlay.rules_font_size) * scale_720p
	var short_title_720p: float = 68.0 * scale_720p

	asserts.assert_true(long_title_720p >= 11.5, "Long title at 720p must reach ~12 physical px (got %.2f px)" % long_title_720p)
	asserts.assert_true(rules_720p >= 11.5, "Rules text at 720p must reach ~12 physical px (got %.2f px)" % rules_720p)
	asserts.assert_true(short_title_720p >= 16.0, "Short title at 720p must exceed 16 physical px (got %.2f px)" % short_title_720p)

	overlay.free()


func _test_p009_r01b_spell_frame_asset(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:p009_r01b_spell_frame_asset")

	# Runtime texture must be loaded and match production dimensions
	asserts.assert_true(SPELL_FRAME != null, "Spell frame runtime texture must load successfully")
	if SPELL_FRAME != null:
		asserts.assert_equal(SPELL_FRAME.get_size(), Vector2(1086, 1448), "Spell frame must be exactly 1086x1448 px")
		var img: Image = SPELL_FRAME.get_image()
		asserts.assert_true(img != null, "Spell frame image must be accessible")
		if img != null:
			# Validate exterior transparency
			asserts.assert_equal(img.get_pixel(0, 0).a, 0.0, "Exterior top-left corner must be fully transparent")
			asserts.assert_equal(img.get_pixel(1085, 0).a, 0.0, "Exterior top-right corner must be fully transparent")
			asserts.assert_equal(img.get_pixel(0, 1447).a, 0.0, "Exterior bottom-left corner must be fully transparent")
			asserts.assert_equal(img.get_pixel(1085, 1447).a, 0.0, "Exterior bottom-right corner must be fully transparent")

			# Validate aperture interior transparency
			asserts.assert_equal(img.get_pixel(543, 500).a, 0.0, "Aperture center must be fully transparent")

			# Validate solid interiors (normalized to 255 / 1.0)
			asserts.assert_equal(img.get_pixel(153, 151).a, 1.0, "Mana housing center must be fully opaque (alpha 1.0)")
			asserts.assert_equal(img.get_pixel(597, 137).a, 1.0, "Title bar center must be fully opaque")
			asserts.assert_equal(img.get_pixel(543, 949).a, 1.0, "Category bar center must be fully opaque")
			asserts.assert_equal(img.get_pixel(543, 1110).a, 1.0, "Effect description panel center must be fully opaque")

			# Validate lower corners: quiet solid bronze/enamel, no stat sockets or holes
			asserts.assert_equal(img.get_pixel(162, 1279).a, 1.0, "Former creature Attack position must be solid material")
			asserts.assert_equal(img.get_pixel(919, 1279).a, 1.0, "Former creature Health position must be solid material")


func _test_p009_r01b_solid_variants(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:p009_r01b_solid_variants")

	var creature_v: RefCounted = VARIANT.create_creature_variant()
	var spell_v: RefCounted = VARIANT.create_spell_variant()
	var equip_v: RefCounted = VARIANT.create_equipment_variant()

	# Creature variant properties
	asserts.assert_equal(creature_v.category, CardContentOverlay.Category.CREATURE, "Creature variant category must be CREATURE")
	asserts.assert_equal(creature_v.frame_texture, VARIANT.MASTER_CREATURE_FRAME, "Creature variant must use master frame v03")
	asserts.assert_equal(creature_v.rules_bounds, CardViewLayout.RULES_BOUNDS, "Creature rules bounds must be protected narrow column")
	asserts.assert_true(creature_v.supports_creature_stats, "Creature variant must flag supports_creature_stats as true")
	asserts.assert_equal(creature_v.card_size, Vector2(1086, 1448), "Creature card size must be 1086x1448")

	# Spell variant properties
	asserts.assert_equal(spell_v.category, CardContentOverlay.Category.SPELL, "Spell variant category must be SPELL")
	asserts.assert_equal(spell_v.frame_texture, SPELL_FRAME, "Spell variant must use production spell frame")
	asserts.assert_equal(spell_v.rules_bounds, CardViewLayout.SPELL_RULES_BOUNDS, "Spell rules bounds must use enlarged SPELL_RULES_BOUNDS")
	asserts.assert_equal(spell_v.rules_bounds.size, Vector2(806, 240), "Spell effect area must be exactly 806x240 px")
	asserts.assert_false(spell_v.supports_creature_stats, "Spell variant must flag supports_creature_stats as false")
	asserts.assert_equal(spell_v.illustration_bounds, CardViewLayout.APERTURE_BOUNDS, "Shared illustration aperture bounds")
	asserts.assert_equal(spell_v.mana_center, CardViewLayout.MANA_CENTER, "Shared mana center")

	# Area gain verification (+62.7% area gain over creature description)
	var creature_area: float = CardViewLayout.RULES_BOUNDS.size.x * CardViewLayout.RULES_BOUNDS.size.y
	var spell_area: float = CardViewLayout.SPELL_RULES_BOUNDS.size.x * CardViewLayout.SPELL_RULES_BOUNDS.size.y
	var gain_pct: float = ((spell_area - creature_area) / creature_area) * 100.0
	asserts.assert_true(gain_pct >= 62.0 and gain_pct <= 63.5, "Spell effect area gain must be ~62.7%% (got %.2f%%)" % gain_pct)

	# Factory resolution
	asserts.assert_equal(VARIANT.for_category(CardContentOverlay.Category.CREATURE).category, CardContentOverlay.Category.CREATURE, "Factory CREATURE resolution")
	asserts.assert_equal(VARIANT.for_category(CardContentOverlay.Category.SPELL).category, CardContentOverlay.Category.SPELL, "Factory SPELL resolution")
	asserts.assert_equal(VARIANT.for_category(CardContentOverlay.Category.EQUIPMENT).category, CardContentOverlay.Category.EQUIPMENT, "Factory EQUIPMENT resolution")


func _test_p009_r01b_spell_presentation_model(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:p009_r01b_spell_presentation_model")

	# 1. Fireball
	var fireball: RefCounted = MODEL.create_spell("Fireball", 3, &"rare", "Deal 4 damage to target enemy creature.", null, "spell_fireball")
	asserts.assert_equal(fireball.title, "Fireball", "Fireball title")
	asserts.assert_equal(fireball.category, CardContentOverlay.Category.SPELL, "Fireball category is SPELL")
	asserts.assert_equal(fireball.cost, 3, "Fireball cost is 3")
	asserts.assert_equal(fireball.rarity, &"rare", "Fireball rarity is rare")
	asserts.assert_equal(fireball.tribe, "", "Spell must have empty tribe")
	asserts.assert_equal(fireball.attack, 0, "Spell attack must default to 0")
	asserts.assert_equal(fireball.max_health, 0, "Spell health must default to 0")

	# 2. Mending Light
	var mending: RefCounted = MODEL.create_spell("Mending Light", 2, &"common", "Restore 3 Health to target allied creature.", null, "spell_heal")
	asserts.assert_equal(mending.title, "Mending Light", "Mending Light title")
	asserts.assert_equal(mending.cost, 2, "Mending Light cost is 2")
	asserts.assert_equal(mending.rarity, &"common", "Mending Light rarity is common")

	# 3. Arcane Barrier
	var barrier: RefCounted = MODEL.create_spell("Arcane Barrier", 2, &"uncommon", "Grant 3 Shield to target allied creature.", null, "spell_barrier")
	asserts.assert_equal(barrier.cost, 2, "Arcane Barrier cost is 2")
	asserts.assert_equal(barrier.rarity, &"uncommon", "Arcane Barrier rarity is uncommon")

	# 4. Martial Blessing
	var blessing: RefCounted = MODEL.create_spell("Martial Blessing", 2, &"common", "Target allied creature gains +2 Attack until end of turn.", null, "spell_blessing")
	asserts.assert_equal(blessing.cost, 2, "Martial Blessing cost is 2")

	# 5. Boundary cost tests (0 cost and double-digit 10 cost)
	var zero_cost: RefCounted = MODEL.create_spell("Zero Spell", 0, &"common", "Cost zero test.")
	asserts.assert_equal(zero_cost.cost, 0, "0-cost spell supported")
	var ten_cost: RefCounted = MODEL.create_spell("Ten Spell", 10, &"legendary", "Cost ten test.")
	asserts.assert_equal(ten_cost.cost, 10, "10-cost spell supported")


func _test_p009_r01b_card_mana_overlay(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:p009_r01b_card_mana_overlay")

	var mana_overlay: Control = (MANA_OVERLAY as GDScript).new()
	asserts.assert_true(mana_overlay != null, "CardManaOverlay must instantiate cleanly")
	asserts.assert_true(mana_overlay is CardSocketOverlay, "CardManaOverlay must inherit CardSocketOverlay")
	asserts.assert_false((mana_overlay as Object) is CardStatOverlay, "CardManaOverlay must NOT inherit CardStatOverlay")
	asserts.assert_false((mana_overlay as Object) is CardCategoryOverlay, "CardManaOverlay must NOT inherit CardCategoryOverlay")

	# Mana values setting
	for test_mana in [0, 2, 3, 10]:
		mana_overlay.call(&"set_mana", test_mana)
		asserts.assert_equal(mana_overlay.get("_mana"), test_mana, "Mana value %d must be stored" % test_mana)

	asserts.assert_equal(mana_overlay.get_child_count(), 0, "CardManaOverlay must have zero child nodes (pure immediate canvas draw)")
	mana_overlay.free()


func _test_p009_r01b_card_view_composition(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:p009_r01b_card_view_composition")

	var view: Control = (CARD_VIEW as GDScript).new()
	asserts.assert_true(view != null, "CardView must instantiate cleanly")

	# 1. Compose Creature card
	var creature_model: RefCounted = MODEL.create_creature("Arcane Knight", 4, &"rare", 4, 5, "Human", "Whenever this creature attacks, gain 1 Shield.", 2, 1)
	var err_c: Error = view.call(&"apply_model", creature_model)
	asserts.assert_equal(err_c, OK, "CardView must configure creature with OK")
	asserts.assert_true(view.has_node("Aperture"), "Creature view must have Aperture")
	asserts.assert_true(view.has_node("Frame"), "Creature view must have Frame")
	asserts.assert_true(view.has_node("Content"), "Creature view must have Content")
	asserts.assert_true(view.has_node("Stats"), "Creature view must have Stats overlay")
	asserts.assert_false(view.has_node("Mana"), "Creature view must NOT have standalone Mana overlay")
	asserts.assert_equal((view.get_node("Frame") as TextureRect).texture, VARIANT.MASTER_CREATURE_FRAME, "Creature Frame texture must be master v03")
	var creature_content: CardContentOverlay = view.get_node("Content") as CardContentOverlay
	asserts.assert_equal(creature_content.active_rules_bounds, CardViewLayout.RULES_BOUNDS, "Creature content bounds must be narrow column")

	# 2. Compose Spell card
	var spell_model: RefCounted = MODEL.create_spell("Fireball", 3, &"rare", "Deal 4 damage to target enemy creature.", null, "spell_fireball")
	var err_s: Error = view.call(&"apply_model", spell_model)
	asserts.assert_equal(err_s, OK, "CardView must configure spell with OK")
	asserts.assert_true(view.has_node("Aperture"), "Spell view must have Aperture")
	asserts.assert_true(view.has_node("Frame"), "Spell view must have Frame")
	asserts.assert_true(view.has_node("Content"), "Spell view must have Content")
	asserts.assert_true(view.has_node("Mana"), "Spell view must have Mana overlay")
	asserts.assert_false(view.has_node("Stats"), "Spell view must NOT have Stats overlay")
	asserts.assert_false(view.has_node("CategoryOverlay"), "Spell view must NOT have legacy CategoryOverlay rosette engravings")
	asserts.assert_equal((view.get_node("Frame") as TextureRect).texture, SPELL_FRAME, "Spell Frame texture must be production spell frame")
	var spell_content: CardContentOverlay = view.get_node("Content") as CardContentOverlay
	asserts.assert_equal(spell_content.active_rules_bounds, CardViewLayout.SPELL_RULES_BOUNDS, "Spell content bounds must use enlarged SPELL_RULES_BOUNDS")
	asserts.assert_equal(spell_content.type_label.text, "Spell", "Spell type text must be 'Spell' without tribe")

	# 3. Two independent Spell instances do not share mutable state
	var view2: Control = (CARD_VIEW as GDScript).new()
	var spell_model2: RefCounted = MODEL.create_spell("Mending Light", 2, &"common", "Restore 3 Health to target allied creature.")
	view2.call(&"apply_model", spell_model2)
	asserts.assert_equal((view.get_node("Content") as CardContentOverlay).title_label.text, "Fireball", "View 1 title preserved")
	asserts.assert_equal((view2.get_node("Content") as CardContentOverlay).title_label.text, "Mending Light", "View 2 title correct")
	asserts.assert_equal(view.get_node("Mana").get("_mana"), 3, "View 1 mana cost is 3")
	asserts.assert_equal(view2.get_node("Mana").get("_mana"), 2, "View 2 mana cost is 2")

	# 4. Stress text fit in enlarged 806x240 envelope
	var stress_spell: RefCounted = MODEL.create_spell(
		"Cataclysmic Conflagration", 8, &"epic",
		"Deal 8 damage to all enemy frontline creatures. If any creature is destroyed, ignite adjacent positions for 2 damage per turn.")
	var err_stress: Error = view.call(&"apply_model", stress_spell)
	asserts.assert_equal(err_stress, OK, "Stress spell rules must fit in enlarged 806x240 envelope")

	view.free()
	view2.free()


func _test_p009_r01b_combat_preview_cards_integration(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:p009_r01b_combat_preview_cards_integration")

	var fan: CombatPreviewCards = CombatPreviewCards.new()
	fan.size = Vector2(1920, 270)
	fan.display_count = 7
	fan.rebuild()

	asserts.assert_equal(fan.get_child_count(), 7, "Fan must have 7 child cards")

	# Check mixed hand: index 0 is Creature, index 1 is Spell
	var card0: Control = fan.get_child(0) as Control
	var card1: Control = fan.get_child(1) as Control

	asserts.assert_true(card0.has_node("Stats"), "Card 0 (Creature) must have Stats overlay")
	asserts.assert_false(card0.has_node("Mana"), "Card 0 (Creature) must NOT have Mana overlay")
	asserts.assert_equal((card0.get_node("Frame") as TextureRect).texture, VARIANT.MASTER_CREATURE_FRAME, "Card 0 Frame is master creature")

	asserts.assert_true(card1.has_node("Mana"), "Card 1 (Spell) must have Mana overlay")
	asserts.assert_false(card1.has_node("Stats"), "Card 1 (Spell) must NOT have Stats overlay")
	asserts.assert_equal((card1.get_node("Frame") as TextureRect).texture, SPELL_FRAME, "Card 1 Frame is production spell frame")

	# Check spells-only scenario
	fan.set_preview_scenario("spells_only")
	for i: int in range(fan.get_child_count()):
		var spell_card: Control = fan.get_child(i) as Control
		asserts.assert_true(spell_card.has_node("Mana"), "Card %d in spells-only hand must have Mana overlay" % i)
		asserts.assert_false(spell_card.has_node("Stats"), "Card %d in spells-only hand must NOT have Stats overlay" % i)
		asserts.assert_equal((spell_card.get_node("Frame") as TextureRect).texture, SPELL_FRAME, "Card %d Frame is spell frame" % i)

	# Check creatures-only scenario
	fan.set_preview_scenario("creatures_only")
	for i: int in range(fan.get_child_count()):
		var creature_card: Control = fan.get_child(i) as Control
		asserts.assert_true(creature_card.has_node("Stats"), "Card %d in creatures-only hand must have Stats overlay" % i)
		asserts.assert_false(creature_card.has_node("Mana"), "Card %d in creatures-only hand must NOT have Mana overlay" % i)
		asserts.assert_equal((creature_card.get_node("Frame") as TextureRect).texture, VARIANT.MASTER_CREATURE_FRAME, "Card %d Frame is creature frame" % i)

	# Check interaction picking consistency: picking formula respects exact card box
	var card_center: Vector2 = Vector2(960, 135)
	asserts.assert_true(CombatPreviewCards.is_point_in_card(card_center, card_center, 0.0, 270.0), "Card center must be inside card")
	asserts.assert_false(CombatPreviewCards.is_point_in_card(card_center + Vector2(200, 0), card_center, 0.0, 270.0), "Point outside card width must be rejected")

	fan.free()


func _test_p009_r01c_category_alignment(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:p009_r01c_category_alignment")

	# 1. Authoritative geometry constants
	asserts.assert_equal(CardViewLayout.SPELL_TYPE_BOUNDS, Rect2(180, 908, 726, 38), "Spell category reservation clears the upper shoulders")
	asserts.assert_equal(CardViewLayout.SPELL_TYPE_SIZE, 36, "Spell category uses calibrated 36 px serif")

	# 2. Bounded within dark enamel interior y in [898, 946]
	var box_top: float = CardViewLayout.SPELL_TYPE_BOUNDS.position.y
	var box_bottom: float = box_top + CardViewLayout.SPELL_TYPE_BOUNDS.size.y
	var box_center: float = box_top + CardViewLayout.SPELL_TYPE_BOUNDS.size.y * 0.5
	asserts.assert_true(box_top >= 898.0, "Spell category box top must clear upper bronze border (got %.1f, >= 898)" % box_top)
	asserts.assert_true(box_bottom <= 946.0, "Spell category box bottom must clear lower bronze divider (got %.1f, <= 946)" % box_bottom)
	asserts.assert_equal(box_center, 927.0, "Spell reservation centers at y=927 below the bridge shoulders")

	# 3. CardVisualVariant wiring
	var creature_v: RefCounted = VARIANT.create_creature_variant()
	var spell_v: RefCounted = VARIANT.create_spell_variant()
	asserts.assert_equal(creature_v.category_bounds, CardViewLayout.TYPE_BOUNDS, "Creature variant preserves TYPE_BOUNDS")
	asserts.assert_equal(creature_v.category_size, CardViewLayout.TYPE_SIZE, "Creature variant preserves TYPE_SIZE (48 pt)")
	asserts.assert_equal(spell_v.category_bounds, CardViewLayout.SPELL_TYPE_BOUNDS, "Spell variant uses SPELL_TYPE_BOUNDS")
	asserts.assert_equal(spell_v.category_size, CardViewLayout.SPELL_TYPE_SIZE, "Spell variant uses the calibrated type size")
	asserts.assert_equal(creature_v.category_glyph_spacing, 0, "Creature variant preserves the original tracking")
	asserts.assert_equal(spell_v.category_glyph_spacing, CardViewLayout.SPELL_TYPE_GLYPH_SPACING, "Spell variant supplies tracking")

	# 4. CardView composition of category label
	var view: Control = (CARD_VIEW as GDScript).new()
	var spell_model: RefCounted = MODEL.create_spell("Fireball", 3, &"rare", "Deal 4 damage to target enemy creature.", null, "spell_fireball")
	view.call(&"apply_model", spell_model)

	var content: CardContentOverlay = view.get_node("Content") as CardContentOverlay
	asserts.assert_equal(content.active_type_bounds, CardViewLayout.SPELL_TYPE_BOUNDS, "Content overlay active_type_bounds matches SPELL_TYPE_BOUNDS")
	asserts.assert_equal(content.active_type_size, CardViewLayout.SPELL_TYPE_SIZE, "Content overlay active_type_size matches SPELL_TYPE_SIZE")
	asserts.assert_equal(content.type_label.position, CardViewLayout.SPELL_TYPE_BOUNDS.position, "Label position matches SPELL_TYPE_BOUNDS")
	asserts.assert_equal(content.type_label.size, CardViewLayout.SPELL_TYPE_BOUNDS.size, "Label size matches SPELL_TYPE_BOUNDS")
	asserts.assert_equal(content.type_label.get_theme_font_size(&"font_size"), 36, "Label font size is 36 px")
	var font: FontVariation = content.type_label.get_theme_font(&"font") as FontVariation
	asserts.assert_true(font != null and font.spacing_glyph == CardViewLayout.SPELL_TYPE_GLYPH_SPACING, "Category label uses configured tracking")
	asserts.assert_equal(content.type_label.text, "Spell", "Spell type text is 'Spell'")

	# 5. All 4 Lot 1 spells format cleanly within bounds
	var lot1_spells: Array[RefCounted] = [
		MODEL.create_spell("Fireball", 3, &"rare", "Deal 4 damage to target enemy creature.", null, "spell_fireball"),
		MODEL.create_spell("Mending Light", 2, &"common", "Restore 3 Health to target allied creature.", null, "spell_heal"),
		MODEL.create_spell("Arcane Barrier", 2, &"uncommon", "Grant 3 Shield to target allied creature.", null, "spell_barrier"),
		MODEL.create_spell("Martial Blessing", 2, &"common", "Target allied creature gains +2 Attack until end of turn.", null, "spell_blessing")
	]
	for sp: RefCounted in lot1_spells:
		var err: Error = view.call(&"apply_model", sp)
		content = view.get_node("Content") as CardContentOverlay
		asserts.assert_equal(err, OK, "Spell '%s' must apply model cleanly" % sp.title)
		asserts.assert_false(content.title_overflow, "Title must not overflow for '%s'" % sp.title)
		asserts.assert_false(content.rules_overflow, "Rules must not overflow for '%s'" % sp.title)
		asserts.assert_equal(content.type_label.text, "Spell", "Each reference Spell supplies the same category label")

	view.free()


func _test_p009_r01c_rarity_mask_registration(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:p009_r01c_rarity_mask_registration")

	# 1. Mask asset loading and dimensions
	asserts.assert_true(GEM_TREATMENT.SPELL_MASK != null, "Spell rarity mask must be loaded")
	if GEM_TREATMENT.SPELL_MASK != null:
		asserts.assert_equal(GEM_TREATMENT.SPELL_MASK.get_size(), Vector2(1086, 1448), "Spell mask must be 1086x1448 px")
		var mask_img: Image = GEM_TREATMENT.SPELL_MASK.get_image()
		asserts.assert_true(mask_img != null, "Mask image must be accessible")
		if mask_img != null:
			# Crown crystal interior (white / recolored)
			asserts.assert_true(mask_img.get_pixel(543, 53).r > 0.5, "Crown crystal interior must be white in mask")

			# Bridge crystal interior (white / recolored)
			asserts.assert_true(mask_img.get_pixel(543, 866).r > 0.5, "Bridge crystal interior must be white in mask")

			# Footer crystal interior at actual Spell position y ~ 1375 (white / recolored)
			asserts.assert_true(mask_img.get_pixel(543, 1375).r > 0.5, "Actual Spell footer crystal interior must be white in mask")

			# Old Creature footer position y=1286 MUST BE BLACK (zero leakage into description panel)
			asserts.assert_equal(mask_img.get_pixel(543, 1286).r, 0.0, "Former creature footer position must be black (zero leakage)")

			# Rules description area MUST BE BLACK
			asserts.assert_equal(mask_img.get_pixel(543, 1110).r, 0.0, "Description panel center must be black")
			asserts.assert_equal(mask_img.get_pixel(300, 1110).r, 0.0, "Description panel left must be black")
			asserts.assert_equal(mask_img.get_pixel(780, 1110).r, 0.0, "Description panel right must be black")

			# Bezel flanking footer crystal MUST BE BLACK
			asserts.assert_equal(mask_img.get_pixel(500, 1375).r, 0.0, "Bronze bezel left of footer crystal must be black")
			asserts.assert_equal(mask_img.get_pixel(586, 1375).r, 0.0, "Bronze bezel right of footer crystal must be black")

	# 2. Material independence between Creature and Spell
	var creature_view: Control = (CARD_VIEW as GDScript).new()
	var spell_view: Control = (CARD_VIEW as GDScript).new()

	var c_model: RefCounted = MODEL.create_creature("Arcane Knight", 1, &"rare", 2, 3, "Human")
	var s_model: RefCounted = MODEL.create_spell("Fireball", 3, &"rare", "Deal 4 damage.")

	creature_view.call(&"apply_model", c_model)
	spell_view.call(&"apply_model", s_model)

	var c_mat: ShaderMaterial = (creature_view.get_node("Frame") as TextureRect).material as ShaderMaterial
	var s_mat: ShaderMaterial = (spell_view.get_node("Frame") as TextureRect).material as ShaderMaterial

	asserts.assert_true(c_mat != null and s_mat != null, "Both views must have ShaderMaterial")
	asserts.assert_false(c_mat == s_mat, "Creature and Spell must have independent ShaderMaterial instances")
	asserts.assert_equal(c_mat.shader, s_mat.shader, "Creature and Spell use the same rarity shader")
	asserts.assert_equal(c_mat.get_shader_parameter("gem_mask"), GEM_TREATMENT.MASK, "Creature material must use MASK (frame_v03_gem_mask.svg)")
	asserts.assert_equal(s_mat.get_shader_parameter("gem_mask"), GEM_TREATMENT.SPELL_MASK, "Spell material must use SPELL_MASK (frame_spell_v01_gem_mask.svg)")

	# 3. All 5 rarities on Spell generate valid materials with SPELL_MASK
	for r: StringName in [&"common", &"uncommon", &"rare", &"epic", &"legendary"]:
		var mat: ShaderMaterial = GEM_TREATMENT.create_material(r, true, GEM_TREATMENT.SPELL_MASK)
		asserts.assert_true(mat != null, "Material for rarity '%s' must not be null" % r)
		asserts.assert_equal(mat.get_shader_parameter("gem_mask"), GEM_TREATMENT.SPELL_MASK, "Rarity '%s' must carry SPELL_MASK" % r)

	creature_view.free()
	spell_view.free()


func _test_intentional_failure(asserts: TestAsserts) -> void:
	asserts.set_current_test("card_presentation:intentional_failure_mode")
	print(">>> Triggering intentional failing assertion for presentation suite verification...")
	asserts.assert_true(false, "Deliberate failure triggered for presentation negative test verification (--test-failure-mode)")
