extends Control
## Static art-direction study. Coordinates are presentation-only reference pixels.
## No domain objects, commands, input gameplay, catalog data, or random state.
const Tokens = preload("res://scripts/presentation/ui_design_tokens.gd")
const REFERENCE: Vector2 = Vector2(1920, 1080)
var canvas: Control

func ink(key: StringName, opacity: float = 1.0) -> Color:
	var value: Color = Tokens.color_token(key)
	value.a = opacity
	return value

func _ready() -> void:
	canvas = Control.new()
	canvas.size = REFERENCE
	add_child(canvas)
	resized.connect(_fit)
	_build()
	_fit()

func _fit() -> void:
	var factor: float = minf(size.x / REFERENCE.x, size.y / REFERENCE.y)
	canvas.scale = Vector2.ONE * factor
	canvas.position = (size - REFERENCE * factor) * 0.5
	queue_redraw()

func panel(at: Rect2, variant: StringName) -> Panel:
	var item: Panel = Panel.new()
	item.position = at.position
	item.size = at.size
	item.theme_type_variation = variant
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(item)
	return item

func text(value: String, at: Rect2, points: int = 24, tint: StringName = &"text", display: bool = false) -> Label:
	var item: Label = Label.new()
	item.text = value
	item.position = at.position
	item.size = at.size
	item.add_theme_font_size_override("font_size", points)
	item.add_theme_color_override("font_color", ink(tint))
	if display:
		item.add_theme_font_override("font", theme.get_font("font", "ScreenTitle"))
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(item)
	return item

func ornament(at: Vector2, radius: float, tint: StringName) -> void:
	var art: Control = Control.new()
	art.position = at
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(art)
	art.draw.connect(func() -> void:
		for ring: int in range(5):
			art.draw_arc(Vector2.ZERO, radius + ring * 5, 0, TAU, 80, ink(tint, 0.08 if ring > 1 else 0.6), 1.0, true)
		for ray: int in range(12):
			var angle: float = ray * TAU / 12.0
			art.draw_line(Vector2.from_angle(angle) * (radius - 6), Vector2.from_angle(angle) * (radius + 10), ink(tint, 0.7), 2, true)
		var shape: PackedVector2Array = PackedVector2Array([Vector2(0,-radius*0.7), Vector2(radius*0.4,0), Vector2(0,radius*0.7),Vector2(-radius*0.4,0),Vector2(0,-radius*0.7)])
		art.draw_polyline(shape, ink(tint), 2, true)
	)

func hero(y: float, opponent: bool) -> void:
	var camp: StringName = &"opponent" if opponent else &"player"
	panel(Rect2(650,y,620,116), &"HeroFrame")
	ornament(Vector2(712,y+58),38,camp)
	text("O" if opponent else "P",Rect2(699,y+34,40,50),32,camp,true)
	text("OPPONENT  /  THE ASHEN WATCH" if opponent else "PLAYER  /  THE STARBOUND",Rect2(777,y+15,480,26),20,camp)
	text("24 HP     4 / 5 MANA" if opponent else "28 HP     3 / 5 MANA",Rect2(777,y+45,480,36),28)
	text("DECK 28   /   HAND 4" if opponent else "DECK 27   /   HAND 5",Rect2(777,y+83,450,24),18,&"secondary")

func token(x: float, y: float, tint: StringName, atk: String, hp: String) -> void:
	var art: Control = Control.new()
	art.position = Vector2(x,y)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(art)
	art.draw.connect(func() -> void:
		var crest: PackedVector2Array = PackedVector2Array([Vector2(-59,-52),Vector2(59,-52),Vector2(55,22),Vector2(0,65),Vector2(-55,22),Vector2(-59,-52)])
		art.draw_colored_polygon(crest,ink(&"surface"))
		art.draw_polyline(crest,ink(tint),3,true)
		art.draw_circle(Vector2(0,-15),27,ink(tint,0.14))
		art.draw_colored_polygon(PackedVector2Array([Vector2(-28,24),Vector2(-18,-5),Vector2(0,-14),Vector2(18,-5),Vector2(28,24)]),ink(tint,0.55))
		art.draw_colored_polygon(PackedVector2Array([Vector2(-13,-15),Vector2(-15,-31),Vector2(0,-43),Vector2(15,-31),Vector2(13,-15),Vector2(0,-8)]),ink(tint,0.85))
		art.draw_line(Vector2(-10,-26),Vector2(10,-26),ink(&"background"),4,true)
		art.draw_line(Vector2(0,-42),Vector2(0,-15),ink(&"text",0.6),2,true)
		art.draw_line(Vector2(-24,10),Vector2(24,10),ink(&"accent",0.7),2,true)
		art.draw_line(Vector2(-44,-39),Vector2(-44,14),ink(&"accent",0.6),1,true)
	)
	text(atk,Rect2(x-47,y+21,40,40),28,&"text_bright")
	text(hp,Rect2(x+23,y+21,40,40),28,&"text_bright")

func card(x: float, y: float, title: String, kind: String, rarity: StringName, cost: String, stat: String) -> void:
	panel(Rect2(x,y,202,267),&"CardFrame")
	text(cost,Rect2(x+14,y+10,35,40),30,&"player",true)
	text(title,Rect2(x+48,y+18,150,30),21,&"text_bright",true)
	ornament(Vector2(x+101,y+102),38,rarity)
	text(kind,Rect2(x+15,y+158,190,24),18,rarity)
	text("STATIC FIXTURE",Rect2(x+15,y+189,190,25),18,&"secondary")
	text(stat,Rect2(x+15,y+225,180,30),22)

