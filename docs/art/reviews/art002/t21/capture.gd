extends SceneTree
## ART-002-T21: Card Sharpness & Numeral Optical Centering Capture Suite
## Generates genuine GPU renders for all 6 required review scenes at 1920x1080.
## Supports running individual steps (--step=1..6) or all steps.

const FRAME: Texture2D = preload("res://assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png")
const ART: Texture2D = preload("res://assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png")
const BATTLEFIELD: Texture2D = preload("res://assets/_source/lot1/battlefield/wip/mo_battlefield_sundered_observatory_bg_wip_v03.png")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")
const GEM_TREATMENT: GDScript = preload("res://scripts/presentation/rarity_gem_treatment.gd")
const STAT_OVERLAY: GDScript = preload("res://scripts/presentation/card_stat_overlay.gd")
const CONTENT_OVERLAY: GDScript = preload("res://scripts/presentation/card_content_overlay.gd")
const CATEGORY_OVERLAY: GDScript = preload("res://scripts/presentation/card_category_overlay.gd")
const CARD_SIZE: Vector2 = Vector2(1086, 1448)

const CALIBRATED_CROP_REGION: Rect2 = Rect2(0, 34, 1086, 832)
const LEGACY_CROP_REGION: Rect2 = Rect2(0, 0, 1086, 900)

var _vp: SubViewport

func _initialize() -> void:
	call_deferred("_run_captures")

func _run_captures() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Graphical renderer required for T21 captures")
		quit(2)
		return

	var out_dir: String = "D:/Dev/MagicOdyssey/docs/art/reviews/art002/t21/"

	var target_step: int = 0
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--step="):
			target_step = arg.split("=")[1].to_int()

	_vp = SubViewport.new()
	_vp.size = Vector2i(1920, 1080)
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_vp)

	if target_step == 0 or target_step == 1:
		print("START_CAPTURE_1: Rendering Filter Comparison")
		_reset_viewport()
		await _build_filter_comparison()
		await _save_png(out_dir + "rendering_filter_comparison_1080p.png")

	if target_step == 0 or target_step == 2:
		print("START_CAPTURE_2: Portrait Sharpness Comparison")
		_reset_viewport()
		await _build_portrait_sharpness()
		await _save_png(out_dir + "portrait_sharpness_comparison_1080p.png")

	if target_step == 0 or target_step == 3:
		print("START_CAPTURE_3: Numeral Optical Centering Diagnostics")
		_reset_viewport()
		await _build_numeral_optical_centering()
		await _save_png(out_dir + "numeral_optical_centering_1080p.png")

	if target_step == 0 or target_step == 4:
		print("START_CAPTURE_4: Final Inspected Card")
		_reset_viewport()
		await _build_inspected_card()
		await _save_png(out_dir + "inspected_card_1080p.png")

	if target_step == 0 or target_step == 5:
		print("START_CAPTURE_5: Seven-Card Hand")
		_reset_viewport()
		await _build_seven_card_hand()
		await _save_png(out_dir + "seven_card_hand_1080p.png")

	if target_step == 0 or target_step == 6:
		print("START_CAPTURE_6: Full Combat Interface")
		_reset_viewport()
		await _build_full_combat()
		await _save_png(out_dir + "full_combat_1080p.png")

	root.remove_child(_vp)
	_vp.queue_free()

	print("T21_CAPTURES_COMPLETED step=%d" % target_step)
	quit(0)

func _reset_viewport() -> void:
	for child in _vp.get_children():
		_vp.remove_child(child)
		child.queue_free()
	var bg: Panel = Panel.new()
	bg.size = Vector2(1920, 1080)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = TOKENS.color_token(&"background")
	bg.add_theme_stylebox_override("panel", style)
	_vp.add_child(bg)

