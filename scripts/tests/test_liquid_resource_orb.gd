class_name TestLiquidResourceOrb
extends RefCounted

const ORB_SCENE: PackedScene = preload("res://scenes/hud/liquid_resource_orb.tscn")
const SCREEN_SCENE: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")

func run_suite(asserts: TestAsserts, _failure_mode: bool = false) -> void:
	asserts.set_current_test("liquid_orb:values_and_configuration")
	var orb: LiquidResourceOrb = ORB_SCENE.instantiate() as LiquidResourceOrb
	asserts.assert_equal(orb.resource_kind, LiquidResourceOrb.ResourceKind.HEALTH, "Default Health")
	asserts.assert_equal(orb.get_visible_fill_ratio(), 1.0, "Initial full ratio")
	asserts.assert_equal(orb.current_value, 30, "Initial exact current")
	asserts.assert_equal(orb.maximum_value, 30, "Initial exact maximum")
	orb.set_resource_kind(LiquidResourceOrb.ResourceKind.MANA)
	asserts.assert_equal(orb.resource_kind, LiquidResourceOrb.ResourceKind.MANA, "Mana configuration")
	asserts.assert_equal((orb.get_node("Kind") as Label).text, "MANA", "Explicit text kind")
	orb.set_resource_values(3, 5, false)
	asserts.assert_true(is_equal_approx(orb.get_visible_fill_ratio(), 0.6), "Intermediate ratio")
	asserts.assert_equal((orb.get_node("Values") as Label).text, "3 / 5", "Exact numbers")
	orb.set_resource_values(25, 100, false)
	asserts.assert_equal(orb.get_visible_fill_ratio(), 0.25, "Quarter full")
	orb.set_resource_values(0, 30, false)
	asserts.assert_equal(orb.get_visible_fill_ratio(), 0.0, "Empty")
	orb.set_resource_values(30, 30, false)
	asserts.assert_equal(orb.get_visible_fill_ratio(), 1.0, "Full")
	orb.set_resource_values(99, 0, false)
	asserts.assert_equal(orb.get_visible_fill_ratio(), 0.0, "Zero maximum")
	asserts.assert_equal((orb.get_node("Values") as Label).text, "0 / 0", "Zero maximum label")
	orb.set_resource_values(-5, 30, false)
	asserts.assert_equal(orb.current_value, 0, "Clamp negative current")
	orb.set_resource_values(99, 30, false)
	asserts.assert_equal(orb.current_value, 30, "Clamp above maximum")
	orb.set_resource_values(5, -1, false)
	asserts.assert_equal(orb.maximum_value, 0, "Clamp negative maximum")
	orb.set_animation_enabled(false)
	for value: int in range(31):
		orb.set_resource_values(value, 30)
	asserts.assert_equal(orb.get_visible_fill_ratio(), 1.0, "Repeated updates settle immediately when disabled")
	asserts.assert_false(orb.is_processing(), "Static mode disables processing")
	asserts.assert_equal(orb._orb_material.get_shader_parameter("clock_seconds"), 0.0, "Static clock reset")
	orb.size = Vector2(180, 100)
	orb._layout_contents()
	asserts.assert_equal((orb.get_node("Reservoir") as Control).size, Vector2(100, 100), "Circular on rectangular resize")
	asserts.assert_equal((orb.get_node("Reservoir") as Control).position, Vector2(40, 0), "Centered on resize")
	orb.size = Vector2(80, 80)
	orb._layout_contents()
	asserts.assert_equal((orb.get_node("Reservoir") as Control).size, Vector2(80, 80), "Opponent scale")
	orb.set_resource_values(99, 99, false)
	var label: Label = orb.get_node("Values") as Label
	var font_size: int = label.get_theme_font_size("font_size")
	var text_width: float = label.get_theme_font("font").get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	asserts.assert_true(text_width + 8.0 <= 80.0 * 0.65, "Two digit values fit inside the glass with outline clearance")
	orb.set_resource_values(100, 100, false)
	font_size = label.get_theme_font_size("font_size")
	text_width = label.get_theme_font("font").get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	asserts.assert_true(text_width + 8.0 <= 80.0 * 0.65, "Three digit gallery values fit too")
	orb.set_animation_enabled(true)
	asserts.assert_true(orb.is_processing(), "Animation can be re-enabled")
	orb.free()
	_test_integration(asserts)
	_test_artwork_mounting(asserts)

