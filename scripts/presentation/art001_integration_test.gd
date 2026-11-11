extends "res://scripts/presentation/premium_combat_shell.gd"
## Isolated, static feasibility study. Inherited helpers supply existing visuals only.
## The base shell and normative geometry remain unchanged.
@export_enum("A - Background only", "B - Typical combat", "C - Maximum occupation") var preset: int = 1
@export_range(0.0, 0.65, 0.01) var board_darkening: float = 0.30
const ARTWORK: Texture2D = preload("res://assets/_source/lot1/battlefield/wip/mo_battlefield_sundered_observatory_bg_wip_v02.png")
const GRID_ORIGIN: Vector2 = Vector2(478, 263)
const SLOT_SIZE: Vector2 = Vector2(164, 120)
const COLUMN_STEP: float = 185.0
const ROW_Y: Array[float] = [263.0, 389.0, 535.0, 661.0]

func _draw() -> void:
	# Suppress inherited procedural environment; the exact WIP PNG is the environment.
	pass

func _build() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--preset="):
			preset = clampi(argument.trim_prefix("--preset=").to_int(), 0, 2)
	var background: TextureRect = TextureRect.new()
	background.texture = ARTWORK
	background.size = REFERENCE
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(background)
	if preset == 0:
		return
	var scrim: ColorRect = ColorRect.new()
	scrim.position = Vector2(260,245)
	scrim.size = Vector2(1400,548)
	scrim.color = ink(&"background", board_darkening)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(scrim)
	_header_and_hud()
	_grid()
	_hand(7 if preset == 2 else 5)

func _header_and_hud() -> void:
	panel(Rect2(42,23,510,86), &"InspectorFrame")
	text("THE SUNDERED OBSERVATORY",Rect2(62,39,490,32),26,&"accent",true)
	text("ART-001-T01 / %s / STATIC FIXTURES" % ("C" if preset == 2 else "B"),Rect2(62,76,490,25),19,&"secondary")
	hero(115,true)
	panel(Rect2(42,329,198,310), &"InspectorFrame")
	text("INSPECTED",Rect2(62,350,170,30),20,&"accent")
	text("Crest study",Rect2(62,391,175,35),26,&"text",true)
	text("ATK    4\nHP      7\nArmor  2\nShield  3",Rect2(62,441,175,140),24)
	text("[+] SELECTED",Rect2(62,596,175,30),18,&"selected")
	panel(Rect2(42,674,198,232), &"HeroFrame")
	text("PLAYER / YOU",Rect2(62,693,180,30),20,&"player")
	text("28 HP",Rect2(62,737,175,40),34,&"text",true)
	text("3 / 5 MANA\nDECK 27\nHAND %d" % (7 if preset == 2 else 5),Rect2(62,790,180,100),23)
	panel(Rect2(1680,345,198,285), &"InspectorFrame")
	text("YOUR TURN",Rect2(1699,369,170,30),22,&"accent")
	text("V",Rect2(1746,406,100,85),64,&"text",true)
	var action: Button = Button.new()
	action.position = Vector2(1695,513)
	action.size = Vector2(168,62)
	action.text = "End Turn"
	action.theme_type_variation = &"PrimaryButton"
	action.tooltip_text = "Visual fixture only; no combat command."
	canvas.add_child(action)
	text("[OK] FIXTURE",Rect2(1699,589,175,28),18,&"valid")

func _grid() -> void:
	var row_names: Array[String] = ["O / DEFENSE", "O / ATTACK", "P / ATTACK", "P / DEFENSE"]
	for row: int in range(4):
		var camp: StringName = &"opponent" if row < 2 else &"player"
		panel(Rect2(278, ROW_Y[row]+38, 184, 40), &"InspectorFrame")
		text(row_names[row],Rect2(289,ROW_Y[row]+42,170,30),20,camp)
		for column: int in range(6):
			var x: float = GRID_ORIGIN.x + column * COLUMN_STEP
			var y: float = ROW_Y[row]
			var occupied: bool = preset == 2 or Vector2i(column,row) in [Vector2i(0,1),Vector2i(3,0),Vector2i(1,2),Vector2i(4,3)]
			var slot: Panel = panel(Rect2(Vector2(x,y), SLOT_SIZE), &"TokenFrame")
			var style: StyleBoxFlat = theme.get_stylebox("panel", "TokenFrame").duplicate() as StyleBoxFlat
			style.bg_color = ink(&"background",0.14)
			style.border_color = ink(camp,0.65)
			style.shadow_size = 0
			slot.add_theme_stylebox_override("panel",style)
			if occupied:
				token(x+82,y+53,camp,str(2+column%4),str(4+row%3))
				if preset == 2 and (column+row)%3 == 0:
					var badge: Panel = panel(Rect2(x+25,y+3,114,25),&"InspectorFrame")
					badge.z_index = 1
					var values: Label = text("AR 2 / SH 3",Rect2(x+30,y+3,110,26),18,&"text_bright")
					values.z_index = 1
			else:
				text("%02d" % (column+1),Rect2(x+69,y+42,50,32),22,&"text")

func _hand(count: int) -> void:
	var parent_canvas: Control = canvas
	var hand_canvas: Control = Control.new()
	hand_canvas.position = Vector2(290 if count == 7 else 480,816)
	hand_canvas.scale = Vector2(0.90,0.90)
	canvas.add_child(hand_canvas)
	canvas = hand_canvas
	var names: Array[String] = ["Runic study","Ember study","Oath study","Veil study","Crown study","Mist study","Iron study"]
	var rarities: Array[StringName] = [&"uncommon",&"rare",&"common",&"epic",&"legendary",&"uncommon",&"common"]
	for index: int in range(count):
		card(index*212.0,0,names[index],"VISUAL FIXTURE",rarities[index],str(index%4+1),"ATK  4   HP  7")
	canvas = parent_canvas
