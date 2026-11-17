class_name TestCombatHud
extends RefCounted
## Automated native test suite for P007: Hero & Turn HUD Data Binding.
## Verifies typed view-models, snapshot injection, granular updates, component
## adapters, End Turn signals, and strict preservation of P005/P006 baselines.

const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")

var _hud_applied_count: int = 0
var _end_turn_requested_count: int = 0

func run_suite(asserts: TestAsserts, failure_mode: bool = false) -> void:
	_test_view_model_construction_and_validation(asserts)
	_test_turn_and_phase_formatting(asserts)
	_test_snapshot_injection_and_idempotence(asserts)
	_test_resource_updates_and_clamping(asserts)
	_test_deck_and_graveyard_binding(asserts)
	_test_end_turn_presentation_and_signals(asserts)
	_test_recent_actions_log(asserts)
	_test_granular_update_apis(asserts)
	_test_p005_and_p006_preservation(asserts)

	if failure_mode:
		_test_intentional_failure(asserts)

func _test_view_model_construction_and_validation(asserts: TestAsserts) -> void:
	asserts.set_current_test("combat_hud:view_model_construction_and_validation")

	# 1. Default creation
	var default_vm: CombatHudViewModel = CombatHudViewModel.create_default()
	asserts.assert_true(default_vm != null, "Default CombatHudViewModel must instantiate cleanly")
	asserts.assert_true(default_vm.is_valid(), "Default CombatHudViewModel must validate as valid")
	asserts.assert_equal(default_vm.player_hero.hero_name, "Player", "Default player hero name")
	asserts.assert_equal(default_vm.opponent_hero.hero_name, "Opponent", "Default opponent hero name")
	asserts.assert_equal(default_vm.player_hero.current_health, 30, "Default player health 30")
	asserts.assert_equal(default_vm.player_hero.current_mana, 1, "Default player mana 1")
	asserts.assert_equal(default_vm.turn_number, 1, "Default turn number 1")
	asserts.assert_equal(default_vm.active_camp, BattlefieldSlot.Camp.PLAYER, "Default active camp PLAYER")
	asserts.assert_equal(default_vm.phase, CombatHudViewModel.Phase.ACTION, "Default phase ACTION")
	asserts.assert_true(default_vm.end_turn_enabled, "Default end turn enabled")

	# 2. Decoupled cloning
	var clone_vm: CombatHudViewModel = default_vm.duplicate_model()
	asserts.assert_true(clone_vm != default_vm, "Clone must be a distinct object reference")
	asserts.assert_true(clone_vm.player_hero != default_vm.player_hero, "Cloned player hero must be distinct")
	clone_vm.player_hero.current_health = 15
	asserts.assert_equal(default_vm.player_hero.current_health, 30, "Mutating clone must not affect original")

	# 3. Invalid model rejection
	var invalid_hero: HeroHudViewModel = HeroHudViewModel.new("", -5, 30, 0, 1, 0, 0)
	asserts.assert_false(invalid_hero.is_valid(), "Hero with empty name or negative health must be invalid")

	var invalid_turn_vm: CombatHudViewModel = CombatHudViewModel.create_default()
	invalid_turn_vm.turn_number = 0
	asserts.assert_false(invalid_turn_vm.is_valid(), "Turn number < 1 must be invalid")

	var invalid_null_hero_vm: CombatHudViewModel = CombatHudViewModel.new(null, null, 1)
	asserts.assert_true(invalid_null_hero_vm.is_valid(), "Null hero parameters fallback to valid default heroes")

