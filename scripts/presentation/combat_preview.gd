extends Node
## Temporary entry-point policy, deliberately separate from reusable CombatScreen.
func _ready() -> void:
	set_process(false)
	_configure_review.call_deferred()
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

## Explicit standalone review flags only; no game state or automatic combat.
func _configure_review() -> void:
	var screen: CombatScreen = get_node("CombatScreen") as CombatScreen
	var fan: CombatPreviewCards = screen.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--preview-slots":
			screen.slot_hovered.connect(func(c: BattlefieldSlot.Camp, n: int, r: BattlefieldSlot.Row) -> void: print("SLOT_ENTER %d %d %d" % [c, n, r]))
			screen.slot_unhovered.connect(func(c: BattlefieldSlot.Camp, n: int, r: BattlefieldSlot.Row) -> void: print("SLOT_LEAVE %d %d %d" % [c, n, r]))
			screen.slot_selected.connect(_report_slot_click)
			for orb: LiquidResourceOrb in [screen.get_player_health_orb(), screen.get_player_mana_orb(), screen.get_opponent_health_orb(), screen.get_opponent_mana_orb()]:
				orb.set_animation_enabled(false)
			set_process(true)
		if argument == "--preview-utility":
			screen.get_end_turn_button().pressed.connect(func() -> void: print("UTILITY_PREVIEW_ACTIVATED"))
			screen.get_end_turn_button().focus_entered.connect(func() -> void: print("UTILITY_PREVIEW_FOCUSED"))
		if argument.begins_with("--preview-hand="):
			fan.display_count = clampi(argument.trim_prefix("--preview-hand=").to_int(), 0, 10)
			fan.rebuild()
		if argument == "--preview-animate":
			var timer: Timer = Timer.new()
			timer.wait_time = 1.5
			add_child(timer)
			timer.timeout.connect(_review_resource_step)
			timer.start()

var _review_step: int = 0
var _review_hand_index: int = -2

func _process(_delta: float) -> void:
	var fan: CombatPreviewCards = get_node("CombatScreen/CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
	var index: int = fan.get_hovered_index()
	if index != _review_hand_index:
		_review_hand_index = index
		print("SLOT_REVIEW_HAND %d" % index)

func _report_slot_click(camp: BattlefieldSlot.Camp, column: int, row: BattlefieldSlot.Row) -> void:
	var screen: CombatScreen = get_node("CombatScreen") as CombatScreen
	var selected: BattlefieldSlot = screen.get_selected_slot()
	print("SLOT_CLICK %d %d %d SELECTED %s" % [camp, column, row, "NONE" if selected == null else "%d %d %d" % [selected.camp, selected.column, selected.row]])

func _review_resource_step() -> void:
	var screen: CombatScreen = get_node("CombatScreen") as CombatScreen
	var health: Array[int] = [30, 18, 8, 0]
	var mana: Array[int] = [5, 3, 0, 5]
	_review_step = (_review_step + 1) % 4
	screen.get_player_health_orb().set_resource_values(health[_review_step], 30)
	screen.get_player_mana_orb().set_resource_values(mana[_review_step], 5)
	# Explicit --preview-animate fixture only, never the default opponent 0/0 state.
	screen.get_opponent_health_orb().set_resource_values(health[_review_step], 30)
	screen.get_opponent_mana_orb().set_resource_values(mana[_review_step], 5)
