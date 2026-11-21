extends CreatureToken
## Review adapter: probes call the actual production numeral implementation.
var probe_stat: int = -1
var probe_value: int = 12
var probe_material: bool = false
var hide_ink: bool = false
var frame_only: bool = false

func cells() -> Array[Rect2]:
	return [Rect2(GEOMETRY.ATTACK-GEOMETRY.INLAY_SIZE*0.5,GEOMETRY.INLAY_SIZE),GEOMETRY.ARMOR,GEOMETRY.SHIELD,Rect2(GEOMETRY.HEALTH-GEOMETRY.INLAY_SIZE*0.5,GEOMETRY.INLAY_SIZE)]

func _draw() -> void:
	if frame_only:
		draw_texture_rect(FRAME,Rect2(Vector2.ZERO,GEOMETRY.SOURCE_SIZE),false)
	elif probe_stat < 0:
		super._draw()
	elif probe_material:
		var materials: Array[Texture2D] = [CardStatOverlay.INLAY_ATTACK,CardStatOverlay.PLATE_ARMOR,CardStatOverlay.PLATE_SHIELD,CardStatOverlay.INLAY_HEALTH]
		draw_texture_rect(materials[probe_stat],cells()[probe_stat],false)
	else:
		var primary: bool = probe_stat in [0,3]
		draw_number(cells()[probe_stat].get_center(),probe_value,GEOMETRY.PRIMARY_POINTS if primary else GEOMETRY.SECONDARY_POINTS,GEOMETRY.PRIMARY_WIDTH if primary else GEOMETRY.SECONDARY_WIDTH,TOKENS.color_token(&"text_bright"),GEOMETRY.PRIMARY_RADIUS if primary else 0.0,Vector2.ZERO)

func draw_number(center: Vector2,value: int,points: int,max_width: float,ink: Color,safe_radius: float = 0.0,custom_optical_offset: Variant = null) -> void:
	if not hide_ink:
		super.draw_number(center,value,points,max_width,ink,safe_radius,custom_optical_offset)
