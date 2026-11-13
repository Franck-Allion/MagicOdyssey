extends SceneTree
const FIXTURE: PackedScene = preload("res://docs/art/reviews/art002/t06/fixture.tscn")
const CATEGORY: GDScript = preload("res://scripts/presentation/card_category_overlay.gd")
const CONTENT: GDScript = preload("res://scripts/presentation/card_content_overlay.gd")
const GEMS: GDScript = preload("res://scripts/presentation/rarity_gem_treatment.gd")
const OUT: String = "res://docs/art/reviews/art002/t06/"
var _failures: int = 0
var _checks: int = 0

class ManaBaseline extends CardStatOverlay:
	func _draw() -> void:
		draw_number(MANA_CENTER,_mana,126,145,TOKENS.color_token(&"text_bright"),SOCKET_SAFE_RADIUS)

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, description: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
	print("%s %s" % ["PASS" if ok else "FAIL",description])

func _viewport(dimensions: Vector2i) -> SubViewport:
	var viewport: SubViewport = SubViewport.new()
	viewport.size = dimensions
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	return viewport

func _render(viewport: SubViewport) -> Image:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	return viewport.get_texture().get_image()

func _node_image(viewport: SubViewport, node: Control) -> Image:
	viewport.add_child(node)
	var image: Image = await _render(viewport)
	viewport.remove_child(node)
	node.free()
	return image

func _category_pixels() -> void:
	var viewport: SubViewport = _viewport(Vector2i(1086,1448))
	var mana: ManaBaseline = ManaBaseline.new()
	mana.set_printed_values(12,0,0)
	var original: PackedByteArray = (await _node_image(viewport,mana)).get_data()
	var frame: Image = load("res://assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png").get_image()
	frame.convert(Image.FORMAT_RGBA8)
	var frame_pixels: PackedByteArray = frame.get_data()
	var gem_mask: Image = GEMS.MASK.get_image()
	gem_mask.convert(Image.FORMAT_RGBA8)
	var mask: PackedByteArray = gem_mask.get_data()
	var previous: PackedByteArray = PackedByteArray()
	for kind: CardContentOverlay.Category in [CardContentOverlay.Category.SPELL,CardContentOverlay.Category.EQUIPMENT]:
		var overlay: CardCategoryOverlay = CATEGORY.new()
		overlay.category = kind
		overlay.set_printed_values(12,0,0)
		var cue: Vector2 = overlay.category_cue_center()
		var cue_rect: Rect2 = Rect2(cue-Vector2(32,32),Vector2(64,64))
		_check(CONTENT.TYPE_BOUNDS.encloses(cue_rect) and not cue_rect.intersects(CONTENT.RULES_BOUNDS),"category cue stays in the existing type line")
		var clean: PackedByteArray = (await _node_image(viewport,overlay)).get_data()
		var outside: int = 0
		var changed_gems: int = 0
		var transparency_changes: int = 0
		var socket_changes: PackedInt32Array = PackedInt32Array([0,0])
		var common_socket_difference: int = 0
		for offset: int in range(0,clean.size(),4):
			var point_index: int = offset/4
			var point: Vector2 = Vector2(point_index % 1086,point_index/1086)
			var socket: int = -1
			if point.distance_to(CardStatOverlay.ATTACK_CENTER) <= CATEGORY.ENGRAVING_RADIUS:
				socket = 0
			elif point.distance_to(CardStatOverlay.HEALTH_CENTER) <= CATEGORY.ENGRAVING_RADIUS:
				socket = 1
			var changed: bool = false
			for channel: int in range(4):
				changed = changed or clean[offset+channel] != original[offset+channel]
				if not previous.is_empty() and socket >= 0 and clean[offset+channel] != previous[offset+channel]:
					common_socket_difference += 1
			if not changed:
				continue
			if socket >= 0:
				socket_changes[socket] += 1
			elif not cue_rect.has_point(point):
				outside += 1
			if mask[offset] > 0:
				changed_gems += 1
			if frame_pixels[offset+3] != 255:
				transparency_changes += 1
		_check(outside == 0 and socket_changes[0] > 100 and socket_changes[1] > 100,
			"INACTIVE_BOUNDARIES category=%s outside=%d socket_pixels=%s" % [CONTENT.category_name(kind),outside,socket_changes])
		_check(changed_gems == 0 and transparency_changes == 0,"no rarity-mask or original transparency interference gems=%d alpha=%d" % [changed_gems,transparency_changes])
		_check(common_socket_difference == 0,"Spell and Equipment use the identical neutral socket seal")
		var junk: CardCategoryOverlay = CATEGORY.new()
		junk.category = kind
		junk.set_printed_values(12,99,999,99)
		junk.set_shield_overlay(999)
		var junk_pixels: PackedByteArray = (await _node_image(viewport,junk)).get_data()
		_check(clean == junk_pixels,"PHANTOM_STATS category=%s ignored Attack/Health/Armor/Shield" % CONTENT.category_name(kind))
		previous = clean
	viewport.queue_free()
	await process_frame

