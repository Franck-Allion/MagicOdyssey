extends Node
## Temporary entry-point policy, deliberately separate from reusable CombatScreen.
func _ready() -> void:
	if DisplayServer.get_name() != "headless":
		_report_ready.call_deferred()
		var usable: Rect2i = DisplayServer.screen_get_usable_rect()
		var dimensions: Vector2i = Vector2i(mini(1920, usable.size.x - 32), mini(1080, usable.size.y - 64))
		# Review-only exact client sizes, still ordinary windowed mode.
		for argument: String in OS.get_cmdline_user_args():
			if argument.begins_with("--preview-size="):
				var parts: PackedStringArray = argument.trim_prefix("--preview-size=").split("x")
				if parts.size() == 2 and parts[0].is_valid_int() and parts[1].is_valid_int():
					dimensions = Vector2i(maxi(1280, parts[0].to_int()), maxi(720, parts[1].to_int()))
					DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
					DisplayServer.window_set_size(dimensions)
					DisplayServer.window_set_position(usable.position)
					return
		DisplayServer.window_set_size(dimensions)
		DisplayServer.window_set_position(usable.position + (usable.size - dimensions) / 2)

func _report_ready() -> void:
	# Desktop checks must wait for the scene, rather than photograph the splash.
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	print("COMBAT_PREVIEW_READY")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		get_tree().quit(0)
