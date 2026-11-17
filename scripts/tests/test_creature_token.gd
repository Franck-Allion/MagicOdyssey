class_name TestCreatureToken
extends RefCounted
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")
const TOKEN: PackedScene = preload("res://scenes/combat/creature_token.tscn")

func run_suite(a: TestAsserts, _failure_mode: bool = false) -> void:
	a.set_current_test("P008: typed snapshots, board lifecycle and preservation")
	var token: CreatureToken = TOKEN.instantiate() as CreatureToken
	a.assert_true(token != null, "Reusable token scene")
	a.assert_equal(token.mouse_filter, Control.MOUSE_FILTER_IGNORE, "Decorations never consume clicks")
	a.assert_false(token.apply_view_model(null), "Null model rejected")
	for fixture: CreatureTokenViewModel in CreatureTokenDemo.MODELS:
		a.assert_true(token.apply_view_model(fixture), "Typed model accepted")
		var copy: CreatureTokenViewModel = token.get_view_model()
		a.assert_equal(copy.effective_attack, fixture.effective_attack, "Effective Attack preserved")
		a.assert_equal(copy.current_health, fixture.current_health, "Current Health, not maximum")
		a.assert_equal(copy.maximum_health, fixture.maximum_health, "Maximum retained separately")
		a.assert_equal(copy.armor, fixture.armor, "Armor independent")
		a.assert_equal(copy.shield, fixture.shield, "Shield independent")
		a.assert_equal(copy.portrait, fixture.portrait, "Portrait injected")
		a.assert_equal(token.get_visible_status_count(), mini(3, fixture.statuses.size()), "Three visible statuses")
		a.assert_equal(token.get_status_overflow(), maxi(0, fixture.statuses.size() - 3), "Exact +N overflow")
		copy.effective_attack = 999
		a.assert_equal(token.get_view_model().effective_attack, fixture.effective_attack, "Getter isolates mutations")
	for value: int in [0, 1, 4, 7, 10, 12, 14, 99, 100]:
		var digits: CreatureTokenViewModel = CreatureTokenDemo.MODELS[0].duplicate_model()
		digits.effective_attack = value
		digits.current_health = value
		digits.maximum_health = 100
		digits.armor = value
		digits.shield = value
		a.assert_true(token.apply_view_model(digits), "Zero, asymmetric and multi-digit input")
		a.assert_equal(token.get_view_model().effective_attack, value, "Attack exact")
		a.assert_equal(token.get_view_model().current_health, value, "Current HP exact")
		a.assert_equal(token.get_view_model().armor, value, "Armor exact")
		a.assert_equal(token.get_view_model().shield, value, "Shield exact")
	var accepted: CreatureTokenViewModel = token.get_view_model()
	for field: String in ["effective_attack", "current_health", "maximum_health", "armor", "shield"]:
		var invalid: CreatureTokenViewModel = accepted.duplicate_model()
		invalid.set(field, -1)
		a.assert_false(token.apply_view_model(invalid), "Reject negative " + field)
		a.assert_equal(token.get_view_model().effective_attack, accepted.effective_attack, "Invalid injection preserves prior display")
	var invalid: CreatureTokenViewModel = accepted.duplicate_model()
	invalid.current_health = invalid.maximum_health + 1
	a.assert_false(token.apply_view_model(invalid), "Inconsistent health rejected")
	invalid = accepted.duplicate_model()
	invalid.instance_id = &""
	a.assert_false(token.apply_view_model(invalid), "Empty identity rejected")
	invalid = accepted.duplicate_model()
	invalid.portrait = null
	a.assert_false(token.apply_view_model(invalid), "Missing portrait rejected")
	invalid = accepted.duplicate_model()
	invalid.statuses.append(null)
	a.assert_false(token.apply_view_model(invalid), "Null status rejected")
	var heavy: CreatureTokenViewModel = CreatureTokenDemo.MODELS[3].duplicate_model()
	a.assert_true(token.apply_view_model(heavy), "Five statuses injected")
	heavy.statuses[0].status_id = &"mutated"
	a.assert_equal(token.get_view_model().statuses[0].status_id, &"diagnostic_0", "Nested data copied on injection")
	var retrieved: CreatureTokenViewModel = token.get_view_model()
	retrieved.statuses[0].diagnostic_label = "X"
	a.assert_equal(token.get_view_model().statuses[0].diagnostic_label, "1", "Nested getter is isolated")
	for weapon: bool in [false, true]:
		for protection: bool in [false, true]:
			var model: CreatureTokenViewModel = accepted.duplicate_model()
			model.weapon_attached = weapon
			model.protection_attached = protection
			a.assert_true(token.apply_view_model(model), "Equipment combination")
			a.assert_equal(token.get_view_model().weapon_attached, weapon, "Weapon independent")
			a.assert_equal(token.get_view_model().protection_attached, protection, "Protection independent")
	for dimensions: Vector2i in [Vector2i(60, 240), Vector2i(240, 60), Vector2i(100, 100)]:
		var image: Image = Image.create(dimensions.x, dimensions.y, false, Image.FORMAT_RGBA8)
		image.fill(Color.WHITE)
		var model: CreatureTokenViewModel = accepted.duplicate_model()
		model.portrait = ImageTexture.create_from_image(image)
		a.assert_true(token.apply_view_model(model), "Replace portrait aspect")
		a.assert_equal(token.get_view_model().portrait, model.portrait, "Replacement accepted")
		var crop: Rect2 = CreatureTokenLayout.portrait_region(Vector2(dimensions))
		a.assert_true(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(crop), "Aspect-fill crop inside source")
		a.assert_true(is_equal_approx(crop.size.x / crop.size.y, CreatureTokenLayout.PORTRAIT_BOUNDS.size.x / CreatureTokenLayout.PORTRAIT_BOUNDS.size.y), "No portrait distortion")
	token.free()
	var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
	var hud: CombatHudViewModel = CombatHudViewModel.create_default()
	screen.apply_hud_view_model(hud, false)
	var fan: CombatPreviewCards = screen.get_node("CombatLayout/PlayerHandZone/Fan") as CombatPreviewCards
	var printed: int = fan.display_count
	var printed_overlay: CardStatOverlay = CardStatOverlay.new()
	printed_overlay.set_printed_values(2, 4, 5, 1)
	CreatureTokenDemo.populate(screen, "full_board")
	var ids: Dictionary[StringName, bool] = {}
	for slot: BattlefieldSlot in screen.get_slots():
		var identity: Vector3i = slot.get_slot_identity()
		var child: CreatureToken = screen.get_creature_token(identity)
		a.assert_true(child != null, "24 tokens visible")
		a.assert_equal(slot.get_token_anchor().get_child_count(), 1, "Exactly one per existing anchor")
		a.assert_equal(child.get_parent(), slot.get_token_anchor(), "Mounted in P006 anchor")
		a.assert_equal(slot.size, Vector2(162, 112), "Slot geometry preserved")
		a.assert_false(ids.has(child.get_view_model().instance_id), "Unique instance")
		ids[child.get_view_model().instance_id] = true
		a.assert_false(screen.add_creature_token(identity, accepted), "Occupied slot rejects add")
		var model: CreatureTokenViewModel = child.get_view_model()
		model.effective_attack = 0
		model.current_health = 0
		model.armor = 12
		model.shield = 10
		a.assert_true(screen.update_creature_token(identity, model), "In-place update")
		a.assert_equal(screen.get_creature_token(identity), child, "Update preserves node")
		a.assert_equal(child.get_view_model().current_health, 0, "Zero health retained")
		model.instance_id = &"different"
		a.assert_false(screen.update_creature_token(identity, model), "Update cannot change identity")
		slot.mouse_entered.emit()
		a.assert_true(slot.hovered, "Populated hover works")
		var click: InputEventMouseButton = InputEventMouseButton.new()
		click.pressed = true
		click.button_index = MOUSE_BUTTON_LEFT
		slot.gui_input.emit(click)
		a.assert_equal(screen.get_selected_slot(), slot, "Populated click selection switches")
		slot.mouse_exited.emit()
	var first: Vector3i = screen.get_slots()[0].get_slot_identity()
	var duplicate_id: CreatureTokenViewModel = screen.get_creature_token(screen.get_slots()[1].get_slot_identity()).get_view_model()
	a.assert_true(screen.remove_creature_token(first), "Removal succeeds")
	a.assert_equal(screen.get_creature_token(first), null, "Removed immediately")
	a.assert_false(screen.remove_creature_token(first), "Repeated removal false")
	a.assert_false(screen.add_creature_token(first, duplicate_id), "Same instance cannot occupy second slot")
	a.assert_true(screen.add_creature_token(first, accepted), "Immediate reuse after removal")
	for bad: Vector3i in [Vector3i(-1, 1, 0), Vector3i(0, 0, 0), Vector3i(0, 7, 0), Vector3i(0, 1, 2)]:
		a.assert_false(screen.add_creature_token(bad, accepted), "Invalid slot add rejected")
		a.assert_false(screen.update_creature_token(bad, accepted), "Invalid slot update rejected")
		a.assert_false(screen.remove_creature_token(bad), "Invalid slot removal rejected")
		a.assert_equal(screen.get_creature_token(bad), null, "Invalid slot query null")
	a.assert_false(screen.update_creature_token(first, null), "Null update false")
	screen.clear_creature_tokens()
	for slot: BattlefieldSlot in screen.get_slots():
		a.assert_equal(slot.get_token_anchor().get_child_count(), 0, "Clear immediately empties anchors")
	a.assert_equal(screen.get_hud_view_model().player_hero.current_health, hud.player_hero.current_health, "P007 snapshot preserved")
	a.assert_equal(screen.get_hud_view_model().turn_number, hud.turn_number, "No turn advancement")
	a.assert_equal(screen.get_player_mana_orb().current_value, hud.player_hero.current_mana, "No mana spent")
	a.assert_equal(fan.display_count, printed, "Hand fixture untouched")
	var after: CombatHudViewModel = screen.get_hud_view_model()
	for field: String in ["turn_number", "active_camp", "phase", "end_turn_enabled", "recent_actions", "turn_display_override", "phase_display_override"]:
		a.assert_equal(after.get(field), hud.get(field), "P007 snapshot field preserved: " + field)
	for camp: String in ["player_hero", "opponent_hero"]:
		var actual: HeroHudViewModel = after.get(camp) as HeroHudViewModel
		var expected: HeroHudViewModel = hud.get(camp) as HeroHudViewModel
		for field: String in ["hero_name", "current_health", "max_health", "current_mana", "max_mana", "deck_count", "graveyard_count", "top_graveyard_card"]:
			a.assert_equal(actual.get(field), expected.get(field), "P007 hero snapshot unchanged: " + camp + "/" + field)
	a.assert_equal(printed_overlay._attack, 4, "Printed Attack immutable")
	a.assert_equal(printed_overlay._max_health, 5, "Printed maximum HP immutable")
	a.assert_equal(printed_overlay._native_armor, 1, "Printed Armor immutable")
	printed_overlay.free()
	var geometry: Rect2 = CreatureTokenLayout.fitted_rect(Vector2(162, 112))
	a.assert_true(Rect2(Vector2(4, 4), Vector2(154, 104)).encloses(geometry), "4px feedback margin")
	a.assert_true(is_equal_approx(geometry.size.x / geometry.size.y, 1.5), "3:2 source ratio")
	a.assert_true(CreatureTokenLayout.ATTACK.x < CreatureTokenLayout.ARMOR.position.x, "Attack left")
	a.assert_true(CreatureTokenLayout.ARMOR.end.x < CreatureTokenLayout.SHIELD.position.x, "Armor before Shield")
	a.assert_true(CreatureTokenLayout.SHIELD.end.x < CreatureTokenLayout.HEALTH.x, "Health right")
	for path: String in ["res://scripts/presentation/creature_token.gd", "res://scripts/presentation/creature_token_view_model.gd"]:
		var source: String = FileAccess.get_file_as_string(path)
		a.assert_false(source.contains("res://scripts/domain/"), "No domain dependencies")
		a.assert_false(source.contains("set_printed_values("), "No printed card mutation")
	screen.free()
