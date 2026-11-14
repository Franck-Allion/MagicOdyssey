class_name TestLiquidResourceOrb
extends RefCounted

const ORB_SCENE: PackedScene = preload("res://scenes/hud/liquid_resource_orb.tscn")
const SCREEN_SCENE: PackedScene = preload("res://scenes/combat/combat_screen.tscn")

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
