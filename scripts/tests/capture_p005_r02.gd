extends SceneTree
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const OUT: String = "res://docs/art/reviews/p005-r02/"
var _failed: bool = false

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	for dimensions: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var vp: SubViewport = SubViewport.new()
		vp.size = dimensions
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(vp)
		var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
		screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
		screen.size = Vector2(dimensions)
		vp.add_child(screen)
		for orb: LiquidResourceOrb in [screen.get_player_health_orb(), screen.get_player_mana_orb(), screen.get_opponent_health_orb(), screen.get_opponent_mana_orb()]:
			orb.set_animation_enabled(false)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var image: Image = vp.get_texture().get_image()
		_check(image.save_png(OUT + "combat_screen_%dp.png" % dimensions.y) == OK, "Capture %s" % dimensions)
		var bounds: Rect2 = Rect2(Vector2.ZERO, Vector2(dimensions))
		for zone: Control in [screen.get_opponent_hero_zone(), screen.get_player_hero_zone(), screen.get_battlefield_zone(), screen.get_player_hand_zone(), screen.get_match_status(), screen.get_action_bar_zone(), screen.get_node("CombatLayout/OpponentHand") as Control]:
			_check(bounds.encloses(zone.get_global_rect()), "%s enclosed at %s" % [zone.name, dimensions])
		var guides: int = 0
		for row: Control in [screen.get_opponent_defense_row(), screen.get_opponent_attack_row(), screen.get_player_attack_row(), screen.get_player_defense_row()]:
			for child: Node in row.get_children():
				if child.name.begins_with("SlotGuide_"):
					guides += 1
					_check(bounds.encloses((child as Control).get_global_rect()), "Tactical guide enclosed")
		_check(guides == 24, "24 tactical positions")
		var opponent_hand: Control = screen.get_node("CombatLayout/OpponentHand") as Control
		_check(opponent_hand.get_child_count() == 6, "Opponent sample has six backs")
		for card: Node in opponent_hand.get_children():
			_check(card.has_node("CardBack"), "Opponent card is a back")
			_check(card.find_children("*", "TextureRect", true, false).is_empty(), "Opponent cards have no face textures")
		for fan: Control in [screen.get_node("CombatLayout/OpponentHand") as Control, screen.get_node("CombatLayout/PlayerHandZone/Fan") as Control]:
			for card: Node in fan.get_children():
				var c: Control = card as Control
				for point: Vector2 in [Vector2.ZERO, Vector2(c.size.x, 0), c.size, Vector2(0, c.size.y)]:
					_check(bounds.has_point(c.get_global_transform() * point), "Fan card corner visible")
		if dimensions.y == 1080:
			_check(image.get_region(Rect2i(40, 240, 300, 790)).save_png(OUT + "combat_screen_closeup_left_hero.png") == OK, "Hero closeup")
			_check(image.get_region(Rect2i(400, 810, 1120, 260)).save_png(OUT + "combat_screen_closeup_hand.png") == OK, "Hand closeup")
		vp.queue_free()
	await _resource_readability()
	print("P005-R02 GPU RESULT: %s" % ("FAIL" if _failed else "PASS"))
	quit(1 if _failed else 0)

func _resource_readability() -> void:
	var vp: SubViewport = SubViewport.new()
	vp.size = Vector2i(1000, 260)
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var sample_values: Array[Vector2i] = [Vector2i(1, 30), Vector2i(8, 100), Vector2i(99, 100), Vector2i(100, 100)]
	var scene: PackedScene = load("res://scenes/hud/liquid_resource_orb.tscn") as PackedScene
	for index: int in range(sample_values.size()):
		var orb: LiquidResourceOrb = scene.instantiate() as LiquidResourceOrb
		orb.position = Vector2(15 + index * 250, 20)
		orb.size = Vector2(220, 220)
		vp.add_child(orb)
		orb.set_animation_enabled(false)
		orb.set_resource_values(sample_values[index].x, sample_values[index].y, false)
		var label: Label = orb.get_node("Values") as Label
		var font: Font = label.get_theme_font("font")
		var width: float = font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, label.get_theme_font_size("font_size")).x
		_check(width + 8.0 <= orb.size.x * 0.65, "Asymmetric and multi-digit values fit glass")
		_check(is_equal_approx(label.position.x + label.size.x * 0.5, orb.size.x * 0.5), "Value label centered on reservoir axis")
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	_check(vp.get_texture().get_image().save_png(OUT + "resource_readability.png") == OK, "Resource readability gallery")
	vp.queue_free()

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error(message)
