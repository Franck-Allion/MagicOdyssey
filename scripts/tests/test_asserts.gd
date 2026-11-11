class_name TestAsserts
extends RefCounted

## Reusable, fully typed assertion helper for MagicOdyssey native tests.
## Tracks passed and failed assertion counts and contextual failure diagnostics.

var passed_count: int = 0
var failed_count: int = 0
var failures: Array[String] = []
var current_test_name: String = "general"


func set_current_test(test_name: String) -> void:
	current_test_name = test_name


func assert_true(condition: bool, message: String = "") -> bool:
	if condition:
		passed_count += 1
		return true
	_record_failure("Expected TRUE but was FALSE", message)
	return false


func assert_false(condition: bool, message: String = "") -> bool:
	if not condition:
		passed_count += 1
		return true
	_record_failure("Expected FALSE but was TRUE", message)
	return false


func assert_equal(actual: Variant, expected: Variant, message: String = "") -> bool:
	if actual == expected:
		passed_count += 1
		return true
	var detail: String = "Expected <%s> (%s) but got <%s> (%s)" % [
		str(expected), type_string(typeof(expected)),
		str(actual), type_string(typeof(actual))
	]
	_record_failure(detail, message)
	return false


func assert_not_equal(actual: Variant, expected: Variant, message: String = "") -> bool:
	if actual != expected:
		passed_count += 1
		return true
	var detail: String = "Expected values to differ, but both were <%s>" % str(actual)
	_record_failure(detail, message)
	return false


func reset() -> void:
	passed_count = 0
	failed_count = 0
	failures.clear()
	current_test_name = "general"


func get_summary() -> Dictionary:
	return {
		"passed": passed_count,
		"failed": failed_count,
		"total": passed_count + failed_count,
		"failures": failures.duplicate()
	}


func _record_failure(detail: String, user_message: String) -> void:
	failed_count += 1
	var formatted: String
	if user_message.is_empty():
		formatted = "[%s] FAIL: %s" % [current_test_name, detail]
	else:
		formatted = "[%s] FAIL: %s — %s" % [current_test_name, user_message, detail]
	failures.append(formatted)
	print(formatted)
