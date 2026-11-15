class_name TestCombatScreen
extends RefCounted

## P005: CombatScreen Layout & Responsive Architecture Test Suite.
## Validates scene instantiation, named zone hierarchy, 24-slot tactical board reservation,
## hero and hand separation, action bar readiness, overlay readiness, and 1080p/720p bounds.

const COMBAT_SCREEN_SCENE: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")


func run_suite(asserts: TestAsserts, failure_mode: bool = false) -> void:
	_test_scene_loading_and_hierarchy(asserts)
	_test_battlefield_rows_and_semantics(asserts)
	_test_hero_and_hand_zones(asserts)
	_test_action_bar_and_button(asserts)
	_test_adaptive_fan(asserts)
	_test_overlay_layer(asserts)
	_test_responsive_bounds_1080p_and_720p(asserts)

	if failure_mode:
		_test_intentional_failure(asserts)


func _test_scene_loading_and_hierarchy(asserts: TestAsserts) -> void:
	asserts.set_current_test("combat_screen:scene_loading_and_hierarchy")

	asserts.assert_true(COMBAT_SCREEN_SCENE != null, "CombatScreen packed scene must load successfully")
	var instance: Node = COMBAT_SCREEN_SCENE.instantiate()
	asserts.assert_true(instance != null, "CombatScreen scene must instantiate cleanly")

	var screen: CombatScreen = instance as CombatScreen
	asserts.assert_true(screen != null, "Root node must be typed as CombatScreen")

	# Check top-level layers
	asserts.assert_true(screen.has_node("BackgroundLayer"), "BackgroundLayer must exist")
	asserts.assert_true(screen.has_node("CombatLayout"), "CombatLayout must exist")
	asserts.assert_true(screen.has_node("OverlayLayer"), "OverlayLayer must exist")

	# Check background nodes
	asserts.assert_true(screen.has_node("BackgroundLayer/BattlefieldEnvironment"), "BattlefieldEnvironment must exist")
	asserts.assert_true(screen.has_node("BackgroundLayer/AtmosphericOverlay"), "AtmosphericOverlay must exist")

	# Check combat layout zones
	asserts.assert_true(screen.has_node("CombatLayout/OpponentHeroZone"), "OpponentHeroZone must exist")
	asserts.assert_true(screen.has_node("CombatLayout/BattlefieldZone"), "BattlefieldZone must exist")
	asserts.assert_true(screen.has_node("CombatLayout/PlayerHeroZone"), "PlayerHeroZone must exist")
	asserts.assert_true(screen.has_node("CombatLayout/PlayerHandZone"), "PlayerHandZone must exist")
	asserts.assert_true(screen.has_node("CombatLayout/ActionBarZone"), "ActionBarZone must exist")

	instance.free()


func _test_battlefield_rows_and_semantics(asserts: TestAsserts) -> void:
	asserts.set_current_test("combat_screen:battlefield_rows_and_semantics")

	var screen: CombatScreen = COMBAT_SCREEN_SCENE.instantiate() as CombatScreen
	asserts.assert_true(screen != null, "CombatScreen instance required for battlefield tests")
	if screen == null:
		return

	var bf_zone: Panel = screen.get_battlefield_zone()
	asserts.assert_true(bf_zone != null, "BattlefieldZone must be accessible via getter")

	var opp_area: Control = screen.get_opponent_board_area()
	var divider: Control = screen.get_center_divider_area()
	var player_area: Control = screen.get_player_board_area()

	asserts.assert_true(opp_area != null, "OpponentBoardArea must exist")
	asserts.assert_true(divider != null, "CenterDividerArea must exist")
	asserts.assert_true(player_area != null, "PlayerBoardArea must exist")

	var opp_def: Control = screen.get_opponent_defense_row()
	var opp_atk: Control = screen.get_opponent_attack_row()
	var player_atk: Control = screen.get_player_attack_row()
	var player_def: Control = screen.get_player_defense_row()

	asserts.assert_true(opp_def != null, "OpponentDefenseRow must exist")
	asserts.assert_true(opp_atk != null, "OpponentAttackRow must exist")
	asserts.assert_true(player_atk != null, "PlayerAttackRow must exist")
	asserts.assert_true(player_def != null, "PlayerDefenseRow must exist")

	# Logical vertical order from top to bottom:
	# 1. Opponent Defense (back row of opponent)
	# 2. Opponent Attack (front row of opponent facing center)
	# 3. Center Divider (central contestation axis)
	# 4. Player Attack (front row of player facing center)
	# 5. Player Defense (back row of player)
	asserts.assert_true(opp_def.position.y < opp_atk.position.y,
		"Opponent Defense row (y=%.1f) must be above Opponent Attack row (y=%.1f)" % [opp_def.position.y, opp_atk.position.y])
	asserts.assert_true(opp_area.position.y < divider.position.y,
		"Opponent Board Area must be above Center Divider Area")
	asserts.assert_true(divider.position.y < player_area.position.y,
		"Center Divider Area must be above Player Board Area")
	asserts.assert_true(player_atk.position.y < player_def.position.y,
		"Player Attack row (y=%.1f) must be above Player Defense row (y=%.1f)" % [player_atk.position.y, player_def.position.y])

	# Check 6 column reservation guides per row (24 total slot placeholders)
	for row_node: Control in [opp_def, opp_atk, player_atk, player_def]:
		var guide_count: int = 0
		for child: Node in row_node.get_children():
			if child.name.begins_with("SlotGuide_"):
				guide_count += 1
		asserts.assert_equal(guide_count, 6, "Each row must reserve exactly 6 column slots (found %d)" % guide_count)

	screen.free()


