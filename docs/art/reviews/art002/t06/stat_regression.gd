extends "res://docs/art/reviews/art002/t04b/capture.gd"
## Execute the existing 144-case matrix without rewriting T04B review artifacts.
func _run() -> void:
	if DisplayServer.get_name() == "headless":
		quit(2)
		return
	await _measure("res://docs/art/reviews/art002/t06/")
	print("T06_STAT_REGRESSION_FAILURES=%d" % _failures)
	quit(0 if _failures == 0 else 1)
