class_name CreatureToken
extends CardSocketOverlay
## Presentation-only. Shared ART-002 textures and glyph renderer, calibrated to
## the token artwork. The new frame supplies the bronze rings; no extra bezel.
const GEOMETRY: GDScript = preload("res://scripts/presentation/creature_token_layout.gd")
const FRAME: Texture2D = preload("res://assets/textures/tokens/mo_creature_token_frame_v01.png")
var _diagnostic_style: StyleBoxFlat
var _model: CreatureTokenViewModel

func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_diagnostic_style = StyleBoxFlat.new()
	_diagnostic_style.bg_color = TOKENS.color_token(&"background")
	_diagnostic_style.border_color = TOKENS.color_token(&"secondary")
	_diagnostic_style.set_border_width_all(6)
	_diagnostic_style.set_corner_radius_all(12)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = GEOMETRY.SOURCE_SIZE

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = GEOMETRY.SOURCE_SIZE
	if get_parent() is Control:
		(get_parent() as Control).resized.connect(_fit_to_anchor)
		_fit_to_anchor()

func _fit_to_anchor() -> void:
	var rect: Rect2 = GEOMETRY.fitted_rect((get_parent() as Control).size)
	position = rect.position
	scale = Vector2.ONE * rect.size.x / GEOMETRY.SOURCE_SIZE.x

## Invalid injection preserves the complete previous accepted display.
func apply_view_model(model: CreatureTokenViewModel) -> bool:
	if model == null or not model.is_valid():
		return false
	_model = model.duplicate_model()
	queue_redraw()
	return true

func get_view_model() -> CreatureTokenViewModel:
	return null if _model == null else _model.duplicate_model()

func get_visible_status_count() -> int:
	return 0 if _model == null else mini(3, _model.statuses.size())

func get_status_overflow() -> int:
	return 0 if _model == null else maxi(0, _model.statuses.size() - 3)

func _draw() -> void:
	if _model == null:
		return
	_draw_portrait()
	# Materials behind the frame: its existing bronze masks the disk edges.
	draw_texture_rect(CardStatOverlay.INLAY_ATTACK, Rect2(GEOMETRY.ATTACK - GEOMETRY.INLAY_SIZE * 0.5, GEOMETRY.INLAY_SIZE), false)
	draw_texture_rect(CardStatOverlay.INLAY_HEALTH, Rect2(GEOMETRY.HEALTH - GEOMETRY.INLAY_SIZE * 0.5, GEOMETRY.INLAY_SIZE), false)
	draw_texture_rect(FRAME, Rect2(Vector2.ZERO, GEOMETRY.SOURCE_SIZE), false)
	var ink: Color = TOKENS.color_token(&"text_bright")
	draw_number(GEOMETRY.ATTACK, _model.effective_attack, GEOMETRY.PRIMARY_POINTS, GEOMETRY.PRIMARY_WIDTH, ink, GEOMETRY.PRIMARY_RADIUS, Vector2.ZERO)
	draw_number(GEOMETRY.HEALTH, _model.current_health, GEOMETRY.PRIMARY_POINTS, GEOMETRY.PRIMARY_WIDTH, ink, GEOMETRY.PRIMARY_RADIUS, Vector2.ZERO)
	_draw_plaque(GEOMETRY.ARMOR, CardStatOverlay.PLATE_ARMOR, _model.armor)
	_draw_plaque(GEOMETRY.SHIELD, CardStatOverlay.PLATE_SHIELD, _model.shield)
	for index: int in range(get_visible_status_count()):
		var status: CreatureStatusViewModel = _model.statuses[index]
		var at: Vector2 = GEOMETRY.STATUS_ORIGIN + Vector2(index * GEOMETRY.INDICATOR_STEP, 0)
		if status.icon != null:
			draw_texture_rect(status.icon, Rect2(at, GEOMETRY.INDICATOR_SIZE), false)
		else:
			_draw_diagnostic(at, status.diagnostic_label)
	if get_status_overflow() > 0:
		_draw_diagnostic(GEOMETRY.STATUS_ORIGIN + Vector2(3 * GEOMETRY.INDICATOR_STEP, 0), "+%d" % get_status_overflow())
	if _model.weapon_attached:
		_draw_diagnostic(GEOMETRY.WEAPON, "W")
	if _model.protection_attached:
		_draw_diagnostic(GEOMETRY.PROTECTION, "P")

func _draw_portrait() -> void:
	var crop: Rect2 = GEOMETRY.portrait_region(_model.portrait.get_size())
	var uvs: PackedVector2Array = PackedVector2Array()
	for point: Vector2 in GEOMETRY.PORTRAIT_POLYGON:
		uvs.append((crop.position + (point - GEOMETRY.PORTRAIT_BOUNDS.position) / GEOMETRY.PORTRAIT_BOUNDS.size * crop.size) / _model.portrait.get_size())
	draw_polygon(PackedVector2Array(GEOMETRY.PORTRAIT_POLYGON), PackedColorArray([Color.WHITE]), uvs, _model.portrait)

func _draw_plaque(rect: Rect2, texture: Texture2D, value: int) -> void:
	if value > 0:
		draw_texture_rect(texture, rect, false)
	draw_number(rect.get_center(), value, GEOMETRY.SECONDARY_POINTS, GEOMETRY.SECONDARY_WIDTH, TOKENS.color_token(&"text_bright"), 0.0, Vector2.ZERO)

## Temporary diagnostic fixtures only; injected approved icons replace them.
func _draw_diagnostic(at: Vector2, text: String) -> void:
	var rect: Rect2 = Rect2(at, GEOMETRY.INDICATOR_SIZE)
	draw_style_box(_diagnostic_style, rect)
	var font: Font = TOKENS.THEME.get_font(&"font", &"TacticalNumber")
	var points: int = 130
	while font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, points).x > rect.size.x - 12 and points > 1:
		points -= 1
	var baseline: Vector2 = rect.get_center() + Vector2(-font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, points).x * 0.5, (font.get_ascent(points) - font.get_descent(points)) * 0.5)
	draw_string_outline(font, baseline, text, HORIZONTAL_ALIGNMENT_LEFT, -1, points, 8, TOKENS.color_token(&"background"))
	draw_string(font, baseline, text, HORIZONTAL_ALIGNMENT_LEFT, -1, points, TOKENS.color_token(&"text_bright"))
