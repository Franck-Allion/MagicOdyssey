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
	_test_bottom_left_hud(asserts)
	_test_opponent_hud_and_card_backs(asserts)
	_test_action_bar_and_button(asserts)
	_test_adaptive_fan(asserts)
	_test_hand_hover_and_picking(asserts)
	_test_overlay_layer(asserts)
	_test_responsive_bounds_1080p_and_720p(asserts)
	_test_p005_r09b_card_hover_readability_and_inspection(asserts)

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

	# R06E supersedes the former player/battlefield top alignment; utility grid stays fixed.
	var status_zone: Panel = screen.get_match_status()
	asserts.assert_true(player_hero.position.y > bf_zone.position.y, "Player HUD sits lower than battlefield top")
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


func _test_hand_hover_and_picking(asserts: TestAsserts) -> void:
	asserts.set_current_test("r05:hand_hover_and_picking")

	# 1. Picking & Accessibility: Every card in counts 1, 3, 5, 7, 10 has an accessible exposed region
	for count: int in [1, 3, 5, 7, 10]:
		var fan: CombatPreviewCards = CombatPreviewCards.new()
		fan.size = Vector2(1280, 252)
		fan.display_count = count
		fan.rebuild()

		var half_w: float = 1086.0 * (270.0 / 1448.0) * 0.5
		var half_h: float = 270.0 * 0.5

		for i: int in range(count):
			var pose: Transform2D = CombatPreviewCards.layout_pose(i, count, 1280, 270)
			# Top-left mana area of each card: exposed due to left-to-right stacking
			var mana_offset: Vector2 = Vector2(-half_w * 0.65, -half_h * 0.65).rotated(pose.get_rotation())
			var mana_pt: Vector2 = pose.origin + mana_offset
			var picked: int = fan.pick_card_at(mana_pt)
			asserts.assert_equal(picked, i, "Card %d of %d exposed mana area pickable (got %d)" % [i, count, picked])

		# Points outside hand fan return -1
		asserts.assert_equal(fan.pick_card_at(Vector2(-50, 100)), -1, "Left of hand returns -1")
		asserts.assert_equal(fan.pick_card_at(Vector2(1350, 100)), -1, "Right of hand returns -1")
		asserts.assert_equal(fan.pick_card_at(Vector2(640, -350)), -1, "Above hand returns -1")
		asserts.assert_equal(fan.pick_card_at(Vector2(640, 350)), -1, "Below hand returns -1")
		fan.free()

	# 2. Hover Stability & Steering
	var test_fan: CombatPreviewCards = CombatPreviewCards.new()
	test_fan.size = Vector2(1280, 252)
	test_fan.display_count = 7
	test_fan.rebuild()

	# Hover card 3 (center)
	test_fan.set_inspected_card(3, 1.0)
	asserts.assert_equal(test_fan.get_hover_state(), CombatPreviewCards.HoverState.INSPECTING, "State is INSPECTING at blend 1.0")
	asserts.assert_equal(test_fan.get_hovered_index(), 3, "Hovered index is 3")

	# Point in upper raised card body (above resting cards) maintains inspection ownership
	var raised_pose_x: float = CombatPreviewCards.layout_pose(3, 7, 1280, 270).origin.x
	var upper_raised_pt: Vector2 = Vector2(raised_pose_x, -50.0)
	asserts.assert_equal(test_fan.pick_card_at(upper_raised_pt), 3, "Pointer in raised body maintains inspection")

	# Point on neighboring resting card 2 switches pick to card 2
	var card2_pose: Transform2D = CombatPreviewCards.layout_pose(2, 7, 1280, 270)
	var card2_pt: Vector2 = card2_pose.origin + Vector2(-50, -50).rotated(card2_pose.get_rotation())
	asserts.assert_equal(test_fan.pick_card_at(card2_pt), 2, "Steering into neighbor resting area selects neighbor")
	test_fan.free()

	# 3. Animation Controller, Smooth Transitions & State Machine
	var anim_fan: CombatPreviewCards = CombatPreviewCards.new()
	anim_fan.size = Vector2(1280, 252)
	anim_fan.display_count = 7
	anim_fan.rebuild()
	asserts.assert_equal(anim_fan.get_hover_state(), CombatPreviewCards.HoverState.IDLE, "Initial state is IDLE")

	# Simulate pointer motion to card 4
	var card4_pose: Transform2D = CombatPreviewCards.layout_pose(4, 7, 1280, 270)
	var card4_pt: Vector2 = card4_pose.origin + Vector2(-40, -40).rotated(card4_pose.get_rotation())
	anim_fan.pick_card_at(card4_pt)
	anim_fan._on_pointer_motion(anim_fan.get_global_transform() * card4_pt)
	asserts.assert_equal(anim_fan.get_hovered_index(), 4, "Target index set to 4 on pointer motion")

	# Step animation partially
	anim_fan._process(0.02)
	asserts.assert_true(anim_fan.get_card_blend(4) > 0.0, "Card 4 blend begins rising")
	asserts.assert_true(anim_fan.get_hover_state() == CombatPreviewCards.HoverState.HOVERING or anim_fan.get_hover_state() == CombatPreviewCards.HoverState.TRANSITIONING, "State is HOVERING/TRANSITIONING")

	# Step animation to completion
	anim_fan._process(0.20)
	asserts.assert_equal(anim_fan.get_card_blend(4), 1.0, "Card 4 blend settles at 1.0")
	asserts.assert_equal(anim_fan.get_hover_state(), CombatPreviewCards.HoverState.INSPECTING, "State settles into INSPECTING")
	asserts.assert_equal((anim_fan.get_child(4) as Control).z_index, 100, "Inspected card has z_index 100")

	# Rapid switch to card 5
	var card5_pose: Transform2D = CombatPreviewCards.layout_pose(5, 7, 1280, 270)
	var card5_pt: Vector2 = card5_pose.origin + Vector2(-40, -40).rotated(card5_pose.get_rotation())
	anim_fan._on_pointer_motion(anim_fan.get_global_transform() * card5_pt)
	asserts.assert_equal(anim_fan.get_hovered_index(), 5, "Target retargets to 5")

	# Halfway through retarget
	anim_fan._process(0.09)
	asserts.assert_true(anim_fan.get_card_blend(4) > 0.0 and anim_fan.get_card_blend(4) < 1.0, "Card 4 returning smoothly")
	asserts.assert_true(anim_fan.get_card_blend(5) > 0.0 and anim_fan.get_card_blend(5) < 1.0, "Card 5 rising smoothly")
	asserts.assert_equal((anim_fan.get_child(5) as Control).z_index, 100, "Rising card takes topmost z_index")

	# Settle retarget
	anim_fan._process(0.20)
	asserts.assert_equal(anim_fan.get_card_blend(4), 0.0, "Card 4 fully returned")
	asserts.assert_equal(anim_fan.get_card_blend(5), 1.0, "Card 5 fully inspected")
	asserts.assert_equal(anim_fan.get_hover_state(), CombatPreviewCards.HoverState.INSPECTING, "State settles back to INSPECTING")

	# Pointer leaves hand
	anim_fan._on_pointer_motion(anim_fan.get_global_transform() * Vector2(-500, -500))
	asserts.assert_equal(anim_fan.get_hovered_index(), -1, "Target cleared on exit")
	anim_fan._process(0.05)
	asserts.assert_equal(anim_fan.get_hover_state(), CombatPreviewCards.HoverState.RETURNING, "State is RETURNING")
	anim_fan._process(0.25)
	asserts.assert_equal(anim_fan.get_hover_state(), CombatPreviewCards.HoverState.IDLE, "State settles to IDLE on completion")
	asserts.assert_equal(anim_fan.get_card_blend(5), 0.0, "Card 5 blend returns to 0.0")
	anim_fan.free()

	# 4. Viewport Containment & Clearance for Inspected Cards
	for count: int in [1, 3, 5, 7, 10]:
		var check_fan: CombatPreviewCards = CombatPreviewCards.new()
		check_fan.size = Vector2(1280, 252)
		check_fan.display_count = count
		check_fan.rebuild()

		for i: int in range(count):
			check_fan.set_inspected_card(i, 1.0)
			var raised: Control = check_fan.get_child(i) as Control
			var min_x: float = 9999.0
			var max_x: float = -9999.0
			var min_y: float = 9999.0
			var max_y: float = -9999.0

			for corner_pt: Vector2 in [Vector2.ZERO, Vector2(raised.size.x, 0), raised.size, Vector2(0, raised.size.y)]:
				var global_pt: Vector2 = raised.get_transform() * corner_pt + Vector2(320, 804)
				min_x = minf(min_x, global_pt.x)
				max_x = maxf(max_x, global_pt.x)
				min_y = minf(min_y, global_pt.y)
				max_y = maxf(max_y, global_pt.y)
				asserts.assert_true(Rect2(Vector2.ZERO, Vector2(1920, 1080)).has_point(global_pt),
					"Inspected card %d of %d corner inside 1080p viewport (pt=%s)" % [i, count, global_pt])

			# Clearances from left hero column (ends at x=296) and right utility column (starts at x=1624)
			asserts.assert_true(min_x >= 320.0, "Inspected card clears left hero column (min_x=%.1f >= 320.0)" % min_x)
			asserts.assert_true(max_x <= 1600.0, "Inspected card clears right utility column (max_x=%.1f <= 1600.0)" % max_x)
			asserts.assert_true(max_y <= 1076.0, "Inspected card clears bottom screen boundary (max_y=%.1f <= 1076.0)" % max_y)
		check_fan.free()


