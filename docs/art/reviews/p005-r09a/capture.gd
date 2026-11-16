extends SceneTree
## AUDIT ONLY. Runtime snapshots and geometry fixtures; no persisted production edits.
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const OUT: String = "res://docs/art/reviews/p005-r09a/"
var _failed: bool = false
var _activations: int = 0
var observations: Dictionary[String, Variant] = {}

func _init() -> void:
	if DisplayServer.get_name() == "headless":
		quit(2)
		return
	_run.call_deferred()

func _run() -> void:
	print("R09A GPU: %s / %s" % [Engine.get_version_info().string,RenderingServer.get_video_adapter_name()])
	for dimensions: Vector2i in [Vector2i(1920,1080),Vector2i(1280,720)]:
		var vp: SubViewport = SubViewport.new()
		vp.size = dimensions
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(vp)
		var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
		screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
		screen.size = Vector2(dimensions)
		vp.add_child(screen)
		var orbs: Array[LiquidResourceOrb] = [screen.get_player_health_orb(),screen.get_player_mana_orb(),screen.get_opponent_health_orb(),screen.get_opponent_mana_orb()]
		for orb: LiquidResourceOrb in orbs:
			orb.set_animation_enabled(false)
		var image: Image = await _render(vp)
		_save(image,"combat_default_%dp.png" % dimensions.y)
		var f: float = dimensions.y/1080.0
		if dimensions.y == 1080:
			_save(image.get_region(Rect2i(1624,220,272,836)),"utility_hud_closeup.png")
			_save(image.get_region(Rect2i(24,344,272,700)),"player_hud_closeup.png")
			_save(image.get_region(Rect2i(24,24,272,296)),"opponent_hud_closeup.png")
			_measure_scene(screen)
		var audit_tag: Label = _audit_tag(screen,"AUDIT FIXTURE - 10 DISPLAY CARDS; GAMEPLAY CAP REMAINS 7")
		# Full hand is a UI capacity stress fixture, not a change to the normative 7-card rule.
		var fan: CombatPreviewCards = screen.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
		fan.display_count = 10
		fan.rebuild()
		image = await _render(vp)
		_save(image,"combat_full_hand_%dp.png" % dimensions.y)
		await _hover_scenarios(vp,screen,dimensions)
		audit_tag.visible = false
		var density: Control = _crowded_board(screen)
		image = await _render(vp)
		_save(image,"combat_crowded_board_%dp.png" % dimensions.y)
		density.queue_free()
		await process_frame
		audit_tag.visible = true
		audit_tag.text = "AUDIT FIXTURE - PUBLIC UTILITY SNAPSHOTS; NO COMBAT STATE"
		# Explicit public presentation snapshots; independent from any domain engine.
		fan.display_count = 7
		fan.rebuild()
		screen.set_recent_actions_preview(["Arcane Knight entered play.","Runic Relic equipped.","Opponent drew a card."])
		screen.get_player_deck().visual_count = 100
		screen.get_opponent_deck().visual_count = 34
		var fixture: GraveyardView.PreviewCard = GraveyardView.PreviewCard.new()
		screen.get_player_graveyard().set_preview(12,fixture)
		fixture = GraveyardView.PreviewCard.new()
		fixture.title = "Astral Weaver"
		fixture.rarity = &"epic"
		screen.get_opponent_graveyard().set_preview(1,fixture)
		image = await _render(vp)
		_save(image,"combat_populated_utility_%dp.png" % dimensions.y)
		if dimensions.y == 1080:
			_save(image.get_region(Rect2i(1624,24,272,1032)),"populated_utility_closeup.png")
		await _button_input(vp,screen,dimensions.y)
		audit_tag.text = "AUDIT FIXTURE - EXTREME DISPLAY VALUES; NO COMBAT STATE"
		# Boundary-value fixture.
		for orb: LiquidResourceOrb in orbs:
			orb.set_resource_values(100 if orb.resource_kind == LiquidResourceOrb.ResourceKind.HEALTH else 10,100 if orb.resource_kind == LiquidResourceOrb.ResourceKind.HEALTH else 10,false)
		screen.get_opponent_deck().visual_count = 100
		screen.get_player_graveyard().set_preview(100,fixture)
		screen.get_opponent_graveyard().set_preview(100,fixture)
		screen.set_turn_preview("TURN 10","END-OF-TURN ATTACK")
		screen.set_recent_actions_preview(["Arcane Knight gains 1 Shield whenever this creature attacks.","Runic Relic equipped.","Opponent drew a card."])
		image = await _render(vp)
		_save(image,"combat_worst_case_values_%dp.png" % dimensions.y)
		var label_report: Array[Dictionary] = []
		_collect_labels(screen,label_report)
		observations["labels_%dp" % dimensions.y] = label_report
		audit_tag.text = "AUDIT MOTION FIXTURE - ALL FOUR RESERVOIRS AT 60 PERCENT FILL"
		# Stable 60 percent fill isolates surface motion from changing displayed values.
		for orb: LiquidResourceOrb in orbs:
			orb.set_resource_values(3,5,false)
			orb.set_animation_enabled(true)
		var times: Array[int] = []
		for index: int in range(6):
			image = await _render(vp)
			times.append(Time.get_ticks_msec())
			_save(image,"resource_animation_%dp_%02d.png" % [dimensions.y,index])
			for j: int in range(orbs.size()):
				_save(image.get_region(Rect2i(orbs[j].get_global_rect())),"orb_%dp_%d_%02d.png" % [dimensions.y,j,index])
			await create_timer(0.22).timeout
		observations["animation_times_%dp" % dimensions.y] = times
		for orb: LiquidResourceOrb in orbs:
			orb.set_animation_enabled(false)
		# Reservation overlay is clearly labeled and never saved to the scene.
		if dimensions.y == 1080:
			audit_tag.visible = false
			_artifact_overlay(screen)
			_save(await _render(vp),"artifact_space_study.png")
		vp.queue_free()
		await process_frame
	var file: FileAccess = FileAccess.open(OUT+"observations.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(observations,"  "))
	file.close()
	print("R09A GPU RESULT: %s" % ("FAIL" if _failed else "PASS"))
	quit(1 if _failed else 0)

func _hover_scenarios(vp: SubViewport, screen: CombatScreen, dimensions: Vector2i) -> void:
	var fan: CombatPreviewCards = screen.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
	var report: Array[Dictionary] = []
	var indices: Array[int] = [0,4,9,1,2]
	var names: Array[String] = ["left","center","right","spell","equipment"]
	for j: int in range(indices.size()):
		var index: int = indices[j]
		_pointer(vp,_rest_cost_point(fan,index))
		await create_timer(0.26).timeout
		_check(fan.get_hovered_index() == index,"Actual viewport pointer selects card %d at %dp" % [index,dimensions.y])
		_check(fan.get_hover_state() == CombatPreviewCards.HoverState.INSPECTING,"Hover settles into inspection")
		var card: Control = fan.get_child(index) as Control
		var r: Rect2 = _corners_bounds(card)
		_check(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(r),"Inspected card contained")
		_check(r.position.x >= 320.0*dimensions.y/1080.0 and r.end.x <= 1600.0*dimensions.y/1080.0,"Inspection clears both side HUDs")
		var content: CardContentOverlay
		for child: Node in card.get_children():
			if child is CardContentOverlay:
				content = child as CardContentOverlay
		report.append({"index":index,"bounds":[r.position.x,r.position.y,r.size.x,r.size.y],"title":content.accepted_content.title,"category":content.accepted_content.category,"title_physical_px":content.title_font_size*card.scale.y*dimensions.y/1080.0,"rules_physical_px":content.rules_font_size*card.scale.y*dimensions.y/1080.0})
		_save(await _render(vp),"combat_hover_%s_%dp.png" % [names[j],dimensions.y])
		_pointer(vp,Vector2(960,400)*dimensions.y/1080.0)
		await create_timer(0.26).timeout
		_check(fan.get_hovered_index() == -1 and fan.get_hover_state() == CombatPreviewCards.HoverState.IDLE,"Pointer leaves hand and fan returns to rest")
	for index: int in [0,2,4,6,8,9]:
		_pointer(vp,_rest_cost_point(fan,index))
		await create_timer(0.035).timeout
	_pointer(vp,Vector2(960,400)*dimensions.y/1080.0)
	await create_timer(0.26).timeout
	_check(fan.get_hover_state() == CombatPreviewCards.HoverState.IDLE,"Rapid scrubbing settles to rest")
	_save(await _render(vp),"combat_hover_return_%dp.png" % dimensions.y)
	observations["hover_%dp" % dimensions.y] = report

func _rest_cost_point(fan: CombatPreviewCards,index: int) -> Vector2:
	var pose: Transform2D = CombatPreviewCards.layout_pose(index,10,fan.size.x,fan.preferred_height)
	var delta: Vector2 = (CardViewLayout.MANA_CENTER-CardViewLayout.CARD_SIZE*0.5)*fan.preferred_height/1448.0
	return fan.get_global_transform()*(pose.origin+delta.rotated(pose.get_rotation()))

func _pointer(vp: SubViewport,point: Vector2) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = point
	event.global_position = point
	vp.push_input(event,true)

func _crowded_board(screen: CombatScreen) -> Control:
	var group: Control = Control.new()
	group.name = "AuditDensityOnly"
	screen.get_combat_layout().add_child(group)
	_diagnostic_label(group,"AUDIT ONLY - 24 GEOMETRY PLACEHOLDERS - NOT P008",Rect2(540,192,800,26),18)
	var rows: Array[Control] = [screen.get_opponent_defense_row(),screen.get_opponent_attack_row(),screen.get_player_attack_row(),screen.get_player_defense_row()]
	for row_index: int in range(rows.size()):
		for col: int in range(6):
			var guide: Control = rows[row_index].get_node("SlotGuide_%02d" % (col+1)) as Control
			var origin: Vector2 = guide.get_global_rect().position
			origin = screen.get_combat_layout().get_global_transform().affine_inverse()*origin
			var box: Panel = _diagnostic_box(group,Rect2(origin+Vector2(8,6),Vector2(146,100)),Color(0.1,0.7,0.75,0.8))
			_diagnostic_label(box,"TEMP C%d" % (col+1),Rect2(10,6,126,22),16)
			_diagnostic_label(box,"W                 P",Rect2(8,29,130,20),14)
			_diagnostic_label(box,"A12 / H12",Rect2(10,49,126,22),17)
			_diagnostic_label(box,"S1 S2 S3 +N",Rect2(8,75,130,20),14)
	return group

func _artifact_overlay(screen: CombatScreen) -> void:
	var overlay: Control = Control.new()
	overlay.name = "AuditArtifactReservationOnly"
	overlay.z_index = 200
	screen.get_combat_layout().add_child(overlay)
	_diagnostic_label(overlay,"AUDIT OVERLAY ONLY - Artifact candidates; no capacity assumed",Rect2(360,192,1030,26),18)
	_diagnostic_box(overlay,Rect2(296,344,24,436),Color(1,0.3,0.25,0.8))
	_diagnostic_label(overlay,"A: 24px gutter - too narrow",Rect2(320,350,330,28),16)
	_diagnostic_box(overlay,Rect2(320,780,1280,24),Color(1,0.65,0.2,0.8))
	_diagnostic_label(overlay,"B: 24px corridor - hand-hover conflict",Rect2(620,780,610,24),16)
	_diagnostic_box(overlay,Rect2(1640,198,240,48),Color(0.2,1,0.65,0.8))
	_diagnostic_label(overlay,"C: 240x48 reservation",Rect2(1644,207,232,28),16)

func _audit_tag(screen: CombatScreen,value: String) -> Label:
	var label: Label = Label.new()
	label.text = value
	label.position = Vector2(500,192)
	label.size = Vector2(1050,26)
	label.add_theme_font_size_override("font_size",17)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 200
	screen.get_combat_layout().add_child(label)
	return label

func _diagnostic_box(parent: Control,rect: Rect2,color: Color) -> Panel:
	var panel: Panel = Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.02,0.06,0.09,0.75)
	style.border_color = color
	style.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel",style)
	parent.add_child(panel)
	return panel

