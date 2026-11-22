extends "res://docs/art/reviews/p008-f04/capture.gd"
## Verify the installed default style, with no candidate-style override.
const PRODUCTION: GDScript = preload("res://docs/art/reviews/p008-f03/verification/v05.gd")

func make_token(_variant: String) -> Control:
	return PRODUCTION.new() as Control

func probes(_variant: String,_height: int,_at: Vector2,_token_scale: Vector2) -> void:
	pass

func _run() -> void:
	for dim: Vector2i in [Vector2i(1920,1080),Vector2i(1280,720)]:
		await capture("production",dim)
	var file: FileAccess = FileAccess.open(OUT+"production_results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(checks.get_summary(),"  "))
	print("F04_PRODUCTION_GPU=",checks.get_summary())
	quit(0 if checks.failed_count==0 else 1)
