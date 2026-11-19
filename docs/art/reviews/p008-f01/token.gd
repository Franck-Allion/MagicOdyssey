extends CreatureToken
## Review-only, neutral functional prototype. No game rules or production APIs.
var variant: String = "A"
var probe_stat: int = -1
var probe_value: int = 12
var hide_ink: bool = false
var probe_material: bool = false
const UNIT: float = 1536.0 / 154.0

func box(x: float,y: float,w: float,h: float) -> Rect2:
	return Rect2(x*UNIT,y*UNIT,w*UNIT,h*UNIT)

func cells() -> Array[Rect2]:
	match variant:
		"B": return [box(1,63,39,38.6667),box(43,49,32,33),box(79,49,32,33),box(114,63,39,38.6667)]
		"C": return [box(1,56,42,45.6667),box(45,64,31,30),box(78,64,31,30),box(111,56,42,45.6667)]
	return [box(1,74,38,27.6667),box(40,76,36,25.6667),box(78,76,36,25.6667),box(116,74,37,27.6667)]

func points_for(index: int) -> int:
	return (300 if variant == "B" else 320 if variant == "C" else 260) if index in [0,3] else (240 if variant == "B" else 230 if variant == "C" else 220)

func _draw() -> void:
	var rects: Array[Rect2] = cells()
	if probe_stat >= 0:
		if probe_material:
			var textures: Array[Texture2D] = [CardStatOverlay.INLAY_ATTACK,CardStatOverlay.PLATE_ARMOR,CardStatOverlay.PLATE_SHIELD,CardStatOverlay.INLAY_HEALTH]
			draw_texture_rect(textures[probe_stat],rects[probe_stat],false)
		else:
			_draw_ink(rects[probe_stat],probe_value,probe_stat)
		return
	if _model == null:
		return
	draw_rect(Rect2(Vector2.ZERO,GEOMETRY.SOURCE_SIZE),TOKENS.color_token(&"background"))
	var portrait: Rect2 = box(1,1,152,72 if variant == "A" else 81 if variant == "B" else 54)
	var factor: float = maxf(portrait.size.x/_model.portrait.get_width(),portrait.size.y/_model.portrait.get_height())
	var crop: Vector2 = portrait.size/factor
	draw_texture_rect_region(_model.portrait,portrait,Rect2(Vector2((_model.portrait.get_width()-crop.x)*0.5,0),crop))
	var values: Array[int] = [_model.effective_attack,_model.armor,_model.shield,_model.current_health]
	var materials: Array[Texture2D] = [CardStatOverlay.INLAY_ATTACK,CardStatOverlay.PLATE_ARMOR,CardStatOverlay.PLATE_SHIELD,CardStatOverlay.INLAY_HEALTH]
	for index: int in range(4):
		draw_rect(rects[index],TOKENS.color_token(&"background"))
		if index in [0,3] or values[index] > 0:
			draw_texture_rect(materials[index],rects[index],false)
			if not hide_ink:
				_draw_ink(rects[index],values[index],index)
		draw_rect(rects[index],Color(0.22,0.24,0.27),false,5.0)
	# Explicitly non-production numbered icon placeholders + overflow and W/P.
	for index: int in range(get_visible_status_count()):
		var at: Vector2 = Vector2((25+index*17)*UNIT,3*UNIT)
		var status: CreatureStatusViewModel = _model.statuses[index]
		if status.icon != null:
			draw_texture_rect(status.icon,Rect2(at,Vector2(15,11)*UNIT),false)
		else:
			_tag(at,str(index+1))
	if get_status_overflow() > 0:
		_tag(Vector2(76,3)*UNIT,"+%d" % get_status_overflow())
	if _model.weapon_attached: _tag(Vector2(2,3)*UNIT,"W")
	if _model.protection_attached: _tag(Vector2(136,3)*UNIT,"P")
	draw_rect(Rect2(Vector2(3,3),GEOMETRY.SOURCE_SIZE-Vector2(6,6)),Color(0.25,0.27,0.30),false,6.0)

func _draw_ink(rect: Rect2,value: int,index: int) -> void:
	# Rectangular fitting uses shared unmodified ART-002 glyph/outline renderer.
	super.draw_number(rect.get_center(),value,points_for(index),rect.size.x-50.0,TOKENS.color_token(&"text_bright"),0.0,Vector2.ZERO)

func _tag(at: Vector2,text: String) -> void:
	var rect: Rect2 = Rect2(at,Vector2(15,11)*UNIT)
	draw_rect(rect,Color(0.04,0.05,0.07,0.9))
	var font: Font = TOKENS.THEME.get_font(&"font",&"TacticalNumber")
	draw_string(font,at+Vector2(12,86),text,HORIZONTAL_ALIGNMENT_LEFT,-1,100,TOKENS.color_token(&"text_bright"))
