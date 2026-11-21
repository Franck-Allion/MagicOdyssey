extends SceneTree
## GPU Capture Suite for P008-F03: V05 Integration and Tactical Readability Acceptance.

const SCREEN_SCENE: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")
const OUT_DIR: String = "res://docs/art/reviews/p008-f03/"

const CASES: Array[Vector4i] = [
	Vector4i(1, 1, 0, 0),      # Zero defenses
	Vector4i(4, 5, 2, 1),      # Four positive single digits
	Vector4i(12, 14, 10, 12),  # Four positive double digits
	Vector4i(6, 8, 3, 2),      # Mid values
	Vector4i(99, 99, 14, 14)   # Extreme stress test
]

var clicks: int = 0
var enters: int = 0
var checks: TestAsserts = TestAsserts.new()

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		print("ERROR: capture_f03 requires GPU display server; aborting headless.")
		quit(2)
		return
		
	print("Starting P008-F03 GPU Captures on GPU: %s..." % RenderingServer.get_video_adapter_name())
	
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR + "probes/"))
	
	for dim: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		await _capture_resolution(dim)
		
	await _capture_glyph_probes()
	
	var obs_file: FileAccess = FileAccess.open(OUT_DIR + "observations.json", FileAccess.WRITE)
	obs_file.store_string(JSON.stringify({
		"engine": Engine.get_version_info().string,
		"gpu": RenderingServer.get_video_adapter_name(),
		"checks": checks.get_summary(),
		"clicks": clicks,
		"enters": enters
	}, "  "))
	
	print("ALL P008-F03 GPU CAPTURES COMPLETED. CHECKS PASSED: %d, FAILED: %d" % [checks.passed_count, checks.failed_count])
	quit(0 if checks.failed_count == 0 else 1)

func _capture_resolution(dim: Vector2i) -> void:
	var vp: SubViewport = SubViewport.new()
	vp.size = dim
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	
	var screen: CombatScreen = SCREEN_SCENE.instantiate() as CombatScreen
	screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
	screen.size = Vector2(dim)
	vp.add_child(screen)
	
	for orb in [screen.get_player_health_orb(), screen.get_player_mana_orb(), screen.get_opponent_health_orb(), screen.get_opponent_mana_orb()]:
		orb.set_animation_enabled(false)
		
	screen.slot_selected.connect(func(_c: BattlefieldSlot.Camp, _n: int, _r: BattlefieldSlot.Row) -> void: clicks += 1)
	screen.slot_hovered.connect(func(_c: BattlefieldSlot.Camp, _n: int, _r: BattlefieldSlot.Row) -> void: enters += 1)
	
	var scenarios: Array[String] = [
		"empty", "single_token", "four_positive", "double_digit",
		"zero_defense", "status_overflow", "equipment", "bright_portrait",
		"dark_portrait", "stress_99", "full_board", "mixed_board"
	]
	
	for scenario: String in scenarios:
		screen.clear_creature_tokens()
		screen.clear_slot_selection()
		
		var count: int = 24 if scenario in ["full_board", "mixed_board"] else 0 if scenario == "empty" else 1
		for index: int in range(count):
			var model: CreatureTokenViewModel = CreatureTokenDemo.MODELS[0].duplicate_model()
			var values: Vector4i = CASES[2] # double digit default
			if scenario == "zero_defense":
				values = CASES[0]
			elif scenario == "four_positive":
				values = CASES[1]
			elif scenario == "stress_99":
				values = CASES[4]
			elif scenario in ["full_board", "mixed_board"]:
				values = CASES[index % CASES.size()]
				
			model.instance_id = StringName("p008_f03_%02d" % index)
			model.effective_attack = values.x
			model.current_health = values.y
			model.maximum_health = 99
			model.armor = values.z
			model.shield = values.w
			
			if scenario in ["status_overflow", "equipment"] or (count == 24 and index % 6 == 3):
				model.statuses = CreatureTokenDemo.MODELS[3].duplicate_model().statuses
			model.weapon_attached = scenario == "equipment" or (count == 24 and index % 3 == 0)
			model.protection_attached = model.weapon_attached
			
			if scenario in ["bright_portrait", "dark_portrait"]:
				var image: Image = model.portrait.get_image()
				if image.is_compressed():
					image.decompress()
				image.adjust_bcs(2.5 if scenario == "bright_portrait" else 0.18, 1.0, 1.0)
				model.portrait = ImageTexture.create_from_image(image)
				
			var slot: BattlefieldSlot = screen.get_slots()[index]
			screen.add_creature_token(slot.get_slot_identity(), model)
			screen.get_creature_token(slot.get_slot_identity()).diagnostic_indicators_enabled = true
			
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		
		var shot: Image = vp.get_texture().get_image()
		shot.save_png("%sv05_%s_%dp.png" % [OUT_DIR, scenario, dim.y])
		print("Saved %sv05_%s_%dp.png" % [OUT_DIR, scenario, dim.y])
		
		if scenario == "full_board":
			for slot: BattlefieldSlot in screen.get_slots():
				var token: CreatureToken = screen.get_creature_token(slot.get_slot_identity())
				checks.assert_true(slot.get_global_rect().encloses(token.get_global_rect()), "Token contained in P006 slot")
				var before_c: int = clicks
				var before_e: int = enters
				var center: Vector2 = slot.get_global_rect().get_center()
				
				# Simulate hover
				var ev_m: InputEventMouseMotion = InputEventMouseMotion.new()
				ev_m.position = center
				vp.push_input(ev_m, true)
				await process_frame
				
				# Simulate click
				for pressed: bool in [true, false]:
					var ev_b: InputEventMouseButton = InputEventMouseButton.new()
					ev_b.position = center
					ev_b.button_index = MOUSE_BUTTON_LEFT
					ev_b.pressed = pressed
					vp.push_input(ev_b, true)
					await process_frame
					
				checks.assert_equal(clicks, before_c + 1, "Populated slot click routed")
				checks.assert_equal(enters, before_e + 1, "Populated slot hover routed")
				checks.assert_equal(screen.get_selected_slot(), slot, "Slot selection switches")
				
			# Save selected and hover states
			await RenderingServer.frame_post_draw
			vp.get_texture().get_image().save_png("%sv05_selected_%dp.png" % [OUT_DIR, dim.y])
			print("Saved %sv05_selected_%dp.png" % [OUT_DIR, dim.y])
			
	vp.queue_free()
	await process_frame

