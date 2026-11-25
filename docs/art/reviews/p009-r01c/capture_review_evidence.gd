extends SceneTree
## Run with the Windows Compatibility renderer. The analysis directory holds
## raw frame pairs so pixel measurements use the renderer and imported mask.

const OUT: String = "res://docs/art/reviews/p009-r01c/"
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const ART: Texture2D = preload("res://assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png")
const RARITIES: Array[StringName] = [&"common", &"uncommon", &"rare", &"epic", &"legendary"]
const RESOLUTIONS: Array[Vector2i] = [Vector2i(1920, 1080), Vector2i(1280, 720)]
const REFERENCE: Vector2i = Vector2i(1920, 1080)

var _checks: TestAsserts = TestAsserts.new()
var _analysis_dir: String = ""
var _glyph_cases: Array[Dictionary] = []
var _captures: Array[String] = []


func _init() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("GPU required for P009-R01C captures.")
		quit(2)
		return
	_analysis_dir = OS.get_environment("MO_R01C_ANALYSIS_DIR")
	if _analysis_dir.is_empty():
		_analysis_dir = ProjectSettings.globalize_path("user://p009-r01c")
	call_deferred("_run")


func _run() -> void:
	_check(DirAccess.make_dir_recursive_absolute(_analysis_dir) == OK, "Create analysis directory")
	await _source_frames()
	for resolution: Vector2i in RESOLUTIONS:
		await _gallery(resolution)
		await _hands(resolution)
	var file: FileAccess = FileAccess.open(OUT + "observations.json", FileAccess.WRITE)
	_check(file != null, "Open observations")
	if file != null:
		file.store_string(JSON.stringify({
			"engine": Engine.get_version_info().string,
			"gpu": RenderingServer.get_video_adapter_name(),
			"passed": _checks.passed_count, "failed": _checks.failed_count,
			"captures": _captures, "glyph_cases": _glyph_cases,
		}, "  ") + "\n")
	print("P009-R01C GPU checks: %d passed, %d failed" % [_checks.passed_count, _checks.failed_count])
	quit(0 if _checks.failed_count == 0 else 1)


func _check(condition: bool, message: String) -> void:
	_checks.assert_true(condition, message)


func _viewport(dimensions: Vector2i, transparent: bool = false) -> SubViewport:
	var vp: SubViewport = SubViewport.new()
	vp.size = dimensions
	vp.transparent_bg = transparent
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	if not transparent:
		var bg: ColorRect = ColorRect.new()
		bg.color = Color("#0e121a")
		bg.size = Vector2(dimensions)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vp.add_child(bg)
	return vp


func _image(vp: SubViewport) -> Image:
	await process_frame
	await RenderingServer.frame_post_draw
	return vp.get_texture().get_image()


func _save(image: Image, path: String) -> void:
	_check(image.save_png(path) == OK, "Save " + path.get_file())


func _capture(vp: SubViewport, name: String) -> Image:
	var image: Image = await _image(vp)
	_check(image.get_size() == vp.size, "Native viewport size for " + name)
	_save(image, OUT + name + ".png")
	_captures.append(name + ".png")
	return image


func _spell(rarity: StringName) -> CardPresentationModel:
	return CardPresentationModel.create_spell(
		"Fireball", 3, rarity, "Deal 4 damage to target enemy creature.", ART, "spell_fireball"
	) as CardPresentationModel


func _old_variant() -> CardVisualVariant:
	var variant: CardVisualVariant = CardVisualVariant.create_spell_variant() as CardVisualVariant
	variant.category_bounds = CardViewLayout.TYPE_BOUNDS
	variant.category_size = CardViewLayout.TYPE_SIZE
	variant.category_glyph_spacing = 0
	variant.rarity_mask = RarityGemTreatment.MASK
	return variant


func _card(vp: SubViewport, model: CardPresentationModel, position: Vector2, height: float, variant: CardVisualVariant = null) -> CardView:
	var card: CardView = CardView.new()
	vp.add_child(card)
	_check(card.apply_model(model, variant) == OK, "Apply " + model.title)
	card.position = position
	card.scale = Vector2.ONE * height / CardViewLayout.CARD_SIZE.y
	return card


