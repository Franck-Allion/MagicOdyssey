class_name CardStatOverlay
extends Control
## Frame-v03 source coordinates. Presentation only: no commands or domain state.
## Printed primary values remain separate from the optional live Shield overlay.

const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")

## Painted aperture registration, measured independently from the numerals.
## T04B median of 360-ray inner bronze-edge fits at three warm-metal thresholds:
## docs/art/reviews/art002/t04b/socket_geometry.json. Not glyph-specific nudges.
const MANA_CENTER: Vector2 = Vector2(153, 151)
const ATTACK_CENTER: Vector2 = Vector2(162, 1279)
const HEALTH_CENTER: Vector2 = Vector2(919, 1279)

## Nearest detected metal is >=72 source px away; reserve a 70 px safe disk.
const SOCKET_SAFE_RADIUS: float = 70.0

## Dedicated Integrated Stat Inlays (ART-002-T20)
## Pure material disks replacing only the internal dark cavity of the bronze sockets.
const INLAY_ATTACK: Texture2D = preload("res://assets/textures/cards/icons/mo_inlay_attack.png")
const INLAY_HEALTH: Texture2D = preload("res://assets/textures/cards/icons/mo_inlay_health.png")

## Original Master-Frame Bronze Socket Bezels (ART-002-T20)
## Preserves original sculpted bronze rings, bevels, cardinal points, highlights and shadows.
## Sits on Layer 3 over Layer 2 inlays; aperture makes only the internal dark cavity transparent.
const SOCKET_BEZEL_ATTACK: Texture2D = preload("res://assets/textures/cards/icons/mo_socket_bezel_attack.png")
const SOCKET_BEZEL_HEALTH: Texture2D = preload("res://assets/textures/cards/icons/mo_socket_bezel_health.png")

## Calibrated Inlay Size and Offsets (ART-002-T20)
## Scaled to 190x190 px so the internal material fills the socket cavity (radius ~76 px)
## and seats smoothly underneath the original master-frame bronze socket bevel (r=71.5-74.5 px).
const ATTACK_INLAY_SIZE: Vector2 = Vector2(190, 190)
const ATTACK_INLAY_OFFSET: Vector2 = Vector2(0, 0)
const HEALTH_INLAY_SIZE: Vector2 = Vector2(190, 190)
const HEALTH_INLAY_OFFSET: Vector2 = Vector2(0, 0)

## Bronze Bezel Overlay Box Size (covers r=110 px from center = 220x220 px)
const SOCKET_BEZEL_SIZE: Vector2 = Vector2(220, 220)
const SOCKET_BEZEL_OFFSET: Vector2 = Vector2(0, 0)

## Dedicated Integrated Stat Plaque Inlays (ART-002-T23)
## Internal plaque inserts replacing floating mini-icons in the central bronze stat plate slots.
const PLATE_ARMOR: Texture2D = preload("res://assets/textures/cards/icons/mo_plate_armor.png")
const PLATE_SHIELD: Texture2D = preload("res://assets/textures/cards/icons/mo_plate_shield.png")

## Calibrated Plaque Size and Offsets (ART-002-T23)
## Fitted cleanly inside the 198x100 bronze slot (inner usable area 192x94 px, corner radius 20 px).
## Scaled to 180 px width preserving natural aspect ratio (Armor 2.89 -> 180x62, Shield 2.60 -> 180x69).
## Zero spill beyond inner bronze border; white numeral centered over the plaque.
const ARMOR_PLAQUE_SIZE: Vector2 = Vector2(180, 62)
const ARMOR_PLAQUE_OFFSET: Vector2 = Vector2(0, 0)

const SHIELD_PLAQUE_SIZE: Vector2 = Vector2(180, 69)
const SHIELD_PLAQUE_OFFSET: Vector2 = Vector2(0, 0)

## Centralized optical alignment for plaque badge numeral (ART-002-T23/T24)
## Refined in ART-002-T24 from 76 pt to 62 pt to provide comfortable vertical breathing room
## (5.5 px top/bottom margin on Armor, 9.0 px on Shield) without crowding plaque borders.
const BADGE_PLAQUE_NUMBER_LOCAL_CENTER: Vector2 = Vector2(99, 50)
const BADGE_PLAQUE_NUMBER_FONT_SIZE: int = 62
const BADGE_PLAQUE_NUMBER_MAX_WIDTH: float = 83.0

## Coherent Global Numeral Styling (ART-002-T25)
## Mandate: Applied identically across all four stats (Attack, Health, Armor, Shield).
## Provides crisp dark edge definition (4 px outline) and subtle directional depth separation (y=+2 px).
const NUMERAL_OUTLINE_SIZE: int = 4
const NUMERAL_SHADOW_OFFSET: Vector2 = Vector2(0, 2)
const NUMERAL_SHADOW_COLOR: Color = Color(0.0, 0.0, 0.0, 0.8)