func _test_hero_and_hand_zones(asserts: TestAsserts) -> void:
	asserts.set_current_test("combat_screen:hero_and_hand_zones")

	var screen: CombatScreen = COMBAT_SCREEN_SCENE.instantiate() as CombatScreen
	asserts.assert_true(screen != null, "CombatScreen instance required for hero and hand tests")
	if screen == null:
		return

	var opp_hero: Panel = screen.get_opponent_hero_zone()
	var player_hero: Panel = screen.get_player_hero_zone()
	var bf_zone: Panel = screen.get_battlefield_zone()
	var hand_zone: Panel = screen.get_player_hand_zone()
	var action_zone: Panel = screen.get_action_bar_zone()

	# Opponent Hero is positioned in upper screen region above battlefield
	asserts.assert_true(opp_hero.position.y < bf_zone.position.y,
		"Opponent Hero Zone (y=%.1f) must sit above Battlefield (y=%.1f)" % [opp_hero.position.y, bf_zone.position.y])

	# R02 dedicates the left column to the player hero.
	asserts.assert_true(player_hero.position.x + player_hero.size.x <= bf_zone.position.x,
		"Player Hero Zone must sit fully to the left of Battlefield")

	# Hand zone sits in lower screen region and between Player Hero and Action Bar
	asserts.assert_true(hand_zone.position.y > bf_zone.position.y,
		"Player Hand Zone must sit below Battlefield")
	asserts.assert_true(hand_zone.position.x > player_hero.position.x,
		"Player Hand Zone must be horizontally placed to the right of Player Hero Zone")
	asserts.assert_true(action_zone.position.x > hand_zone.position.x,
		"Action Bar Zone must be horizontally placed to the right of Player Hand Zone")

	# Compact idle fan reserves less height while allowing future upward lift.
	asserts.assert_true(hand_zone.size.x >= 1000.0, "Hand has room for seven overlapping cards")
	asserts.assert_true(hand_zone.size.y < 320.0, "Idle fan height is reduced from P005")
	asserts.assert_false(hand_zone.clip_contents, "Future hovered cards may lift above the idle zone")
	asserts.assert_true(player_hero.size.y > hand_zone.size.y, "Left hero column has dedicated vertical space")
	asserts.assert_true(screen.has_node("CombatLayout/OpponentHand"), "Opponent card-back region exists")

	# P005-R03 Master Grid Alignment: Top edge alignment across Left Hero, Battlefield, and Right MatchStatus
	var status_zone: Panel = screen.get_match_status()
	asserts.assert_equal(player_hero.position.y, bf_zone.position.y, "Left Hero Column and Battlefield must share top alignment line")
	asserts.assert_equal(status_zone.position.y, bf_zone.position.y, "Right Utility Column top (MatchStatus) and Battlefield must share top alignment line")

	# P005-R03 Master Grid Alignment: Bottom edge alignment across Left Hero, Player Hand, and Right ActionBar
	var hero_bottom: float = player_hero.position.y + player_hero.size.y
	var hand_bottom: float = hand_zone.position.y + hand_zone.size.y
	var action_bottom: float = action_zone.position.y + action_zone.size.y
	asserts.assert_true(hero_bottom <= hand_bottom, "Compact hero panel stays above hand bottom")
	asserts.assert_equal(action_bottom, hand_bottom, "Right Utility Column and Player Hand must share bottom alignment line")

	# P005-R03 Left Hero Column Proportions: Portrait prominence over liquid resource orbs
	var portrait: TextureRect = player_hero.get_node("Portrait") as TextureRect
	var health_orb: LiquidResourceOrb = screen.get_player_health_orb()
	asserts.assert_true(portrait != null, "Hero portrait must exist")
	asserts.assert_true(portrait.size.y < health_orb.size.y,
		"Hero portrait height (%.1f) must be smaller than resource orb height (%.1f)" % [portrait.size.y, health_orb.size.y])
	asserts.assert_true(health_orb.size.x <= player_hero.size.x * 0.70,
		"Resource orb footprint must leave balanced horizontal breathing room inside hero panel")

	screen.free()