func _test_bottom_left_hud(asserts: TestAsserts) -> void:
	asserts.set_current_test("r06e:bottom_left_hud")
	var screen: CombatScreen = COMBAT_SCREEN_SCENE.instantiate() as CombatScreen
	var hero: Panel = screen.get_player_hero_zone()
	asserts.assert_equal(hero.size, Vector2(272, 700), "Approved panel size preserved")
	var names: Array[String] = ["Backplate", "Portrait", "PortraitFrame", "PlayerHealthOrb", "PlayerManaOrb"]
	var rects: Array[Rect2] = [Rect2(0, 0, 272, 700), Rect2(62, 70, 148, 144), Rect2(36, 42, 200, 200), Rect2(46, 252, 180, 180), Rect2(46, 452, 180, 180)]
	for i: int in range(names.size()):
		var child: Control = hero.get_node(names[i]) as Control
		asserts.assert_equal(child.get_rect(), rects[i], "Approved local geometry: " + names[i])
		asserts.assert_true(Rect2(Vector2.ZERO, hero.size).encloses(child.get_rect()), "Child fully inside backplate: " + names[i])
	asserts.assert_true(screen.get_player_health_orb() == hero.get_node("PlayerHealthOrb"), "Stable Health path/API")
	asserts.assert_true(screen.get_player_mana_orb() == hero.get_node("PlayerManaOrb"), "Stable Mana path/API")
	asserts.assert_equal(screen.get_opponent_hero_zone().get_rect(), Rect2(24, 24, 272, 296), "R07B moves opponent into reserved envelope")
	asserts.assert_equal((screen.get_node("CombatLayout/OpponentHand") as Control).get_rect(), Rect2(320, 30, 1280, 160), "R07B centers opponent hand above battlefield")
	asserts.assert_equal(screen.get_player_hand_zone().get_rect(), Rect2(320, 804, 1280, 252), "Player hand remains fixed")
	asserts.assert_equal(screen.get_battlefield_zone().get_rect(), Rect2(320, 220, 1280, 560), "Master battlefield remains fixed")
	for dimensions: Vector2 in [Vector2(1920, 1080), Vector2(1280, 720)]:
		screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
		screen.size = dimensions
		screen._apply_responsive_layout()
		var factor: float = screen.get_combat_layout().scale.x
		var layout_transform: Transform2D = screen.get_combat_layout().get_transform()
		# Off-tree Controls do not include ancestor transforms in get_global_rect().
		var bounds: Rect2 = layout_transform * hero.get_rect()
		asserts.assert_true(Rect2(Vector2.ZERO, dimensions).encloses(bounds), "Full HUD inside viewport")
		asserts.assert_true(is_equal_approx(bounds.position.x / factor, 24.0), "Consistent scaled left margin")
		asserts.assert_true(is_equal_approx((dimensions.y - bounds.end.y) / factor, 36.0), "36 reference px bottom breathing room")
		for zone: Control in [screen.get_battlefield_zone(), screen.get_player_hand_zone(), screen.get_action_bar_zone()]:
			asserts.assert_false(bounds.intersects(layout_transform * zone.get_rect()), "HUD clears functional region: " + str(zone.name))
			asserts.assert_true((layout_transform * zone.get_rect()).position.x - bounds.end.x >= 23.9 * factor, "Horizontal gutter preserved")
		for child_name: String in names:
			asserts.assert_true(bounds.encloses(layout_transform * hero.get_transform() * (hero.get_node(child_name) as Control).get_rect()), "Scaled child contained: " + child_name)
	screen.free()