func _build() -> void:
	text("M A G I C O D Y S S E Y",Rect2(54,24,670,50),32,&"accent",true)
	text("THE SUNDERED OBSERVATORY",Rect2(55,74,630,26),18,&"secondary")
	text("COMBAT PRESENTATION  /  STATIC STUDY",Rect2(1370,35,520,30),20,&"secondary")
	hero(116,true)
	panel(Rect2(260,256,1400,534),&"BattleBoard")
	text("O / DEFENSE",Rect2(280,289,200,26),19,&"opponent")
	text("O / ATTACK",Rect2(280,403,200,26),19,&"opponent")
	text("P / ATTACK",Rect2(280,555,200,26),19,&"player")
	text("P / DEFENSE",Rect2(280,681,200,26),19,&"player")
	for row: int in range(4):
		var y: float = [279.0, 393.0, 540.0, 666.0][row]
		for column: int in range(6):
			var x: float = 482.0 + column * 188.0
			var slot: Panel = panel(Rect2(x,y,167,100),&"TokenFrame")
			slot.modulate.a = 0.4
			text("%02d" % (column+1),Rect2(x+69,y+35,50,35),20,&"accent_dim")
	text("I    /    II    /    III    /    IV    /    V    /    VI",Rect2(590,505,900,30),19,&"accent_dim")
	token(566,439,&"opponent","3","5")
	token(1130,325,&"opponent","2","6")
	token(754,585,&"player","4","7")
	token(1318,711,&"player","2","4")
	# A contextual inspection study, never a permanent gameplay sidebar.
	panel(Rect2(42,318,198,330),&"InspectorFrame")
	text("INSPECTED",Rect2(62,340,180,30),18,&"accent")
	text("Crest study",Rect2(62,380,175,35),26,&"text",true)
	text("ATK    4\nHP      7\nArmor  2\nShield  3",Rect2(62,437,175,145),24)
	text("[+] SELECTED",Rect2(62,597,175,28),18,&"selected")
	panel(Rect2(1680,345,198,285),&"InspectorFrame")
	text("YOUR TURN",Rect2(1699,369,170,30),22,&"accent")
	text("V",Rect2(1746,406,100,85),64,&"text",true)
	var action: Button = Button.new()
	action.position = Vector2(1695,513)
	action.size = Vector2(168,62)
	action.text = "End turn"
	action.theme_type_variation = &"PrimaryButton"
	action.tooltip_text = "Static presentation sample. No command is submitted."
	canvas.add_child(action)
	text("[OK] READY",Rect2(1708,589,170,28),18,&"valid")
	panel(Rect2(42,674,198,232),&"HeroFrame")
	text("PLAYER / YOU",Rect2(62,693,180,28),20,&"player")
	text("28 HP",Rect2(62,737,180,40),34,&"text",true)
	text("3 / 5 MANA\nDECK 27\nHAND 5",Rect2(62,790,180,100),23)
	panel(Rect2(365,935,1190,180),&"BattleBoard")
	# Cards overlap the tray, but each face remains completely readable.
	card(412,786,"Runic study","EQUIPMENT",&"uncommon","2","ARMOR  +2")
	card(626,790,"Ember study","SPELL",&"rare","3","ARCANE  /  FIRE")
	card(840,796,"Oath study","CREATURE",&"common","2","ATK  4     HP  7")
	card(1054,790,"Veil study","SPELL",&"epic","4","ARCANE  /  MIST")
	card(1268,786,"Crown study","RELIC MOTIF",&"legendary","5","GOLD / MOTIF")
	text("HAND / 5",Rect2(62,956,260,40),28,&"accent",true)
	text("Static values\nNo gameplay attached",Rect2(62,1000,300,58),20,&"secondary")
	text("COMMON / WHITE\nUNCOMMON / BLUE\nRARE / RED\nEPIC / VIOLET\nLEGENDARY / GOLD",Rect2(1630,845,275,165),20,&"secondary")

func _draw() -> void:
	var factor: float = minf(size.x / REFERENCE.x,size.y / REFERENCE.y)
	draw_set_transform((size-REFERENCE*factor)*0.5,0,Vector2.ONE*factor)
	draw_rect(Rect2(Vector2.ZERO,REFERENCE),ink(&"background"))
	# Fixed layered haze, distant architecture, and celestial engraving.
	for layer: int in range(40):
		var ratio: float = layer / 40.0
		draw_circle(Vector2(960,430),850-layer*17,Color(0.06,0.17,0.22,0.015+ratio*0.006))
	for pillar: int in range(10):
		var x: float = pillar * 230.0 - 80
		draw_colored_polygon(PackedVector2Array([Vector2(x,850),Vector2(x+35,140),Vector2(x+65,90),Vector2(x+92,150),Vector2(x+120,850)]),Color(0.025,0.04,0.06,0.65))
	for ring: int in range(7):
		draw_arc(Vector2(960,515),300+ring*55,0,TAU,180,ink(&"accent",0.075),1,true)
	for mark: int in range(80):
		var point: Vector2 = Vector2(float((mark*397)%1920),float((mark*173)%1080))
		draw_circle(point,1.2,ink(&"accent",0.25))
	draw_line(Vector2(55,103),Vector2(1865,103),ink(&"accent",0.5),1,true)
	draw_set_transform(Vector2.ZERO)