func _test_turn_and_phase_formatting(asserts: TestAsserts) -> void:
	asserts.set_current_test("combat_hud:turn_and_phase_formatting")

	var vm: CombatHudViewModel = CombatHudViewModel.create_default()

	# Turn formatting
	vm.turn_number = 1
	asserts.assert_equal(vm.get_formatted_turn(), "TURN 01", "Turn 1 formats as TURN 01")
	vm.turn_number = 10
	asserts.assert_equal(vm.get_formatted_turn(), "TURN 10", "Turn 10 formats as TURN 10")
	vm.turn_display_override = "FINAL TURN"
	asserts.assert_equal(vm.get_formatted_turn(), "FINAL TURN", "Explicit turn override honored")
	vm.turn_display_override = ""

	# Phase formatting across camps
	vm.active_camp = BattlefieldSlot.Camp.PLAYER
	vm.phase = CombatHudViewModel.Phase.TURN_START
	asserts.assert_equal(vm.get_formatted_phase(), "PLAYER  /  START", "Player start phase")
	vm.phase = CombatHudViewModel.Phase.ACTION
	asserts.assert_equal(vm.get_formatted_phase(), "PLAYER  /  ACTION", "Player action phase")
	vm.phase = CombatHudViewModel.Phase.ATTACK
	asserts.assert_equal(vm.get_formatted_phase(), "END-OF-TURN ATTACK", "Attack phase string")
	vm.phase = CombatHudViewModel.Phase.CLEANUP
	asserts.assert_equal(vm.get_formatted_phase(), "PLAYER  /  CLEANUP", "Player cleanup phase")
	vm.phase = CombatHudViewModel.Phase.MATCH_OVER
	asserts.assert_equal(vm.get_formatted_phase(), "MATCH OVER", "Match over phase")

	vm.active_camp = BattlefieldSlot.Camp.OPPONENT
	vm.phase = CombatHudViewModel.Phase.ACTION
	asserts.assert_equal(vm.get_formatted_phase(), "OPPONENT  /  ACTION", "Opponent action phase")
	vm.phase = CombatHudViewModel.Phase.TURN_START
	asserts.assert_equal(vm.get_formatted_phase(), "OPPONENT  /  START", "Opponent start phase")

	vm.phase_display_override = "SPECIAL RESOLUTION"
	asserts.assert_equal(vm.get_formatted_phase(), "SPECIAL RESOLUTION", "Explicit phase override honored")

func _test_snapshot_injection_and_idempotence(asserts: TestAsserts) -> void:
	asserts.set_current_test("combat_hud:snapshot_injection_and_idempotence")

	var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
	_hud_applied_count = 0
	screen.hud_view_model_applied.connect(func(_vm): _hud_applied_count += 1)

	# 1. Invalid injection fails closed with zero mutation
	var invalid_vm: CombatHudViewModel = CombatHudViewModel.create_default()
	invalid_vm.turn_number = -1
	asserts.assert_false(screen.apply_hud_view_model(null), "Null model rejected")
	asserts.assert_false(screen.apply_hud_view_model(invalid_vm), "Invalid model rejected")
	asserts.assert_equal(_hud_applied_count, 0, "No signal emitted on rejected injection")

	# 2. Valid snapshot application
	var vm: CombatHudViewModel = CombatHudViewModel.create_default()
	vm.player_hero.current_health = 28
	vm.player_hero.max_health = 30
	vm.player_hero.current_mana = 2
	vm.player_hero.max_mana = 3
	vm.opponent_hero.current_health = 25
	vm.opponent_hero.max_health = 30
	vm.opponent_hero.current_mana = 1
	vm.opponent_hero.max_mana = 2
	vm.player_hero.deck_count = 32
	vm.opponent_hero.deck_count = 31
	vm.player_hero.graveyard_count = 0
	vm.opponent_hero.graveyard_count = 0
	vm.turn_number = 3
	vm.active_camp = BattlefieldSlot.Camp.PLAYER
	vm.phase = CombatHudViewModel.Phase.ACTION
	vm.end_turn_enabled = true
	vm.recent_actions = ["Arcane Knight summoned in Col 2"]

	var ok: bool = screen.apply_hud_view_model(vm, false)
	asserts.assert_true(ok, "Valid snapshot must apply with true")
	asserts.assert_equal(_hud_applied_count, 1, "hud_view_model_applied signal emitted once")

	# 3. Verify applied values on controls
	asserts.assert_equal(screen.get_player_health_orb().current_value, 28, "Player health applied")
	asserts.assert_equal(screen.get_player_health_orb().maximum_value, 30, "Player max health applied")
	asserts.assert_equal(screen.get_player_mana_orb().current_value, 2, "Player mana applied")
	asserts.assert_equal(screen.get_player_mana_orb().maximum_value, 3, "Player max mana applied")

	asserts.assert_equal(screen.get_opponent_health_orb().current_value, 25, "Opponent health applied")
	asserts.assert_equal((screen.get_opponent_hero_zone().get_node("HealthValues") as Label).text, "25 / 30", "Opponent health label text updated")
	asserts.assert_equal(screen.get_opponent_mana_orb().current_value, 1, "Opponent mana applied")
	asserts.assert_equal((screen.get_opponent_hero_zone().get_node("ManaValues") as Label).text, "1 / 2", "Opponent mana label text updated")

	asserts.assert_equal(screen.get_player_deck().visual_count, 32, "Player deck count applied")
	asserts.assert_equal(screen.get_opponent_deck().visual_count, 31, "Opponent deck count applied")

	asserts.assert_equal((screen.get_match_status().get_node("Turn") as Label).text, "TURN 03", "Turn label text applied")
	asserts.assert_equal((screen.get_match_status().get_node("Phase") as Label).text, "PLAYER  /  ACTION", "Phase label text applied")
	asserts.assert_false(screen.get_end_turn_button().disabled, "End turn button enabled applied")
	asserts.assert_equal((screen.get_action_bar_zone().get_node("RecentActions") as Label).text, "Arcane Knight summoned in Col 2", "Recent actions applied")

	# 4. Idempotent re-injection
	var ok_repeat: bool = screen.apply_hud_view_model(vm, false)
	asserts.assert_true(ok_repeat, "Identical snapshot must reapply cleanly")
	asserts.assert_equal(_hud_applied_count, 2, "Signal emitted on second snapshot")
	asserts.assert_equal(screen.get_player_health_orb().current_value, 28, "Values remain stable on repeat")

	# 5. Getter parity
	var readback_vm: CombatHudViewModel = screen.get_hud_view_model()
	asserts.assert_equal(readback_vm.turn_number, 3, "Getter matches applied turn")
	asserts.assert_equal(readback_vm.player_hero.current_health, 28, "Getter matches applied player health")
	asserts.assert_equal(readback_vm.opponent_hero.current_health, 25, "Getter matches applied opponent health")

	screen.free()

