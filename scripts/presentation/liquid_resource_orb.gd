class_name LiquidResourceOrb
extends Control
## Presentation-only reservoir. Each instance owns exactly one mutable material.

enum ResourceKind { HEALTH, MANA }

## Emitted immediately after clamping, including updates with unchanged fill ratio.
signal resource_values_changed(current: int, maximum: int)

const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")
const LIQUID_SHADER: Shader = preload("res://resources/shaders/liquid_resource_orb.gdshader")
const TRANSITION_SECONDS: float = 0.28

@export var resource_kind: ResourceKind = ResourceKind.HEALTH:
	set(value):
		resource_kind = value
		_configure_material()
		_update_labels()
@export var current_value: int = 30
@export var maximum_value: int = 30
## Compact HUDs may provide external labels without duplicating the reservoir.
@export var internal_labels_visible: bool = true:
	set(value):
		internal_labels_visible = value
		for label_name: String in ["Kind", "Values"]:
			var label: Label = get_node_or_null(label_name) as Label
			if label != null:
				label.visible = value
## Optional foreground artwork; null preserves the reusable procedural orb.
@export var housing_texture: Texture2D:
	set(value):
		housing_texture = value
		_configure_material()
		if is_node_ready():
			_layout_contents()
## Optional presentation-level color modulation for the housing artwork.
@export var housing_modulate: Color = Color.WHITE:
	set(value):
		housing_modulate = value
		if is_node_ready() and has_node("Housing"):
			($Housing as TextureRect).modulate = housing_modulate

var _orb_material: ShaderMaterial
var _visible_ratio: float = 1.0
var _target_ratio: float = 1.0
var _start_ratio: float = 1.0
var _transition_elapsed: float = TRANSITION_SECONDS
var _clock: float = 0.0
var _response: float = 0.0
var _slosh_elapsed: float = 2.0
var _slosh_strength: float = 0.0
var _animation_enabled: bool = true

func _init() -> void:
	_orb_material = ShaderMaterial.new()
	_orb_material.shader = LIQUID_SHADER
	_configure_material()

func _ready() -> void:
	theme = TOKENS.THEME
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	($Reservoir as ColorRect).material = _orb_material
	resized.connect(_layout_contents)
	_layout_contents()
	set_resource_values(current_value, maximum_value, false)
	set_process(_animation_enabled)

func set_resource_kind(kind: ResourceKind) -> void:
	resource_kind = kind

func set_resource_values(current: int, maximum: int, animate: bool = true) -> void:
	maximum_value = maxi(0, maximum)
	current_value = clampi(current, 0, maximum_value)
	var target: float = float(current_value) / float(maximum_value) if maximum_value > 0 else 0.0
	_update_labels() # Exact values never wait for the fluid animation.
	resource_values_changed.emit(current_value, maximum_value)
	if animate and _animation_enabled and is_inside_tree():
		if is_equal_approx(target, _target_ratio):
			return
		_orb_material.set_shader_parameter("restoration", 1.0 if target > _target_ratio else 0.0)
		_slosh_elapsed = 0.0
		_slosh_strength = clampf((_visible_ratio - target) * 0.16, -0.06, 0.06)
		_response = 1.0
		_start_ratio = _visible_ratio
		_target_ratio = target
		_transition_elapsed = 0.0
	else:
		_target_ratio = target
		_transition_elapsed = TRANSITION_SECONDS
		_slosh_elapsed = 2.0
		_orb_material.set_shader_parameter("surface_tilt", 0.0)
		_response = 0.0
		_orb_material.set_shader_parameter("response", 0.0)
		_set_visible_ratio(target)

func get_visible_fill_ratio() -> float:
	return _visible_ratio

func set_animation_enabled(enabled: bool) -> void:
	_animation_enabled = enabled
	set_process(enabled)
	if not enabled:
		_transition_elapsed = TRANSITION_SECONDS
		_slosh_elapsed = 2.0
		_orb_material.set_shader_parameter("surface_tilt", 0.0)
		_response = 0.0
		_clock = 0.0
		_orb_material.set_shader_parameter("clock_seconds", 0.0)
		_orb_material.set_shader_parameter("response", 0.0)
		_set_visible_ratio(_target_ratio)

func _process(delta: float) -> void:
	_slosh_elapsed = minf(2.0, _slosh_elapsed + delta)
	var tilt: float = _slosh_strength * sin(_slosh_elapsed * 14.0) * exp(-_slosh_elapsed * 4.5) if _slosh_elapsed < 2.0 else 0.0
	_orb_material.set_shader_parameter("surface_tilt", tilt)
	_clock += delta
	_orb_material.set_shader_parameter("clock_seconds", _clock)
	if _transition_elapsed < TRANSITION_SECONDS:
		_transition_elapsed = minf(TRANSITION_SECONDS, _transition_elapsed + delta)
		var fraction: float = _transition_elapsed / TRANSITION_SECONDS
		_set_visible_ratio(lerpf(_start_ratio, _target_ratio, smoothstep(0.0, 1.0, fraction)))
	if _response > 0.0:
		_response = maxf(0.0, _response - delta * 3.5)
		_orb_material.set_shader_parameter("response", _response)

