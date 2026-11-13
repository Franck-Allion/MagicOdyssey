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

## Premium Stat Icons (ART-002-T08 & ART-002-T10)
const ICON_ATTACK: Texture2D = preload("res://assets/textures/cards/icons/mo_icon_attack.png")
const ICON_HEALTH: Texture2D = preload("res://assets/textures/cards/icons/mo_icon_health.png")
const ICON_ARMOR: Texture2D = preload("res://assets/textures/cards/icons/mo_icon_armor.png")
const ICON_SHIELD: Texture2D = preload("res://assets/textures/cards/icons/mo_icon_shield.png")

const ICON_ATTACK_V01: Texture2D = preload("res://assets/textures/cards/icons/mo_icon_attack_v01.png")
const ICON_HEALTH_V01: Texture2D = preload("res://assets/textures/cards/icons/mo_icon_health_v01.png")
const ICON_ARMOR_V01: Texture2D = preload("res://assets/textures/cards/icons/mo_icon_armor_v01.png")
const ICON_SHIELD_V01: Texture2D = preload("res://assets/textures/cards/icons/mo_icon_shield_v01.png")

const ICON_ATTACK_V02: Texture2D = preload("res://assets/textures/cards/icons/mo_icon_attack_v02.png")
const ICON_HEALTH_V02: Texture2D = preload("res://assets/textures/cards/icons/mo_icon_health_v02.png")
const ICON_ARMOR_V02: Texture2D = preload("res://assets/textures/cards/icons/mo_icon_armor_v02.png")
const ICON_SHIELD_V02: Texture2D = preload("res://assets/textures/cards/icons/mo_icon_shield_v02.png")

## Centralized optical alignment and scale constants for premium icons
const ATTACK_EMBLEM_CENTER: Vector2 = Vector2(162, 1187)
const HEALTH_EMBLEM_CENTER: Vector2 = Vector2(919, 1187)

## Calibrated V2 optical constants (ART-002-T11 refined sizing & alignment)
const ATTACK_ICON_OFFSET: Vector2 = Vector2(0, 0)
const ATTACK_ICON_SIZE: Vector2 = Vector2(48, 48)

const HEALTH_ICON_OFFSET: Vector2 = Vector2(0, -1)
const HEALTH_ICON_SIZE: Vector2 = Vector2(52, 52)

const BADGE_ICON_LOCAL_CENTER: Vector2 = Vector2(50, 50)
const BADGE_NUMBER_LOCAL_CENTER: Vector2 = Vector2(140, 50)

const ARMOR_ICON_OFFSET: Vector2 = Vector2(0, 0)
const ARMOR_ICON_SIZE: Vector2 = Vector2(52, 52)

const SHIELD_ICON_OFFSET: Vector2 = Vector2(0, 0)
const SHIELD_ICON_SIZE: Vector2 = Vector2(50, 50)

## Preserved T10 optical constants for comparison & diagnostics
const ATTACK_ICON_OFFSET_T10: Vector2 = Vector2(0, -1)
const ATTACK_ICON_SIZE_T10: Vector2 = Vector2(60, 60)
const HEALTH_ICON_OFFSET_T10: Vector2 = Vector2(0, -1)
const HEALTH_ICON_SIZE_T10: Vector2 = Vector2(68, 68)
const ARMOR_ICON_OFFSET_T10: Vector2 = Vector2(0, 0)
const ARMOR_ICON_SIZE_T10: Vector2 = Vector2(68, 68)
const SHIELD_ICON_OFFSET_T10: Vector2 = Vector2(0, 0)
const SHIELD_ICON_SIZE_T10: Vector2 = Vector2(64, 64)
const ATTACK_EMBLEM_CENTER_T10: Vector2 = Vector2(157, 1187)
const HEALTH_EMBLEM_CENTER_T10: Vector2 = Vector2(934, 1187)
const BADGE_ICON_LOCAL_CENTER_T10: Vector2 = Vector2(48, 50)
const BADGE_NUMBER_LOCAL_CENTER_T10: Vector2 = Vector2(137, 50)

## Preserved V1 optical constants for rollback & comparison
const ATTACK_ICON_OFFSET_V01: Vector2 = Vector2(-2, 1)
const ATTACK_ICON_SIZE_V01: Vector2 = Vector2(62, 62)
const HEALTH_ICON_OFFSET_V01: Vector2 = Vector2(0, 0)
const HEALTH_ICON_SIZE_V01: Vector2 = Vector2(62, 62)
const ARMOR_ICON_OFFSET_V01: Vector2 = Vector2(0, 0)
const ARMOR_ICON_SIZE_V01: Vector2 = Vector2(66, 66)
const SHIELD_ICON_OFFSET_V01: Vector2 = Vector2(0, 0)
const SHIELD_ICON_SIZE_V01: Vector2 = Vector2(66, 66)
const ATTACK_EMBLEM_CENTER_V01: Vector2 = Vector2(157, 1187)
const HEALTH_EMBLEM_CENTER_V01: Vector2 = Vector2(934, 1187)
const BADGE_ICON_LOCAL_CENTER_V01: Vector2 = Vector2(48, 50)
const BADGE_NUMBER_LOCAL_CENTER_V01: Vector2 = Vector2(137, 50)

