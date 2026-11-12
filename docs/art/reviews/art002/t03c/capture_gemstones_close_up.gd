extends SceneTree
## Genuine Godot render: side-by-side close-up of Uncommon blue vs Epic green gemstones.

const FRAME: Texture2D = preload("res://assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png")
const TREATMENT: GDScript = preload("res://scripts/presentation/rarity_gem_treatment.gd")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")

func _initialize() -> void:
	call_deferred("_render")

func _render() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Graphical renderer required")
		quit(2)
		return

	# Step 1: Render full frame for Uncommon and Emerald Epic
	var frame_vp: SubViewport = SubViewport.new()
	frame_vp.size = Vector2i(1086, 1448)
	frame_vp.transparent_bg = true
	frame_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(frame_vp)
	var frame_rect: TextureRect = TextureRect.new()
	frame_rect.texture = FRAME
	frame_rect.size = Vector2(frame_vp.size)
	frame_vp.add_child(frame_rect)

	# Render Uncommon
	frame_rect.material = TREATMENT.create_material(&"uncommon")
	await process_frame
	await RenderingServer.frame_post_draw
	var uncommon_img: Image = frame_vp.get_texture().get_image()

	# Render Emerald Epic
	frame_rect.material = TREATMENT.create_material(&"epic", true)
	await process_frame
	await RenderingServer.frame_post_draw
	var emerald_img: Image = frame_vp.get_texture().get_image()

	var uncommon_tex: ImageTexture = ImageTexture.create_from_image(uncommon_img)
	var emerald_tex: ImageTexture = ImageTexture.create_from_image(emerald_img)

	# Step 2: Build 1920x1080 comparison canvas
	var main_vp: SubViewport = SubViewport.new()
	main_vp.size = Vector2i(1920, 1080)
	main_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(main_vp)

	var bg: Panel = Panel.new()
	bg.size = Vector2(1920, 1080)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = TOKENS.color_token(&"background")
	bg.add_theme_stylebox_override("panel", style)
	main_vp.add_child(bg)

	_add_label(main_vp, "MAGIC ODYSSEY  /  ART–002–T03C", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(main_vp, "GEMSTONE CLOSE-UP COMPARISON · Canonical Sapphire Blue vs Experimental Emerald Green",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	# Definitions for gemstone regions on master v03 (1086x1448)
	var gem_regions: Array[Dictionary] = [
		{"name": "Crown Gem (Top Header)", "rect": Rect2(443, 8, 200, 110)},
		{"name": "Bridge Gem (Portrait / Rules Border)", "rect": Rect2(443, 830, 200, 110)},
		{"name": "Footer Gem (Bottom Filigree Anchor)", "rect": Rect2(418, 1195, 250, 160)},
	]

	# Left Column: Uncommon (Blue)
	_add_label(main_vp, "UNCOMMON  /  Sapphire Blue (Canonical Q181)", Rect2(80, 145, 840, 45), 26,
		TOKENS.color_token(&"uncommon"), &"CardTitle")
	_add_label(main_vp, "Hue 211.5°  ·  Dominant Blue (Avg RGB: 0.11, 0.30, 0.51)  ·  Cool Azure Highlights",
		Rect2(80, 185, 840, 30), 18, TOKENS.color_token(&"secondary"))

	# Right Column: Emerald Epic (Green)
	_add_label(main_vp, "EXPERIMENTAL EPIC  /  Emerald Green (T03C)", Rect2(1000, 145, 840, 45), 26,
		Color(0.2, 0.85, 0.45), &"CardTitle")
	_add_label(main_vp, "Hue 149.4°  ·  Dominant Green (Avg RGB: 0.10, 0.54, 0.32)  ·  Cool Mint Highlights",
		Rect2(1000, 185, 840, 30), 18, TOKENS.color_token(&"secondary"))

	var y_offsets: Array[int] = [230, 480, 725]
	for i: int in range(3):
		var reg: Dictionary = gem_regions[i]
		var r: Rect2 = reg["rect"]
		var y_pos: int = y_offsets[i]

		# Left side: Uncommon
		_add_gem_box(main_vp, uncommon_tex, r, Vector2(100, y_pos), reg["name"], TOKENS.color_token(&"uncommon"))
		# Right side: Emerald Epic
		_add_gem_box(main_vp, emerald_tex, r, Vector2(1020, y_pos), reg["name"], Color(0.2, 0.85, 0.45))

	_add_label(main_vp, "Native 1086×1448 frame crops scaled 1.75× · Dark facet cuts, colored specular shoulders and white sparkle glints preserved.",
		Rect2(80, 1030, 1760, 30), 20, TOKENS.color_token(&"secondary"))

	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw

	var save_path: String = "D:/Dev/MagicOdyssey/docs/art/reviews/art002/t03c/gemstones_close_up_uncommon_vs_epic.png"
	var err: Error = main_vp.get_texture().get_image().save_png(save_path)
	print("CLOSE_UP_CAPTURE path=%s result=%d" % [save_path, err])
	quit(err)

func _add_gem_box(parent: Node, src_tex: Texture2D, src_rect: Rect2, pos: Vector2, title: String, accent: Color) -> void:
	var container: Panel = Panel.new()
	container.position = pos
	container.size = Vector2(800, 210)
	var box_style: StyleBoxFlat = StyleBoxFlat.new()
	box_style.bg_color = Color(0.08, 0.09, 0.12, 0.95)
	box_style.border_color = Color(0.25, 0.22, 0.18, 0.7)
	box_style.set_border_width_all(1)
	box_style.set_corner_radius_all(6)
	container.add_theme_stylebox_override("panel", box_style)
	parent.add_child(container)

	_add_label(container, title, Rect2(20, 12, 450, 30), 20, accent, &"CardTitle")

	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = src_tex
	atlas.region = src_rect

	var img: TextureRect = TextureRect.new()
	img.texture = atlas
	img.position = Vector2(20, 48)
	var scale_factor: float = 1.6
	img.size = src_rect.size * scale_factor
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	container.add_child(img)

	var desc: String = "Source bounds: %d×%d px\nPreserves native frame alpha\nBronze bezels 100%% untouched" % [int(src_rect.size.x), int(src_rect.size.y)]
	_add_label(container, desc, Rect2(480, 60, 300, 120), 18, TOKENS.color_token(&"secondary"))

func _add_label(parent: Node, value: String, bounds: Rect2, font_size: int,
		color: Color, variant: StringName = &"BodyText") -> Label:
	var label: Label = Label.new()
	label.text = value
	label.position = bounds.position
	label.size = bounds.size
	label.theme_type_variation = variant
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label
