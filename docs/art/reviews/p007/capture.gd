extends SceneTree
## P007: Hero & Turn HUD Data Binding GPU Review Capture Script
## Generates definitive GPU review evidence at 1920x1080 and 1280x720 across all P007 demonstration scenarios.

const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const OUT: String = "res://docs/art/reviews/p007/"

var observations: Dictionary[String, Variant] = {}

func _init() -> void:
	if DisplayServer.get_name() == "headless":
		print("ERROR: Graphical display server required for GPU captures.")
		quit(2)
		return
	_run.call_deferred()

func _run() -> void:
	print("P007 GPU Capture Suite: Hero & Turn HUD Data Binding")
	print("Engine: %s | GPU: %s" % [Engine.get_version_info().string, RenderingServer.get_video_adapter_name()])

	observations["engine"] = Engine.get_version_info().string
	observations["adapter"] = RenderingServer.get_video_adapter_name()
	observations["timestamp"] = Time.get_datetime_string_from_system()

	# 1. Scenario A — Default battle HUD (1080p and 720p)
	await _capture_scenario_default()

	# 2. Scenario B — Resource changes (1080p and 720p)
	await _capture_scenario_resources()

	# 3. Scenario C — Turn transition (1080p and 720p)
	await _capture_scenario_turn_transition()

	# 4. Scenario D — Counters and log (1080p and 720p)
	await _capture_scenario_counters_and_log()

	# 5. Scenario E — Extreme supported values (1080p and 720p)
	await _capture_scenario_extreme_values()

	# 6. Scenario F — Disabled End Turn state (1080p and 720p)
	await _capture_scenario_disabled_end_turn()

	# 7. Full Combat Screen after P007 (1080p and 720p)
	await _capture_full_combat_after_p007()

	# 8. Timed resource animation samples
	await _capture_resource_animation_samples()

	# Save observations
	var file: FileAccess = FileAccess.open(OUT + "observations.json", FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(observations, "  "))
		file.close()

	print("P007 GPU Captures completed successfully.")
	quit(0)

func _create_viewport(dim: Vector2i, animate_orbs: bool = false) -> SubViewport:
	var vp: SubViewport = SubViewport.new()
	vp.size = dim
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
	screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
	screen.size = Vector2(dim)
	vp.add_child(screen)
	if not animate_orbs:
		screen.get_player_health_orb().set_animation_enabled(false)
		screen.get_player_mana_orb().set_animation_enabled(false)
		screen.get_opponent_health_orb().set_animation_enabled(false)
		screen.get_opponent_mana_orb().set_animation_enabled(false)
	return vp

func _render_image(vp: SubViewport) -> Image:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	return vp.get_texture().get_image()

func _save_png(img: Image, filename: String) -> void:
	var path: String = ProjectSettings.globalize_path(OUT + filename)
	var err: Error = img.save_png(path)
	print("  [SAVED] %s (%d×%d px, err=%d)" % [filename, img.get_width(), img.get_height(), err])

func _capture_scenario_default() -> void:
	print("--- Scenario A: Default Battle HUD ---")
	for dim: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var vp: SubViewport = _create_viewport(dim)
		var screen: CombatScreen = vp.get_child(0) as CombatScreen

		var vm: CombatHudViewModel = CombatHudViewModel.create_default()
		screen.apply_hud_view_model(vm, false)

		var img: Image = await _render_image(vp)
		_save_png(img, "hud_default_%dp.png" % dim.y)

		root.remove_child(vp)
		vp.queue_free()
		await process_frame

func _capture_scenario_resources() -> void:
	print("--- Scenario B: Resource Changes ---")
	for dim: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var vp: SubViewport = _create_viewport(dim)
		var screen: CombatScreen = vp.get_child(0) as CombatScreen

		var player: HeroHudViewModel = HeroHudViewModel.new("Player", 22, 30, 0, 4, 32, 0)
		var opponent: HeroHudViewModel = HeroHudViewModel.new("Opponent", 18, 30, 2, 4, 31, 0)
		var actions: Array[String] = ["Fireball cast on Column 2 (-3 Mana, -4 Enemy HP)"]
		var vm: CombatHudViewModel = CombatHudViewModel.new(player, opponent, 2, BattlefieldSlot.Camp.PLAYER, CombatHudViewModel.Phase.ACTION, true, actions)
		screen.apply_hud_view_model(vm, false)

		var img: Image = await _render_image(vp)
		_save_png(img, "hud_resource_changed_%dp.png" % dim.y)

		root.remove_child(vp)
		vp.queue_free()
		await process_frame

func _capture_scenario_turn_transition() -> void:
	print("--- Scenario C: Turn Transition ---")
	for dim: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var vp: SubViewport = _create_viewport(dim)
		var screen: CombatScreen = vp.get_child(0) as CombatScreen

		var player: HeroHudViewModel = HeroHudViewModel.new("Player", 22, 30, 4, 4, 32, 0)
		var opponent: HeroHudViewModel = HeroHudViewModel.new("Opponent", 18, 30, 3, 4, 31, 0)
		var actions: Array[String] = ["Player ended turn.", "Opponent Turn 3 initiated."]
		var vm: CombatHudViewModel = CombatHudViewModel.new(player, opponent, 3, BattlefieldSlot.Camp.OPPONENT, CombatHudViewModel.Phase.ACTION, false, actions)
		screen.apply_hud_view_model(vm, false)

		var img: Image = await _render_image(vp)
		_save_png(img, "hud_turn_transition_%dp.png" % dim.y)

		root.remove_child(vp)
		vp.queue_free()
		await process_frame

