extends SceneTree
## R08C real production GPU review. --baseline MUST run before production edits.
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const OUT: String = "res://docs/art/reviews/p005-r08c/"
var _failed: bool = false
var _activations: int = 0

func _init() -> void:
	if DisplayServer.get_name() == "headless":
		quit(2)
		return
	_run.call_deferred()

func _run() -> void:
	var baseline_mode: bool = "--baseline" in OS.get_cmdline_user_args()
	var study_mode: bool = "--study" in OS.get_cmdline_user_args()
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
		var f: float = float(dimensions.y)/1080.0
		var img: Image = await _render(vp)
		if baseline_mode:
			_save(img,"before_%dp.png" % dimensions.y)
			_save(img.get_region(_scaled(Rect2i(1624,372,272,684),f)),"utility_before_%dp.png" % dimensions.y)
		elif study_mode:
			for option: String in ["A","B"]:
				_study_layout(screen,option)
				var fixture: GraveyardView.PreviewCard = GraveyardView.PreviewCard.new()
				screen.get_player_deck().visual_count = 100
				screen.get_player_graveyard().set_preview(100,fixture)
				img = await _render(vp)
				_save(img.get_region(_scaled(Rect2i(1624,372,272,684),f)),"option_%s_%dp.png" % [option,dimensions.y])
		else:
			_save(img,"combat_screen_%dp.png" % dimensions.y)
			_save(img.get_region(_scaled(Rect2i(1624,372,272,684),f)),"utility_after_%dp.png" % dimensions.y)
			await _validate_refinement(vp,screen,img,dimensions)
		vp.queue_free()
		await process_frame
	print("R08C GPU RESULT: %s" % ("FAIL" if _failed else "PASS"))
	quit(1 if _failed else 0)

