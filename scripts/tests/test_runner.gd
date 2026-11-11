extends SceneTree

## MagicOdyssey — Native Headless Test Runner
## Executes registered GDScript test suites in deterministic order without a GUI.
## Exits with code 0 on success, code 1 on failure, code 2 if no tests executed.

const TestAssertsScript = preload("res://scripts/tests/test_asserts.gd")
const TestHarnessSelfScript = preload("res://scripts/tests/test_harness_self.gd")


func _init() -> void:
	var failure_mode: bool = _is_failure_mode_requested()

	print("==================================================")
	print("MagicOdyssey — Native Headless Test Runner")
	print("Engine: %s" % Engine.get_version_info().string)
	if failure_mode:
		print("MODE: Intentional Failure Mode Activated (--test-failure-mode)")
	print("==================================================")

	var asserts: TestAsserts = TestAssertsScript.new()

	_run_registered_suites(asserts, failure_mode)

	var total_tests: int = asserts.passed_count + asserts.failed_count
	if total_tests == 0:
		print("ERROR: Zero tests were executed! Failing to prevent false-positive.")
		quit(2)
		return

	print("--------------------------------------------------")
	print("Test Execution Summary:")
	print("  Total Assertions: %d" % total_tests)
	print("  Passed:           %d" % asserts.passed_count)
	print("  Failed:           %d" % asserts.failed_count)
	print("==================================================")

	if asserts.failed_count > 0:
		print("RESULT: FAILED (%d failures recorded)" % asserts.failed_count)
		quit(1)
	else:
		print("RESULT: ALL TESTS PASSED")
		quit(0)


func _run_registered_suites(asserts: TestAsserts, failure_mode: bool) -> void:
	# Explicit suite registry for deterministic execution order.
	# Future test suites will be appended here.
	print("[RUN] TestHarnessSelf")
	var self_suite: TestHarnessSelf = TestHarnessSelfScript.new()
	self_suite.run_suite(asserts, failure_mode)


func _is_failure_mode_requested() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		if arg == "--test-failure-mode":
			return true
	for arg: String in OS.get_cmdline_args():
		if arg == "--test-failure-mode":
			return true
	return false