## Feature toggle: when true, applies principled optical centering for asymmetrical numerals.
static var use_optical_numeral_centering: bool = true

var _mana: int = 0
var _attack: int = 0
var _max_health: int = 0
var _native_armor: int = 0
var _shield: int = 0
var _badge_plate: StyleBoxFlat

func _init() -> void:
	size = Vector2(1086, 1448)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge_plate = _create_badge_plate()

func _ready() -> void:
	size = Vector2(1086, 1448)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

static func _create_badge_plate() -> StyleBoxFlat:
	var plate: StyleBoxFlat = StyleBoxFlat.new()
	plate.bg_color = TOKENS.color_token(&"background")
	plate.border_color = TOKENS.color_token(&"accent_dim")
	plate.set_border_width_all(3)
	plate.set_corner_radius_all(23)
	plate.shadow_color = Color(0, 0, 0, 0.7)
	plate.shadow_size = 6
	return plate

func set_printed_values(mana: int, attack: int, max_health: int, native_armor: int = 0) -> void:
	_mana = maxi(0, mana)
	_attack = maxi(0, attack)
	_max_health = maxi(0, max_health)
	_native_armor = maxi(0, native_armor)
	queue_redraw()

## Optional transient status. Never replaces printed HP, attack, cost or native Armor.
func set_shield_overlay(shield: int) -> void:
	_shield = maxi(0, shield)
	queue_redraw()

func _draw() -> void:
	var ink: Color = TOKENS.color_token(&"text_bright")
	draw_number(MANA_CENTER, _mana, 126, 145, ink, SOCKET_SAFE_RADIUS)

	# Production ART-002-T20: Integrated Attack & Health Inlays
	# Layer 2: Stat Inlay Material (seamlessly under bronze ornamentation)
	_draw_inlay(ATTACK_CENTER + ATTACK_INLAY_OFFSET, INLAY_ATTACK, ATTACK_INLAY_SIZE)
	_draw_inlay(HEALTH_CENTER + HEALTH_INLAY_OFFSET, INLAY_HEALTH, HEALTH_INLAY_SIZE)

	# Layer 3: Original Master-Frame Bronze Socket Ornamentation
	# Preserves original rings, bevels, cardinal points, highlights and shadows.
	_draw_inlay(ATTACK_CENTER + SOCKET_BEZEL_OFFSET, SOCKET_BEZEL_ATTACK, SOCKET_BEZEL_SIZE)
	_draw_inlay(HEALTH_CENTER + SOCKET_BEZEL_OFFSET, SOCKET_BEZEL_HEALTH, SOCKET_BEZEL_SIZE)

	# Layer 4: Primary Stat Numerals
	draw_number(ATTACK_CENTER, _attack, 126, 145, ink, SOCKET_SAFE_RADIUS)
	draw_number(HEALTH_CENTER, _max_health, 126, 145, ink, SOCKET_SAFE_RADIUS)

	# Production ART-002-T23: Integrated Plaque Inlays (Armor & Shield)
	if _native_armor > 0:
		_badge(Rect2(280, 1280, 198, 100), &"armor", _native_armor)
	if _shield > 0:
		_badge(Rect2(608, 1280, 198, 100), &"shield", _shield)

## Render dedicated integrated texture centered at position
func _draw_inlay(center: Vector2, tex: Texture2D, dest_size: Vector2) -> void:
	if tex == null:
		return
	var dest_pos: Vector2 = (center - dest_size * 0.5).round()
	draw_texture_rect(tex, Rect2(dest_pos, dest_size), false)

## Backward compatibility alias for _draw_inlay
func _draw_cabochon(center: Vector2, tex: Texture2D, dest_size: Vector2) -> void:
	_draw_inlay(center, tex, dest_size)

## Centralized optical centering offsets for asymmetrical numerals (ART-002-T21).
## Compensates for visual mass imbalance relative to mathematical bounding box center.
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

static func get_numeral_optical_offset(value: int) -> Vector2:
	if NUMERAL_OPTICAL_OFFSETS.has(value):
		return NUMERAL_OPTICAL_OFFSETS[value]
	if value >= 10 and value <= 19 and value != 11:
		return Vector2(-2, 0)
	return Vector2.ZERO