func _capture_scenario_counters_and_log() -> void:
	print("--- Scenario D: Counters and Populated Log ---")
	for dim: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var vp: SubViewport = _create_viewport(dim)
		var screen: CombatScreen = vp.get_child(0) as CombatScreen

		var player: HeroHudViewModel = HeroHudViewModel.new("Player", 26, 30, 1, 5, 24, 5)
		var player_card: GraveyardView.PreviewCard = GraveyardView.PreviewCard.new()
		player_card.title = "Arcane Knight"
		player.top_graveyard_card = player_card

		var opponent: HeroHudViewModel = HeroHudViewModel.new("Opponent", 14, 30, 0, 5, 22, 4)
		var opponent_card: GraveyardView.PreviewCard = GraveyardView.PreviewCard.new()
		opponent_card.title = "Rampart Guard"
		opponent.top_graveyard_card = opponent_card

		var actions: Array[String] = [
			"Rampart Guard destroyed in Column 1",
			"Arcane Study cast (-3 Mana, drew 2 cards)",
			"Archon of the Sundered Sphere summoned in Column 4"
		]
		var vm: CombatHudViewModel = CombatHudViewModel.new(player, opponent, 4, BattlefieldSlot.Camp.PLAYER, CombatHudViewModel.Phase.ACTION, true, actions)
		screen.apply_hud_view_model(vm, false)

		var img: Image = await _render_image(vp)
		_save_png(img, "hud_counters_updated_%dp.png" % dim.y)

		root.remove_child(vp)
		vp.queue_free()
		await process_frame

func _capture_scenario_extreme_values() -> void:
	print("--- Scenario E: Extreme Supported Values ---")
	for dim: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var vp: SubViewport = _create_viewport(dim)
		var screen: CombatScreen = vp.get_child(0) as CombatScreen

		var player: HeroHudViewModel = HeroHudViewModel.new("Player", 0, 30, 0, 10, 0, 40)
		var opponent: HeroHudViewModel = HeroHudViewModel.new("Opponent", 30, 30, 10, 10, 100, 25)
		var actions: Array[String] = ["Lethal damage dealt to Player Hero", "Match concluded at Turn 99"]
		var vm: CombatHudViewModel = CombatHudViewModel.new(player, opponent, 99, BattlefieldSlot.Camp.PLAYER, CombatHudViewModel.Phase.MATCH_OVER, false, actions)
		screen.apply_hud_view_model(vm, false)

		var img: Image = await _render_image(vp)
		_save_png(img, "hud_extreme_values_%dp.png" % dim.y)

		root.remove_child(vp)
		vp.queue_free()
		await process_frame

func _capture_scenario_disabled_end_turn() -> void:
	print("--- Scenario F: Disabled End Turn State ---")
	for dim: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var vp: SubViewport = _create_viewport(dim)
		var screen: CombatScreen = vp.get_child(0) as CombatScreen

		var vm: CombatHudViewModel = CombatHudViewModel.create_default()
		vm.phase = CombatHudViewModel.Phase.ATTACK
		vm.end_turn_enabled = false
		screen.apply_hud_view_model(vm, false)

		var img: Image = await _render_image(vp)
		_save_png(img, "hud_disabled_end_turn_%dp.png" % dim.y)

		root.remove_child(vp)
		vp.queue_free()
		await process_frame

func _capture_full_combat_after_p007() -> void:
	print("--- Scenario G: Full Combat Screen after P007 ---")
	for dim: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var vp: SubViewport = _create_viewport(dim)
		var screen: CombatScreen = vp.get_child(0) as CombatScreen
		var fan: CombatPreviewCards = screen.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
		fan.display_count = 7
		fan.rebuild()

		var vm: CombatHudViewModel = CombatHudViewModel.create_default()
		screen.apply_hud_view_model(vm, false)

		var img: Image = await _render_image(vp)
		_save_png(img, "full_combat_after_p007_%dp.png" % dim.y)

		root.remove_child(vp)
		vp.queue_free()
		await process_frame

func _capture_resource_animation_samples() -> void:
	print("--- H. Capturing Timed Resource Animation Samples ---")
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080), true)
	var screen: CombatScreen = vp.get_child(0) as CombatScreen

	# Inject a model with animating resource change
	var vm: CombatHudViewModel = CombatHudViewModel.create_default()
	vm.player_hero.current_health = 18
	vm.player_hero.current_mana = 0
	vm.player_hero.max_mana = 4
	screen.apply_hud_view_model(vm, true)

	var sample_times: Array[float] = [0.0, 0.4, 0.8, 1.2]
	var sample_names: Array[String] = ["p007_resource_anim_t00.png", "p007_resource_anim_t04.png", "p007_resource_anim_t08.png", "p007_resource_anim_t12.png"]
	var crop_rect: Rect2i = Rect2i(24, 344, 272, 700)

	for s: int in range(sample_times.size()):
		if s > 0:
			var delay: float = sample_times[s] - sample_times[s - 1]
			await create_timer(delay).timeout
		var full_img: Image = await _render_image(vp)
		var orb_crop: Image = full_img.get_region(crop_rect)
		_save_png(orb_crop, sample_names[s])

	root.remove_child(vp)
	vp.queue_free()
	await process_frame
