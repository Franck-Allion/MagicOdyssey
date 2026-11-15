extends SceneTree
## Actual GPU evidence, native input and explicit review-only fixture states.
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const OUT: String = "res://docs/art/reviews/p005-r08b/"
var _failed: bool = false
var _activations: int = 0

func _init() -> void:
	if DisplayServer.get_name() == "headless":
		quit(2)
		return
	_run.call_deferred()

func _run() -> void:
	print("R08B GPU: %s / %s" % [Engine.get_version_info().string, RenderingServer.get_video_adapter_name()])
	for dimensions: Vector2i in [Vector2i(1920,1080), Vector2i(1280,720)]:
		var vp: SubViewport = SubViewport.new()
		vp.size = dimensions
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(vp)
		var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
		screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
		screen.size = Vector2(dimensions)
		vp.add_child(screen)
		for orb: LiquidResourceOrb in [screen.get_player_health_orb(),screen.get_player_mana_orb(),screen.get_opponent_health_orb(),screen.get_opponent_mana_orb()]:
			orb.set_animation_enabled(false)
		var img: Image = await _render(vp)
		_save(img,"combat_screen_%dp.png" % dimensions.y)
		var f: float = float(dimensions.y)/1080.0
		_save(img.get_region(_scaled(Rect2i(1624,220,272,836),f)),"utility_hud_%dp.png" % dimensions.y)
		_save(img.get_region(_scaled(Rect2i(1624,24,272,166),f)),"opponent_deck_graveyard_%dp.png" % dimensions.y)
		var baseline: Image = Image.load_from_file(ProjectSettings.globalize_path(OUT+"before_%dp.png" % dimensions.y))
		for region: Rect2i in [Rect2i(0,0,312,1080),Rect2i(320,24,1280,166),Rect2i(320,220,1280,560),Rect2i(320,804,1280,252)]:
			var a: Image = baseline.get_region(_scaled(region,f))
			var b: Image = img.get_region(_scaled(region,f))
			var changed: int = 0
			var maximum: float = 0.0
			for y: int in range(a.get_height()):
				for x: int in range(a.get_width()):
					var ca: Color = a.get_pixel(x,y)
					var cb: Color = b.get_pixel(x,y)
					if ca != cb:
						changed += 1
						maximum = maxf(maximum,maxf(absf(ca.r-cb.r),maxf(absf(ca.g-cb.g),absf(ca.b-cb.b))))
			print("PRESERVED %dp %s changed=%d max=%.6f" % [dimensions.y,region,changed,maximum])
			_check(changed == 0,"Preserved region bit-exact: %s %dp" % [region,dimensions.y])
		if dimensions.y == 1080:
			var comparison: Image = Image.create_empty(3840,1080,false,img.get_format())
			comparison.blit_rect(baseline,Rect2i(0,0,1920,1080),Vector2i.ZERO)
			comparison.blit_rect(img,Rect2i(0,0,1920,1080),Vector2i(1920,0))
			_save(comparison,"before_after_1080p.png")
			_save(img.get_region(Rect2i(1758,660,104,212)),"empty_graveyard.png")
		# All fixtures below are explicit visual samples, never combat state.
		for count: int in [0,1,9,10,34,100]:
			screen.get_player_deck().visual_count = count
			screen.get_opponent_deck().visual_count = count
			await _render(vp)
			for deck: DeckStackView in [screen.get_player_deck(),screen.get_opponent_deck()]:
				_text_fits(deck.get_node("Count") as Label)
			if dimensions.y == 1080:
				_save((await _render(vp)).get_region(Rect2i(1648,24,220,166)),"deck_count_%d.png" % count)
		for count: int in [0,1,12,100]:
			var fixture: GraveyardView.PreviewCard = GraveyardView.PreviewCard.new()
			fixture.title = "Arcane Knight" if count <= 1 else "Astral Weaver"
			fixture.rarity = &"rare" if count <= 1 else &"epic"
			_check(screen.get_player_graveyard().set_preview(count,fixture),"Accept explicit last-entering snapshot")
			_check(screen.get_opponent_graveyard().set_preview(count,fixture),"Same opponent graveyard API")
			var sample: Image = await _render(vp)
			for grave: GraveyardView in [screen.get_player_graveyard(),screen.get_opponent_graveyard()]:
				_text_fits(grave.get_node("Count") as Label)
			_save(sample.get_region(_scaled(Rect2i(1648,660,220,212),f)),"graveyard_%dp_%d.png" % [dimensions.y,count])
			if dimensions.y == 1080 and count == 12:
				_save(sample.get_region(Rect2i(1758,660,104,212)),"nonempty_graveyard.png")
		for turn_text: String in ["TURN 1","TURN 10"]:
			for phase_text: String in ["PLAYER / ACTION","OPPONENT / ACTION","END-OF-TURN ATTACK"]:
				screen.set_turn_preview(turn_text,phase_text)
				await _render(vp)
				_text_fits(screen.get_match_status().get_node("Turn") as Label)
				_text_fits(screen.get_match_status().get_node("Phase") as Label)
		_save((await _render(vp)).get_region(_scaled(Rect2i(1624,220,272,836),f)),"worst_case_%dp.png" % dimensions.y)
		await _button_input(vp,screen,dimensions.y)
		vp.queue_free()
		await process_frame
	print("R08B GPU RESULT: %s" % ("FAIL" if _failed else "PASS"))
	quit(1 if _failed else 0)