func _capture_glyph_probes() -> void:
	print("Capturing isolated glyph probes for exact measurement...")
	for h: int in [720, 1080]:
		var vp: SubViewport = SubViewport.new()
		vp.size = Vector2i(200, 140)
		vp.transparent_bg = true
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(vp)
		
		var scale_factor: float = (154.0 / 1536.0) * (float(h) / 1080.0)
		
		for stat_idx: int in range(4):
			var stat_name: String = ["Attack", "Armor", "Shield", "Health"][stat_idx]
			for val: int in [0, 1, 2, 6, 8, 10, 12, 14, 99]:
				# Draw single isolated glyph probe
				var probe_token: Control = Control.new()
				probe_token.scale = Vector2.ONE * scale_factor
				vp.add_child(probe_token)
				
				var center: Vector2
				if stat_idx == 0: center = CreatureTokenLayout.ATTACK
				elif stat_idx == 1: center = CreatureTokenLayout.ARMOR.get_center()
				elif stat_idx == 2: center = CreatureTokenLayout.SHIELD.get_center()
				else: center = CreatureTokenLayout.HEALTH
				
				var pts: int = CreatureTokenLayout.PRIMARY_POINTS if (stat_idx == 0 or stat_idx == 3) else CreatureTokenLayout.SECONDARY_POINTS
				var rad: float = CreatureTokenLayout.PRIMARY_RADIUS if (stat_idx == 0 or stat_idx == 3) else 0.0
				var width: float = CreatureTokenLayout.PRIMARY_WIDTH if (stat_idx == 0 or stat_idx == 3) else CreatureTokenLayout.SECONDARY_WIDTH
				
				probe_token.draw.connect(func() -> void:
					var font: Font = TOKENS.THEME.get_font(&"font", &"TacticalNumber")
					var ink: Color = TOKENS.color_token(&"text_bright")
					probe_token.draw_string(font, center + Vector2(0, 30), str(val), HORIZONTAL_ALIGNMENT_CENTER, int(width), pts, ink)
				)
				
				await process_frame
				await process_frame
				await RenderingServer.frame_post_draw
				
				var probe_img: Image = vp.get_texture().get_image()
				var p_path: String = "%sprobes/v05_%s_%d_%dp.png" % [OUT_DIR, stat_name, val, h]
				probe_img.save_png(p_path)
				probe_token.queue_free()
				await process_frame
				
		vp.queue_free()
		await process_frame