func _validate_refinement(vp: SubViewport, screen: CombatScreen, img: Image, dimensions: Vector2i) -> void:
	var f: float = float(dimensions.y)/1080.0
	var baseline: Image = Image.load_from_file(ProjectSettings.globalize_path(OUT+"before_%dp.png" % dimensions.y))
	for region: Rect2i in [Rect2i(0,0,1624,1080),Rect2i(1624,0,296,372)]:
		_check(img.get_region(_scaled(region,f)).get_data() == baseline.get_region(_scaled(region,f)).get_data(),"Both heroes, hands, battlefield, opponent piles and status preserved bit-exact: %s %dp" % [region,dimensions.y])
	var utility: Rect2i = _scaled(Rect2i(1624,372,272,684),f)
	var before: Image = baseline.get_region(utility)
	var after: Image = img.get_region(utility)
	var comparison: Image = Image.create_empty(utility.size.x*2,utility.size.y,false,img.get_format())
	comparison.blit_rect(before,Rect2i(Vector2i.ZERO,utility.size),Vector2i.ZERO)
	comparison.blit_rect(after,Rect2i(Vector2i.ZERO,utility.size),Vector2i(utility.size.x,0))
	_save(comparison,"before_after_%dp.png" % dimensions.y)
	if dimensions.y == 1080:
		_save(img.get_region(Rect2i(1624,872,272,90)),"end_turn_closeup.png")
	var log_rect: Rect2i = _scaled(Rect2i(1624,420,272,208),f)
	var typography: Image = Image.create_empty(log_rect.size.x*4,log_rect.size.y,false,img.get_format())
	var samples: Array[PackedStringArray] = [PackedStringArray(),PackedStringArray(["Arcane Knight entered play."]),PackedStringArray(["Arcane Knight entered play.","Runic Relic equipped.","Opponent drew a card."]),PackedStringArray(["Arcane Knight gains 1 Shield whenever this creature attacks."])]
	var body: Label = screen.get_action_bar_zone().get_node("RecentActions") as Label
	var title: Label = screen.get_action_bar_zone().get_node("RecentTitle") as Label
	_text_fits(title)
	for index: int in range(samples.size()):
		var entries: Array[String] = []
		entries.assign(samples[index])
		screen.set_recent_actions_preview(entries)
		var sample: Image = await _render(vp)
		_check(body.get_line_count() <= 5,"Valid recent action fixture fits visible line budget: %d" % index)
		_check(body.get_line_count()*body.get_theme_font("font").get_height(16)+(body.get_line_count()-1)*3 <= body.size.y,"Recent actions fit safe height")
		_check(body.position.y+body.size.y <= screen.get_player_deck().position.y,"Log cannot enter pile area")
		typography.blit_rect(sample,log_rect,Vector2i(index*log_rect.size.x,0))
		_save(sample.get_region(utility),"recent_%dp_%d.png" % [dimensions.y,index])
	_save(typography,"recent_actions_typography_%dp.png" % dimensions.y)
	if dimensions.y == 1080:
		_save(typography,"recent_actions_typography.png")
	screen.set_recent_actions_preview([])
	for count: int in [0,1,9,10,34,100]:
		screen.get_player_deck().visual_count = count
		await _render(vp)
		_text_fits(screen.get_player_deck().get_node("Count") as Label)
		_text_fits(screen.get_player_deck().get_node("Caption") as Label)
	for count: int in [0,1,12,100]:
		var fixture: GraveyardView.PreviewCard = GraveyardView.PreviewCard.new()
		_check(screen.get_player_graveyard().set_preview(count,fixture),"Last-entering preview remains functional")
		var sample: Image = await _render(vp)
		_text_fits(screen.get_player_graveyard().get_node("Count") as Label)
		_text_fits(screen.get_player_graveyard().get_node("Caption") as Label)
		_save(sample.get_region(_scaled(Rect2i(1624,618,272,210),f)),"graveyard_%dp_%d.png" % [dimensions.y,count])
		if dimensions.y == 1080 and count == 100:
			_save(sample.get_region(Rect2i(1624,618,272,210)),"deck_graveyard_closeup.png")
	_save(await _render(vp),"stress_counts_%dp.png" % dimensions.y)
	screen.get_player_deck().visual_count = 34
	screen.get_player_graveyard().set_preview(0)
	await _render(vp)
	await _button_input(vp,screen,dimensions.y)
	_check((screen.get_match_status().get_node("Turn") as Label).text == "TURN 01","Button input never advances a turn")

func _study_layout(screen: CombatScreen, option: String) -> void:
	var zone: Panel = screen.get_action_bar_zone()
	var title: Label = zone.get_node("RecentTitle") as Label
	title.position = Vector2(40,64)
	title.size = Vector2(192,32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size",19)
	var heading_font: SystemFont = SystemFont.new()
	heading_font.font_names = PackedStringArray(["Segoe UI", "Calibri", "Arial"])
	heading_font.font_weight = 600
	title.add_theme_font_override("font",heading_font)
	title.add_theme_color_override("font_color",UIDesignTokens.color_token(&"text_bright"))
	var body: Label = zone.get_node("RecentActions") as Label
	body.position = Vector2(44,112)
	body.size = Vector2(184,144)
	body.add_theme_font_size_override("font_size",16)
	for index: int in range(2):
		var pile: Control = screen.get_player_deck() if index == 0 else screen.get_player_graveyard()
		pile.position = Vector2(32+index*104 if option == "A" else 35+index*98,258)
		pile.size = Vector2(104,200 if option == "A" else 178)
		if index == 0:
			screen.get_player_deck().refresh()
		else:
			screen.get_player_graveyard().refresh()
	var button: Button = screen.get_end_turn_button()
	button.position = Vector2(40.38,520)
	button.size = Vector2(190,190.0*522.0/2090.0)

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
	await process_frame
	_check(button.has_focus(),"Native keyboard focus")
	_save((await _render(vp)).get_region(Rect2i(button.get_global_rect()).grow(4)),"end_turn_focus_%dp.png" % resolution)
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