func _source_frames() -> void:
	var vp: SubViewport = _viewport(Vector2i(CardViewLayout.CARD_SIZE), true)
	var card: CardView = _card(vp, _spell(&"rare"), Vector2.ZERO, 1448.0)
	card.aperture_node.hide()
	card.mana_overlay.hide()
	card.content_overlay.title_label.hide()
	card.content_overlay.rules_label.hide()
	for old: bool in [true, false]:
		var variant: CardVisualVariant = _old_variant() if old else CardVisualVariant.create_spell_variant() as CardVisualVariant
		_check(card.content_overlay.configure(
			CardContentOverlay.Content.new("Fireball", CardContentOverlay.Category.SPELL, "", "Deal 4 damage."),
			variant.rules_bounds, variant.category_bounds, variant.category_size, variant.category_glyph_spacing
		) == OK, "Build before/after text diagnostic")
		card.content_overlay.title_label.hide()
		card.content_overlay.rules_label.hide()
		var label: Label = card.content_overlay.type_label
		card.frame_node.material = null
		await _capture(vp, "spell_text_" + ("before" if old else "alignment_diagnostic"))
		card.frame_node.hide()
		_save(await _image(vp), _analysis_dir.path_join("glyph_%s.png" % ("before" if old else "after")))
		card.frame_node.show()
		if not old:
			var points: int = label.get_theme_font_size(&"font_size")
			var font: Font = label.get_theme_font(&"font")
			_glyph_cases.append({"case": "source", "font_px": points, "ascent": font.get_ascent(points),
				"descent": font.get_descent(points), "line_separation": label.get_theme_constant(&"line_separation")})
	card.content_overlay.type_label.hide()
	_save(await _image(vp), _analysis_dir.path_join("bare.png"))
	_save(RarityGemTreatment.MASK.get_image(), _analysis_dir.path_join("old_mask.png"))
	_save(RarityGemTreatment.SPELL_MASK.get_image(), _analysis_dir.path_join("spell_mask.png"))
	card.frame_node.material = RarityGemTreatment.create_material(&"rare", true, RarityGemTreatment.MASK)
	_save(await _image(vp), _analysis_dir.path_join("rare_before.png"))
	for rarity: StringName in RARITIES:
		card.frame_node.material = RarityGemTreatment.create_material(rarity, true, RarityGemTreatment.SPELL_MASK)
		_save(await _image(vp), _analysis_dir.path_join(String(rarity) + ".png"))
	card.frame_node.texture = RarityGemTreatment.SPELL_MASK
	card.frame_node.material = null
	await _capture(vp, "spell_mask_diagnostic")
	vp.free()


func _gallery(dimensions: Vector2i) -> void:
	var suffix: String = "%dp" % dimensions.y
	var middle: Vector2 = Vector2(dimensions) * 0.5
	var height: float = dimensions.y * 0.78
	var card_size: Vector2 = Vector2(height * 0.75, height)
	var vp: SubViewport = _viewport(dimensions)
	var creature: CardView = _card(vp, CardPresentationModel.create_creature(
		"Arcane Knight", 4, &"rare", 4, 5, "Human", "Whenever this creature attacks, gain 1 Shield.", 2, 1, ART
	) as CardPresentationModel, middle - card_size * 0.5, height)
	await _capture(vp, "creature_rare_baseline_" + suffix)
	creature.position.x -= dimensions.x * 0.215
	var corrected: CardView = _card(vp, _spell(&"rare"), middle - card_size * 0.5 + Vector2(dimensions.x * 0.215, 0), height)
	await _capture(vp, "creature_vs_spell_comparison_" + suffix)
	creature.free()
	var before: CardView = _card(vp, _spell(&"rare"), corrected.position - Vector2(dimensions.x * 0.43, 0), height, _old_variant())
	await _capture(vp, "spell_rare_before_after_" + suffix)
	before.free()
	corrected.free()
	for rarity: StringName in RARITIES:
		var view: CardView = _card(vp, _spell(rarity), middle - card_size * 0.5, height)
		await _capture(vp, "spell_%s_%s" % [rarity, suffix])
		view.free()
	var diagnostic: CardView = _card(vp, _spell(&"rare"), middle - card_size * 0.5, height)
	diagnostic.aperture_node.hide()
	diagnostic.mana_overlay.hide()
	diagnostic.content_overlay.title_label.hide()
	diagnostic.content_overlay.rules_label.hide()
	diagnostic.frame_node.material = null
	await _capture(vp, "spell_text_alignment_diagnostic_" + suffix)
	diagnostic.content_overlay.hide()
	diagnostic.frame_node.texture = RarityGemTreatment.SPELL_MASK
	await _capture(vp, "spell_mask_diagnostic_" + suffix)
	vp.free()


