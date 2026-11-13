class_name CardCategoryOverlay
extends CardStatOverlay
## Non-creature presentation only. Original enamel remains visible through engraving.
## Category cues are typographic ornaments, never gameplay keywords or statistics.
const CONTENT: GDScript = preload("res://scripts/presentation/card_content_overlay.gd")
const ENGRAVING_RADIUS: float = 56.0
var category: CardContentOverlay.Category = CardContentOverlay.Category.SPELL

func _draw() -> void:
	draw_number(MANA_CENTER, _mana, 126, 145, TOKENS.color_token(&"text_bright"), SOCKET_SAFE_RADIUS)
	engrave_socket(ATTACK_CENTER)
	engrave_socket(HEALTH_CENTER)
	draw_category_cue()

func engrave_socket(center: Vector2) -> void:
	var shadow: Color = TOKENS.color_token(&"background")
	shadow.a = 0.68
	var bronze: Color = TOKENS.color_token(&"accent_dim")
	bronze.a = 0.74
	var light: Color = TOKENS.color_token(&"accent")
	light.a = 0.42
	# Quatrefoil seal etched into the existing enamel: no opaque disk or fake glyph.
	var rosette: PackedVector2Array = PackedVector2Array()
	for step: int in range(97):
		var angle: float = TAU*step/96.0
		var radius: float = 29.0+12.0*cos(4.0*angle)
		rosette.append(center+Vector2.from_angle(angle)*radius)
	var recessed: PackedVector2Array = PackedVector2Array()
	for point: Vector2 in rosette:
		recessed.append(point+Vector2(0,1.5))
	draw_polyline(recessed,shadow,3.5,true)
	draw_polyline(rosette,bronze,2.6,true)
	for step: int in range(4):
		var angle: float = PI*0.25+step*PI*0.5
		var direction: Vector2 = Vector2.from_angle(angle)
		draw_line(center+direction*46.0,center+direction*53.0,bronze,2.6,true)
	# A broken upper highlight suggests recessed tooling rather than a glowing gem.
	for petal: int in range(4):
		var start: int = petal*24+3
		var glint: PackedVector2Array = rosette.slice(start,start+9)
		draw_polyline(glint,light,1.5,true)

func category_cue_center() -> Vector2:
	var name_text: String = CONTENT.category_name(category)
	var font: Font = TOKENS.THEME.get_font(&"font",&"CardTitle")
	var width: float = font.get_string_size(name_text,HORIZONTAL_ALIGNMENT_LEFT,-1,CONTENT.TYPE_SIZE).x
	# 28 px cue half-width + 16 px breathing room before the existing category text.
	return CONTENT.TYPE_BOUNDS.get_center()-Vector2(width*0.5+44.0,0)

func draw_category_cue() -> void:
	var center: Vector2 = category_cue_center()
	var ink: Color = TOKENS.color_token(&"accent")
	var low: Color = TOKENS.color_token(&"accent_dim")
	if category == CardContentOverlay.Category.SPELL:
		# Small arcane flare. Neutral gold, independent of rarity or spell behavior.
		var flare: PackedVector2Array = PackedVector2Array([Vector2(0,-26),Vector2(7,-7),Vector2(26,0),Vector2(7,7),Vector2(0,26),Vector2(-7,7),Vector2(-26,0),Vector2(-7,-7),Vector2(0,-26)])
		for index: int in range(flare.size()):
			flare[index] += center
		draw_polyline(flare,low,3.0,true)
		draw_line(center+Vector2(0,-18),center+Vector2(0,18),ink,2.5,true)
		draw_line(center+Vector2(-18,0),center+Vector2(18,0),ink,2.5,true)
	else:
		# Equipment clasp: two rails and a pin, not an Armor or weapon stat icon.
		var clasp: PackedVector2Array = PackedVector2Array([Vector2(-24,-21),Vector2(24,-21),Vector2(24,21),Vector2(-24,21),Vector2(-24,-21)])
		for index: int in range(clasp.size()):
			clasp[index] += center
		draw_polyline(clasp,low,3.0,true)
		draw_line(center+Vector2(-17,-14),center+Vector2(17,-14),ink,2.5,true)
		draw_line(center+Vector2(0,-21),center+Vector2(0,21),ink,3.0,true)
		draw_line(center+Vector2(0,0),center+Vector2(27,0),ink,3.0,true)
