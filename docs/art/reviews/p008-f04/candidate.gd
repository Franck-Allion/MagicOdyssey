extends "res://docs/art/reviews/p008-f03/verification/v05.gd"
## All candidates delegate to the production renderer and production fitter.
var treatment: String = "c"
var probe_layer: int = 0
var _mipmap_font: SystemFont

func get_numeral_style() -> NumeralStyle:
	var style: NumeralStyle = NUMERAL_STYLE.duplicate() as NumeralStyle
	style.outline_size = 10
	if treatment == "b":
		style.font = TOKENS.THEME.get_font(&"font",&"TacticalNumber")
		style.primary_width_scale = 0.8
		style.secondary_points = GEOMETRY.SECONDARY_POINTS
	elif treatment == "c14":
		style.outline_size = 14
	elif treatment == "n":
		style.outline_size = 0
	elif treatment == "d":
		if _mipmap_font == null:
			_mipmap_font = style.font.duplicate() as SystemFont
			_mipmap_font.generate_mipmaps = true
		style.font = _mipmap_font
	if probe_layer == 1:
		style.outline_color = Color.TRANSPARENT
	elif probe_layer == 2:
		style.fill = Color.TRANSPARENT
	return style
