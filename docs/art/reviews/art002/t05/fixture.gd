extends "res://scripts/presentation/art002_card_integration_test.gd"
## Companion review fixture inheriting the ART-002 card/layer/capture architecture.
## Every non-catalog name, paragraph and reused portrait is a visual sample only.
const CONTENT: GDScript = preload("res://scripts/presentation/card_content_overlay.gd")
const STRESS_RULES: String = "Armor reduces each damage instance. Shield absorbs damage after Armor. Damage remaining after both protections reduces current HP. Armor is not consumed by damage."
const TOO_LONG_TITLE: String = "Guardian of the Ancient Grove and the Forgotten Observatory Beyond the Northern Mountains"
const TOO_LONG_RULES: String = "Armor is never consumed or depleted by taking damage. Shield absorbs damage after Armor. "

func fields(title_value: String, category: CardContentOverlay.Category = CardContentOverlay.Category.CREATURE,
		tribe_value: String = "Human", rules_value: String = "") -> CardContentOverlay.Content:
	var data: CardContentOverlay.Content = CardContentOverlay.Content.new(title_value, category, tribe_value, rules_value)
	# Explicit presentational character spans for documented terms, not gameplay parsing.
	var offset: int = 0
	while offset < rules_value.length():
		var next_armor: int = rules_value.find("Armor", offset)
		var next_shield: int = rules_value.find("Shield", offset)
		var at: int = next_shield if next_armor == -1 else next_armor
		if next_shield != -1 and (at == -1 or next_shield < at):
			at = next_shield
		if at == -1:
			break
		var count: int = 5 if rules_value.substr(at,5) == "Armor" else 6
		data.keywords.append(CardContentOverlay.KeywordSpan.new(at,count))
		offset = at+count
	return data

func samples() -> Array[CardContentOverlay.Content]:
	return [
		fields("Fireball", CardContentOverlay.Category.SPELL, "", "Deal 4 damage to an enemy creature."),
		fields("Arcane Knight", CardContentOverlay.Category.CREATURE, "Human", "Whenever this creature attacks, gain 1 Shield."),
		fields("Guardian of the Ancient Grove", CardContentOverlay.Category.CREATURE, "Elf", STRESS_RULES),
		fields("Rampart Guard", CardContentOverlay.Category.CREATURE, "Human", "Armor 1."),
		fields("Bastion Armor", CardContentOverlay.Category.EQUIPMENT, "", "Equipped creature has +2 Armor."),
		fields("Arcane Barrier", CardContentOverlay.Category.SPELL, "", "Grant 3 Shield to an allied creature."),
		fields("Ancestral Drake", CardContentOverlay.Category.CREATURE, "Dragon", "")
	]

func _sample(parent: Control, origin: Vector2, height: float, data: CardContentOverlay.Content, index: int = 0) -> Control:
	# Category-independent rendering; indices select documented fixture numbers only.
	var costs: Array[int] = [3,4,4,2,3,2,6]
	var attack_values: Array[int] = [0,4,4,1,0,0,7]
	var health_values: Array[int] = [0,5,5,5,0,0,7]
	return _card(parent,origin,height,index % RARITIES.size(),null,1 if index == 3 else 0,
		0,costs[index],attack_values[index],health_values[index],data)