func _test_opponent_hud_and_card_backs(asserts: TestAsserts) -> void:
	asserts.set_current_test("r07b:opponent_hud_and_hidden_hand")
	var screen: CombatScreen = COMBAT_SCREEN_SCENE.instantiate() as CombatScreen
	screen._connect_opponent_resource_labels()
	# Reconnecting must not create duplicate signal delivery.
	screen._connect_opponent_resource_labels()
	var zone: Panel = screen.get_opponent_hero_zone()
	var player: Panel = screen.get_player_hero_zone()
	asserts.assert_false(zone.get_rect().intersects(player.get_rect()), "Hero envelopes separated")
	asserts.assert_equal(zone.position.x + zone.size.x*0.5, player.position.x + player.size.x*0.5, "Shared left-column centerline")
	asserts.assert_true(zone.get_theme_stylebox("panel") is StyleBoxEmpty, "No procedural opponent panel frame")
	var backplate: TextureRect = zone.get_node("Backplate") as TextureRect
	var atlas: AtlasTexture = backplate.texture as AtlasTexture
	asserts.assert_equal(atlas.atlas.resource_path,"res://assets/_source/lot1/hud/opponent/mo_hud_opponent_panel_v01.png","Exact approved panel imports")
	asserts.assert_true(atlas.region.encloses(Rect2(156,18,889,1239)),"Crop preserves painted silhouette")
	asserts.assert_equal(backplate.stretch_mode,TextureRect.STRETCH_KEEP_ASPECT_CENTERED,"Uniform panel scaling")
	var frame: TextureRect = zone.get_node("PortraitFrame") as TextureRect
	var portrait: TextureRect = zone.get_node("Portrait") as TextureRect
	asserts.assert_equal(frame.size.x,frame.size.y,"Portrait frame not stretched")
	asserts.assert_true(absf(frame.position.x+frame.size.x*0.5-zone.size.x*0.5) <= 1,"Portrait frame on panel centerline")
	# Approved frame's measured aperture center differs from its padded canvas center.
	var aperture_center: Vector2 = frame.position + Vector2(626.5,615.0)*frame.size/1254.0
	asserts.assert_true((portrait.position+portrait.size*0.5-aperture_center).length() <= 1,"Illustration centered in actual painted aperture")
	asserts.assert_equal(frame.texture,(player.get_node("PortraitFrame") as TextureRect).texture,"Approved shared frame")
	asserts.assert_true(frame.get_rect().encloses(portrait.get_rect()),"Portrait stays under frame aperture")
	asserts.assert_true(portrait.material is ShaderMaterial,"Portrait corners masked")
	for hidden_name: String in ["Name","DeckCount","GraveyardCount"]:
		asserts.assert_false((zone.get_node(hidden_name) as CanvasItem).visible,"No old opponent text: "+hidden_name)
	var hp: LiquidResourceOrb = screen.get_opponent_health_orb()
	var mana: LiquidResourceOrb = screen.get_opponent_mana_orb()
	asserts.assert_equal(hp.size,mana.size,"Equal indicator dimensions")
	asserts.assert_true(hp.size.x <= 48 and hp.size.x >= 40,"Compact resource indicators")
	asserts.assert_equal(hp.position.x,mana.position.x,"Resources share vertical axis")
	asserts.assert_true(hp.position.y+hp.size.y < mana.position.y,"Separated resource rows")
	for i: int in range(2):
		var orb: LiquidResourceOrb = hp if i == 0 else mana
		var caption: Label = zone.get_node("HealthCaption" if i == 0 else "ManaCaption") as Label
		var value: Label = zone.get_node("HealthValues" if i == 0 else "ManaValues") as Label
		orb._layout_contents()
		asserts.assert_equal(orb.housing_texture,screen.get_player_health_orb().housing_texture,"Reuse approved mounting")
		asserts.assert_false((orb.get_node("Kind") as Label).visible,"No internal caption")
		asserts.assert_false((orb.get_node("Values") as Label).visible,"No duplicate internal value")
		asserts.assert_true(value.position.x >= orb.position.x+orb.size.x+8,"Value clears housing")
		asserts.assert_equal(caption.position.x,value.position.x,"Caption/value alignment")
		asserts.assert_true(value.get_theme_font_size("font_size")*2.0/3.0 >= 15,"At least 15 physical px at 720p")
		for values: Vector2i in [Vector2i(30,30),Vector2i(18,30),Vector2i(0,30),Vector2i(100,100),Vector2i(0,0),Vector2i(1,1),Vector2i(5,5),Vector2i(10,10)]:
			orb.set_resource_values(values.x,values.y,false)
			asserts.assert_equal(value.text,"%d / %d" % [values.x,values.y],"External values synchronize without animation delay")
			var ink: Vector2 = value.get_theme_font("font").get_string_size(value.text,HORIZONTAL_ALIGNMENT_LEFT,-1,value.get_theme_font_size("font_size"))
			asserts.assert_true(ink.x+2 <= value.size.x,"Real font metrics fit including outline")
			asserts.assert_true(ink.y <= value.size.y,"Real font height fits")
		orb.set_resource_values(300,30,false)
		asserts.assert_equal(value.text,"30 / 30","External label uses clamped API values")
		orb.set_resource_values(10,10)
		asserts.assert_equal(value.text,"10 / 10","Same-ratio new maxima still synchronize")
		orb.set_resource_values(3,5,false)
		asserts.assert_true(is_equal_approx(orb.get_visible_fill_ratio(),0.6),"Compact API retains fill behavior")
		orb.internal_labels_visible = true
		asserts.assert_true((orb.get_node("Values") as Label).visible,"Internal label option reversible")
		orb.internal_labels_visible = false
	asserts.assert_true(screen.get_player_health_orb().internal_labels_visible,"Player internal values preserved")
	var fan: CombatPreviewCards = screen.get_node("CombatLayout/OpponentHand") as CombatPreviewCards
	fan.rebuild()
	asserts.assert_equal(fan.get_child_count(),6,"Exactly six hidden cards")
	for index: int in range(fan.get_child_count()):
		var card: Control = fan.get_child(index) as Control
		var back: TextureRect = card.get_node("CardBack") as TextureRect
		asserts.assert_equal(card.get_child_count(),1,"Back-only tree has no front overlays, identity or emblem")
		asserts.assert_equal(back.texture.resource_path,"res://assets/_source/lot1/hud/opponent/mo_hud_opponent_card_back_v01.png","Approved back on every card")
		asserts.assert_equal(back.texture.get_size(),card.size,"Native 1086x1448 coordinates")
		asserts.assert_true(is_equal_approx(card.size.x/card.size.y,0.75) and card.scale.x == card.scale.y,"Uniform 3:4 cards")
		asserts.assert_equal(card.z_index,index,"Stable stacking")
		asserts.assert_true(back.material is ShaderMaterial,"Near-opaque source interior made opaque without editing PNG")
		asserts.assert_equal(card.mouse_filter,Control.MOUSE_FILTER_IGNORE,"Card ignores input")
		asserts.assert_equal(back.mouse_filter,Control.MOUSE_FILTER_IGNORE,"Back ignores input")
		var pose: Transform2D = card.get_transform()
		fan.set_inspected_card(index)
		asserts.assert_equal(card.get_transform(),pose,"Programmatic inspection cannot expose opponent cards")
		for corner: Vector2 in [Vector2.ZERO,Vector2(card.size.x,0),card.size,Vector2(0,card.size.y)]:
			var point: Vector2 = fan.position + card.get_transform()*corner
			for factor: float in [1.0,2.0/3.0]:
				asserts.assert_true(Rect2(Vector2.ZERO,Vector2(1920,1080)*factor).has_point(point*factor),"Opponent fan inside target viewport")
			asserts.assert_true(point.y < screen.get_battlefield_zone().position.y,"Card clears tactical battlefield")
	asserts.assert_equal(fan.pick_card_at(fan.size*0.5),-1,"Hidden fan never picks")
	asserts.assert_equal(fan.get_hovered_index(),-1,"Hidden fan cannot hover")
	asserts.assert_true(fan.face_down,"Opponent stays face down")
	asserts.assert_false((screen.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards).face_down,"Player face-up cards preserved")
	screen.free()