func _test_action_bar_and_button(asserts: TestAsserts) -> void:
	asserts.set_current_test("combat_screen:action_bar_and_button")

	var screen: CombatScreen = COMBAT_SCREEN_SCENE.instantiate() as CombatScreen
	asserts.assert_true(screen != null, "CombatScreen instance required for action bar tests")
	if screen == null:
		return

	var action_zone: Panel = screen.get_action_bar_zone()
	asserts.assert_true(action_zone != null, "ActionBarZone must exist")

	var btn: Button = screen.get_end_turn_button()
	asserts.assert_true(btn != null, "EndTurnButton must be accessible via getter")
	asserts.assert_equal(btn.theme_type_variation, &"PrimaryButton", "EndTurnButton must use PrimaryButton theme variation")
	asserts.assert_true(btn.is_inside_tree() or btn.get_parent() == action_zone, "EndTurnButton must be child of ActionBarZone")
	asserts.assert_false(btn.disabled, "EndTurnButton must be interactable / enabled for visual/focus testing")

	screen.free()


func _test_overlay_layer(asserts: TestAsserts) -> void:
	asserts.set_current_test("combat_screen:overlay_layer")

	var screen: CombatScreen = COMBAT_SCREEN_SCENE.instantiate() as CombatScreen
	asserts.assert_true(screen != null, "CombatScreen instance required for overlay tests")
	if screen == null:
		return

	var overlay: Control = screen.get_overlay_layer()
	asserts.assert_true(overlay != null, "OverlayLayer must exist for P010 tooltip/inspector hosting")
	asserts.assert_equal(overlay.mouse_filter, Control.MOUSE_FILTER_IGNORE,
		"OverlayLayer must default to MOUSE_FILTER_IGNORE so it does not block combat interaction when empty")

	screen.free()


func _test_responsive_bounds_1080p_and_720p(asserts: TestAsserts) -> void:
	asserts.set_current_test("combat_screen:responsive_bounds_1080p_and_720p")

	var screen: CombatScreen = COMBAT_SCREEN_SCENE.instantiate() as CombatScreen
	asserts.assert_true(screen != null, "CombatScreen instance required for bounds test")
	if screen == null:
		return

	# Test 1: Native 1920x1080
	screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
	screen.size = Vector2(1920, 1080)
	screen._apply_responsive_layout()

	var layout: Control = screen.get_combat_layout()
	asserts.assert_equal(layout.size, Vector2(1920, 1080), "Layout reference size must be 1920x1080")
	asserts.assert_equal(layout.scale, Vector2.ONE, "Layout scale at 1080p must be 1.0")

	# Verify every main zone bounding box at 1080p is within [0..1920, 0..1080]
	var zones_to_check: Array[Control] = [
		screen.get_match_header(),
		screen.get_opponent_hero_zone(),
		screen.get_match_status(),
		screen.get_battlefield_zone(),
		screen.get_player_hero_zone(),
		screen.get_player_hand_zone(),
		screen.get_action_bar_zone()
	]

	var viewport_1080p: Rect2 = Rect2(Vector2.ZERO, Vector2(1920, 1080))
	for z: Control in zones_to_check:
		var r: Rect2 = Rect2(z.position, z.size)
		asserts.assert_true(viewport_1080p.encloses(r),
			"Zone %s (%s) must be completely enclosed in 1080p viewport" % [z.name, r])

	# Test 2: Secondary 1280x720
	screen.size = Vector2(1280, 720)
	screen._apply_responsive_layout()

	var expected_scale: float = 720.0 / 1080.0 # 0.666667
	asserts.assert_true(absf(layout.scale.x - expected_scale) < 0.001,
		"Layout scale at 720p must be proportionally downscaled to ~0.667 (got %.4f)" % layout.scale.x)
	asserts.assert_true(layout.position.x >= 0.0 and layout.position.y >= 0.0,
		"Layout position must remain non-negative after scaling at 720p")

	var scaled_end: Vector2 = layout.position + layout.size * layout.scale
	asserts.assert_true(scaled_end.x <= 1280.1 and scaled_end.y <= 720.1,
		"Scaled layout bounds (end=%s) must fit inside 1280x720 viewport" % scaled_end)

	screen.free()


