class_name PremiumEndTurnButton
extends Button
## Native Button input and signals, with presentation-only artwork feedback.
enum VisualState { NORMAL, HOVER, PRESSED, DISABLED }
const ART: Texture2D = preload("res://assets/_source/lot1/hud/utility/mo_hud_end_turn_normal_v01.png")
var _face: TextureRect
var _transition: Tween
var _state: VisualState = VisualState.NORMAL

func _ready() -> void:
	for style: StringName in [&"normal", &"hover", &"pressed", &"disabled", &"focus"]:
		add_theme_stylebox_override(style, StyleBoxEmpty.new())
	var focus: StyleBoxFlat = StyleBoxFlat.new()
	focus.bg_color = Color.TRANSPARENT
	focus.border_color = UIDesignTokens.color_token(&"accent_dim")
	focus.set_border_width_all(1)
	focus.content_margin_left = 12
	focus.content_margin_right = 12
	add_theme_stylebox_override(&"focus", focus)
	_face = GraveyardView.texture(self, ART, Vector2.ZERO, size)
	_face.name = "Artwork"
	_face.show_behind_parent = true
	var treatment: ShaderMaterial = ShaderMaterial.new()
	treatment.shader = preload("res://resources/shaders/utility_button_state.gdshader")
	_face.material = treatment
	resized.connect(_layout_art)
	_layout_art()
	add_theme_font_size_override("font_size", 21)
	for color_name: StringName in [&"font_color", &"font_hover_color", &"font_pressed_color", &"font_hover_pressed_color"]:
		add_theme_color_override(color_name, UIDesignTokens.color_token(&"text_bright"))
	set_process(true)

func _layout_art() -> void:
	_face.size = size
	_face.pivot_offset = size * 0.5

func _process(_delta: float) -> void:
	var next_state: VisualState = VisualState.NORMAL
	if disabled:
		next_state = VisualState.DISABLED
	elif is_pressed():
		next_state = VisualState.PRESSED
	elif is_hovered():
		next_state = VisualState.HOVER
	if next_state != _state:
		set_visual_state(next_state)

## Also used by explicit review fixtures. Does not activate gameplay.
func set_visual_state(state: VisualState, animate: bool = true) -> void:
	_state = state
	if _face == null:
		return
	if _transition != null:
		_transition.kill()
	var light: float = 1.0
	if state == VisualState.HOVER:
		light = 1.12
	elif state == VisualState.PRESSED:
		light = 0.86
	elif state == VisualState.DISABLED:
		light = 0.52
	var target_scale: Vector2 = Vector2.ONE * (0.98 if state == VisualState.PRESSED else 1.0)
	(_face.material as ShaderMaterial).set_shader_parameter("saturation", 0.1 if state == VisualState.DISABLED else 1.0)
	if animate and is_inside_tree():
		_transition = create_tween().set_parallel(true)
		_transition.tween_property(_face, "modulate", Color(light, light, light, 1), 0.10)
		_transition.tween_property(_face, "scale", target_scale, 0.10)
	else:
		_face.modulate = Color(light, light, light, 1)
		_face.scale = target_scale

func get_visual_state() -> VisualState:
	return _state