## Dedicated optical offsets for plaque badge numerals (ART-002-T24).
## Calibrated specifically for horizontal rectangular plaques:
## Vertical offset is strictly 0 to preserve equal top/bottom breathing room.
## Horizontal offset balances asymmetrical visual mass (e.g. narrow '1' in '10', '12', '14').
const BADGE_PLAQUE_NUMERAL_OPTICAL_OFFSETS: Dictionary = {
	1: Vector2(0, 0),
	2: Vector2(0, 0),
	4: Vector2(-1, 0),
	5: Vector2(0, 0),
	7: Vector2(1, 0),
	8: Vector2(0, 0),
	10: Vector2(-2, 0),
	12: Vector2(-2, 0),
	14: Vector2(-2, 0),
}

static func get_badge_plaque_numeral_optical_offset(value: int) -> Vector2:
	if BADGE_PLAQUE_NUMERAL_OPTICAL_OFFSETS.has(value):
		return BADGE_PLAQUE_NUMERAL_OPTICAL_OFFSETS[value]
	if value >= 10 and value <= 19 and value != 11:
		return Vector2(-2, 0)
	return Vector2.ZERO

## Center visible glyph bounds rather than a line box (which includes descender space).
## Measures individual glyph advances to prevent OpenType kerning/advance discrepancies.
## Applies principled optical centering for asymmetrical numerals (ART-002-T21).
func draw_number(center: Vector2, value: int, points: int, max_width: float, ink: Color,
		safe_radius: float = 0.0, custom_optical_offset: Variant = null) -> void:
	var text: String = str(value)
	var font: Font = TOKENS.THEME.get_font(&"font", &"TacticalNumber")
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
		if safe_radius <= 0.0 or bounds.size.length() * 0.5 + 4.0 <= safe_radius or font_size <= 1:
			break
		font_size -= 1

	var opt_offset: Vector2 = Vector2.ZERO
	if use_optical_numeral_centering:
		opt_offset = custom_optical_offset if custom_optical_offset != null else get_numeral_optical_offset(value)
	var baseline: Vector2 = (center + opt_offset - bounds.get_center()).round()

	for index: int in range(glyphs.size()):
		var at: Vector2 = baseline + Vector2(offsets[index], 0)

		# Layer A: Coherent directional depth shadow across all stat numerals (ART-002-T25)
		server.font_draw_glyph_outline(font_rid, get_canvas_item(), font_size, NUMERAL_OUTLINE_SIZE, at + NUMERAL_SHADOW_OFFSET, glyphs[index], NUMERAL_SHADOW_COLOR)
		server.font_draw_glyph(font_rid, get_canvas_item(), font_size, at + NUMERAL_SHADOW_OFFSET, glyphs[index], NUMERAL_SHADOW_COLOR)

		# Layer B: Crisp boundary stroke
		server.font_draw_glyph_outline(font_rid, get_canvas_item(), font_size, NUMERAL_OUTLINE_SIZE, at, glyphs[index], TOKENS.color_token(&"background"))

		# Layer C: Bright ivory numeral fill
		server.font_draw_glyph(font_rid, get_canvas_item(), font_size, at, glyphs[index], ink)

func _badge(bounds: Rect2, kind: StringName, value: int) -> void:
	# Layer 1: Slot background & bronze frame (cached StyleBoxFlat)
	draw_style_box(_badge_plate, bounds)

	# Production ART-002-T23: Integrated Plaque Inlay Treatment
	# Layer 2: Plaque Inlay Material
	var plaque_tex: Texture2D = PLATE_ARMOR if kind == &"armor" else PLATE_SHIELD
	var plaque_size: Vector2 = ARMOR_PLAQUE_SIZE if kind == &"armor" else SHIELD_PLAQUE_SIZE
	var plaque_offset: Vector2 = ARMOR_PLAQUE_OFFSET if kind == &"armor" else SHIELD_PLAQUE_OFFSET
	var center: Vector2 = bounds.get_center() + plaque_offset
	var dest_pos: Vector2 = (center - plaque_size * 0.5).round()
	draw_texture_rect(plaque_tex, Rect2(dest_pos, plaque_size), false)

	# Layer 3: Top inner bronze highlight line
	draw_line(bounds.position + Vector2(24, 3), bounds.end - Vector2(24, bounds.size.y - 3), TOKENS.color_token(&"accent"), 2, true)

	# Layer 4: White Stat Numeral centered over plaque (ART-002-T24 refined breathing room)
	var badge_offset: Vector2 = get_badge_plaque_numeral_optical_offset(value)
	draw_number(bounds.position + BADGE_PLAQUE_NUMBER_LOCAL_CENTER, value,
		BADGE_PLAQUE_NUMBER_FONT_SIZE, BADGE_PLAQUE_NUMBER_MAX_WIDTH, TOKENS.color_token(&"text_bright"), 0.0, badge_offset)