func _test_artwork_mounting(asserts: TestAsserts) -> void:
	asserts.set_current_test("liquid_orb:approved_player_mounting")
	var screen: CombatScreen = SCREEN_SCENE.instantiate() as CombatScreen
	var zone: Panel = screen.get_player_hero_zone()
	asserts.assert_true(zone.get_theme_stylebox("panel") is StyleBoxEmpty, "Old player panel border is neutralized")
	var backplate: TextureRect = zone.get_node("Backplate") as TextureRect
	var panel_atlas: AtlasTexture = backplate.texture as AtlasTexture
	asserts.assert_true(panel_atlas != null and panel_atlas.atlas != null, "Approved panel imports")
	asserts.assert_equal(panel_atlas.atlas.resource_path, "res://assets/_source/lot1/hud/player/mo_hud_player_panel_v01.png", "Exact approved panel")
	asserts.assert_equal(backplate.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Panel uses uniform scaling")
	asserts.assert_equal(zone.get_child(0), backplate, "Panel is behind foreground")
	asserts.assert_false((zone.get_node("Name") as Label).visible, "Placeholder name cannot collide with panel crest")
	var portrait: TextureRect = zone.get_node("Portrait") as TextureRect
	var frame: TextureRect = zone.get_node("PortraitFrame") as TextureRect
	asserts.assert_true(portrait.material is ShaderMaterial, "Illustration corners clipped under aperture")
	asserts.assert_true(frame.get_index() > portrait.get_index(), "Portrait frame above illustration")
	asserts.assert_equal(frame.size.x, frame.size.y, "Square frame not distorted")
	asserts.assert_equal(frame.texture.get_size(), Vector2(1254, 1254), "Approved portrait frame imports")
	var hp: LiquidResourceOrb = screen.get_player_health_orb()
	var mana: LiquidResourceOrb = screen.get_player_mana_orb()
	asserts.assert_equal(hp.housing_texture, mana.housing_texture, "Both resources reuse exactly one mounting")
	asserts.assert_equal(hp.housing_texture.resource_path, "res://assets/_source/lot1/hud/player/mo_hud_player_health_orb_housing_v01.png", "Approved housing path")
	asserts.assert_equal(hp.size, mana.size, "Matching external dimensions")
	asserts.assert_equal(hp.position.x, mana.position.x, "Same vertical axis")
	# P005-R06C: Centerline, spacing harmony, and housing modulate assertions
	var frame_center_x: float = frame.position.x + frame.size.x * 0.5
	var hp_center_x: float = hp.position.x + hp.size.x * 0.5
	var mana_center_x: float = mana.position.x + mana.size.x * 0.5
	asserts.assert_true(is_equal_approx(frame_center_x, hp_center_x), "Portrait frame and Health orb share exact horizontal centerline")
	asserts.assert_true(is_equal_approx(hp_center_x, mana_center_x), "Health orb and Mana orb share exact horizontal centerline")
	asserts.assert_true(frame.position.y + frame.size.y < hp.position.y, "Portrait frame is above Health orb")
	asserts.assert_true(hp.position.y + hp.size.y < mana.position.y, "Health orb is above Mana orb")
	var gap_frame_to_hp: float = hp.position.y - (frame.position.y + frame.size.y)
	var gap_hp_to_mana: float = mana.position.y - (hp.position.y + hp.size.y)
	asserts.assert_true(absf(gap_frame_to_hp - gap_hp_to_mana) <= 12.0, "Vertical gaps are optically balanced (gap1=%.1f, gap2=%.1f)" % [gap_frame_to_hp, gap_hp_to_mana])
	asserts.assert_equal(hp.housing_modulate, mana.housing_modulate, "Health and Mana share identical bronze modulation")
	asserts.assert_true(is_equal_approx(hp.housing_modulate.a, 1.0), "Housing modulation preserves full opacity")
	asserts.assert_true(hp.housing_modulate.r <= 1.0 and hp.housing_modulate.g <= 1.0 and hp.housing_modulate.b <= 1.0, "Housing modulation tones down golden excess")
	# P005-R06D: Mana bottom clearance and safe-area fit
	var bottom_clearance: float = zone.size.y - (mana.position.y + mana.size.y)
	asserts.assert_true(bottom_clearance >= 60.0, "Mana orb has comfortable bottom breathing room (clearance=%.1f >= 60 px)" % bottom_clearance)
	asserts.assert_equal(hp.size, Vector2(180, 180), "Health orb 180 px diameter")
	asserts.assert_equal(mana.size, Vector2(180, 180), "Mana orb 180 px diameter")
	asserts.assert_true(screen.get_opponent_health_orb().housing_texture == null and screen.get_opponent_mana_orb().housing_texture == null, "Opponent keeps procedural mounting")
	for orb: LiquidResourceOrb in [hp, mana]:
		orb._layout_contents()
		asserts.assert_equal(orb._orb_material.get_shader_parameter("external_housing"), true, "Procedural rim suppressed for player")
		var mounting: TextureRect = orb.get_node("Housing") as TextureRect
		asserts.assert_true(mounting.get_index() > orb.get_node("Reservoir").get_index() and mounting.get_index() < orb.get_node("Values").get_index(), "Liquid / artwork / text order")
		asserts.assert_equal(mounting.mouse_filter, Control.MOUSE_FILTER_IGNORE, "Mounting does not intercept hand pointer")
		var kind_label: Label = orb.get_node("Kind") as Label
		var values_label: Label = orb.get_node("Values") as Label
		asserts.assert_true(kind_label.get_theme_font_size("font_size") < values_label.get_theme_font_size("font_size"), "Caption font size is secondary to numeric values")
		asserts.assert_true(kind_label.get_theme_constant("outline_size") < values_label.get_theme_constant("outline_size"), "Caption outline is more delicate than numeric outline")
		asserts.assert_equal(kind_label.get_theme_color("font_color"), TOKENS.color_token(&"secondary"), "Caption uses muted secondary text color")
		asserts.assert_equal(values_label.get_theme_color("font_color"), TOKENS.color_token(&"text_bright"), "Numeric value uses focal text_bright color")
		# P005-R06D: Check that standard 30/30 value has at least 10 px clearance on each side inside glass aperture
		orb.set_resource_values(30, 30, false)
		var sz_30: int = values_label.get_theme_font_size("font_size")
		var w_30: float = values_label.get_theme_font("font").get_string_size(values_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, sz_30).x
		var glass_aperture_w: float = orb.size.x * 0.664
		asserts.assert_true(glass_aperture_w - w_30 >= 20.0, "30/30 has at least 10 px safe margin on each side (glass=%.1f, w=%.1f, margin=%.1f)" % [glass_aperture_w, w_30, (glass_aperture_w - w_30) * 0.5])
		for values: Vector2i in [Vector2i(30, 30), Vector2i(18, 30), Vector2i(0, 30), Vector2i(100, 100), Vector2i(1, 1), Vector2i(5, 5), Vector2i(0, 5), Vector2i(10, 10)]:
			orb.set_resource_values(values.x, values.y, false)
			var label: Label = orb.get_node("Values") as Label
			var font_size: int = label.get_theme_font_size("font_size")
			var width: float = label.get_theme_font("font").get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			asserts.assert_true(width + 8 <= orb.size.x * 0.65, "All requested values fit aperture with outline")
			asserts.assert_true(font_size * 2.0 / 3.0 >= 16, "Values at least 16 physical pixels at 720p")
		# Optional mounting can be removed without losing the original reusable behavior.
		orb.housing_texture = null
		orb._layout_contents()
		asserts.assert_equal(orb._orb_material.get_shader_parameter("external_housing"), false, "Null mounting restores procedural shader")
		asserts.assert_false(mounting.visible, "No empty overlay after removing mounting")
		asserts.assert_equal((orb.get_node("Reservoir") as Control).size, orb.size, "Default reservoir geometry restored")
	screen.free()

func _test_integration(asserts: TestAsserts) -> void:
	asserts.set_current_test("liquid_orb:four_independent_instances")
	var screen: CombatScreen = SCREEN_SCENE.instantiate() as CombatScreen
	var orbs: Array[LiquidResourceOrb] = [screen.get_player_health_orb(), screen.get_player_mana_orb(), screen.get_opponent_health_orb(), screen.get_opponent_mana_orb()]
	for i: int in range(orbs.size()):
		asserts.assert_true(orbs[i] != null, "Integrated orb %d" % i)
		var zone: Control = orbs[i].get_parent() as Control
		asserts.assert_true(Rect2(Vector2.ZERO, zone.size).encloses(Rect2(orbs[i].position, orbs[i].size)), "Orb contained in existing hero panel")
		orbs[i].set_resource_values(3, 5, false)
		for j: int in range(i):
			asserts.assert_not_equal(orbs[i]._orb_material, orbs[j]._orb_material, "Unique mutable material")
			asserts.assert_equal(orbs[i]._orb_material.shader, orbs[j]._orb_material.shader, "Shared immutable shader")
	orbs[0].set_resource_values(0, 30, false)
	for i: int in range(1, 4):
		asserts.assert_true(is_equal_approx(orbs[i].get_visible_fill_ratio(), 0.6), "Other orb fill unaffected")
		asserts.assert_true(is_equal_approx(float(orbs[i]._orb_material.get_shader_parameter("fill_ratio")), 0.6), "Other GPU uniform unaffected")
	asserts.assert_equal(orbs[1].resource_kind, LiquidResourceOrb.ResourceKind.MANA, "Player Mana")
	asserts.assert_equal(orbs[2].resource_kind, LiquidResourceOrb.ResourceKind.HEALTH, "Opponent Health")
	asserts.assert_equal(orbs[3].resource_kind, LiquidResourceOrb.ResourceKind.MANA, "Opponent Mana")
	var mana_color: Color = orbs[1]._orb_material.get_shader_parameter("liquid_color")
	orbs[0].set_resource_kind(LiquidResourceOrb.ResourceKind.MANA)
	orbs[0].set_resource_kind(LiquidResourceOrb.ResourceKind.HEALTH)
	asserts.assert_equal(orbs[1]._orb_material.get_shader_parameter("liquid_color"), mana_color, "Palette changes remain independent")
	screen.free()
