class_name TestUtilityHud
extends RefCounted
const SCREEN: PackedScene = preload("res://scenes/combat/combat_screen.tscn")

func run_suite(asserts: TestAsserts, _failure_mode: bool = false) -> void:
	asserts.set_current_test("r08b:shared_deck_stack")
	var screen: CombatScreen = SCREEN.instantiate() as CombatScreen
	var official: Texture2D = CombatPreviewCards.CARD_BACK
	for deck: DeckStackView in [screen.get_player_deck(),screen.get_opponent_deck()]:
		var counts: Array[int] = [-1,0,1,2,5,6,9,10,15,16,34,100]
		var expected: Array[int] = [0,0,1,2,2,3,3,3,3,5,5,5]
		for i: int in range(counts.size()):
			deck.visual_count = counts[i]
			asserts.assert_equal(deck.visual_count,maxi(0,counts[i]),"Visual counts nonnegative")
			asserts.assert_equal(deck.get_child_count()-2,expected[i],"Actual rendered layers for count %d" % counts[i])
			asserts.assert_equal((deck.get_node("Count") as Label).text,str(maxi(0,counts[i])),"Count updates immediately")
			for index: int in range(expected[i]):
				var back: TextureRect = deck.get_node("Layer%d" % index) as TextureRect
				asserts.assert_true(back.texture == official,"Player/opponent/hidden-hand exact shared texture identity")
				asserts.assert_equal(back.get_child_count(),0,"No hidden face-up card data")
				asserts.assert_equal(back.mouse_filter,Control.MOUSE_FILTER_IGNORE,"Pile does not intercept hand input")
				asserts.assert_true(Rect2(Vector2.ZERO,deck.size).encloses(back.get_rect()),"Restrained stack layers contained")
				asserts.assert_true(is_equal_approx(back.size.x/back.size.y,0.75),"True 3:4 uniform scale")
			_label_fits(asserts,deck.get_node("Count") as Label)
			_label_fits(asserts,deck.get_node("Caption") as Label)
	asserts.set_current_test("r08b:shared_graveyard")
	for grave: GraveyardView in [screen.get_player_graveyard(),screen.get_opponent_graveyard()]:
		asserts.assert_true(grave.set_preview(0),"Accept empty")
		asserts.assert_true(grave.has_node("Empty"),"Empty state shows skull placeholder")
		asserts.assert_true((grave.get_node("Empty") as TextureRect).texture == GraveyardView.EMPTY,"Exact transparent approved placeholder")
		asserts.assert_false(grave.has_node("LastEnteringCard"),"No extra decorative frame")
		asserts.assert_true(Rect2(Vector2.ZERO,grave.size).encloses((grave.get_node("Empty") as Control).get_rect()),"Empty miniature respects intended dimensions")
		for count: int in [1,12,100]:
			var fixture: GraveyardView.PreviewCard = GraveyardView.PreviewCard.new()
			fixture.title = "Arcane Knight" if count == 1 else "Astral Weaver"
			fixture.rarity = &"rare" if count == 1 else &"epic"
			asserts.assert_true(grave.set_preview(count,fixture),"Accept explicit last-entering fixture")
			asserts.assert_true(grave.last_card == fixture,"Last entering snapshot retained independently of count")
			asserts.assert_false(grave.has_node("Empty"),"Nonempty replaces placeholder")
			var card: Control = grave.get_node("LastEnteringCard") as Control
			asserts.assert_true(card.has_node("Illustration") and card.has_node("Frame"),"Face-up ART-002 artwork and frame")
			asserts.assert_true((card.get_node("Frame") as TextureRect).texture == CombatPreviewCards.FRAME,"Exact approved master frame")
			asserts.assert_true(((card.get_node("Illustration") as TextureRect).texture as AtlasTexture).atlas == fixture.illustration,"Supplied last entering illustration")
			asserts.assert_equal(card.size,CardViewLayout.CARD_SIZE,"Native 3:4 geometry")
			asserts.assert_equal(card.scale.x,card.scale.y,"Uniform miniature scale")
			asserts.assert_equal((grave.get_node("Count") as Label).text,str(count),"Separate graveyard count")
			asserts.assert_false(grave.set_preview(100,null),"Reject missing nonempty identity")
			asserts.assert_true(grave.last_card == fixture and grave.visual_count == count,"Rejected snapshot preserves last accepted view")
			_label_fits(asserts,grave.get_node("Count") as Label)
		asserts.assert_true(grave.set_preview(0),"Reversible empty transition")
		asserts.assert_true(grave.last_card == null and grave.has_node("Empty"),"Empty discards previous face-up identity")
		for category: CardContentOverlay.Category in [CardContentOverlay.Category.SPELL,CardContentOverlay.Category.EQUIPMENT]:
			var other: GraveyardView.PreviewCard = GraveyardView.PreviewCard.new()
			other.category = category
			other.title = "Arcane Study" if category == CardContentOverlay.Category.SPELL else "Runic Relic"
			other.subtype = ""
			other.rules_text = "Draw 2 cards." if category == CardContentOverlay.Category.SPELL else "Equipped creature gains +2 Armor and Taunt."
			asserts.assert_true(grave.set_preview(1,other),"Accept noncreature face-up snapshot")
			var stat_count: int = 0
			var seal_count: int = 0
			for child: Node in grave.get_node("LastEnteringCard").get_children():
				if child is CardStatOverlay:
					stat_count += 1
				if child is CardCategoryOverlay:
					seal_count += 1
			asserts.assert_equal(stat_count,0,"No invented noncreature stats")
			asserts.assert_equal(seal_count,1,"Existing ART-002 noncreature presentation")
	asserts.set_current_test("r08b:layout_and_typography")
	asserts.assert_true(screen.get_action_bar_zone().get_theme_stylebox("panel") is StyleBoxEmpty,"No duplicated utility border")
	asserts.assert_true(screen.get_match_status().get_theme_stylebox("panel") is StyleBoxEmpty,"No duplicated status border")
	for zone: Control in [screen.get_action_bar_zone(),screen.get_match_status()]:
		var art: TextureRect = zone.get_node("Backplate") as TextureRect
		asserts.assert_equal(art.stretch_mode,TextureRect.STRETCH_KEEP_ASPECT_CENTERED,"Backplate uniform scaling")
		asserts.assert_true(Rect2(Vector2.ZERO,zone.size).encloses(art.get_rect()),"Backplate control contained")
	asserts.assert_equal(screen.get_action_bar_zone().get_rect(),Rect2(1624,372,272,684),"Utility envelope preserved")
	asserts.assert_equal(screen.get_match_status().get_rect(),Rect2(1624,220,272,136),"Status envelope preserved")
	var opponent: Control = screen.get_node("CombatLayout/OpponentPiles") as Control
	asserts.assert_true(opponent.get_rect().end.y <= 190,"Opponent piles clear status and battlefield")
	for pile: Control in [screen.get_player_deck(),screen.get_player_graveyard()]:
		asserts.assert_true(Rect2(Vector2.ZERO,screen.get_action_bar_zone().size).encloses(pile.get_rect()),"Player pile inside utility region")
		asserts.assert_true(pile.get_rect().end.y+32 <= screen.get_end_turn_button().position.y,"Pile/button breathing room")
	for turn_text: String in ["TURN 1","TURN 10"]:
		for phase_text: String in ["PLAYER / ACTION","OPPONENT / ACTION","END-OF-TURN ATTACK"]:
			screen.set_turn_preview(turn_text,phase_text)
			_label_fits(asserts,screen.get_match_status().get_node("Turn") as Label)
			_label_fits(asserts,screen.get_match_status().get_node("Phase") as Label)
	screen.set_recent_actions_preview([])
	asserts.assert_equal((screen.get_action_bar_zone().get_node("RecentActions") as Label).text,"Awaiting first action...","Obvious existing empty fixture")
	screen.set_recent_actions_preview(["First","Second","Third","Fourth"])
	asserts.assert_equal((screen.get_action_bar_zone().get_node("RecentActions") as Label).text,"First\nSecond\nThird","At most three recent entries")
	asserts.assert_true(screen.get_end_turn_button() is PremiumEndTurnButton,"Native Button semantics preserved")
	asserts.assert_equal(screen.get_end_turn_button().focus_mode,Control.FOCUS_ALL,"Keyboard focusable")
	asserts.assert_true(Rect2(Vector2.ZERO,screen.get_action_bar_zone().size).encloses(screen.get_end_turn_button().get_rect()),"Button contained with bottom clearance")
	screen.free()

func _label_fits(asserts: TestAsserts, label: Label) -> void:
	var font: Font = UIDesignTokens.THEME.get_font("font", "Label")
	var font_size: int = label.get_theme_font_size("font_size")
	var ink: Vector2 = font.get_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size)
	asserts.assert_true(ink.x <= label.size.x,"Label width fits actual font: "+label.text)
	asserts.assert_true(ink.y <= label.size.y,"Label height fits actual font: "+label.text)