func _test_resource_updates_and_clamping(asserts: TestAsserts) -> void:
	asserts.set_current_test("combat_hud:resource_updates_and_clamping")

	var screen: CombatScreen = SCREEN.instantiate() as CombatScreen

	# Test partial, empty, and restoration
	screen.apply_hero_resources(BattlefieldSlot.Camp.PLAYER, 15, 30, 0, 5, false)
	asserts.assert_equal(screen.get_player_health_orb().current_value, 15, "Player health updated to 15")
	asserts.assert_equal(screen.get_player_health_orb().maximum_value, 30, "Player max health 30")
	asserts.assert_true(is_equal_approx(screen.get_player_health_orb().get_visible_fill_ratio(), 0.5), "Fill ratio is 0.5")
	asserts.assert_equal(screen.get_player_mana_orb().current_value, 0, "Player mana 0")
	asserts.assert_true(is_equal_approx(screen.get_player_mana_orb().get_visible_fill_ratio(), 0.0), "Fill ratio is 0.0 for empty mana")

	# Restore resources
	screen.apply_hero_resources(BattlefieldSlot.Camp.PLAYER, 30, 30, 5, 5, false)
	asserts.assert_equal(screen.get_player_health_orb().current_value, 30, "Player health restored to 30")
	asserts.assert_equal(screen.get_player_mana_orb().current_value, 5, "Player mana restored to 5")
	asserts.assert_true(is_equal_approx(screen.get_player_health_orb().get_visible_fill_ratio(), 1.0), "Fill ratio is 1.0")

	# Clamping: current > max is clamped to max
	screen.apply_hero_resources(BattlefieldSlot.Camp.OPPONENT, 45, 30, 10, 5, false)
	asserts.assert_equal(screen.get_opponent_health_orb().current_value, 30, "Over-health clamped to max_health")
	asserts.assert_equal(screen.get_opponent_mana_orb().current_value, 5, "Over-mana clamped to max_mana")

	# Invalid negative values rejected
	asserts.assert_false(screen.apply_hero_resources(BattlefieldSlot.Camp.PLAYER, -1, 30, 0, 1), "Negative health rejected")

	screen.free()