func _hands(dimensions: Vector2i) -> void:
	var suffix: String = "%dp" % dimensions.y
	var vp: SubViewport = _viewport(dimensions)
	vp.size_2d_override = REFERENCE
	vp.size_2d_override_stretch = true
	var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
	vp.add_child(screen)
	for orb: LiquidResourceOrb in [screen.get_player_health_orb(), screen.get_player_mana_orb(),
			screen.get_opponent_health_orb(), screen.get_opponent_mana_orb()]:
		orb.set_animation_enabled(false)
	var fan: CombatPreviewCards = screen.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
	fan.set_preview_scenario("mixed")
	for count: int in [2, 10]:
		fan.display_count = count
		fan.rebuild()
		var tag: String = "combat_screen_mixed_%s_%s" % ["small" if count == 2 else "large", suffix]
		var rest: Image = await _capture(vp, tag)
		var spell: CardView = fan.get_node("Card%02d" % (count - 1)) as CardView
		await _measure_visible_glyph(vp, spell, rest, tag, false)
		fan.set_preview_scenario("spells")
		for index: int in range(4):
			if index >= fan.display_count:
				break
			fan.set_inspected_card(-1, 0.0)
			var card: CardView = fan.get_node("Card%02d" % index) as CardView
			var point: Vector2 = _pick_point(fan, card, index)
			_check(point != Vector2.INF, "Exposed rest hit point for " + card.get_model().title)
			if point == Vector2.INF:
				continue
			var motion: InputEventMouseMotion = InputEventMouseMotion.new()
			motion.position = point
			motion.global_position = point
			vp.push_input(motion, true)
			var deadline: int = Time.get_ticks_msec() + 1500
			while fan.get_hover_state() != CombatPreviewCards.HoverState.INSPECTING and Time.get_ticks_msec() < deadline:
				await process_frame
			_check(fan.get_hovered_index() == index and fan.get_hover_state() == CombatPreviewCards.HoverState.INSPECTING,
				"GUI pointer lifts " + card.get_model().title)
			var name: String = "inspect_%s_%d_%s" % [card.get_model().title.to_snake_case(), count, suffix]
			var raised: Image
			if count == 10:
				raised = await _capture(vp, name)
			else:
				raised = await _image(vp)
			await _measure_visible_glyph(vp, card, raised, name, true)
		fan.set_preview_scenario("mixed")
	vp.free()


func _pick_point(fan: CombatPreviewCards, card: CardView, index: int) -> Vector2:
	for x: int in range(100, 1000, 40):
		var point: Vector2 = card.get_global_transform() * Vector2(x, 500)
		if fan.pick_card_at_global(point) == index:
			return point
	return Vector2.INF


func _measure_visible_glyph(vp: SubViewport, card: CardView, shown: Image, tag: String, raised: bool) -> void:
	var label: Label = card.content_overlay.type_label
	var t: Transform2D = card.get_global_transform()
	var scale_factor: float = float(vp.size.y) / REFERENCE.y
	_save(shown, _analysis_dir.path_join(tag + "_shown.png"))
	label.hide()
	_save(await _image(vp), _analysis_dir.path_join(tag + "_hidden.png"))
	label.show()
	_glyph_cases.append({"case": tag, "raised": raised, "title": card.get_model().title,
		"transform": [t.x.x, t.x.y, t.y.x, t.y.y, t.origin.x, t.origin.y], "viewport_scale": scale_factor})