## Version selection: 2 = V2 (default), 1 = V1
static var icon_version: int = 2

## Diagnostic flag: when true, uses pre-T11 sizing and offsets for comparison
static var use_t10_sizing: bool = false

## Per-icon overrides for individual icon version selection (e.g. {"attack": 1})
static var icon_overrides: Dictionary = {}

## Diagnostic / comparison flag: when true, draws legacy procedural silhouettes.
static var use_procedural_icons: bool = false

var _mana: int = 0
var _attack: int = 0
var _max_health: int = 0
var _native_armor: int = 0
var _shield: int = 0

func _ready() -> void:
	size = Vector2(1086, 1448)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

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
	draw_number(ATTACK_CENTER, _attack, 126, 145, ink, SOCKET_SAFE_RADIUS)
	draw_number(HEALTH_CENTER, _max_health, 126, 145, ink, SOCKET_SAFE_RADIUS)
	var atk_emblem: Vector2 = ATTACK_EMBLEM_CENTER
	var hp_emblem: Vector2 = HEALTH_EMBLEM_CENTER
	if icon_version == 1:
		atk_emblem = ATTACK_EMBLEM_CENTER_V01
		hp_emblem = HEALTH_EMBLEM_CENTER_V01
	elif use_t10_sizing:
		atk_emblem = ATTACK_EMBLEM_CENTER_T10
		hp_emblem = HEALTH_EMBLEM_CENTER_T10
	_socket_emblem(atk_emblem, &"attack")
	_socket_emblem(hp_emblem, &"health")
	if _native_armor > 0:
		_badge(Rect2(280, 1280, 198, 100), &"armor", _native_armor)
	if _shield > 0:
		_badge(Rect2(608, 1280, 198, 100), &"shield", _shield)

## Center visible glyph bounds rather than a line box (which includes descender space).
## The same measured glyphs are drawn, avoiding kerning/advance discrepancies.
func draw_number(center: Vector2, value: int, points: int, max_width: float, ink: Color,
		safe_radius: float = 0.0) -> void:
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
	var baseline: Vector2 = (center - bounds.get_center()).round()
	for index: int in range(glyphs.size()):
		var at: Vector2 = baseline + Vector2(offsets[index], 0)
		server.font_draw_glyph_outline(font_rid, get_canvas_item(), font_size, 3, at, glyphs[index], TOKENS.color_token(&"background"))
		server.font_draw_glyph(font_rid, get_canvas_item(), font_size, at, glyphs[index], ink)

func _socket_emblem(center: Vector2, kind: StringName) -> void:
	# Small bronze collet seated on the socket's upper rim; numeral keeps the full center.
	draw_circle(center + Vector2(0, 3), 37, TOKENS.color_token(&"background"))
	draw_circle(center, 34, TOKENS.color_token(&"accent_dim"))
	draw_circle(center, 29, TOKENS.color_token(&"surface"))
	draw_arc(center, 32, PI, TAU, 24, TOKENS.color_token(&"accent_bright"), 2, true)
	_symbol(center, kind, 1.0 if not use_procedural_icons else 0.83)

func _badge(bounds: Rect2, kind: StringName, value: int) -> void:
	var plate: StyleBoxFlat = StyleBoxFlat.new()
	plate.bg_color = TOKENS.color_token(&"background")
	plate.border_color = TOKENS.color_token(&"accent_dim")
	plate.set_border_width_all(3)
	plate.set_corner_radius_all(23)
	plate.shadow_color = Color(0, 0, 0, 0.7)
	plate.shadow_size = 6
	draw_style_box(plate, bounds)
	draw_line(bounds.position + Vector2(24, 3), bounds.end - Vector2(24, bounds.size.y - 3), TOKENS.color_token(&"accent"), 2, true)
	var ico_center: Vector2 = BADGE_ICON_LOCAL_CENTER
	var num_center: Vector2 = BADGE_NUMBER_LOCAL_CENTER
	if icon_version == 1:
		ico_center = BADGE_ICON_LOCAL_CENTER_V01
		num_center = BADGE_NUMBER_LOCAL_CENTER_V01
	elif use_t10_sizing:
		ico_center = BADGE_ICON_LOCAL_CENTER_T10
		num_center = BADGE_NUMBER_LOCAL_CENTER_T10
	_symbol(bounds.position + ico_center, kind, 1.0 if not use_procedural_icons else 1.12)
	draw_number(bounds.position + num_center, value, 76, 83, TOKENS.color_token(&"text_bright"))

