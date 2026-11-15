extends SceneTree
## Production-scene GPU evidence. --before captures the pre-integration checkout.
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const OUT: String = "res://docs/art/reviews/p005-r07b/"
var _failed: bool = false

func _init() -> void:
	if DisplayServer.get_name() == "headless":
		quit(2)
		return
	_run.call_deferred()

func _run() -> void:
	print("R07B GPU: %s / %s" % [Engine.get_version_info().string, RenderingServer.get_video_adapter_name()])
	var before_mode: bool = "--before" in OS.get_cmdline_user_args()
	if not before_mode:
		await _card_back_opacity()
	for dimensions: Vector2i in [Vector2i(1920,1080), Vector2i(1280,720)]:
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
		if before_mode:
			_save(image,"before_%dp.png" % dimensions.y)
		else:
			_save(image,"combat_screen_%dp.png" % dimensions.y)
			var factor: float = float(dimensions.y)/1080.0
			_save(image.get_region(_scaled(Rect2i(16,16,288,312),factor)),"opponent_hud_closeup_%dp.png" % dimensions.y)
			_save(image.get_region(_scaled(Rect2i(640,16,640,184),factor)),"opponent_hand_%dp.png" % dimensions.y)
			var baseline: Image = Image.load_from_file(ProjectSettings.globalize_path(OUT+"before_%dp.png" % dimensions.y))
			_check(not baseline.is_empty(),"Before GPU capture available")
			_check(image.get_region(_scaled(Rect2i(0,344,1920,736),factor)).get_data() == baseline.get_region(_scaled(Rect2i(0,344,1920,736),factor)).get_data(),"Player, board and utilities bit-exact below header")
			if dimensions.y == 1080:
				var comparison: Image = Image.create_empty(3840,1080,false,image.get_format())
				comparison.blit_rect(baseline,Rect2i(0,0,1920,1080),Vector2i.ZERO)
				comparison.blit_rect(image,Rect2i(0,0,1920,1080),Vector2i(1920,0))
				_save(comparison,"before_after_1080p.png")
			_check_containment(screen.get_opponent_hero_zone(),screen.get_opponent_hero_zone().get_global_rect())
			var hp: LiquidResourceOrb = orbs[2]
			var mana: LiquidResourceOrb = orbs[3]
			for values: Vector2i in [Vector2i(30,30),Vector2i(18,30),Vector2i(0,30),Vector2i(100,100)]:
				hp.set_resource_values(values.x,values.y,false)
				mana.set_resource_values(10,10,false)
				var sample: Image = await _render(vp)
				_save(sample,"values_%dp_hp%d_%d.png" % [dimensions.y,values.x,values.y])
				if values.x == 100:
					_save(sample.get_region(_scaled(Rect2i(16,16,288,312),factor)),"worst_case_closeup_%dp.png" % dimensions.y)
			for values: Vector2i in [Vector2i(0,0),Vector2i(1,1),Vector2i(5,5),Vector2i(10,10)]:
				mana.set_resource_values(values.x,values.y,false)
				_save(await _render(vp),"mana_%dp_%d_%d.png" % [dimensions.y,values.x,values.y])
			for orb: LiquidResourceOrb in [hp,mana]:
				orb.set_animation_enabled(true)
				orb.set_resource_values(3,5,false)
			var first: Image = await _render(vp)
			_save(first,"animation_%dp_0.png" % dimensions.y)
			await create_timer(0.35).timeout
			var second: Image = await _render(vp)
			_save(second,"animation_%dp_1.png" % dimensions.y)
			for orb: LiquidResourceOrb in [hp,mana]:
				var region: Rect2i = Rect2i(orb.get_global_rect())
				_check(first.get_region(region).get_data() != second.get_region(region).get_data(),"Miniature %s GPU animation %dp" % [orb.name,dimensions.y])
		vp.queue_free()
		await process_frame
	print("R07B GPU RESULT: %s" % ("FAIL" if _failed else "PASS"))
	quit(1 if _failed else 0)

func _card_back_opacity() -> void:
	var vp: SubViewport = SubViewport.new()
	vp.size = Vector2i(192,256)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var background: ColorRect = ColorRect.new()
	background.size = Vector2(vp.size)
	background.color = Color.RED
	vp.add_child(background)
	var fan: CombatPreviewCards = CombatPreviewCards.new()
	fan.face_down = true
	fan.size = Vector2(1280,160)
	fan.rebuild()
	var back: TextureRect = fan.get_child(0).get_node("CardBack").duplicate() as TextureRect
	back.size = Vector2(vp.size)
	fan.free()
	vp.add_child(back)
	var red: Image = await _render(vp)
	background.color = Color.GREEN
	var green: Image = await _render(vp)
	var interior: Rect2i = Rect2i(30,40,130,176)
	_check(red.get_region(interior).get_data() == green.get_region(interior).get_data(),"Card interior opaque over contrasting backgrounds")
	_check(red.get_pixel(0,0) != green.get_pixel(0,0),"Card exterior retains genuine transparency")
	_save(red,"card_back_over_red.png")
	_save(green,"card_back_over_green.png")
	vp.queue_free()
	await process_frame

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

func _check_containment(parent: Control, bounds: Rect2) -> void:
	for node: Node in parent.get_children():
		var child: Control = node as Control
		if child == null or not child.is_visible_in_tree():
			continue
		_check(bounds.grow(0.1).encloses(child.get_global_rect()),"Visible child contained: "+str(child.name))
		_check_containment(child,bounds)