func _button_input(vp: SubViewport, screen: CombatScreen, resolution: int) -> void:
	var button: PremiumEndTurnButton = screen.get_end_turn_button() as PremiumEndTurnButton
	button.pressed.connect(func() -> void: _activations += 1)
	var center: Vector2 = button.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = center
	motion.global_position = center
	vp.push_input(motion,true)
	await create_timer(0.16).timeout
	_check(button.is_hovered(),"Real viewport pointer hover")
	_check(button.get_visual_state() == PremiumEndTurnButton.VisualState.HOVER,"Hover state follows native input")
	var hover: Image = await _render(vp)
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.position = center
	click.global_position = center
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	vp.push_input(click,true)
	await create_timer(0.16).timeout
	_check(button.is_pressed(),"Native Button held down")
	_check(button.get_visual_state() == PremiumEndTurnButton.VisualState.PRESSED,"Pressed feedback follows native input")
	var pressed: Image = await _render(vp)
	var previous: int = _activations
	click.pressed = false
	vp.push_input(click,true)
	await process_frame
	_check(_activations == previous+1,"Native mouse activation signal")
	button.grab_focus()
	var key: InputEventKey = InputEventKey.new()
	key.keycode = KEY_SPACE
	key.pressed = true
	vp.push_input(key,true)
	await process_frame
	key.pressed = false
	vp.push_input(key,true)
	await process_frame
	_check(_activations == previous+2,"Keyboard activation signal")
	button.release_focus()
	button.disabled = true
	await create_timer(0.16).timeout
	var disabled_img: Image = await _render(vp)
	_check(button.get_visual_state() == PremiumEndTurnButton.VisualState.DISABLED,"Disabled contrast and saturation")
	previous = _activations
	click.pressed = true
	vp.push_input(click,true)
	click.pressed = false
	vp.push_input(click,true)
	await process_frame
	_check(_activations == previous,"Disabled Button rejects activation")
	button.disabled = false
	motion.position = Vector2(960,500)*float(resolution)/1080.0
	motion.global_position = motion.position
	vp.push_input(motion,true)
	await create_timer(0.16).timeout
	var normal: Image = await _render(vp)
	var region: Rect2i = Rect2i(button.get_global_rect())
	var states: Array[Image] = [normal,hover,pressed,disabled_img]
	var sheet: Image = Image.create_empty(region.size.x,region.size.y*4,false,normal.get_format())
	for index: int in range(4):
		sheet.blit_rect(states[index],region,Vector2i(0,index*region.size.y))
		if index > 0:
			_check(states[0].get_region(region).get_data() != states[index].get_region(region).get_data(),"Distinct rendered button state %d" % index)
	_save(sheet,"end_turn_states_%dp.png" % resolution)
	if resolution == 1080:
		_save(sheet,"end_turn_states.png")

func _text_fits(label: Label) -> void:
	var font: Font = label.get_theme_font("font")
	var font_size: int = label.get_theme_font_size("font_size")
	_check(label.get_line_count()*font.get_height(font_size) <= label.size.y+0.1,"Text height fits: "+label.text)
	_check(font.get_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x <= label.size.x+0.1,"Text width fits: "+label.text)

func _scaled(rect: Rect2i, factor: float) -> Rect2i:
	return Rect2i(Vector2(rect.position)*factor,Vector2(rect.size)*factor)

func _render(vp: SubViewport) -> Image:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	return vp.get_texture().get_image()

func _save(img: Image, filename: String) -> void:
	_check(img.save_png(ProjectSettings.globalize_path(OUT+filename)) == OK,"CAPTURE "+filename)

func _check(condition: bool, message: String) -> void:
	print("%s: %s" % ["PASS" if condition else "FAIL",message])
	_failed = _failed or not condition