func _diagnostic_label(parent: Control,value: String,rect: Rect2,font_size: int) -> void:
	var label: Label = Label.new()
	label.text = value
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size",font_size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)

func _corners_bounds(control: Control) -> Rect2:
	var transform: Transform2D = control.get_global_transform()
	var points: PackedVector2Array = PackedVector2Array([transform*Vector2.ZERO,transform*Vector2(control.size.x,0),transform*control.size,transform*Vector2(0,control.size.y)])
	var r: Rect2 = Rect2(points[0],Vector2.ZERO)
	for point: Vector2 in points:
		r = r.expand(point)
	return r

func _measure_scene(screen: CombatScreen) -> void:
	var regions: Dictionary[String,Variant] = {}
	for path: String in ["CombatLayout/PlayerHeroZone","CombatLayout/OpponentHeroZone","CombatLayout/OpponentHand","CombatLayout/BattlefieldZone","CombatLayout/PlayerHandZone","CombatLayout/ActionBarZone","CombatLayout/MatchStatus"]:
		var control: Control = screen.get_node(path) as Control
		regions[path] = [control.position.x,control.position.y,control.size.x,control.size.y]
	var art: Dictionary[String,Variant] = {}
	for path: String in ["CombatLayout/PlayerHeroZone/Backplate","CombatLayout/OpponentHeroZone/Backplate","CombatLayout/ActionBarZone/Backplate","CombatLayout/MatchStatus/Backplate","CombatLayout/ActionBarZone/EndTurnButton/Artwork"]:
		var image: TextureRect = screen.get_node(path) as TextureRect
		var r: Rect2 = image.get_global_rect()
		var atlas: AtlasTexture = image.texture as AtlasTexture
		art[path] = {"rect":[r.position.x,r.position.y,r.size.x,r.size.y],"texture_size":[image.texture.get_width(),image.texture.get_height()],"source":image.texture.resource_path if atlas == null else atlas.atlas.resource_path,"crop":[0,0,image.texture.get_width(),image.texture.get_height()] if atlas == null else [atlas.region.position.x,atlas.region.position.y,atlas.region.size.x,atlas.region.size.y]}
	observations["regions"] = regions
	observations["artwork"] = art

func _collect_labels(parent: Node,report: Array[Dictionary]) -> void:
	for child: Node in parent.get_children():
		if child is Label and (child as Label).is_visible_in_tree():
			var label: Label = child as Label
			# Card text is measured separately via CardContentOverlay to include native-to-screen scale.
			if label.get_global_rect().size.x < 400:
				var r: Rect2 = label.get_global_rect()
				report.append({"path":str(label.get_path()),"text":label.text,"reference_font":label.get_theme_font_size("font_size"),"physical_font":label.get_theme_font_size("font_size")*label.get_global_transform().get_scale().y,"rect":[r.position.x,r.position.y,r.size.x,r.size.y],"lines":label.get_line_count(),"visible_lines":label.get_visible_line_count()})
		_collect_labels(child,report)

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
	_save(hover,"combat_populated_utility_hover_%dp.png" % resolution)
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
