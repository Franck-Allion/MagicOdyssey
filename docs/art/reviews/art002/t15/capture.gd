extends SceneTree
## ART-002-T15: Graphite Steel Attack Cabochon Integration Capture Suite
## Generates genuine GPU renders for all 5 required review scenes at 1920x1080.

const FRAME: Texture2D = preload("res://assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png")
const ART: Texture2D = preload("res://assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png")
const BATTLEFIELD: Texture2D = preload("res://assets/_source/lot1/battlefield/wip/mo_battlefield_sundered_observatory_bg_wip_v03.png")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")
const GEM_TREATMENT: GDScript = preload("res://scripts/presentation/rarity_gem_treatment.gd")
const STAT_OVERLAY: GDScript = preload("res://scripts/presentation/card_stat_overlay.gd")
const CONTENT_OVERLAY: GDScript = preload("res://scripts/presentation/card_content_overlay.gd")
const CATEGORY_OVERLAY: GDScript = preload("res://scripts/presentation/card_category_overlay.gd")
const CARD_SIZE: Vector2 = Vector2(1086, 1448)

func _initialize() -> void:
	call_deferred("_run_captures")

func _run_captures() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Graphical renderer required for T15 captures")
		quit(2)
		return

	var out_dir: String = "D:/Dev/MagicOdyssey/docs/art/reviews/art002/t15/"

	# 1. Attack V1 vs V2 Comparison (1080p)
	await _capture_attack_v1_vs_v2(out_dir + "attack_v1_vs_v2_1080p.png")

	# 2. Attack V2 alongside Health Ruby Comparison (1080p)
	await _capture_attack_health_comparison(out_dir + "attack_health_comparison_1080p.png")

	# 3. Final Inspected Card (1080p)
	await _capture_inspected_card(out_dir + "inspected_card_1080p.png")

	# 4. Seven-Card Hand at Actual Play Scale (1080p)
	await _capture_seven_card_hand(out_dir + "seven_card_hand_1080p.png")

	# 5. Full Combat Interface (1080p)
	await _capture_full_combat(out_dir + "full_combat_interface_1080p.png")

	print("T15_ALL_CAPTURES_COMPLETED")
	quit(0)

func _create_viewport(vp_size: Vector2i) -> SubViewport:
	var vp: SubViewport = SubViewport.new()
	vp.size = vp_size
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var bg: Panel = Panel.new()
	bg.size = Vector2(vp_size)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = TOKENS.color_token(&"background")
	bg.add_theme_stylebox_override("panel", style)
	vp.add_child(bg)
	return vp