func _test_deck_and_graveyard_binding(asserts: TestAsserts) -> void:
	asserts.set_current_test("combat_hud:deck_and_graveyard_binding")

	var screen: CombatScreen = SCREEN.instantiate() as CombatScreen

	# 1. Deck counts
	screen.apply_deck_counts(34, 30)
	asserts.assert_equal(screen.get_player_deck().visual_count, 34, "Player deck 34")
	asserts.assert_equal(screen.get_opponent_deck().visual_count, 30, "Opponent deck 30")

	screen.apply_deck_counts(0, 100)
	asserts.assert_equal(screen.get_player_deck().visual_count, 0, "Player deck 0 (empty)")
	asserts.assert_equal(screen.get_opponent_deck().visual_count, 100, "Opponent deck 100 (3-digit count)")

	asserts.assert_false(screen.apply_deck_counts(-1, 20), "Negative deck count rejected")

	# 2. Graveyard count updates
	screen.apply_graveyard_counts(0, 0)
	asserts.assert_equal(screen.get_player_graveyard().visual_count, 0, "Player graveyard 0")
	asserts.assert_true(screen.get_player_graveyard().has_node("Empty"), "Empty graveyard shows Empty node")

	# Update count without top card
	screen.apply_graveyard_counts(4, 2)
	asserts.assert_equal(screen.get_player_graveyard().visual_count, 4, "Player graveyard count 4")
	asserts.assert_equal(screen.get_opponent_graveyard().visual_count, 2, "Opponent graveyard count 2")

	# Update count with top card
	var top_card: GraveyardView.PreviewCard = GraveyardView.PreviewCard.new()
	top_card.title = "Arcane Knight"
	screen.get_player_graveyard().set_card_count(5, top_card)
	asserts.assert_equal(screen.get_player_graveyard().visual_count, 5, "Graveyard count 5")
	asserts.assert_true(screen.get_player_graveyard().has_node("LastEnteringCard"), "Top card miniature rendered")

	# Preserving top card on count change
	screen.get_player_graveyard().set_card_count(6, null)
	asserts.assert_equal(screen.get_player_graveyard().visual_count, 6, "Count updated to 6")
	asserts.assert_true(screen.get_player_graveyard().has_node("LastEnteringCard"), "Top card miniature preserved")

	# Clearing to 0 discards top card
	screen.get_player_graveyard().set_card_count(0, null)
	asserts.assert_equal(screen.get_player_graveyard().visual_count, 0, "Graveyard reset to 0")
	asserts.assert_true(screen.get_player_graveyard().has_node("Empty"), "Reset to Empty node")

	screen.free()

func _test_end_turn_presentation_and_signals(asserts: TestAsserts) -> void:
	asserts.set_current_test("combat_hud:end_turn_presentation_and_signals")

	var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
	_end_turn_requested_count = 0
	screen.end_turn_requested.connect(func(): _end_turn_requested_count += 1)

	var btn: Button = screen.get_end_turn_button()
	asserts.assert_false(btn.disabled, "End turn button enabled by default")

	# Disable via presentation API
	screen.set_end_turn_enabled(false)
	asserts.assert_true(btn.disabled, "Button disabled property updated")

	# Re-enable
	screen.set_end_turn_enabled(true)
	asserts.assert_false(btn.disabled, "Button re-enabled")

	# Simulate button press
	btn.emit_signal("pressed")
	asserts.assert_equal(_end_turn_requested_count, 1, "end_turn_requested signal emitted on button press")

	screen.free()

func _test_recent_actions_log(asserts: TestAsserts) -> void:
	asserts.set_current_test("combat_hud:recent_actions_log")

	var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
	var label: Label = screen.get_action_bar_zone().get_node("RecentActions") as Label

	# Empty
	screen.apply_recent_actions([])
	asserts.assert_equal(label.text, "Awaiting first action...", "Empty log placeholder text")

	# 1 action
	screen.apply_recent_actions(["Player drew 1 card."])
	asserts.assert_equal(label.text, "Player drew 1 card.", "Single action displayed")

	# 3 actions
	screen.apply_recent_actions(["Action 1", "Action 2", "Action 3"])
	asserts.assert_equal(label.text, "Action 1\nAction 2\nAction 3", "Three actions joined")

	# Truncation: 5 actions capped at 3
	screen.apply_recent_actions(["A1", "A2", "A3", "A4", "A5"])
	asserts.assert_equal(label.text, "A1\nA2\nA3", "Capped at top 3 entries")

	screen.free()

