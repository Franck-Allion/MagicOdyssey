extends SceneTree
## Graphical regression check for ART-002-T03C:
## Tests canonical rarities AND experimental emerald Epic against untreated frame.

const FRAME: Texture2D = preload("res://assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png")
const TREATMENT: GDScript = preload("res://scripts/presentation/rarity_gem_treatment.gd")
const RARITIES: Array[StringName] = [&"common", &"uncommon", &"rare", &"epic", &"legendary"]

func _initialize() -> void:
	call_deferred("_verify")

func _verify() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("A graphical renderer is required to verify the gem shader")
		quit(2)
		return
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(1086, 1448)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var frame: TextureRect = TextureRect.new()
	frame.texture = FRAME
	frame.size = Vector2(viewport.size)
	viewport.add_child(frame)
	await process_frame
	await RenderingServer.frame_post_draw
	var baseline: PackedByteArray = viewport.get_texture().get_image().get_data()
	var mask_image: Image = TREATMENT.MASK.get_image()
	mask_image.convert(Image.FORMAT_RGBA8)
	var mask: PackedByteArray = mask_image.get_data()
	var failed: bool = false

	var test_cases: Array[Dictionary] = [
		{"name": "common", "mat": TREATMENT.create_material(&"common")},
		{"name": "uncommon", "mat": TREATMENT.create_material(&"uncommon")},
		{"name": "rare", "mat": TREATMENT.create_material(&"rare")},
		{"name": "epic_canonical_violet", "mat": TREATMENT.create_material(&"epic", false)},
		{"name": "epic_experimental_emerald", "mat": TREATMENT.create_material(&"epic", true)},
		{"name": "legendary", "mat": TREATMENT.create_material(&"legendary")},
	]

	for test_case: Dictionary in test_cases:
		var name_str: String = test_case["name"]
		frame.material = test_case["mat"]
		await process_frame
		await RenderingServer.frame_post_draw
		var rendered: Image = viewport.get_texture().get_image()
		var pixels: PackedByteArray = rendered.get_data()
		var alpha_changes: int = 0
		var outside_changes: int = 0
		var changed_gems: PackedInt32Array = PackedInt32Array([0, 0, 0])
		for offset: int in range(0, pixels.size(), 4):
			if pixels[offset + 3] != baseline[offset + 3]:
				alpha_changes += 1
			var difference: int = maxi(absi(pixels[offset] - baseline[offset]),
				maxi(absi(pixels[offset + 1] - baseline[offset + 1]),
				absi(pixels[offset + 2] - baseline[offset + 2])))
			if difference <= 1:
				continue
			if mask[offset] == 0:
				outside_changes += 1
			else:
				var row: int = (offset / 4) / viewport.size.x
				var gem_index: int = 0 if row < 120 else (1 if row < 1000 else 2)
				changed_gems[gem_index] += 1
		var passed: bool = alpha_changes == 0 and outside_changes == 0
		for count: int in changed_gems:
			passed = passed and count > 200
		failed = failed or not passed
		print("GEM_VERIFY %-28s alpha_changes=%d outside_mask_changes=%d changed_gems=%s pass=%s" % [
			name_str, alpha_changes, outside_changes, changed_gems, passed])
	quit(1 if failed else 0)