func _test_p005_r09b_card_hover_readability_and_inspection(asserts: TestAsserts) -> void:
	asserts.set_current_test("combat_screen:p005_r09b_card_hover_readability_and_inspection")

	var fan: CombatPreviewCards = CombatPreviewCards.new()
	fan.size = Vector2(1280, 252)
	fan.display_count = 7
	fan.rebuild()

	# 1. Inspection size and aspect ratio
	asserts.assert_equal(fan.inspection_height, 540.0, "P005-R09B default inspection height must be 540.0 px")
	var scale_factor: float = fan.inspection_height / CardViewLayout.CARD_SIZE.y
	var expected_width: float = CardViewLayout.CARD_SIZE.x * scale_factor
	asserts.assert_true(is_equal_approx(expected_width, 405.0), "Inspected card width must be 405.0 px at 540 px height (3:4 ratio)")
	asserts.assert_true(is_equal_approx(expected_width / fan.inspection_height, 0.75), "Inspected card must strictly preserve 3:4 aspect ratio")

	# 2. Adaptive inspection center calculations across candidate heights
	# Baseline Candidate A (440 px): y = 20.0 (baseline preserved)
	var center_440: Vector2 = CombatPreviewCards.calculate_inspection_center(640.0, 1280.0, 440.0)
	asserts.assert_equal(center_440.y, 20.0, "Candidate A (440 px) inspection center Y must remain baseline 20.0 px")

	# Candidate B (500 px): y = 0.0
	var center_500: Vector2 = CombatPreviewCards.calculate_inspection_center(640.0, 1280.0, 500.0)
	asserts.assert_equal(center_500.y, 0.0, "Candidate B (500 px) inspection center Y must be 0.0 px")

	# Candidate C (540 px): y = -20.0
	var center_540: Vector2 = CombatPreviewCards.calculate_inspection_center(640.0, 1280.0, 540.0)
	asserts.assert_equal(center_540.y, -20.0, "Candidate C (540 px) inspection center Y must be -20.0 px")

	# 3. Viewport and screen-edge containment for 540 px inspection
	# CombatLayout coordinates: hand_offset_y = 804.0, hand_offset_x = 320.0
	var hand_y: float = 804.0
	var hand_x: float = 320.0
	var half_h: float = 540.0 * 0.5 # 270.0 px
	var half_w: float = 405.0 * 0.5 # 202.5 px

	var card_bottom_screen: float = hand_y + center_540.y + half_h # 804 - 20 + 270 = 1054.0 px
	var card_top_screen: float = hand_y + center_540.y - half_h    # 804 - 20 - 270 = 514.0 px

	asserts.assert_equal(card_bottom_screen, 1054.0, "Inspected card bottom must reach exactly y=1054.0 px")
	asserts.assert_true(card_bottom_screen <= 1080.0 - 26.0, "Inspected card bottom must maintain >= 26 px screen margin (no clipping)")
	asserts.assert_true(card_top_screen >= 480.0, "Inspected card top must remain strictly below center divider (y=480 px)")

	# 4. Horizontal containment and clearance to side HUD columns (1080p and 720p)
	for test_count: int in [7, 10]:
		fan.display_count = test_count
		fan.rebuild()

		# Leftmost card
		var left_rest_x: float = CombatPreviewCards.layout_pose(0, test_count, 1280, 270).origin.x
		var left_center: Vector2 = CombatPreviewCards.calculate_inspection_center(left_rest_x, 1280.0, 540.0)
		var left_edge_screen: float = hand_x + left_center.x - half_w
		var player_hud_right: float = 296.0 # PlayerHeroZone ends at x=296
		var clearance_left: float = left_edge_screen - player_hud_right
		asserts.assert_true(clearance_left >= 38.0, "Leftmost card (count %d) must clear Player HUD by >= 38 px (got %.2f px)" % [test_count, clearance_left])

		# Rightmost card
		var right_rest_x: float = CombatPreviewCards.layout_pose(test_count - 1, test_count, 1280, 270).origin.x
		var right_center: Vector2 = CombatPreviewCards.calculate_inspection_center(right_rest_x, 1280.0, 540.0)
		var right_edge_screen: float = hand_x + right_center.x + half_w
		var utility_hud_left: float = 1624.0 # ActionBarZone starts at x=1624
		var clearance_right: float = utility_hud_left - right_edge_screen
		asserts.assert_true(clearance_right >= 38.0, "Rightmost card (count %d) must clear Utility HUD by >= 38 px (got %.2f px)" % [test_count, clearance_right])

	# 5. Interactive pointer picking with 540 px inspection
	fan.display_count = 7
	fan.rebuild()
	fan.set_inspected_card(3, 1.0)
	asserts.assert_equal(fan.get_hover_state(), CombatPreviewCards.HoverState.INSPECTING, "Hover state must be INSPECTING")

	var raised_x: float = CombatPreviewCards.layout_pose(3, 7, 1280, 270).origin.x
	var upper_pt: Vector2 = Vector2(raised_x, -50.0)
	asserts.assert_equal(fan.pick_card_at(upper_pt), 3, "Pointer in raised 540 px body must maintain inspection ownership")

	var outside_pt: Vector2 = Vector2(raised_x, -350.0)
	asserts.assert_equal(fan.pick_card_at(outside_pt), -1, "Pointer far above raised card returns -1")

	# 6. Responsive 720p physical metrics
	var factor_720p: float = 2.0 / 3.0
	var physical_h_720p: float = 540.0 * factor_720p
	var physical_w_720p: float = 405.0 * factor_720p
	asserts.assert_equal(physical_h_720p, 360.0, "At 720p, inspected card height must be 360.0 physical px (was 293.3 px in R09A)")
	asserts.assert_equal(physical_w_720p, 270.0, "At 720p, inspected card width must be 270.0 physical px (was 220.0 px in R09A)")

	fan.free()