func _test_granular_update_apis(asserts: TestAsserts) -> void:
	asserts.set_current_test("combat_hud:granular_update_apis")

	var screen: CombatScreen = SCREEN.instantiate() as CombatScreen

	# Apply initial snapshot
	var initial_vm: CombatHudViewModel = CombatHudViewModel.create_default()
	screen.apply_hud_view_model(initial_vm, false)

	# Update turn state granularly
	screen.apply_turn_state(5, BattlefieldSlot.Camp.OPPONENT, CombatHudViewModel.Phase.ATTACK, false)
	asserts.assert_equal((screen.get_match_status().get_node("Turn") as Label).text, "TURN 05", "Turn updated to 05")
	asserts.assert_equal((screen.get_match_status().get_node("Phase") as Label).text, "END-OF-TURN ATTACK", "Phase updated to attack")
	asserts.assert_true(screen.get_end_turn_button().disabled, "Button disabled during attack phase")

	var vm: CombatHudViewModel = screen.get_hud_view_model()
	asserts.assert_equal(vm.turn_number, 5, "View-model reflects granular turn")
	asserts.assert_equal(vm.active_camp, BattlefieldSlot.Camp.OPPONENT, "View-model reflects active camp")
	asserts.assert_equal(vm.phase, CombatHudViewModel.Phase.ATTACK, "View-model reflects attack phase")
	asserts.assert_false(vm.end_turn_enabled, "View-model reflects button disabled")

	screen.free()

func _test_p005_and_p006_preservation(asserts: TestAsserts) -> void:
	asserts.set_current_test("combat_hud:p005_and_p006_preservation")

	var screen: CombatScreen = SCREEN.instantiate() as CombatScreen

	# 1. P006 Battlefield slots remain functional
	var slots: Array[BattlefieldSlot] = screen.get_slots()
	asserts.assert_equal(slots.size(), 24, "All 24 battlefield slots preserved")
	var slot: BattlefieldSlot = screen.get_slot(BattlefieldSlot.Camp.PLAYER, 1, BattlefieldSlot.Row.ATTACK)
	asserts.assert_true(slot != null, "Slot (PLAYER, 1, ATTACK) exists")
	asserts.assert_true(screen.select_slot(BattlefieldSlot.Camp.PLAYER, 1, BattlefieldSlot.Row.ATTACK), "Slot selection works")
	asserts.assert_equal(screen.get_selected_slot(), slot, "Slot selected")

	# Apply a complete HUD update
	var vm: CombatHudViewModel = CombatHudViewModel.create_default()
	vm.player_hero.current_health = 20
	screen.apply_hud_view_model(vm, false)

	# Slots still selected and functional after HUD snapshot
	asserts.assert_equal(screen.get_selected_slot(), slot, "Selected slot retained through HUD injection")
	screen.clear_slot_selection()
	asserts.assert_equal(screen.get_selected_slot(), null, "Slot deselection works")

	# 2. Hand fan preserved
	var fan: CombatPreviewCards = screen.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
	asserts.assert_true(fan != null, "Player hand fan preserved")
	asserts.assert_equal(fan.inspection_height, 540.0, "540 px inspection height preserved")

	# 3. Responsive scaling at 720p
	screen.size = Vector2(1280, 720)
	screen._apply_responsive_layout()
	var factor: float = screen.get_combat_layout().scale.x
	asserts.assert_true(is_equal_approx(factor, 2.0 / 3.0), "720p 2/3 scale factor preserved")

	screen.free()

func _test_intentional_failure(asserts: TestAsserts) -> void:
	asserts.set_current_test("combat_hud:intentional_failure_mode")
	asserts.assert_true(false, "Deliberate failure triggered for HUD suite verification (--test-failure-mode)")
