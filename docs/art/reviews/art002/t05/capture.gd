extends SceneTree
const FIXTURE: PackedScene = preload("res://docs/art/reviews/art002/t05/fixture.tscn")
const CONTENT: GDScript = preload("res://scripts/presentation/card_content_overlay.gd")
const OUT: String = "res://docs/art/reviews/art002/t05/"
var _failures: int = 0
var _checks: int = 0
var _fixture: Control

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, message: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
	print("%s %s" % ["PASS" if ok else "FAIL",message])

func _inside(inner: Rect2, outer: Rect2) -> bool:
	return inner.position.x >= outer.position.x-0.1 and inner.position.y >= outer.position.y-0.1 and inner.end.x <= outer.end.x+0.1 and inner.end.y <= outer.end.y+0.1

func _verify(data: CardContentOverlay.Content) -> void:
	var overlay: CardContentOverlay = CONTENT.new()
	root.add_child(overlay)
	var result: Error = overlay.configure(data)
	_check(result == OK,"accepted title=%s result=%d reason=%s" % [data.title,result,overlay.overflow_reason])
	if result != OK:
		var diagnostic: RichTextLabel = overlay.call("_rules",data,CONTENT.RULES_MINIMUM) as RichTextLabel
		overlay.add_child(diagnostic)
		print("REJECTED_MEASURE height=%d width=%d lines=%d" % [diagnostic.get_content_height(),diagnostic.get_content_width(),diagnostic.get_line_count()])
	if result == OK:
		_check(_inside(Rect2(overlay.title_label.position,overlay.title_label.size),CONTENT.TITLE_BOUNDS),"title native bounds")
		_check(_inside(Rect2(overlay.type_label.position,overlay.type_label.size),CONTENT.TYPE_BOUNDS),"type native bounds")
		_check(_inside(Rect2(overlay.rules_label.position,overlay.rules_label.size),CONTENT.RULES_BOUNDS),"rules native bounds")
		_check(overlay.rules_label.get_parsed_text() == data.rules,"literal rules retained without truncation")
		_check(overlay.title_label.text == data.title,"full title retained")
		_check(overlay.rules_label.get_content_height() <= overlay.rules_label.size.y+0.1,"all wrapped lines visible")
		_check(overlay.title_font_size >= CONTENT.TITLE_MINIMUM and overlay.rules_font_size >= CONTENT.RULES_MINIMUM,"readable size floors")
		_check(data.category == CardContentOverlay.Category.CREATURE or not overlay.type_label.text.contains("·"),"no missing/non-creature tribe placeholder")
		var fonts: Array[Font] = [CONTENT.TOKENS.THEME.get_font(&"font",&"CardTitle"),CONTENT.TOKENS.THEME.get_font(&"normal_font",&"RichTextLabel"),CONTENT.TOKENS.THEME.get_font(&"bold_font",&"RichTextLabel")]
		var missing: int = 0
		var text: String = data.title+data.rules+overlay.type_label.text
		for index: int in range(text.length()):
			if text.unicode_at(index) < 32:
				continue
			for font: Font in fonts:
				if not font.has_char(text.unicode_at(index)):
					missing += 1
		_check(missing == 0,"glyph coverage all Theme fonts")
		print("LAYOUT title=%s chars=%d title_font=%d rules_chars=%d rules_font=%d lines=%d height=%d" % [data.title,data.title.length(),overlay.title_font_size,data.rules.length(),overlay.rules_font_size,overlay.rules_label.get_line_count(),overlay.rules_label.get_content_height()])
	overlay.free()

func _verify_overflow() -> void:
	var overlay: CardContentOverlay = CONTENT.new()
	root.add_child(overlay)
	var accepted: CardContentOverlay.Content = _fixture.call("fields","Arcane Knight") as CardContentOverlay.Content
	_check(overlay.configure(accepted) == OK,"overflow test initial content")
	var original: Label = overlay.title_label
	var too_long: CardContentOverlay.Content = _fixture.call("fields",_fixture.get("TOO_LONG_TITLE")) as CardContentOverlay.Content
	_check(overlay.configure(too_long) != OK and overlay.title_overflow,"explicit very-long title overflow")
	_check(overlay.title_label == original and overlay.accepted_content == accepted,"title rejection is transactional")
	too_long = _fixture.call("fields","Arcane Knight",CardContentOverlay.Category.CREATURE,"Human",String(_fixture.get("TOO_LONG_RULES")).repeat(5)) as CardContentOverlay.Content
	_check(overlay.configure(too_long) != OK and overlay.rules_overflow,"explicit long paragraph overflow")
	_check(overlay.title_label == original and overlay.accepted_content == accepted,"rules rejection is transactional")
	var invalid: CardContentOverlay.Content = CardContentOverlay.Content.new("Fireball",CardContentOverlay.Category.SPELL,"","Literal [b]tags[/b].")
	_check(overlay.configure(invalid) == OK and overlay.rules_label.get_parsed_text() == invalid.rules,"card data is not parsed as BBCode")
	invalid.keywords.append(CardContentOverlay.KeywordSpan.new(500,5))
	_check(overlay.configure(invalid) == ERR_INVALID_DATA,"invalid keyword spans rejected")
	overlay.free()

func _capture(filename: String, dimensions: Vector2i, mode: int) -> void:
	var viewport: SubViewport = SubViewport.new()
	viewport.size = dimensions
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var scene: Control = FIXTURE.instantiate() as Control
	scene.set_anchors_preset(Control.PRESET_TOP_LEFT)
	scene.size = Vector2(dimensions)
	viewport.add_child(scene)
	scene.set("_mode",mode)
	scene.call("_rebuild")
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = viewport.get_texture().get_image()
	var result: Error = image.save_png(OUT+filename)
	_check(result == OK and image.get_size() == dimensions,"CAPTURE %s %s exit=%d" % [filename,dimensions,result])
	viewport.queue_free()
	await process_frame

func _run() -> void:
	_fixture = FIXTURE.instantiate() as Control
	_fixture.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_fixture.size = Vector2(1920,1080)
	root.add_child(_fixture)
	_fixture.visible = false
	var samples: Array[CardContentOverlay.Content] = _fixture.call("samples")
	for data: CardContentOverlay.Content in samples:
		_verify(data)
	_verify(_fixture.call("fields","Arcane Knight",CardContentOverlay.Category.CREATURE,"Human","Armor reduces damage.\nShield absorbs damage.\nRemaining damage reduces HP.\nArmor is not consumed.\nShield can be depleted.") as CardContentOverlay.Content)
	_verify(_fixture.call("fields","Rune Crafter",CardContentOverlay.Category.CREATURE,"","Grant 2 Shield to self.") as CardContentOverlay.Content)
	_verify_overflow()
	if not OS.get_cmdline_user_args().has("--verify-only"):
		if DisplayServer.get_name() == "headless":
			quit(2)
			return
		await _capture("title_length_samples_1080p.png",Vector2i(1920,1080),0)
		await _capture("rules_text_samples_1080p.png",Vector2i(1920,1080),1)
		await _capture("card_categories_1080p.png",Vector2i(1920,1080),2)
		await _capture("mixed_hand_1080p.png",Vector2i(1920,1080),3)
		await _capture("mixed_hand_720p.png",Vector2i(1280,720),3)
		await _capture("typography_stress_test_1080p.png",Vector2i(1920,1080),4)
	_fixture.queue_free()
	await process_frame
	print("T05_CHECKS=%d FAILURES=%d" % [_checks,_failures])
	quit(0 if _failures == 0 else 1)
