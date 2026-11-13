extends "res://docs/art/reviews/art002/t05/fixture.gd"
## T06 review only; inherits the existing ART-002 card composer and T05 content data.

func _ready() -> void:
	super._ready()
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--mode="):
			_mode = clampi(argument.trim_prefix("--mode=").to_int(),0,6)
	_rebuild()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var key: InputEventKey = event as InputEventKey
		if key.keycode >= KEY_1 and key.keycode <= KEY_7:
			_mode = key.keycode-KEY_1
			_rebuild()

func _show(parent: Control, origin: Vector2, height: float, data: CardContentOverlay.Content,
		rarity: int = 3, armor: int = 0, shield: int = 0, cost: int = 4,
		attack: int = 4, health: int = 5, emerald: bool = false) -> Control:
	var material_override: ShaderMaterial = GEM_TREATMENT.create_material(&"epic",true) if emerald else null
	return _card(parent,origin,height,rarity,material_override,armor,shield,cost,attack,health,data)

func category_samples() -> Array[CardContentOverlay.Content]:
	return [fields("Rampart Guard",CardContentOverlay.Category.CREATURE,"Human","Armor 1."),
		fields("Fireball",CardContentOverlay.Category.SPELL,"","Deal 4 damage to an enemy creature."),
		fields("Bastion Armor",CardContentOverlay.Category.EQUIPMENT,"","Equipped creature has +2 Armor.")]

func _crop(parent: Control, at: Vector2, bounds: Rect2, factor: float, data: CardContentOverlay.Content,
		armor: int = 0, shield: int = 0, attack: int = 4, health: int = 5) -> void:
	var crop: Control = Control.new()
	crop.position = at
	crop.size = bounds.size*factor
	crop.clip_contents = true
	parent.add_child(crop)
	_show(crop,-bounds.position*factor,1448*factor,data,3,armor,shield,2,attack,health)

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
	_label(_stage,"MAGIC ODYSSEY / ART-002-T06",Rect2(60,25,1800,55),36,TOKENS.color_token(&"accent"),&"SectionHeading")
	var headings: PackedStringArray = ["One family / Creature, Spell and Equipment", "Dormant enamel / engraved seals, unchanged sockets", "Material detail / source-space icons and numerical sockets", "Mixed seven-card hand / canonical rarities + explicit emerald sample", "Mixed seven-card hand / canonical rarities + explicit emerald sample", "Rarity and category compatibility / canonical palette and opt-in emerald", "Rampart Guard / complete inspection candidate"]
	_label(_stage,headings[_mode],Rect2(60,92,1800,45),28,TOKENS.color_token(&"text"))
	_label(_stage,"Shared original test portrait / visual samples only / original v03 artwork, typography and numerical registration",Rect2(60,147,1800,40),22,TOKENS.color_token(&"secondary"))
	var cases: Array[CardContentOverlay.Content] = category_samples()
	if _mode == 0:
		for index: int in range(3):
			_show(_stage,Vector2(70+625*index,215),740,cases[index],3,1 if index == 0 else 0,0,2 if index == 0 else 3,1,5)
		_label(_stage,"Same frame and violet Epic / dormant seals are ornamental, never zero-valued statistics",Rect2(60,1000,1800,40),24,TOKENS.color_token(&"secondary"))
	elif _mode == 1:
		for index: int in range(3):
			_label(_stage,["CREATURE / active 12 and 10","SPELL / dormant","EQUIPMENT / dormant"][index],Rect2(60,290+index*270,560,60),27,TOKENS.color_token(&"accent"))
			_crop(_stage,Vector2(650,215+index*270),Rect2(40,1130,1006,300),0.95,cases[index],1 if index == 0 else 0,3 if index == 0 else 0,12,10)
	elif _mode == 2:
		_crop(_stage,Vector2(95,330),Rect2(40,35,240,260),1.2,cases[0],1,3)
		_crop(_stage,Vector2(570,335),Rect2(40,1130,1006,300),1.2,cases[0],1,3)
		_label(_stage,"MANA / original numeral and bronze socket",Rect2(95,720,750,50),25,TOKENS.color_token(&"text"))
		_label(_stage,"SWORD / ATTACK     STEEL / ARMOR     AZURE / SHIELD     HEART / MAX HP",Rect2(570,770,1290,70),22,TOKENS.color_token(&"text"))
		_label(_stage,"Top-lit facets retain the approved silhouettes, weight and coordinates. No new gameplay symbols.",Rect2(95,950,1730,50),25,TOKENS.color_token(&"secondary"))
	elif _mode == 3 or _mode == 4:
		var hand: Array[CardContentOverlay.Content] = [cases[0],cases[1],cases[2],
			fields("Guardian of the Ancient Grove",CardContentOverlay.Category.CREATURE,"Elf",STRESS_RULES),
			fields("Arcane Barrier",CardContentOverlay.Category.SPELL,"","Grant 3 Shield to an allied creature."),
			fields("Runic Blade",CardContentOverlay.Category.EQUIPMENT,"","Equipped creature has +2 Attack."),
			fields("Ancestral Drake",CardContentOverlay.Category.CREATURE,"Dragon","")]
		var rarity_indices: Array[int] = [0,1,2,3,4,3,2]
		var costs: Array[int] = [2,3,3,4,2,2,6]
		for index: int in range(7):
			_show(_stage,Vector2(82.5+index*253,586),316,hand[index],rarity_indices[index],1 if index == 0 else 0,
				3 if index == 0 else 0,costs[index],12 if index == 3 else (7 if index == 6 else 1),10 if index == 3 else (7 if index == 6 else 5),index == 5)
		_label(_stage,"Active creature values / dormant neutral seals / small flare = Spell / clasp = Equipment",Rect2(85,340,1750,55),27,TOKENS.color_token(&"accent"),&"SectionHeading")
		_label(_stage,"Card 4 is a long-title / two-digit typography fixture. Card 6 explicitly opts into emerald Epic. Detailed rules require inspection.",Rect2(85,415,1750,65),22,TOKENS.color_token(&"secondary"))
	elif _mode == 5:
		var columns: PackedStringArray = ["Common / white","Uncommon / blue","Rare / red","Epic / violet","Legendary / gold","Epic / emerald*"]
		for column: int in range(6):
			_label(_stage,columns[column],Rect2(220+column*265,192,250,40),22,TOKENS.color_token(&"text"))
		for row: int in range(3):
			_label(_stage,["Creature","Spell","Equipment"][row],Rect2(60,320+row*265,160,50),24,TOKENS.color_token(&"accent"))
			for column: int in range(6):
				_show(_stage,Vector2(220+column*265,235+row*265),240,cases[row],column if column < 5 else 3,1 if row == 0 else 0,0,2 if row == 0 else 3,1,5,column == 5)
		_label(_stage,"* Emerald is explicit opt-in only. Canonical Epic remains violet. Category ornaments never recolor rarity gemstones.",Rect2(60,1030,1800,35),21,TOKENS.color_token(&"secondary"))
	else:
		_show(_stage,Vector2(385,210),760,cases[0],3,1,3,2,1,5)
		_label(_stage,"RAMPART GUARD\n\nPrinted values: Mana 2 / Attack 1 / Max HP 5\nNative Armor 1\n\nShield 3 is an illustrative live overlay.\nOriginal portrait remains test art.\n\nThe creature face, gem treatment and\nall numeral positions are preserved.",Rect2(1090,325,760,520),27,TOKENS.color_token(&"secondary"))
