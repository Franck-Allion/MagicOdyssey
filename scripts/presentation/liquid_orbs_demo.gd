extends Control
## Standalone presentation samples, unrelated to any combat fixture or rules.
const ORB: PackedScene = preload("res://scenes/hud/liquid_resource_orb.tscn")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")
const HEALTH_STEPS: Array[int] = [30, 21, 8, 0]
const MANA_STEPS: Array[int] = [5, 3, 0, 5]
var health: LiquidResourceOrb
var mana: LiquidResourceOrb
var _step: int = 0
var _elapsed: float = 0.0

func _ready() -> void:
	theme = TOKENS.THEME
	var background: ColorRect = ColorRect.new()
	background.color = TOKENS.color_token(&"background")
	background.size = Vector2(1400, 900)
	add_child(background)
	_label("MAGIC ODYSSEY  /  LIQUID RESERVOIRS", Vector2(60, 25), 30)
	_label("PRESENTATION STUDY    •    HEALTH / MANA", Vector2(60, 72), 18)
	var values: Array[int] = [100, 60, 25, 0]
	for i: int in range(4):
		_label("%d%%" % values[i], Vector2(110 + i * 310, 120), 23)
		for kind: int in range(2):
			var orb: LiquidResourceOrb = _make_orb(Vector2(70 + i * 310, 155 + kind * 240), 220, kind as LiquidResourceOrb.ResourceKind)
			orb.set_animation_enabled(false)
			orb.set_resource_values(values[i], 100, false)
	_label("LIVE  •  30 → 21 → 8 → 0 HP     /     5 → 3 → 0 → 5 MANA", Vector2(60, 648), 22)
	health = _make_orb(Vector2(390, 695), 175, LiquidResourceOrb.ResourceKind.HEALTH)
	mana = _make_orb(Vector2(720, 695), 175, LiquidResourceOrb.ResourceKind.MANA)
	health.set_resource_values(30, 30, false)
	mana.set_resource_values(5, 5, false)

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= 1.25:
		_elapsed = 0.0
		_step = (_step + 1) % HEALTH_STEPS.size()
		health.set_resource_values(HEALTH_STEPS[_step], 30)
		mana.set_resource_values(MANA_STEPS[_step], 5)

func _make_orb(at: Vector2, diameter: float, kind: LiquidResourceOrb.ResourceKind) -> LiquidResourceOrb:
	var orb: LiquidResourceOrb = ORB.instantiate() as LiquidResourceOrb
	orb.position = at
	orb.size = Vector2.ONE * diameter
	orb.set_resource_kind(kind)
	add_child(orb)
	return orb

func _label(text_value: String, at: Vector2, font_size: int) -> void:
	var label: Label = Label.new()
	label.text = text_value
	label.position = at
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", TOKENS.color_token(&"accent"))
	add_child(label)
