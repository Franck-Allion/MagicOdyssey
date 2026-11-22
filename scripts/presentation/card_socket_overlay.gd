class_name CardSocketOverlay
extends Control
## Lightweight shared base overlay for card sockets and numeral rendering.
## Encapsulates socket geometry and coherent numeral styling (stroke 4 px, shadow (0, 2)).
## Does NOT preload any creature-specific inlay, plaque, or bezel textures.

const LAYOUT: GDScript = preload("res://scripts/presentation/card_view_layout.gd")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")

## Authoritative socket aperture coordinates from CardViewLayout
const CARD_SIZE: Vector2 = CardViewLayout.CARD_SIZE
const MANA_CENTER: Vector2 = CardViewLayout.MANA_CENTER
const ATTACK_CENTER: Vector2 = CardViewLayout.ATTACK_CENTER
const HEALTH_CENTER: Vector2 = CardViewLayout.HEALTH_CENTER
const SOCKET_SAFE_RADIUS: float = CardViewLayout.SOCKET_SAFE_RADIUS

## Coherent Global Numeral Styling (ART-002-T25)
## Mandate: Applied identically across all four stats (Attack, Health, Armor, Shield).
## Provides crisp dark edge definition (4 px outline) and subtle directional depth separation (y=+2 px).
const NUMERAL_OUTLINE_SIZE: int = 4
const NUMERAL_SHADOW_OFFSET: Vector2 = Vector2(0, 2)
const NUMERAL_SHADOW_COLOR: Color = Color(0.0, 0.0, 0.0, 0.8)

## Feature toggle: when true, applies principled optical centering for asymmetrical numerals.
static var use_optical_numeral_centering: bool = true

## Centralized optical centering offsets for asymmetrical numerals (ART-002-T21).
const NUMERAL_OPTICAL_OFFSETS: Dictionary = {
	1: Vector2(0, 0),
	4: Vector2(-4, -4),
	5: Vector2(0, 1),
	7: Vector2(2, 2),
	8: Vector2(0, 0),
	10: Vector2(-2, 0),
	12: Vector2(-2, 0),
	14: Vector2(-3, -2),
}

var _mana: int = 0

func _init() -> void:
	size = CardViewLayout.CARD_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _ready() -> void:
	size = CardViewLayout.CARD_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE

static func get_numeral_optical_offset(value: int) -> Vector2:
	if NUMERAL_OPTICAL_OFFSETS.has(value):
		return NUMERAL_OPTICAL_OFFSETS[value]
	if value >= 10 and value <= 19 and value != 11:
		return Vector2(-2, 0)
	return Vector2.ZERO

## Center visible glyph bounds rather than a line box (which includes descender space).
## Measures individual glyph advances to prevent OpenType kerning/advance discrepancies.
## Applies principled optical centering for asymmetrical numerals (ART-002-T21).
func draw_number(center: Vector2, value: int, points: int, max_width: float, ink: Color,
		safe_radius: float = 0.0, custom_optical_offset: Variant = null) -> void:
	draw_number_with_style(center, value, points, max_width, ink, safe_radius, custom_optical_offset)

## One glyph renderer; optional token style leaves the default card path intact.
func draw_number_with_style(center: Vector2, value: int, points: int, max_width: float, ink: Color,
		safe_radius: float = 0.0, custom_optical_offset: Variant = null, style: NumeralStyle = null) -> void:
	var text: String = str(value)
	var font: Font = style.font if style != null and style.font != null else TOKENS.THEME.get_font(&"font", &"TacticalNumber")
	var outline: int = NUMERAL_OUTLINE_SIZE if style == null else style.outline_size
	var outline_color: Color = TOKENS.color_token(&"background") if style == null else style.outline_color
	var fill: Color = ink if style == null else style.fill
	var radius_padding: float = 4.0 if style == null else maxf(4.0, outline + 1.0)
	var measured: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, points)
	var font_size: int = mini(points, maxi(1, int(points * max_width / maxf(measured.x, 1.0))))
	var server: TextServer = TextServerManager.get_primary_interface()
	var font_rid: RID = font.get_rids()[0]
	var glyphs: PackedInt32Array = PackedInt32Array()
	var offsets: PackedFloat32Array = PackedFloat32Array()
	var bounds: Rect2 = Rect2()
	while true:
		glyphs.clear()
		offsets.clear()
		var cursor: float = 0.0
		for index: int in range(text.length()):
			var glyph: int = server.font_get_glyph_index(font_rid, font_size, text.unicode_at(index), 0)
			server.font_render_glyph(font_rid, Vector2i(font_size, 0), glyph)
			var glyph_bounds: Rect2 = Rect2(
				server.font_get_glyph_offset(font_rid, Vector2i(font_size, 0), glyph) + Vector2(cursor, 0),
				server.font_get_glyph_size(font_rid, Vector2i(font_size, 0), glyph))
			bounds = glyph_bounds if index == 0 else bounds.merge(glyph_bounds)
			glyphs.append(glyph)
			offsets.append(cursor)
			cursor += server.font_get_glyph_advance(font_rid, font_size, glyph).x
		# A width-only fit cannot protect a circular socket's diagonal corners.
		# Keep the existing glyph-bounds centering; fit its enclosing rectangle in
		# the safe disk, including 3 px outline + 1 px baseline rounding allowance.
		if safe_radius <= 0.0 or bounds.size.length() * 0.5 + radius_padding <= safe_radius or font_size <= 1:
			break
		font_size -= 1

	var opt_offset: Vector2 = Vector2.ZERO
	if use_optical_numeral_centering:
		opt_offset = custom_optical_offset if custom_optical_offset != null else get_numeral_optical_offset(value)
	var baseline: Vector2 = (center + opt_offset - bounds.get_center()).round()

	for index: int in range(glyphs.size()):
		var at: Vector2 = baseline + Vector2(offsets[index], 0)

		# Layer A: Coherent directional depth shadow across all stat numerals (ART-002-T25)
		if style == null or style.shadow_enabled:
			server.font_draw_glyph_outline(font_rid, get_canvas_item(), font_size, NUMERAL_OUTLINE_SIZE, at + NUMERAL_SHADOW_OFFSET, glyphs[index], NUMERAL_SHADOW_COLOR)
			server.font_draw_glyph(font_rid, get_canvas_item(), font_size, at + NUMERAL_SHADOW_OFFSET, glyphs[index], NUMERAL_SHADOW_COLOR)

		# Layer B: Crisp boundary stroke
		if outline > 0:
			server.font_draw_glyph_outline(font_rid, get_canvas_item(), font_size, outline, at, glyphs[index], outline_color)

		# Layer C: Bright ivory numeral fill
		server.font_draw_glyph(font_rid, get_canvas_item(), font_size, at, glyphs[index], fill)

## Polymorphic API stub for setting printed values (overridden by child classes)
func set_printed_values(mana: int, _attack: int = 0, _max_health: int = 0, _native_armor: int = 0) -> void:
	_mana = maxi(0, mana)
	queue_redraw()

## Polymorphic API stub for transient shield overlay (overridden by CardStatOverlay)
func set_shield_overlay(_shield: int) -> void:
	pass
