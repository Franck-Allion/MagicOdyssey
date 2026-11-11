class_name TestHarnessSelf
extends RefCounted

## Self-test suite verifying the native test harness itself.
## Confirms assert_true, assert_false, assert_equal, assert_not_equal,
## and tests negative failure reporting when --test-failure-mode is passed.


func run_suite(asserts: TestAsserts, failure_mode: bool) -> void:
	_test_boolean_assertions(asserts)
	_test_equality_assertions(asserts)
	_test_inequality_assertions(asserts)
	_test_variant_types(asserts)

	if failure_mode:
		_test_intentional_failure(asserts)


func _test_boolean_assertions(asserts: TestAsserts) -> void:
	asserts.set_current_test("self:boolean_assertions")
	asserts.assert_true(true, "Literal true must pass assert_true")
	asserts.assert_true(1 < 2, "Comparison 1 < 2 must evaluate to true")
	asserts.assert_false(false, "Literal false must pass assert_false")
	asserts.assert_false(2 < 1, "Comparison 2 < 1 must evaluate to false")


func _test_equality_assertions(asserts: TestAsserts) -> void:
	asserts.set_current_test("self:equality_assertions")
	asserts.assert_equal(42, 42, "Integer equality must hold")
	asserts.assert_equal("MagicOdyssey", "MagicOdyssey", "String equality must hold")
	asserts.assert_equal(3.1415, 3.1415, "Float equality must hold")
	asserts.assert_equal(Vector2i(1, 2), Vector2i(1, 2), "Vector2i equality must hold")
	asserts.assert_equal([1, 2, 3], [1, 2, 3], "Array equality must hold")


func _test_inequality_assertions(asserts: TestAsserts) -> void:
	asserts.set_current_test("self:inequality_assertions")
	asserts.assert_not_equal(10, 20, "Different integers must not be equal")
	asserts.assert_not_equal("Player", "Opponent", "Different strings must not be equal")
	asserts.assert_not_equal(Vector2(1.0, 0.0), Vector2(0.0, 1.0), "Different vectors must not be equal")


func _test_variant_types(asserts: TestAsserts) -> void:
	asserts.set_current_test("self:variant_types")
	var dict_a: Dictionary = {"camp": "player", "slot": 3}
	var dict_b: Dictionary = {"camp": "player", "slot": 3}
	asserts.assert_equal(dict_a, dict_b, "Dictionaries with identical contents must equal")
	asserts.assert_not_equal(dict_a, {"camp": "opponent"}, "Different dictionaries must not equal")


func _test_intentional_failure(asserts: TestAsserts) -> void:
	asserts.set_current_test("self:intentional_failure_mode")
	print(">>> Triggering intentional failing assertion for harness verification...")
	asserts.assert_true(false, "Deliberate failure triggered for harness negative test verification (--test-failure-mode)")