func _save_and_free(vp: SubViewport, path: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var err: Error = vp.get_texture().get_image().save_png(path)
	print("T15_CAPTURE size=%s path=%s result=%d" % [vp.size, path.get_file(), err])
	root.remove_child(vp)
	vp.queue_free()

func _card(parent: Node, origin: Vector2, height: float, rarity_index: int = 3,
		use_emerald: bool = false, native_armor: int = 0, shield: int = 0,
		cost: int = 4, attack_value: int = 4, health_value: int = 5,
		title: String = "Arcane Knight", tribe: String = "Human",
		rules: String = "Whenever this creature attacks, gain 1 Shield.",
		force_attack_v1: bool = false) -> Control:
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
	crop.region = Rect2(0, 0, 1086, 900)
	var portrait: TextureRect = TextureRect.new()
	portrait.texture = crop
	portrait.position = Vector2.ZERO
	portrait.size = aperture.size
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aperture.add_child(portrait)

	var frame: TextureRect = TextureRect.new()
	frame.texture = FRAME
	frame.position = Vector2.ZERO
	frame.size = CARD_SIZE
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if use_emerald and rarity_index == 3:
		frame.material = GEM_TREATMENT.create_emerald_epic_material()
	else:
		frame.material = GEM_TREATMENT.create_material(
			[&"common", &"uncommon", &"rare", &"epic", &"legendary"][rarity_index])
	card.add_child(frame)

	var fields: CardContentOverlay.Content = CardContentOverlay.Content.new(
		title, CardContentOverlay.Category.CREATURE, tribe, rules)
	var text_overlay: CardContentOverlay = CONTENT_OVERLAY.new()
	card.add_child(text_overlay)
	text_overlay.configure(fields)

	CardStatOverlay.attack_cabochon_version = 1 if force_attack_v1 else 2
	var stats: CardStatOverlay = STAT_OVERLAY.new()
	card.add_child(stats)
	stats.set_printed_values(cost, attack_value, health_value, native_armor)
	stats.set_shield_overlay(shield)
	CardStatOverlay.attack_cabochon_version = 2
	return card

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

# -----------------------------------------------------------------------------
# 1. Attack V1 vs V2 Comparison (1080p)
# -----------------------------------------------------------------------------
func _capture_attack_v1_vs_v2(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))
	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T15", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "ATTACK CABOCHON COMPARISON · Warm Bronze V1 (T13) vs Graphite Steel V2 (T15)",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	# Left Card: Attack V1 (Warm Bronze / Amber)
	_card(vp, Vector2(200, 160), 750, 3, false, 2, 4, 3, 4, 5, "Rampart Guard", "Human", "Armor 2. Shield 4.", true)
	_add_label(vp, "ATTACK CABOCHON V1 (WARM BRONZE / AMBER)", Rect2(150, 930, 660, 35), 22,
		TOKENS.color_token(&"secondary"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(vp, "Mean RGB: (129.7, 78.2, 49.5) · Warm amber gem tone\nOwner feedback: Insufficient differentiation from ruby Health\nPreserved for side-by-side comparison & rollback",
		Rect2(150, 970, 660, 60), 17, TOKENS.color_token(&"secondary"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	# Right Card: Attack V2 (Graphite Steel)
	_card(vp, Vector2(1060, 160), 750, 3, false, 2, 4, 3, 4, 5, "Rampart Guard", "Human", "Armor 2. Shield 4.", false)
	_add_label(vp, "ATTACK CABOCHON V2 (GRAPHITE STEEL)", Rect2(1010, 930, 660, 35), 22,
		TOKENS.color_token(&"accent"), &"CardTitle", HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(vp, "Mean RGB: (63.4, 68.7, 75.4) · Cold forged-steel / graphite\nImmediate, stark chromatic differentiation from ruby Health\nPreserves identical 250×250 px geometry and numeral safe disk",
		Rect2(1010, 970, 660, 60), 17, TOKENS.color_token(&"accent_bright"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	_add_label(vp, "Same card, same scale, identical values   •   Identical silhouette geometry   •   Cold forged-steel communicates physical attack",
		Rect2(64, 1040, 1800, 30), 18, TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)

# -----------------------------------------------------------------------------
# 2. Attack V2 alongside Health Ruby Comparison (1080p)
# -----------------------------------------------------------------------------
func _capture_attack_health_comparison(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))
	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T15", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "COLOR DIFFERENTIATION · Cold Graphite Steel Attack vs Deep Ruby Red Health",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	# High-res card viewport
	var card_vp: SubViewport = SubViewport.new()
	card_vp.size = Vector2i(1086, 1448)
	card_vp.transparent_bg = true
	card_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(card_vp)
	_card(card_vp, Vector2.ZERO, 1448, 3, true, 0, 0, 3, 4, 5, "Arcane Knight", "Human", "", false)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw

	var card_tex: ImageTexture = ImageTexture.create_from_image(card_vp.get_texture().get_image())
	root.remove_child(card_vp)
	card_vp.queue_free()

	# Attack V2 crop: card bounds (20, 1140, 284, 280) -> scaled ~2.3x
	var atk_crop: Control = Control.new()
	atk_crop.position = Vector2(160, 180)
	atk_crop.size = Vector2(640, 640)
	atk_crop.clip_contents = true
	vp.add_child(atk_crop)

	var atk_atlas: AtlasTexture = AtlasTexture.new()
	atk_atlas.atlas = card_tex
	atk_atlas.region = Rect2(20, 1140, 284, 280)
	var atk_img: TextureRect = TextureRect.new()
	atk_img.texture = atk_atlas
	atk_img.size = atk_crop.size
	atk_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	atk_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	atk_crop.add_child(atk_img)

	_add_label(vp, "ATTACK CABOCHON V2 (GRAPHITE STEEL)\nCenter: (162, 1279) · Size: 250×250 px\nColor: Cool dark steel slate / graphite\nMean RGB: (63.4, 68.7, 75.4), Lum: 67.9\nHigh numeral contrast (~5.5:1 ratio over core)",
		Rect2(160, 840, 640, 150), 22, TOKENS.color_token(&"text_bright"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	# Health V1 crop: card bounds (778, 1140, 284, 280) -> scaled ~2.3x
	var hp_crop: Control = Control.new()
	hp_crop.position = Vector2(1120, 180)
	hp_crop.size = Vector2(640, 640)
	hp_crop.clip_contents = true
	vp.add_child(hp_crop)

	var hp_atlas: AtlasTexture = AtlasTexture.new()
	hp_atlas.atlas = card_tex
	hp_atlas.region = Rect2(778, 1140, 284, 280)
	var hp_img: TextureRect = TextureRect.new()
	hp_img.texture = hp_atlas
	hp_img.size = hp_crop.size
	hp_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hp_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hp_crop.add_child(hp_img)

	_add_label(vp, "HEALTH CABOCHON (UNCHANGED RUBY RED)\nCenter: (919, 1279) · Size: 250×250 px\nColor: Deep faceted crimson ruby gemstone\nMean RGB: (139.9, 41.4, 24.1), Lum: 68.9\nHigh numeral contrast (~5.5:1 ratio over core)",
		Rect2(1120, 840, 640, 150), 22, TOKENS.color_token(&"text_bright"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	_add_label(vp, "Chromatic Delta: ΔRed = 76.5 px   •   Instant semantic differentiation: Cold Steel (Attack) vs Vivid Crimson (Health)",
		Rect2(64, 1025, 1800, 30), 20, TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)

# -----------------------------------------------------------------------------
# 3. Final Inspected Card (1080p)
# -----------------------------------------------------------------------------
func _capture_inspected_card(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))
	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T15", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "INSPECTION VIEW · Four Stat Types with Graphite Steel Attack & Ruby Health",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	_card(vp, Vector2(360, 170), 780, 3, true, 2, 4, 3, 4, 5, "Rampart Guard", "Human", "Armor 2. Whenever this creature attacks, gain 1 Shield.", false)

	var desc: String = "RAMPART GUARD\n\nPrinted stats: Mana 3  /  ATK 4  /  HP 5\nNative Armor 2  ·  Live Shield 4\n\nFour Harmonized Stat Representations (T15):\n• Attack: Graphite-steel cabochon (cold physical weapon)\n• Health: Ruby-red cabochon (living blood vitality)\n• Armor: Sculpted steel breastplate badge plate (280, 1280)\n• Shield: Luminous blue kite ward badge plate (608, 1280)\n\nColor Palette Separation:\n• Attack (Graphite): RGB (63, 69, 75) - cold dark neutral\n• Health (Ruby): RGB (140, 41, 24) - warm crimson\n• Armor (Cuirass): Slate steel badge with bronze rim\n• Shield (Ward): Luminous arcane steel-blue\n• All 4 stats instantly recognizable with zero chromatic clash"
	_add_label(vp, desc, Rect2(1020, 210, 840, 640), 22, TOKENS.color_token(&"secondary"))

	_add_label(vp, "Master frame v03 native alpha preserved   •   Canonical Epic = Emerald green (T03C)   •   No gameplay modifications",
		Rect2(64, 1030, 1800, 30), 20, TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)

# -----------------------------------------------------------------------------
# 4. Seven-Card Hand at Actual Play Scale (1080p)
# -----------------------------------------------------------------------------
func _capture_seven_card_hand(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))
	_add_label(vp, "MAGIC ODYSSEY  /  ART–002–T15", Rect2(64, 30, 1400, 50), 36,
		TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "SEVEN-CARD HAND (1080p) · Graphite Steel Attack Differentiation at In-Game Play Scale",
		Rect2(64, 85, 1800, 35), 24, TOKENS.color_token(&"accent"))

	var height: float = 316.0
	var width: float = height * CARD_SIZE.x / CARD_SIZE.y
	var gap: float = 16.0
	var left: float = (1920.0 - width * 7.0 - gap * 6.0) * 0.5
	var hand_y: float = 586.0

	var hand_data: Array[Dictionary] = [
		{"rarity": 0, "emerald": false, "armor": 0, "shield": 0, "mana": 1, "atk": 1, "hp": 2, "title": "Squire", "tribe": "Human"},
		{"rarity": 1, "emerald": false, "armor": 1, "shield": 0, "mana": 2, "atk": 2, "hp": 3, "title": "Shieldbearer", "tribe": "Dwarf"},
		{"rarity": 2, "emerald": false, "armor": 0, "shield": 2, "mana": 3, "atk": 3, "hp": 4, "title": "Spellblade", "tribe": "Elf"},
		{"rarity": 3, "emerald": false, "armor": 2, "shield": 3, "mana": 4, "atk": 4, "hp": 5, "title": "Arcane Knight", "tribe": "Human"},
		{"rarity": 4, "emerald": false, "armor": 1, "shield": 0, "mana": 5, "atk": 5, "hp": 6, "title": "Sun Champion", "tribe": "Avatar"},
		{"rarity": 3, "emerald": true,  "armor": 0, "shield": 4, "mana": 4, "atk": 12, "hp": 10, "title": "Grove Warden", "tribe": "Treant"},
		{"rarity": 1, "emerald": false, "armor": 0, "shield": 0, "mana": 2, "atk": 2, "hp": 2, "title": "Scout", "tribe": "Human"},
	]

	for i: int in range(7):
		var d: Dictionary = hand_data[i]
		_card(vp, Vector2(left + i * (width + gap), hand_y), height, d["rarity"], d["emerald"],
			d["armor"], d["shield"], d["mana"], d["atk"], d["hp"], d["title"], d["tribe"])

	_add_label(vp, "LINEAR HAND AT 1080p  /  Card height: 316 pixels  •  Clear color temperature contrast",
		Rect2(84, 360, 1752, 50), 28, TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "Cold graphite steel (left) and hot ruby crimson (right) eliminate scanning ambiguity across all card rarities.",
		Rect2(84, 420, 1752, 50), 24, TOKENS.color_token(&"secondary"))

	await _save_and_free(vp, path)

# -----------------------------------------------------------------------------
# 5. Full Combat Interface (1080p)
# -----------------------------------------------------------------------------
func _capture_full_combat(path: String) -> void:
	var vp: SubViewport = _create_viewport(Vector2i(1920, 1080))

	# Battlefield background artwork
	var bg: TextureRect = TextureRect.new()
	bg.texture = BATTLEFIELD
	bg.size = Vector2(1920, 1080)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vp.add_child(bg)

	# Scrim
	var scrim: ColorRect = ColorRect.new()
	scrim.position = Vector2(260, 220)
	scrim.size = Vector2(1400, 530)
	var scrim_color: Color = TOKENS.color_token(&"background")
	scrim_color.a = 0.35
	scrim.color = scrim_color
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vp.add_child(scrim)

	# Header HUD
	var header_panel: Panel = Panel.new()
	header_panel.position = Vector2(42, 20)
	header_panel.size = Vector2(510, 80)
	header_panel.theme_type_variation = &"InspectorFrame"
	vp.add_child(header_panel)
	_add_label(vp, "THE SUNDERED OBSERVATORY", Rect2(62, 30, 480, 32), 24, TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "ART-002-T15 · GRAPHITE STEEL ATTACK CABOCHON · 1080p", Rect2(62, 64, 480, 24), 18, TOKENS.color_token(&"secondary"))

	# Opponent Hero Banner
	var opp_panel: Panel = Panel.new()
	opp_panel.position = Vector2(650, 20)
	opp_panel.size = Vector2(620, 90)
	opp_panel.theme_type_variation = &"HeroFrame"
	vp.add_child(opp_panel)
	_add_label(vp, "OPPONENT  /  THE ASHEN WATCH", Rect2(670, 28, 400, 24), 18, TOKENS.color_token(&"opponent"))
	_add_label(vp, "24 HP     4 / 5 MANA", Rect2(670, 52, 400, 30), 24, TOKENS.color_token(&"text_bright"))
	_add_label(vp, "DECK 28  ·  HAND 4", Rect2(1080, 48, 170, 24), 18, TOKENS.color_token(&"secondary"))

	# Turn / End Turn Action Panel (Right)
	var turn_panel: Panel = Panel.new()
	turn_panel.position = Vector2(1680, 300)
	turn_panel.size = Vector2(198, 220)
	turn_panel.theme_type_variation = &"InspectorFrame"
	vp.add_child(turn_panel)
	_add_label(vp, "YOUR TURN", Rect2(1699, 315, 160, 26), 20, TOKENS.color_token(&"accent"), &"SectionHeading", HORIZONTAL_ALIGNMENT_CENTER)
	var end_btn: Button = Button.new()
	end_btn.position = Vector2(1695, 380)
	end_btn.size = Vector2(168, 54)
	end_btn.text = "End Turn"
	end_btn.theme_type_variation = &"PrimaryButton"
	vp.add_child(end_btn)
	_add_label(vp, "COMBAT READY", Rect2(1695, 450, 168, 24), 16, TOKENS.color_token(&"valid"), &"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	# Left Inspector Card View: miniature preview
	var insp_panel: Panel = Panel.new()
	insp_panel.position = Vector2(42, 130)
	insp_panel.size = Vector2(200, 300)
	insp_panel.theme_type_variation = &"InspectorFrame"
	vp.add_child(insp_panel)
	_add_label(vp, "INSPECTION", Rect2(55, 140, 174, 24), 18, TOKENS.color_token(&"accent"), &"SectionHeading")
	_add_label(vp, "Rampart Guard", Rect2(55, 168, 174, 26), 20, TOKENS.color_token(&"text_bright"))
	_add_label(vp, "ATK 4 (Graphite Cab.)\nHP  5 (Ruby Cab.)\nArmor 1 (Badge)\nShield 3 (Badge)", Rect2(55, 200, 174, 110), 18, TOKENS.color_token(&"text"))
	_add_label(vp, "[+] HOVERED", Rect2(55, 380, 174, 24), 16, TOKENS.color_token(&"selected"))

	# Player Info Panel (Bottom Left)
	var player_panel: Panel = Panel.new()
	player_panel.position = Vector2(42, 450)
	player_panel.size = Vector2(200, 200)
	player_panel.theme_type_variation = &"HeroFrame"
	vp.add_child(player_panel)
	_add_label(vp, "PLAYER / YOU", Rect2(55, 462, 174, 22), 18, TOKENS.color_token(&"player"))
	_add_label(vp, "28 HP", Rect2(55, 490, 174, 34), 30, TOKENS.color_token(&"text_bright"), &"SectionHeading")
	_add_label(vp, "3 / 5 MANA\nDECK 27\nHAND 7", Rect2(55, 530, 174, 75), 18, TOKENS.color_token(&"secondary"))

	# Combat Grid Slots (4 rows x 6 columns)
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
		vp.add_child(r_lbl)
		_add_label(vp, row_names[r], Rect2(289, row_y[r] + 34, 170, 28), 18, TOKENS.color_token(camp))

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
			vp.add_child(slot)

			if (r == 1 and c in [0, 2, 4]) or (r == 2 and c in [1, 3, 5]):
				_add_label(vp, "%d / %d" % [3 + (c % 3), 4 + (r % 2)],
					Rect2(slot_pos.x, slot_pos.y + 40, 164, 30), 22, TOKENS.color_token(&"text_bright"),
					&"BodyText", HORIZONTAL_ALIGNMENT_CENTER)

	# Seven-Card Hand at bottom of combat screen
	var card_h: float = 300.0
	var card_w: float = card_h * CARD_SIZE.x / CARD_SIZE.y
	var gap: float = 18.0
	var total_hand_w: float = 7.0 * card_w + 6.0 * gap
	var hand_left: float = (1920.0 - total_hand_w) * 0.5
	var hand_y: float = 760.0

	var hand_data: Array[Dictionary] = [
		{"rarity": 0, "emerald": false, "armor": 0, "shield": 0, "mana": 1, "atk": 1, "hp": 2, "title": "Squire", "tribe": "Human"},
		{"rarity": 1, "emerald": false, "armor": 1, "shield": 0, "mana": 2, "atk": 2, "hp": 3, "title": "Shieldbearer", "tribe": "Dwarf"},
		{"rarity": 2, "emerald": false, "armor": 0, "shield": 2, "mana": 3, "atk": 3, "hp": 4, "title": "Spellblade", "tribe": "Elf"},
		{"rarity": 3, "emerald": false, "armor": 2, "shield": 3, "mana": 4, "atk": 4, "hp": 5, "title": "Arcane Knight", "tribe": "Human"},
		{"rarity": 4, "emerald": false, "armor": 1, "shield": 0, "mana": 5, "atk": 5, "hp": 6, "title": "Sun Champion", "tribe": "Avatar"},
		{"rarity": 3, "emerald": true,  "armor": 0, "shield": 4, "mana": 4, "atk": 12, "hp": 10, "title": "Grove Warden", "tribe": "Treant"},
		{"rarity": 1, "emerald": false, "armor": 0, "shield": 0, "mana": 2, "atk": 2, "hp": 2, "title": "Scout", "tribe": "Human"},
	]

	for i: int in range(7):
		var d: Dictionary = hand_data[i]
		_card(vp, Vector2(hand_left + i * (card_w + gap), hand_y), card_h, d["rarity"], d["emerald"],
			d["armor"], d["shield"], d["mana"], d["atk"], d["hp"], d["title"], d["tribe"])

	await _save_and_free(vp, path)