func _rebuild() -> void:
	if not is_node_ready():
		return
	if is_instance_valid(_stage):
		remove_child(_stage)
		_stage.queue_free()
	_stage = Control.new()
	_stage.size = Vector2(1920,1080)
	var factor: float = minf(size.x/1920.0,size.y/1080.0)
	_stage.scale = Vector2.ONE*factor
	_stage.position = (size-_stage.size*factor)*0.5
	add_child(_stage)
	var background: ColorRect = ColorRect.new()
	background.size = _stage.size
	background.color = TOKENS.color_token(&"background")
	_stage.add_child(background)
	_label(_stage,"MAGIC ODYSSEY / ART-002-T05",Rect2(60,25,1800,55),36,TOKENS.color_token(&"accent"),&"SectionHeading")
	var titles: PackedStringArray = ["Title lengths / short, medium, long", "Rules composition / empty, concise, wrapped, five lines", "Card categories / Creature, Spell, Equipment", "Mixed seven-card hand / inspection required for full rules", "Supported envelope / explicit rejection beyond readable limits"]
	_label(_stage,titles[mini(_mode,4)],Rect2(60,90,1800,50),28,TOKENS.color_token(&"text"))
	_label(_stage,"Visual presentation samples / shared existing review illustration / canonical gemstone palette",Rect2(60,145,1800,40),22,TOKENS.color_token(&"secondary"))
	var data: Array[CardContentOverlay.Content] = samples()
	if _mode == 0:
		for index: int in range(3):
			_sample(_stage,Vector2(70+index*625,215),740,data[index],index)
		_label(_stage,"Fireball: catalog name / Arcane Knight and Guardian: typography fixtures, not new catalog definitions",Rect2(60,1000,1800,40),23,TOKENS.color_token(&"secondary"))
	elif _mode == 1:
		var cases: Array[CardContentOverlay.Content] = [data[6],data[3],data[5],
			fields("Arcane Knight",CardContentOverlay.Category.CREATURE,"Human","Armor reduces damage.\nShield absorbs damage.\nRemaining damage reduces HP.\nArmor is not consumed.\nShield can be depleted.")]
		var captions: PackedStringArray = ["No rules / Dragon", "One line / native Armor", "Wrapped rule / no tribe", "Five lines / explanatory fixture"]
		for index: int in range(4):
			_sample(_stage,Vector2(48+index*470,235),580,cases[index],6 if index == 0 else (3 if index == 1 else (5 if index == 2 else 1)))
			_label(_stage,captions[index],Rect2(48+index*470,855,445,70),23,TOKENS.color_token(&"text"))
		_label(_stage,"Full wording is retained. Restrained emphasis uses the Theme's bold font; no colored keyword chips.",Rect2(60,970,1800,45),24,TOKENS.color_token(&"secondary"))
	elif _mode == 2:
		var indices: Array[int] = [3,0,4]
		for index: int in range(3):
			_sample(_stage,Vector2(70+index*625,215),740,data[indices[index]],indices[index])
		_label(_stage,"Unused Spell/Equipment sockets retain their original enamel / no Attack or Health values or emblems",Rect2(60,1000,1800,40),23,TOKENS.color_token(&"secondary"))
	elif _mode == 3:
		for index: int in range(7):
			_sample(_stage,Vector2(82.5+index*253,570),316,data[index],index)
		_label(_stage,"Hand scan order: title / mana / illustration / creature stats / category",Rect2(85,330,1750,50),30,TOKENS.color_token(&"accent"),&"SectionHeading")
		_label(_stage,"Long titles and complete rules require inspection. The common portrait is review art, not final category-specific artwork.",Rect2(85,405,1750,70),23,TOKENS.color_token(&"secondary"))
	else:
		_sample(_stage,Vector2(95,210),760,data[2],2)
		var probe: CardContentOverlay = CONTENT.new()
		_stage.add_child(probe)
		probe.visible = false
		var rejected: CardContentOverlay.Content = fields(TOO_LONG_TITLE,CardContentOverlay.Category.CREATURE,"Elf",TOO_LONG_RULES.repeat(5))
		var result: Error = probe.configure(rejected)
		_label(_stage,"LEFT / longest supported review title + dense rules\n\nRIGHT / rejected stress input, shown in full below\nExplicit overflow: error %d / title=%s / rules=%s" % [result,probe.title_overflow,probe.rules_overflow],Rect2(790,235,1050,160),25,TOKENS.color_token(&"accent"))
		var full_text: RichTextLabel = RichTextLabel.new()
		full_text.position = Vector2(790,425)
		full_text.size = Vector2(1030,490)
		full_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		full_text.scroll_active = false
		full_text.add_theme_font_size_override("normal_font_size",23)
		full_text.add_text(rejected.title+"\n\n"+rejected.rules)
		_stage.add_child(full_text)
		_label(_stage,"Rejected content is not committed to a card. No ellipsis, tiny fonts or lost words.\nP009 hover and P010 inspector remain outside this review.",Rect2(790,950,1050,95),22,TOKENS.color_token(&"secondary"))