func _test_intentional_failure(asserts: TestAsserts) -> void:
	asserts.set_current_test("combat_screen:intentional_failure_mode")
	print(">>> Triggering intentional failing assertion for combat screen suite verification...")
	asserts.assert_true(false, "Deliberate failure triggered for combat screen negative test verification (--test-failure-mode)")

func _test_adaptive_fan(asserts: TestAsserts) -> void:
	asserts.set_current_test("r04:adaptive_fan_0_to_10")
	var previous_width: float = 0.0
	var previous_center_y: float = 0.0
	for count: int in range(11):
		var fan: CombatPreviewCards = CombatPreviewCards.new()
		fan.size = Vector2(1280, 252)
		fan.display_count = count
		fan.rebuild()
		asserts.assert_equal(fan.get_child_count(), count, "Exact display count")
		var left: float = 1280.0
		var right: float = 0.0
		for index: int in range(count):
			var card: Control = fan.get_child(index) as Control
			var mirror: Control = fan.get_child(count - 1 - index) as Control
			var center: Vector2 = card.position + card.pivot_offset
			asserts.assert_true(center.is_finite(), "Finite center")
			asserts.assert_true(is_equal_approx(center.x + mirror.position.x + mirror.pivot_offset.x, 1280.0), "Mirrored centers")
			asserts.assert_true(is_equal_approx(center.y, mirror.position.y + mirror.pivot_offset.y), "Mirrored vertical arc")
			asserts.assert_true(is_equal_approx(card.rotation, -mirror.rotation), "Mirrored rotations")
			asserts.assert_true(is_equal_approx(card.size.x / card.size.y, 0.75) and card.scale.x == card.scale.y, "Native aspect ratio")
			asserts.assert_true(absf(CombatPreviewCards.layout_pose(index, count, 1280, 270).origin.y - previous_center_y) < 30.0 or count <= 1, "No vertical jumps between counts")
			asserts.assert_equal(card.name, StringName("Card%02d" % index), "Stable order")
			for point: Vector2 in [Vector2.ZERO, Vector2(card.size.x, 0), card.size, Vector2(0, card.size.y)]:
				var corner: Vector2 = card.get_transform() * point
				left = minf(left, corner.x)
				right = maxf(right, corner.x)
				for factor: float in [1.0, 2.0 / 3.0]:
					asserts.assert_true(Rect2(Vector2(320, 774) * factor - Vector2.ONE, Vector2(1280, 301) * factor + Vector2.ONE * 2).has_point((corner + Vector2(320, 804)) * factor), "Idle envelope at supported resolution")
			if index > 0:
				var prior: Control = fan.get_child(index - 1) as Control
				var spacing: float = center.x - prior.position.x - prior.pivot_offset.x
				asserts.assert_true(spacing >= 80.0 and spacing < card.size.x * card.scale.x, "Meaningful exposed strip and overlap")
		if count > 1:
			asserts.assert_true(right - left >= previous_width - 1.0, "Smooth nondecreasing fan envelope")
		previous_center_y = CombatPreviewCards.layout_pose(0, count, 1280, 270).origin.y
		previous_width = right - left
		if count == 1:
			asserts.assert_equal((fan.get_child(0) as Control).rotation, 0.0, "Single card unrotated")
		if count > 0:
			var last: Control = fan.get_child(count - 1) as Control
			var neighbor_position: Vector2 = last.position
			fan.set_inspected_card(0)
			if count > 1:
				asserts.assert_equal(last.position, neighbor_position, "Inspection leaves neighbors fixed")
			var raised: Control = fan.get_child(0) as Control
			for point: Vector2 in [Vector2.ZERO, Vector2(raised.size.x, 0), raised.size, Vector2(0, raised.size.y)]:
				asserts.assert_true(Rect2(Vector2.ZERO, Vector2(1920, 1080)).has_point(raised.get_transform() * point + Vector2(320, 804)), "Raised card inside viewport")
			asserts.assert_equal((fan.get_child(0) as Control).z_index, 100, "Inspection above all cards")
		fan.free()