func _set_visible_ratio(ratio: float) -> void:
	_visible_ratio = ratio
	_orb_material.set_shader_parameter("fill_ratio", ratio)

func _configure_material() -> void:
	if _orb_material == null:
		return
	_orb_material.set_shader_parameter("liquid_color", TOKENS.color_token(&"hp" if resource_kind == ResourceKind.HEALTH else &"mana"))
	_orb_material.set_shader_parameter("is_mana", 1.0 if resource_kind == ResourceKind.MANA else 0.0)
	_orb_material.set_shader_parameter("bronze_color", TOKENS.color_token(&"accent_dim"))
	_orb_material.set_shader_parameter("enamel_color", TOKENS.color_token(&"background"))
	_orb_material.set_shader_parameter("external_housing", housing_texture != null)

func _update_labels() -> void:
	var label: Label = get_node_or_null("Values") as Label
	if label == null:
		return
	label.text = "%d / %d" % [current_value, maximum_value]
	_fit_value_label()
	($Kind as Label).text = "HP" if resource_kind == ResourceKind.HEALTH else "MANA"
	tooltip_text = "%s: %d / %d" % ["Health" if resource_kind == ResourceKind.HEALTH else "Mana", current_value, maximum_value]

func _layout_contents() -> void:
	($Kind as Label).visible = internal_labels_visible
	($Values as Label).visible = internal_labels_visible
	var diameter: float = minf(size.x, size.y)
	var origin: Vector2 = (size - Vector2.ONE * diameter) * 0.5
	var reservoir: ColorRect = $Reservoir as ColorRect
	reservoir.position = origin
	reservoir.size = Vector2.ONE * diameter
	var housing: TextureRect = $Housing as TextureRect
	housing.texture = housing_texture
	housing.visible = housing_texture != null
	housing.position = origin
	housing.size = Vector2.ONE * diameter
	housing.modulate = housing_modulate
	if housing_texture != null:
		# Measured source aperture: x=203..1036, y=209..1046 on 1254px.
		# A 0.9d reservoir yields 0.675d glass, overlapping the aperture's inner lip.
		reservoir.size = Vector2.ONE * diameter * 0.9
		reservoir.position = origin + diameter * Vector2(0.044, 0.0504)
		var label: Label = $Values as Label
		label.position = origin + Vector2(diameter * 0.12, diameter * 0.44)
		label.size = Vector2(diameter * 0.76, diameter * 0.26)
		label.add_theme_font_size_override("font_size", maxi(14, roundi(diameter * 0.17)))
		label.add_theme_color_override("font_color", TOKENS.color_token(&"text_bright"))
		label.add_theme_color_override("font_outline_color", TOKENS.color_token(&"background"))
		label.add_theme_constant_override("outline_size", 2)
		var kind_label: Label = $Kind as Label
		kind_label.position = origin + Vector2(diameter * 0.22, diameter * 0.30)
		kind_label.size = Vector2(diameter * 0.56, diameter * 0.13)
		kind_label.add_theme_font_size_override("font_size", maxi(10, roundi(diameter * 0.085)))
		kind_label.add_theme_color_override("font_color", TOKENS.color_token(&"secondary"))
		kind_label.add_theme_color_override("font_outline_color", TOKENS.color_token(&"background"))
		kind_label.add_theme_constant_override("outline_size", 1)
	else:
		var label: Label = $Values as Label
		label.position = origin + Vector2(diameter * 0.13, diameter * 0.40)
		label.size = Vector2(diameter * 0.74, diameter * 0.26)
		label.add_theme_font_size_override("font_size", maxi(14, roundi(diameter * 0.205)))
		label.add_theme_color_override("font_color", TOKENS.color_token(&"text_bright"))
		label.add_theme_color_override("font_outline_color", TOKENS.color_token(&"background"))
		label.add_theme_constant_override("outline_size", 5)
		var kind_label: Label = $Kind as Label
		kind_label.position = origin + Vector2(diameter * 0.22, diameter * 0.25)
		kind_label.size = Vector2(diameter * 0.56, diameter * 0.20)
		kind_label.add_theme_font_size_override("font_size", maxi(12, roundi(diameter * 0.135)))
		kind_label.add_theme_color_override("font_color", TOKENS.color_token(&"text_bright"))
		kind_label.add_theme_color_override("font_outline_color", TOKENS.color_token(&"background"))
		kind_label.add_theme_constant_override("outline_size", 4)
	_fit_value_label()

func _fit_value_label() -> void:
	var label: Label = get_node_or_null("Values") as Label
	if label == null:
		return
	var diameter: float = minf(size.x, size.y)
	var font: Font = label.get_theme_font("font")
	var base_scale: float = 0.17 if housing_texture != null else 0.205
	var font_size: int = maxi(1, roundi(diameter * base_scale))
	var available: float = maxf(1.0, diameter * 0.58 if housing_texture != null else diameter * 0.65 - 8.0)
	while font_size > 1 and font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > available:
		font_size -= 1
	label.add_theme_font_size_override("font_size", font_size)