func _integrated_categories() -> void:
	var scene: Control = FIXTURE.instantiate() as Control
	scene.set_anchors_preset(Control.PRESET_TOP_LEFT)
	scene.size = Vector2(1920,1080)
	root.add_child(scene)
	scene.visible = false
	var data: Array[CardContentOverlay.Content] = scene.call("category_samples")
	var holder: Control = Control.new()
	scene.add_child(holder)
	for kind: CardContentOverlay.Category in [CardContentOverlay.Category.CREATURE,CardContentOverlay.Category.SPELL,CardContentOverlay.Category.EQUIPMENT]:
		var card: Control = scene.call("_show",holder,Vector2.ZERO,760,data[int(kind)],3,1,3,2,1,5) as Control
		var text: CardContentOverlay = card.get_node("CardContent") as CardContentOverlay
		var stats: CardStatOverlay = card.get_child(card.get_child_count()-1) as CardStatOverlay
		_check(text.accepted_content.category == kind and text.title_label.text == data[int(kind)].title and text.rules_label.get_parsed_text() == data[int(kind)].rules,"integrated category keeps complete T05 text")
		_check((stats is CardCategoryOverlay) == (kind != CardContentOverlay.Category.CREATURE),"category selects the correct reusable stat renderer")
		_check(card.size == Vector2(1086,1448) and card.get_child(0).position == Vector2(124,207),"original card geometry and illustration aperture")
		card.free()
	scene.free()

func _capture(filename: String, dimensions: Vector2i, mode: int) -> void:
	var viewport: SubViewport = _viewport(dimensions)
	var scene: Control = FIXTURE.instantiate() as Control
	scene.set_anchors_preset(Control.PRESET_TOP_LEFT)
	scene.size = Vector2(dimensions)
	viewport.add_child(scene)
	scene.set("_mode",mode)
	scene.call("_rebuild")
	var image: Image = await _render(viewport)
	var result: Error = image.save_png(OUT+filename)
	_check(result == OK and image.get_size() == dimensions,"CAPTURE %s %s exit=%d" % [filename,dimensions,result])
	viewport.queue_free()
	await process_frame

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("T06 capture requires a graphical renderer")
		quit(2)
		return
	_integrated_categories()
	await _category_pixels()
	await _capture("creature_spell_equipment_1080p.png",Vector2i(1920,1080),0)
	await _capture("inactive_sockets_closeup_1080p.png",Vector2i(1920,1080),1)
	await _capture("icons_closeup_1080p.png",Vector2i(1920,1080),2)
	await _capture("mixed_hand_1080p.png",Vector2i(1920,1080),3)
	await _capture("mixed_hand_720p.png",Vector2i(1280,720),4)
	await _capture("rarity_category_matrix_1080p.png",Vector2i(1920,1080),5)
	await _capture("final_card_1080p.png",Vector2i(1920,1080),6)
	print("T06_CHECKS=%d FAILURES=%d" % [_checks,_failures])
	quit(0 if _failures == 0 else 1)