## Dedicated premium textures with optical alignment; legacy procedural fallback.
func _symbol(center: Vector2, kind: StringName, factor: float) -> void:
	if use_procedural_icons:
		_draw_procedural_symbol(center, kind, factor)
		return
	var tex: Texture2D
	var base_size: Vector2
	var offset: Vector2 = Vector2.ZERO
	var ver: int = icon_overrides.get(String(kind), icon_version)
	if ver == 1:
		match kind:
			&"attack":
				tex = ICON_ATTACK_V01
				base_size = ATTACK_ICON_SIZE_V01
				offset = ATTACK_ICON_OFFSET_V01
			&"health":
				tex = ICON_HEALTH_V01
				base_size = HEALTH_ICON_SIZE_V01
				offset = HEALTH_ICON_OFFSET_V01
			&"armor":
				tex = ICON_ARMOR_V01
				base_size = ARMOR_ICON_SIZE_V01
				offset = ARMOR_ICON_OFFSET_V01
			&"shield":
				tex = ICON_SHIELD_V01
				base_size = SHIELD_ICON_SIZE_V01
				offset = SHIELD_ICON_OFFSET_V01
	elif use_t10_sizing:
		match kind:
			&"attack":
				tex = ICON_ATTACK
				base_size = ATTACK_ICON_SIZE_T10
				offset = ATTACK_ICON_OFFSET_T10
			&"health":
				tex = ICON_HEALTH
				base_size = HEALTH_ICON_SIZE_T10
				offset = HEALTH_ICON_OFFSET_T10
			&"armor":
				tex = ICON_ARMOR
				base_size = ARMOR_ICON_SIZE_T10
				offset = ARMOR_ICON_OFFSET_T10
			&"shield":
				tex = ICON_SHIELD
				base_size = SHIELD_ICON_SIZE_T10
				offset = SHIELD_ICON_OFFSET_T10
	else:
		match kind:
			&"attack":
				tex = ICON_ATTACK
				base_size = ATTACK_ICON_SIZE
				offset = ATTACK_ICON_OFFSET
			&"health":
				tex = ICON_HEALTH
				base_size = HEALTH_ICON_SIZE
				offset = HEALTH_ICON_OFFSET
			&"armor":
				tex = ICON_ARMOR
				base_size = ARMOR_ICON_SIZE
				offset = ARMOR_ICON_OFFSET
			&"shield":
				tex = ICON_SHIELD
				base_size = SHIELD_ICON_SIZE
				offset = SHIELD_ICON_OFFSET
	if tex == null:
		return
	var dest_size: Vector2 = base_size * factor
	var dest_pos: Vector2 = (center + offset - dest_size * 0.5).round()
	draw_texture_rect(tex, Rect2(dest_pos, dest_size), false)

func _draw_procedural_symbol(center: Vector2, kind: StringName, factor: float) -> void:
	var shape: PackedVector2Array
	var tint: Color = TOKENS.color_token(&"accent_bright")
	match kind:
		&"attack":
			shape = PackedVector2Array([Vector2(0,-26), Vector2(9,-13), Vector2(5,8), Vector2(17,8), Vector2(17,14), Vector2(4,14), Vector2(4,26), Vector2(-4,26), Vector2(-4,14), Vector2(-17,14), Vector2(-17,8), Vector2(-5,8), Vector2(-9,-13)])
		&"health":
			shape = PackedVector2Array([Vector2(0,-12), Vector2(9,-22), Vector2(20,-20), Vector2(26,-9), Vector2(22,3), Vector2(0,25), Vector2(-22,3), Vector2(-26,-9), Vector2(-20,-20), Vector2(-9,-22)])
			tint = TOKENS.color_token(&"hp").lightened(0.32)
		&"armor":
			shape = PackedVector2Array([Vector2(-25,-24), Vector2(25,-24), Vector2(23,6), Vector2(15,19), Vector2(0,29), Vector2(-15,19), Vector2(-23,6)])
			tint = TOKENS.color_token(&"armor").lightened(0.22)
		_:
			# Arcane ward: pointed lozenge and floating energy arcs, unlike solid metal Armor.
			shape = PackedVector2Array([Vector2(0,-28), Vector2(19,-4), Vector2(15,14), Vector2(0,29), Vector2(-15,14), Vector2(-19,-4)])
			tint = TOKENS.color_token(&"shield")
	# Preserve silhouettes and registration; add restrained top-lit material relief.
	var facets: PackedColorArray = PackedColorArray()
	for index: int in range(shape.size()):
		var upper_light: float = clampf((28.0-shape[index].y-shape[index].x*0.35)/62.0,0.0,1.0)
		facets.append(tint.darkened(0.64).lerp(tint.lightened(0.12),upper_light))
		shape[index] = center + shape[index] * factor
	draw_polygon(shape,facets)
	var edge: PackedVector2Array = shape.duplicate()
	edge.append(shape[0])
	draw_polyline(edge, tint, 3.5, true)
	draw_line(center + Vector2(0,-17) * factor, center + Vector2(0,17) * factor, tint.lightened(0.3), 3, true)
	if kind == &"shield":
		draw_arc(center, 29 * factor, -0.9, 0.9, 16, tint, 3, true)
		draw_arc(center, 29 * factor, PI - 0.9, PI + 0.9, 16, tint, 3, true)