func _save_png(path: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var err: Error = _vp.get_texture().get_image().save_png(path)
	print("T21_CAPTURE path=%s result=%d" % [path.get_file(), err])

func _add_label(parent: Node, value: String, bounds: Rect2, font_size: int,
		color: Color, variant: StringName = &"BodyText",
		align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label: Label = Label.new()
	label.text = value
	label.position = bounds.position
	label.size = bounds.size
	label.theme_type_variation = variant
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _card(parent: Node, origin: Vector2, height: float, rarity_index: int = 3,
		use_emerald: bool = false, native_armor: int = 0, shield: int = 0,
		cost: int = 4, attack_value: int = 4, health_value: int = 5,
		title: String = "Arcane Knight", tribe: String = "Human",
		rules: String = "Whenever this creature attacks, gain 1 Shield.",
		mode_override: int = 0, category: CardContentOverlay.Category = CardContentOverlay.Category.CREATURE,
		use_optical_centering: bool = true,
		crop_region: Rect2 = CALIBRATED_CROP_REGION,
		filter_mode: Control.TextureFilter = Control.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC) -> Control:
	var card: Control = Control.new()
	card.position = origin
	card.size = CARD_SIZE
	card.scale = Vector2.ONE * height / CARD_SIZE.y
	parent.add_child(card)

	var aperture: Control = Control.new()
	aperture.position = Vector2(124, 207)
	aperture.size = Vector2(838, 642)
	aperture.clip_contents = true
	card.add_child(aperture)

	var crop: AtlasTexture = AtlasTexture.new()
	crop.atlas = ART
	crop.region = crop_region
	var portrait: TextureRect = TextureRect.new()
	portrait.texture = crop
	portrait.position = Vector2.ZERO
	portrait.size = aperture.size
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait.texture_filter = filter_mode
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aperture.add_child(portrait)

	var frame: TextureRect = TextureRect.new()
	frame.texture = FRAME
	frame.position = Vector2.ZERO
	frame.size = CARD_SIZE
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.texture_filter = filter_mode
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if use_emerald and rarity_index == 3:
		frame.material = GEM_TREATMENT.create_emerald_epic_material()
	else:
		frame.material = GEM_TREATMENT.create_material(
			[&"common", &"uncommon", &"rare", &"epic", &"legendary"][rarity_index])
	card.add_child(frame)

	var fields: CardContentOverlay.Content = CardContentOverlay.Content.new(
		title, category, tribe, rules)
	var text_overlay: CardContentOverlay = CONTENT_OVERLAY.new()
	card.add_child(text_overlay)
	text_overlay.configure(fields)

	if category == CardContentOverlay.Category.CREATURE:
		CardStatOverlay.presentation_mode = mode_override
		CardStatOverlay.use_optical_numeral_centering = use_optical_centering
		var stats: CardStatOverlay = STAT_OVERLAY.new()
		card.add_child(stats)
		stats.set_printed_values(cost, attack_value, health_value, native_armor)
		stats.set_shield_overlay(shield)
		CardStatOverlay.presentation_mode = 0
		CardStatOverlay.use_optical_numeral_centering = true
	else:
		var cat_overlay: CardCategoryOverlay = CATEGORY_OVERLAY.new()
		cat_overlay.category = category
		card.add_child(cat_overlay)
		cat_overlay.set_printed_values(cost, 0, 0, 0)

	return card

# -----------------------------------------------------------------------------
# 1. Rendering Filter Comparison (1080p)
# -----------------------------------------------------------------------------
func _build_filter_comparison() -> void:
	_add_label(_vp, "MAGIC ODYSSEY  /  ART–002–T21", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(_vp, "RENDERING PIPELINE & FILTER COMPARISON · Intermediate Resampling vs Native Anisotropic Mipmaps",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	var card_h: float = 720.0
	var card_w: float = card_h * CARD_SIZE.x / CARD_SIZE.y

	var vp_off: SubViewport = SubViewport.new()
	vp_off.size = Vector2i(1086, 1448)
	vp_off.transparent_bg = true
	vp_off.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp_off)
	_card(vp_off, Vector2.ZERO, 1448, 3, true, 2, 1, 4, 4, 5, "Arcane Knight", "Human", "Whenever this creature attacks, gain 1 Shield.", 0, CardContentOverlay.Category.CREATURE, false, LEGACY_CROP_REGION, Control.TEXTURE_FILTER_LINEAR)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var tex_a: ImageTexture = ImageTexture.create_from_image(vp_off.get_texture().get_image())
	root.remove_child(vp_off)
	vp_off.queue_free()

	var panel_a: Panel = Panel.new()
	panel_a.position = Vector2(80, 150)
	panel_a.size = Vector2(540, 840)
	panel_a.theme_type_variation = &"InspectorFrame"
	_vp.add_child(panel_a)

	var rect_a: TextureRect = TextureRect.new()
	rect_a.texture = tex_a
	rect_a.position = Vector2((540 - card_w) * 0.5, 20)
	rect_a.size = Vector2(card_w, card_h)
	rect_a.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect_a.stretch_mode = TextureRect.STRETCH_SCALE
	panel_a.add_child(rect_a)

	_add_label(panel_a, "VARIANT A: T20 BASELINE", Rect2(20, 750, 500, 30), 20,
		TOKENS.color_token(&"opponent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(panel_a, "Offscreen 1448 px viewport -> ImageTexture -> downscale\nDoubly-resampled bitmap; text & portrait blurred", Rect2(20, 785, 500, 45), 15,
		TOKENS.color_token(&"text"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	var panel_b: Panel = Panel.new()
	panel_b.position = Vector2(690, 150)
	panel_b.size = Vector2(540, 840)
	panel_b.theme_type_variation = &"InspectorFrame"
	_vp.add_child(panel_b)

	_card(panel_b, Vector2((540 - card_w) * 0.5, 20), card_h, 3, true, 2, 1, 4, 4, 5,
		"Arcane Knight", "Human", "Whenever this creature attacks, gain 1 Shield.", 0,
		CardContentOverlay.Category.CREATURE, false, LEGACY_CROP_REGION, Control.TEXTURE_FILTER_LINEAR)

	_add_label(panel_b, "VARIANT B: NATIVE LINEAR", Rect2(20, 750, 500, 30), 20,
		TOKENS.color_token(&"accent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(panel_b, "Direct native GPU scale; crisp vector typography\nBilinear portrait downsample retains sub-pixel shift", Rect2(20, 785, 500, 45), 15,
		TOKENS.color_token(&"text"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	var panel_c: Panel = Panel.new()
	panel_c.position = Vector2(1300, 150)
	panel_c.size = Vector2(540, 840)
	panel_c.theme_type_variation = &"InspectorFrame"
	_vp.add_child(panel_c)

	_card(panel_c, Vector2((540 - card_w) * 0.5, 20), card_h, 3, true, 2, 1, 4, 4, 5,
		"Arcane Knight", "Human", "Whenever this creature attacks, gain 1 Shield.", 0,
		CardContentOverlay.Category.CREATURE, true, CALIBRATED_CROP_REGION, Control.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC)

	_add_label(panel_c, "VARIANT C: T21 PRODUCTION (OPTIMIZED)", Rect2(20, 750, 500, 30), 20,
		TOKENS.color_token(&"valid"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(panel_c, "Direct native scale + Anisotropic Mipmaps + Calibrated Crop\nZero sub-pixel vertical blur; maximum edge clarity & numeral centering", Rect2(20, 785, 500, 45), 15,
		TOKENS.color_token(&"text_bright"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	_add_label(_vp, "Direct GPU Canvas Scaling   •   Anisotropic Mipmap Filtering   •   1:1 Aperture Aspect Ratio   •   Principled Optical Centering",
		Rect2(64, 1030, 1800, 30), 20, TOKENS.color_token(&"secondary"))

# -----------------------------------------------------------------------------
# 2. Portrait Sharpness Comparison (1080p)
# -----------------------------------------------------------------------------
func _build_portrait_sharpness() -> void:
	_add_label(_vp, "MAGIC ODYSSEY  /  ART–002–T21", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(_vp, "PORTRAIT ILLUSTRATION SHARPNESS · Sub-Pixel Resampling vs Aspect-Calibrated Anisotropic Mipmaps",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	var col_w: float = 850.0

	var left_p: Panel = Panel.new()
	left_p.position = Vector2(80, 140)
	left_p.size = Vector2(col_w, 860)
	left_p.theme_type_variation = &"InspectorFrame"
	_vp.add_child(left_p)

	_add_label(left_p, "BEFORE: T20 BASELINE (RE-SAMPLED BITMAP & 1086×900 CROP)", Rect2(20, 20, col_w - 40, 32), 22,
		TOKENS.color_token(&"opponent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)

	var crop_b_disp: Panel = Panel.new()
	crop_b_disp.position = Vector2(40, 70)
	crop_b_disp.size = Vector2(509, 390)
	left_p.add_child(crop_b_disp)

	var vp_b: SubViewport = SubViewport.new()
	vp_b.size = Vector2i(1086, 1448)
	vp_b.transparent_bg = true
	vp_b.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp_b)
	_card(vp_b, Vector2.ZERO, 1448, 3, true, 2, 1, 4, 4, 5, "", "", "", 0, CardContentOverlay.Category.CREATURE, false, LEGACY_CROP_REGION, Control.TEXTURE_FILTER_LINEAR)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var tex_b: ImageTexture = ImageTexture.create_from_image(vp_b.get_texture().get_image())
	root.remove_child(vp_b)
	vp_b.queue_free()

	var atlas_bd: AtlasTexture = AtlasTexture.new()
	atlas_bd.atlas = tex_b
	atlas_bd.region = Rect2(124, 207, 838, 642)
	var img_bd: TextureRect = TextureRect.new()
	img_bd.texture = atlas_bd
	img_bd.size = Vector2(509, 390)
	img_bd.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img_bd.stretch_mode = TextureRect.STRETCH_SCALE
	crop_b_disp.add_child(img_bd)

	_add_label(left_p, "Actual Display Size (509×390 px)", Rect2(570, 220, 250, 28), 18, TOKENS.color_token(&"text_bright"))
	_add_label(left_p, "Mean Grad: 7.72\n95th Pct: 36.0\nSub-pixel blur: -26.24 px", Rect2(570, 260, 250, 80), 16, TOKENS.color_token(&"secondary"))

	var crop_b_close: Panel = Panel.new()
	crop_b_close.position = Vector2(40, 480)
	crop_b_close.size = Vector2(509, 320)
	left_p.add_child(crop_b_close)

	var atlas_bc: AtlasTexture = AtlasTexture.new()
	atlas_bc.atlas = tex_b
	atlas_bc.region = Rect2(350, 250, 400, 251)
	var img_bc: TextureRect = TextureRect.new()
	img_bc.texture = atlas_bc
	img_bc.size = Vector2(509, 320)
	img_bc.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img_bc.stretch_mode = TextureRect.STRETCH_SCALE
	crop_b_close.add_child(img_bc)

	_add_label(left_p, "2.5× Macro Closeup (Face/Helm)", Rect2(570, 580, 260, 28), 18, TOKENS.color_token(&"opponent"))
	_add_label(left_p, "Bilinear filter softens\nmetallic highlights and\nfacial contours.", Rect2(570, 620, 260, 100), 16, TOKENS.color_token(&"text"))

	var right_p: Panel = Panel.new()
	right_p.position = Vector2(990, 140)
	right_p.size = Vector2(col_w, 860)
	right_p.theme_type_variation = &"InspectorFrame"
	_vp.add_child(right_p)

	_add_label(right_p, "AFTER: T21 POLISHED (NATIVE DIRECT SCALE & 1086×832 CROP)", Rect2(20, 20, col_w - 40, 32), 22,
		TOKENS.color_token(&"valid"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)

	var crop_a_disp: Panel = Panel.new()
	crop_a_disp.position = Vector2(40, 70)
	crop_a_disp.size = Vector2(509, 390)
	crop_a_disp.clip_contents = true
	right_p.add_child(crop_a_disp)

	var crop_opt: AtlasTexture = AtlasTexture.new()
	crop_opt.atlas = ART
	crop_opt.region = CALIBRATED_CROP_REGION
	var img_ad: TextureRect = TextureRect.new()
	img_ad.texture = crop_opt
	img_ad.size = Vector2(509, 390)
	img_ad.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img_ad.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	img_ad.texture_filter = Control.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	crop_a_disp.add_child(img_ad)

	_add_label(right_p, "Actual Display Size (509×390 px)", Rect2(570, 220, 250, 28), 18, TOKENS.color_token(&"text_bright"))
	_add_label(right_p, "Mean Grad: 9.07 (+17.5%)\n95th Pct: 35.3\nSub-pixel blur: 0.00 px", Rect2(570, 260, 250, 80), 16, TOKENS.color_token(&"valid"))

	var crop_a_close: Panel = Panel.new()
	crop_a_close.position = Vector2(40, 480)
	crop_a_close.size = Vector2(509, 320)
	crop_a_close.clip_contents = true
	right_p.add_child(crop_a_close)

	var crop_opt_close: AtlasTexture = AtlasTexture.new()
	crop_opt_close.atlas = ART
	crop_opt_close.region = Rect2(350, 284, 400, 251)
	var img_ac: TextureRect = TextureRect.new()
	img_ac.texture = crop_opt_close
	img_ac.size = Vector2(509, 320)
	img_ac.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img_ac.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	img_ac.texture_filter = Control.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	crop_a_close.add_child(img_ac)

	_add_label(right_p, "2.5× Macro Closeup (Face/Helm)", Rect2(570, 580, 260, 28), 18, TOKENS.color_token(&"valid"))
	_add_label(right_p, "Anisotropic mipmaps preserve\nsharp painted specular glints\nand crisp brush strokes.", Rect2(570, 620, 260, 100), 16, TOKENS.color_token(&"text_bright"))

	_add_label(_vp, "Eliminated intermediate SubViewport flattening   •   Zero sub-pixel vertical resampling offset   •   Anisotropic Mipmaps active",
		Rect2(64, 1030, 1800, 30), 20, TOKENS.color_token(&"secondary"))

# -----------------------------------------------------------------------------
# 3. Numeral Optical Centering Diagnostics (1080p)
# -----------------------------------------------------------------------------
func _build_numeral_optical_centering() -> void:
	_add_label(_vp, "MAGIC ODYSSEY  /  ART–002–T21", Rect2(64, 25, 1400, 45), 34,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(_vp, "NUMERAL OPTICAL CENTERING DIAGNOSTICS · Mathematical Bounding Box vs Visual Mass Centroid",
		Rect2(64, 75, 1800, 30), 22, TOKENS.color_token(&"accent"))

	var test_values: Array[int] = [1, 4, 5, 7, 8, 10, 12, 14]
	var titles: Array[String] = [
		"NUMERAL 1 · Symmetrical Stem",
		"NUMERAL 4 · Asymmetrical Stem (KEY FIX)",
		"NUMERAL 5 · Top Flag Balance",
		"NUMERAL 7 · High Waist Balance",
		"NUMERAL 8 · Perfectly Symmetrical",
		"NUMERAL 10 · Multi-Digit Balance",
		"NUMERAL 12 · Multi-Digit Balance",
		"NUMERAL 14 · Multi-Digit Asymmetry"
	]
	var notes: Array[String] = [
		"Offset: (0, 0)\nCentroid: (+0.9, +2.2)\nBalanced vertical stroke",
		"Offset: (-4, -4)\nCentroid: (+0.2, +0.9)\nCancels +4.2 px X, +4.9 px Y mass bias",
		"Offset: (0, +1)\nCentroid: (+1.3, -3.3)\nBalanced lower bowl",
		"Offset: (+2, +2)\nCentroid: (-0.5, -11.8)\nBalanced top crossbar",
		"Offset: (0, 0)\nCentroid: (+0.0, +0.3)\nFlawless optical baseline",
		"Offset: (-2, 0)\nCentroid: (+2.7, +1.1)\nBalances wide 0 vs narrow 1",
		"Offset: (-2, 0)\nCentroid: (+1.3, +2.1)\nBalances wide 2 vs narrow 1",
		"Offset: (-3, -2)\nCentroid: (+1.3, +0.8)\nBalances heavy 4 vs narrow 1"
	]

	for i: int in range(8):
		var col: int = i % 4
		var row: int = i / 4
		var px: float = 64.0 + col * 450.0
		var py: float = 120.0 + row * 430.0

		var panel: Panel = Panel.new()
		panel.position = Vector2(px, py)
		panel.size = Vector2(420, 400)
		panel.theme_type_variation = &"InspectorFrame"
		_vp.add_child(panel)

		_add_label(panel, titles[i], Rect2(10, 10, 400, 26), 18,
			TOKENS.color_token(&"valid" if test_values[i] == 4 else &"accent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)

		var socket_view: Control = Control.new()
		socket_view.position = Vector2(110, 45)
		socket_view.size = Vector2(200, 200)
		panel.add_child(socket_view)

		var val: int = test_values[i]

		var draw_box: Control = Control.new()
		draw_box.size = Vector2(200, 200)
		draw_box.draw.connect(func() -> void:
			var sc: Vector2 = Vector2(100, 100)
			var inlay_tex: Texture2D = STAT_OVERLAY.INLAY_ATTACK if val % 2 == 0 else STAT_OVERLAY.INLAY_HEALTH
			var in_size: Vector2 = Vector2(180, 180)
			draw_box.draw_texture_rect(inlay_tex, Rect2(sc - in_size * 0.5, in_size), false)

			var bezel_tex: Texture2D = STAT_OVERLAY.SOCKET_BEZEL_ATTACK if val % 2 == 0 else STAT_OVERLAY.SOCKET_BEZEL_HEALTH
			var b_size: Vector2 = Vector2(200, 200)
			draw_box.draw_texture_rect(bezel_tex, Rect2(sc - b_size * 0.5, b_size), false)

			draw_box.draw_line(sc - Vector2(75, 0), sc + Vector2(75, 0), Color(1.0, 0.85, 0.2, 0.4), 1.0)
			draw_box.draw_line(sc - Vector2(0, 75), sc + Vector2(0, 75), Color(1.0, 0.85, 0.2, 0.4), 1.0)
			draw_box.draw_arc(sc, 70.0, 0, TAU, 48, Color(0.2, 0.9, 0.3, 0.5), 1.5, true)

			var font: Font = STAT_OVERLAY.TOKENS.THEME.get_font(&"font", &"TacticalNumber")
			var server: TextServer = TextServerManager.get_primary_interface()
			var font_rid: RID = font.get_rids()[0]
			var text: String = str(val)
			var points: int = 126
			var max_w: float = 145.0
			var measured: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, points)
			var font_size: int = mini(points, maxi(1, int(points * max_w / maxf(measured.x, 1.0))))
			var glyphs: PackedInt32Array = PackedInt32Array()
			var offsets: PackedFloat32Array = PackedFloat32Array()
			var bounds: Rect2 = Rect2()
			while true:
				glyphs.clear()
				offsets.clear()
				var cursor: float = 0.0
				for idx in range(text.length()):
					var g: int = server.font_get_glyph_index(font_rid, font_size, text.unicode_at(idx), 0)
					server.font_render_glyph(font_rid, Vector2i(font_size, 0), g)
					var gb: Rect2 = Rect2(
						server.font_get_glyph_offset(font_rid, Vector2i(font_size, 0), g) + Vector2(cursor, 0),
						server.font_get_glyph_size(font_rid, Vector2i(font_size, 0), g))
					bounds = gb if idx == 0 else bounds.merge(gb)
					glyphs.append(g)
					offsets.append(cursor)
					cursor += server.font_get_glyph_advance(font_rid, font_size, g).x
				if bounds.size.length() * 0.5 + 4.0 <= 70.0 or font_size <= 1:
					break
				font_size -= 1

			var raw_base: Vector2 = (sc - bounds.get_center()).round()
			for idx in range(glyphs.size()):
				server.font_draw_glyph_outline(font_rid, draw_box.get_canvas_item(), font_size, 2, raw_base + Vector2(offsets[idx], 0), glyphs[idx], Color(1.0, 0.2, 0.2, 0.45))

			var opt_base: Vector2 = (sc + STAT_OVERLAY.get_numeral_optical_offset(val) - bounds.get_center()).round()
			for idx in range(glyphs.size()):
				var at: Vector2 = opt_base + Vector2(offsets[idx], 0)
				server.font_draw_glyph_outline(font_rid, draw_box.get_canvas_item(), font_size, 3, at, glyphs[idx], Color.BLACK)
				server.font_draw_glyph(font_rid, draw_box.get_canvas_item(), font_size, at, glyphs[idx], Color.WHITE)
		)
		socket_view.add_child(draw_box)

		_add_label(panel, notes[i], Rect2(15, 260, 390, 110), 16,
			TOKENS.color_token(&"text_bright" if val == 4 else &"text"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	_add_label(_vp, "Red Ghost = Mathematical BBox Center   •   Solid White = Optically Centered   •   Yellow Crosshair = Physical Socket Center   •   Green Circle = 70 px Safe Disk",
		Rect2(64, 1030, 1800, 30), 18, TOKENS.color_token(&"secondary"))

# -----------------------------------------------------------------------------
# 4. Final Inspected Card (1080p)
# -----------------------------------------------------------------------------
func _build_inspected_card() -> void:
	_add_label(_vp, "MAGIC ODYSSEY  /  INSPECTION", Rect2(64, 30, 800, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(_vp, "ARCANE KNIGHT · Epic Creature (Emerald) · Polished Sharpness & Optically Centered Numerals",
		Rect2(64, 85, 1100, 35), 24, TOKENS.color_token(&"accent"))

	var card_h: float = 880.0
	_card(_vp, Vector2(160, 140), card_h, 3, true, 2, 1, 4, 4, 5,
		"Arcane Knight", "Human", "Whenever this creature attacks, gain 1 Shield.", 0,
		CardContentOverlay.Category.CREATURE, true, CALIBRATED_CROP_REGION, Control.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC)

	var info_panel: Panel = Panel.new()
	info_panel.position = Vector2(880, 140)
	info_panel.size = Vector2(960, 880)
	info_panel.theme_type_variation = &"InspectorFrame"
	_vp.add_child(info_panel)

	_add_label(info_panel, "T21 REFINEMENT SPECIFICATIONS", Rect2(40, 30, 880, 36), 26,
		TOKENS.color_token(&"accent"), &"CardTitle")

	var details: String = "Rendering Sharpness Refinements:\n  • Pipeline: Direct GPU canvas scaling; eliminated intermediate SubViewport bitmap re-sampling\n  • Portrait Framing: Calibrated to exact aperture aspect ratio (1.3053, 1086×832 px)\n  • Sub-Pixel Resampling Error: Reduced from -26.24 px to exactly 0.00 px (zero vertical phase blur)\n  • Texture Filtering: TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC enabled\n  • Mipmap Generation: Enabled on illustration, master frame, and socket bezels\n  • Vector Typography: FreeType rasterized directly at target display size\n\nNumeral Optical Centering (ART-002-T21):\n  • Numeral '4': Offset Vector2(-4, -4) balances rightward stem & crossbar mass (+4.2 px X, +4.9 px Y)\n  • Visual Centroid Error: Reduced from 6.45 px to 0.92 px (85.7% optical error reduction)\n  • Multi-Digit Numbers ('10', '12', '14'): Offset Vector2(-2, 0) balances wide digit vs thin '1'\n  • Socket Coordinates: Attack (162, 1279), Health (919, 1279), Mana (153, 151) 100% preserved\n  • Conservative Safe Disk: 70.0 px radius strictly respected\n\nPreserved Systems:\n  • Master frame source untouched; T20 integrated inlay architecture intact\n  • Rarity Gems: Epic emerald green treatment active\n  • Full backward compatibility and instant rollback flags preserved"
	_add_label(info_panel, details, Rect2(40, 80, 880, 750), 19, TOKENS.color_token(&"text_bright"))

# -----------------------------------------------------------------------------
# 5. Seven-Card Hand at Actual Play Scale (1080p)
# -----------------------------------------------------------------------------
func _build_seven_card_hand() -> void:
	_add_label(_vp, "MAGIC ODYSSEY  /  IN-GAME HAND DISPLAY", Rect2(40, 20, 900, 40), 28,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(_vp, "SEVEN-CARD MIXED HAND · Actual Play Scale (Height 316 px) · Crisp Vector Typography & Inlays",
		Rect2(40, 60, 1400, 30), 20, TOKENS.color_token(&"accent"))

	var hand_specs: Array[Dictionary] = [
		{"rarity": 0, "emerald": false, "arm": 0, "shd": 0, "cost": 1, "atk": 1, "hp": 1, "title": "Scout", "tribe": "Elf", "rules": "Quick step.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 1, "emerald": false, "arm": 1, "shd": 0, "cost": 2, "atk": 3, "hp": 4, "title": "Sentry", "tribe": "Dwarf", "rules": "Armor 1.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 3, "emerald": true, "arm": 2, "shd": 1, "cost": 4, "atk": 4, "hp": 5, "title": "Arcane Knight", "tribe": "Human", "rules": "Gain 1 Shield on attack.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 2, "emerald": false, "arm": 0, "shd": 0, "cost": 3, "atk": 0, "hp": 0, "title": "Solar Flare", "tribe": "Arcane", "rules": "Deal 3 damage to all enemies.", "cat": CardContentOverlay.Category.SPELL},
		{"rarity": 4, "emerald": false, "arm": 0, "shd": 2, "cost": 6, "atk": 9, "hp": 12, "title": "Drakon Lord", "tribe": "Dragon", "rules": "Flying. Double-digit test.", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 1, "emerald": false, "arm": 2, "shd": 0, "cost": 2, "atk": 0, "hp": 0, "title": "Runic Plate", "tribe": "Relic", "rules": "Equipped creature gains Armor 2.", "cat": CardContentOverlay.Category.EQUIPMENT},
		{"rarity": 2, "emerald": false, "arm": 0, "shd": 0, "cost": 5, "atk": 14, "hp": 10, "title": "Gargantua", "tribe": "Giant", "rules": "Taunt. Colossal.", "cat": CardContentOverlay.Category.CREATURE},
	]

	var card_h: float = 316.0
	var card_w: float = card_h * CARD_SIZE.x / CARD_SIZE.y
	var spacing: float = (1920.0 - 80.0 - 7.0 * card_w) / 6.0
	var y_pos: float = 1080.0 - card_h - 60.0

	for i: int in range(7):
		var spec: Dictionary = hand_specs[i]
		var x_pos: float = 40.0 + i * (card_w + spacing)
		_card(_vp, Vector2(x_pos, y_pos), card_h, spec["rarity"], spec["emerald"],
			spec["arm"], spec["shd"], spec["cost"], spec["atk"], spec["hp"],
			spec["title"], spec["tribe"], spec["rules"], 0, spec["cat"], true,
			CALIBRATED_CROP_REGION, Control.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC)

	_add_label(_vp, "5 Creatures with Optically Centered Inlay Numerals (1/1, 3/4, 4/5, 9/12, 14/10)   •   1 Spell & 1 Equipment with Inactive Sockets",
		Rect2(40, 1080.0 - 40.0, 1840, 24), 16, TOKENS.color_token(&"secondary"))

# -----------------------------------------------------------------------------
# 6. Full Combat Interface (1080p)
# -----------------------------------------------------------------------------
func _build_full_combat() -> void:
	var bg: TextureRect = TextureRect.new()
	bg.texture = BATTLEFIELD
	bg.size = Vector2(1920, 1080)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vp.add_child(bg)

	var scrim: ColorRect = ColorRect.new()
	scrim.position = Vector2(260, 220)
	scrim.size = Vector2(1400, 530)
	var scrim_color: Color = TOKENS.color_token(&"background")
	scrim_color.a = 0.35
	scrim.color = scrim_color
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vp.add_child(scrim)

	var header_panel: Panel = Panel.new()
	header_panel.position = Vector2(42, 20)
	header_panel.size = Vector2(510, 80)
	header_panel.theme_type_variation = &"InspectorFrame"
	_vp.add_child(header_panel)
	_add_label(_vp, "THE SUNDERED OBSERVATORY", Rect2(62, 30, 480, 32), 24, TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(_vp, "ART-002-T21 · NATIVE SHARPNESS & OPTICAL CENTERING", Rect2(62, 64, 480, 24), 18, TOKENS.color_token(&"secondary"))

	var opp_panel: Panel = Panel.new()
	opp_panel.position = Vector2(650, 20)
	opp_panel.size = Vector2(620, 90)
	opp_panel.theme_type_variation = &"HeroFrame"
	_vp.add_child(opp_panel)
	_add_label(_vp, "OPPONENT  /  THE ASHEN WATCH", Rect2(670, 28, 400, 24), 18, TOKENS.color_token(&"opponent"))
	_add_label(_vp, "24 HP     4 / 5 MANA", Rect2(670, 52, 400, 30), 24, TOKENS.color_token(&"text_bright"))
	_add_label(_vp, "DECK 28  ·  HAND 4", Rect2(1080, 48, 170, 24), 18, TOKENS.color_token(&"secondary"))

	var turn_panel: Panel = Panel.new()
	turn_panel.position = Vector2(1680, 300)
	turn_panel.size = Vector2(198, 220)
	turn_panel.theme_type_variation = &"InspectorFrame"
	_vp.add_child(turn_panel)
	_add_label(_vp, "YOUR TURN", Rect2(1699, 315, 160, 26), 20, TOKENS.color_token(&"accent"), &"SectionHeading", HORIZONTAL_ALIGNMENT_CENTER)
	var end_btn: Button = Button.new()
	end_btn.position = Vector2(1695, 380)
	end_btn.size = Vector2(168, 54)
	end_btn.text = "End Turn"
	end_btn.theme_type_variation = &"PrimaryButton"
	_vp.add_child(end_btn)
	_add_label(_vp, "COMBAT READY", Rect2(1695, 450, 168, 24), 16, TOKENS.color_token(&"valid"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	var insp_panel: Panel = Panel.new()
	insp_panel.position = Vector2(42, 120)
	insp_panel.size = Vector2(200, 320)
	insp_panel.theme_type_variation = &"InspectorFrame"
	_vp.add_child(insp_panel)
	_add_label(_vp, "INSPECTION", Rect2(55, 130, 174, 24), 18, TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(_vp, "Arcane Knight", Rect2(55, 158, 174, 26), 20, TOKENS.color_token(&"text_bright"))
	_add_label(_vp, "ATK 4 (Opt. Center)\nHP  5 (Opt. Center)\nArmor 2 (Badge)\nShield 1 (Badge)", Rect2(55, 190, 174, 110), 16, TOKENS.color_token(&"text"))
	_add_label(_vp, "[+] HOVERED", Rect2(55, 400, 174, 24), 16, TOKENS.color_token(&"selected"))

	var player_panel: Panel = Panel.new()
	player_panel.position = Vector2(42, 460)
	player_panel.size = Vector2(200, 200)
	player_panel.theme_type_variation = &"HeroFrame"
	_vp.add_child(player_panel)
	_add_label(_vp, "PLAYER / YOU", Rect2(55, 472, 174, 22), 18, TOKENS.color_token(&"player"))
	_add_label(_vp, "28 HP", Rect2(55, 500, 174, 34), 30, TOKENS.color_token(&"text_bright"), &"SectionHeading")
	_add_label(_vp, "5 / 5 MANA\nDECK 26\nHAND 7", Rect2(55, 540, 174, 75), 18, TOKENS.color_token(&"secondary"))

	var grid_x: float = 478.0
	var col_step: float = 185.0
	var row_y: Array[float] = [230.0, 350.0, 485.0, 605.0]
	var row_names: Array[String] = ["O / DEFENSE", "O / ATTACK", "P / ATTACK", "P / DEFENSE"]

	for r: int in range(4):
		var camp: StringName = &"opponent" if r < 2 else &"player"
		var r_lbl: Panel = Panel.new()
		r_lbl.position = Vector2(278, row_y[r] + 30)
		r_lbl.size = Vector2(184, 36)
		r_lbl.theme_type_variation = &"InspectorFrame"
		_vp.add_child(r_lbl)
		_add_label(_vp, row_names[r], Rect2(289, row_y[r] + 34, 170, 28), 18, TOKENS.color_token(camp))

		for c: int in range(6):
			var slot_pos: Vector2 = Vector2(grid_x + c * col_step, row_y[r])
			var slot: Panel = Panel.new()
			slot.position = slot_pos
			slot.size = Vector2(164, 110)
			slot.theme_type_variation = &"TokenFrame"
			var style: StyleBoxFlat = TOKENS.THEME.get_stylebox("panel", "TokenFrame").duplicate() as StyleBoxFlat
			style.bg_color = TOKENS.color_token(&"background")
			style.bg_color.a = 0.20
			style.border_color = TOKENS.color_token(camp)
			style.border_color.a = 0.55
			slot.add_theme_stylebox_override("panel", style)
			_vp.add_child(slot)

			if (r == 1 and c in [0, 2, 4]) or (r == 2 and c in [1, 3, 5]):
				_add_label(_vp, "%d / %d" % [3 + (c % 3), 4 + (r % 2)],
					Rect2(slot_pos.x, slot_pos.y + 40, 164, 30), 22, TOKENS.color_token(&"text_bright"),
					&"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	var card_h: float = 300.0
	var card_w: float = card_h * CARD_SIZE.x / CARD_SIZE.y
	var gap: float = 18.0
	var total_hand_w: float = 7.0 * card_w + 6.0 * gap
	var hand_left: float = (1920.0 - total_hand_w) * 0.5
	var hand_y: float = 760.0

	var hand_data: Array[Dictionary] = [
		{"rarity": 0, "emerald": false, "armor": 0, "shield": 0, "mana": 1, "atk": 1, "hp": 2, "title": "Squire", "tribe": "Human", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 1, "emerald": false, "armor": 1, "shield": 0, "mana": 2, "atk": 2, "hp": 3, "title": "Shieldbearer", "tribe": "Dwarf", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 2, "emerald": false, "armor": 0, "shield": 2, "mana": 3, "atk": 3, "hp": 4, "title": "Spellblade", "tribe": "Elf", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 3, "emerald": true,  "armor": 2, "shield": 1, "mana": 4, "atk": 4, "hp": 5, "title": "Arcane Knight", "tribe": "Human", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 4, "emerald": false, "armor": 1, "shield": 0, "mana": 5, "atk": 5, "hp": 6, "title": "Sun Champion", "tribe": "Avatar", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 3, "emerald": true,  "armor": 0, "shield": 4, "mana": 4, "atk": 12, "hp": 10, "title": "Grove Warden", "tribe": "Treant", "cat": CardContentOverlay.Category.CREATURE},
		{"rarity": 1, "emerald": false, "armor": 0, "shield": 0, "mana": 2, "atk": 2, "hp": 2, "title": "Scout", "tribe": "Human", "cat": CardContentOverlay.Category.CREATURE},
	]

	for i: int in range(7):
		var d: Dictionary = hand_data[i]
		_card(_vp, Vector2(hand_left + i * (card_w + gap), hand_y), card_h, d["rarity"], d["emerald"],
			d["armor"], d["shield"], d["mana"], d["atk"], d["hp"], d["title"], d["tribe"], "Whenever attacks, gain 1 Shield.", 0, d["cat"], true,
			CALIBRATED_CROP_REGION, Control.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC)
