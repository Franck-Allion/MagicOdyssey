class_name CombatPreviewCards
extends Control
## Static presentation samples and Hearthstone-style hover inspection.
## Presentation-only: no gameplay card selection, placement, commands, or dragging.

enum HoverState {
	IDLE,
	HOVERING,
	TRANSITIONING,
	INSPECTING,
	RETURNING
}

@export var face_down: bool = false
@export_range(0, 10) var display_count: int = 7
@export var preferred_height: float = 270.0
@export var inspection_height: float = 440.0
@export var transition_duration: float = 0.18

var selected_index: int = -1
var _target_index: int = -1
var _hover_state: HoverState = HoverState.IDLE
var _card_blends: Array[float] = []

const FRAME: Texture2D = preload("res://assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png")
const ART: Texture2D = preload("res://assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png")
const CARD_BACK: Texture2D = preload("res://assets/_source/lot1/hud/opponent/mo_hud_opponent_card_back_v01.png")
const CARD_BACK_SHADER: Shader = preload("res://resources/shaders/card_back_opacity.gdshader")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS if not face_down else Control.MOUSE_FILTER_IGNORE
	rebuild()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_MOUSE_EXIT:
		if _target_index != -1:
			_target_index = -1
			selected_index = -1
			set_process(true)

func _gui_input(event: InputEvent) -> void:
	if face_down:
		return
	if event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event as InputEventMouseMotion
		_on_pointer_motion(motion.global_position)

func _input(event: InputEvent) -> void:
	if face_down:
		return
	if event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event as InputEventMouseMotion
		_on_pointer_motion(motion.global_position)

func _on_pointer_motion(global_pos: Vector2) -> void:
	var local_p: Vector2 = get_global_transform().affine_inverse() * global_pos
	var picked: int = pick_card_at(local_p)
	if picked != _target_index:
		_target_index = picked
		selected_index = picked
		set_process(true)

func _process(delta: float) -> void:
	if face_down:
		set_process(false)
		return
	var count: int = clampi(display_count, 0, 10)
	if count == 0:
		_hover_state = HoverState.IDLE
		set_process(false)
		return

	var is_animating: bool = false
	var speed: float = 1.0 / maxf(0.01, transition_duration)
	for i: int in range(mini(count, _card_blends.size())):
		var target_blend: float = 1.0 if i == _target_index else 0.0
		if not is_equal_approx(_card_blends[i], target_blend):
			_card_blends[i] = move_toward(_card_blends[i], target_blend, speed * delta)
			is_animating = true

	_apply_card_transforms()
	_update_hover_state()

	if not is_animating:
		set_process(false)

func _update_hover_state() -> void:
	var count: int = clampi(display_count, 0, 10)
	if _target_index < 0 or _target_index >= count:
		var any_active: bool = false
		for b: float in _card_blends:
			if b > 0.001:
				any_active = true
				break
		_hover_state = HoverState.RETURNING if any_active else HoverState.IDLE
	else:
		var active_blend: float = _card_blends[_target_index]
		if active_blend >= 0.999:
			_hover_state = HoverState.INSPECTING
		elif active_blend <= 0.05:
			_hover_state = HoverState.HOVERING
		else:
			_hover_state = HoverState.TRANSITIONING

func _apply_card_transforms() -> void:
	var count: int = clampi(display_count, 0, 10)
	for i: int in range(mini(count, get_child_count())):
		var card: Control = get_child(i) as Control
		var raw_blend: float = _card_blends[i] if i < _card_blends.size() else 0.0
		var t: float = raw_blend * raw_blend * (3.0 - 2.0 * raw_blend) # Smoothstep easing

		var rest_pose: Transform2D = layout_pose(i, count, size.x, preferred_height)
		var rest_center: Vector2 = rest_pose.origin
		var rest_rot: float = rest_pose.get_rotation()
		var rest_h: float = preferred_height

		var inspect_h: float = inspection_height
		var scale_inspect: float = inspect_h / CardViewLayout.CARD_SIZE.y
		var half_w_inspect: float = CardViewLayout.CARD_SIZE.x * scale_inspect * 0.5
		var inspect_center_x: float = clampf(rest_center.x, half_w_inspect + 16.0, size.x - half_w_inspect - 16.0)
		var inspect_center_y: float = 20.0
		var inspect_rot: float = 0.0

		var current_h: float = lerpf(rest_h, inspect_h, t)
		var current_rot: float = lerpf(rest_rot, inspect_rot, t)
		var current_center: Vector2 = rest_center.lerp(Vector2(inspect_center_x, inspect_center_y), t)

		card.rotation = current_rot
		card.scale = Vector2.ONE * current_h / CardViewLayout.CARD_SIZE.y
		card.position = current_center - card.pivot_offset
		card.modulate = Color.WHITE.lerp(Color(1.04, 1.04, 1.06, 1.0), t)

		if i == _target_index and raw_blend > 0.001:
			card.z_index = 100 # Rising/inspected card on very top
		elif raw_blend > 0.001:
			card.z_index = 90 # Returning card above resting cards (0..9) but below rising card
		else:
			card.z_index = i # Left-to-right stacking exposes mana socket

func rebuild() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()

	_card_blends.clear()
	var count: int = 6 if face_down else clampi(display_count, 0, 10)
	for i: int in range(count):
		_card_blends.append(0.0)
	_target_index = -1
	selected_index = -1
	_hover_state = HoverState.IDLE

	for index: int in range(count):
		var card: Control = Control.new()
		card.name = "Card%02d" % index
		card.size = Vector2(1086, 1448)
		var height: float = 144.0 if face_down else preferred_height
		card.scale = Vector2.ONE * height / 1448.0
		card.pivot_offset = card.size * 0.5
		if face_down:
			var spread: float = float(index) - 2.5
			var center: Vector2 = Vector2(size.x * 0.5 + spread * 72.0, height * 0.5 + absf(spread) * 3.0)
			card.position = center - card.pivot_offset
			card.rotation = deg_to_rad(spread * 3.5)
		else:
			var pose: Transform2D = layout_pose(index, display_count, size.x, preferred_height)
			card.position = pose.origin - card.pivot_offset
			card.rotation = pose.get_rotation()
			card.z_index = index # Left-to-right stacking exposes mana cost at rest
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(card)
		if face_down:
			var back: TextureRect = _texture(card, CARD_BACK, card.size)
			back.name = "CardBack"
			back.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			back.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			var opacity: ShaderMaterial = ShaderMaterial.new()
			opacity.shader = CARD_BACK_SHADER
			back.material = opacity
			card.z_index = index
		else:
			var aperture: Control = Control.new()
			aperture.position = CardViewLayout.APERTURE_BOUNDS.position
			aperture.size = CardViewLayout.APERTURE_BOUNDS.size
			aperture.clip_contents = true
			card.add_child(aperture)
			var crop: AtlasTexture = AtlasTexture.new()
			crop.atlas = ART
			crop.region = CardViewLayout.PORTRAIT_CROP_REGION
			_texture(aperture, crop, aperture.size)
			var frame: TextureRect = _texture(card, FRAME, card.size)
			var rarities: Array[StringName] = [&"common", &"uncommon", &"rare", &"epic", &"legendary"]
			frame.material = RarityGemTreatment.create_material(rarities[index % rarities.size()])
			var content: CardContentOverlay = CardContentOverlay.new()
			card.add_child(content)
			var category: CardContentOverlay.Category = (index % 3) as CardContentOverlay.Category
			var titles: Array[String] = [
				"Arcane Knight", "Arcane Study", "Runic Relic",
				"Astral Weaver", "Pyretic Inscription", "Voidbound Talisman",
				"Celestial Warden", "Gilded Divination", "Obsidian Blade",
				"Archon of the Sundered Sphere"
			]
			var bodies: Array[String] = [
				"Whenever this creature attacks, gain 1 Shield.",
				"Draw 2 cards. If you control an Arcane creature, reduce their cost by 1.",
				"Equipped creature gains +2 Armor and Taunt.",
				"Battlecry: Return an allied creature to your hand.",
				"Deal 3 damage to all enemy frontline positions.",
				"At the start of your turn, add 1 Mana Crystal.",
				"Whenever an enemy attacks your hero, retaliate for 2 damage.",
				"Discover an ancient spell from your library.",
				"Equipped creature gains +3 Attack and Piercing.",
				"Legendary creature. Battlecry: Banish all enemy tokens until end of turn."
			]
			var subtypes: Array[String] = [
				"Human", "", "", "Elf", "", "", "Archon", "", "", "Celestial"
			]
			var costs: Array[int] = [1, 2, 3, 4, 5, 2, 6, 3, 4, 8]
			var attacks: Array[int] = [2, 0, 0, 3, 0, 0, 5, 0, 0, 7]
			var healths: Array[int] = [3, 0, 0, 4, 0, 0, 6, 0, 0, 8]

			var card_title: String = titles[index % titles.size()]
			var card_body: String = bodies[index % bodies.size()]
			var card_subtype: String = subtypes[index % subtypes.size()]
			var card_cost: int = costs[index % costs.size()]

			content.configure(CardContentOverlay.Content.new(card_title, category, card_subtype, card_body))
			if category == CardContentOverlay.Category.CREATURE:
				var stats: CardStatOverlay = CardStatOverlay.new()
				card.add_child(stats)
				stats.set_printed_values(card_cost, attacks[index % attacks.size()], healths[index % healths.size()], 0)
			else:
				var seal: CardCategoryOverlay = CardCategoryOverlay.new()
				seal.category = category
				seal.set("_mana", card_cost)
				card.add_child(seal)

## Deterministic compressed circular arc; position is the visual center.
## Horizontal overlap preserves scale. Vertical compression reserves the tactical area.
static func layout_pose(index: int, count: int, width: float, height: float, maximum_spread: float = 9.0, curvature: float = 0.2, minimum_overlap: float = 0.36) -> Transform2D:
	var half_count: float = float(count - 1) * 0.5
	var angular_limit: float = deg_to_rad(minf(maximum_spread, maxf(0.0, float(count - 1)) * 1.6))
	var step: float = minf(height * (1.0 - minimum_overlap), maxf(0.0, width - height * 0.95 - 24.0) / maxf(1.0, float(count - 1)))
	var radius: float = step * maxf(half_count, 1.0) / maxf(sin(angular_limit), 0.001)
	var angle: float = (float(index) - half_count) / maxf(half_count, 1.0) * angular_limit
	var drop: float = radius * (1.0 - cos(angle)) * curvature
	var outer_drop: float = radius * (1.0 - cos(angular_limit)) * curvature
	var outer_half_height: float = height * (cos(angular_limit) + 0.75 * sin(angular_limit)) * 0.5
	var center_y: float = 270.0 - outer_half_height - outer_drop
	return Transform2D(angle, Vector2(width * 0.5 + radius * sin(angle), center_y + drop))

## Tests whether a point in local space is inside an oriented card box.
static func is_point_in_card(p: Vector2, center: Vector2, rotation: float, card_height: float) -> bool:
	var offset: Vector2 = (p - center).rotated(-rotation)
	var scale_factor: float = card_height / CardViewLayout.CARD_SIZE.y
	var half_width: float = CardViewLayout.CARD_SIZE.x * scale_factor * 0.5
	var half_height: float = card_height * 0.5
	return absf(offset.x) <= half_width and absf(offset.y) <= half_height

## Deterministic card picking respecting rotation, overlap, z-order, and raised state.
func pick_card_at(local_point: Vector2) -> int:
	var count: int = clampi(display_count, 0, 10)
	if count == 0 or face_down:
		return -1

	# 1. Active inspection hysteresis: if a card is currently raised or transitioning,
	# test if pointer is inside its raised visual footprint.
	if _target_index >= 0 and _target_index < count:
		var raised_blend: float = _card_blends[_target_index] if _target_index < _card_blends.size() else 0.0
		if raised_blend > 0.08:
			var rest_pose: Transform2D = layout_pose(_target_index, count, size.x, preferred_height)
			var inspect_h: float = inspection_height
			var scale_inspect: float = inspect_h / CardViewLayout.CARD_SIZE.y
			var half_w_inspect: float = CardViewLayout.CARD_SIZE.x * scale_inspect * 0.5
			var inspect_center_x: float = clampf(rest_pose.origin.x, half_w_inspect + 16.0, size.x - half_w_inspect - 16.0)
			var inspect_center_y: float = 20.0
			var current_center: Vector2 = rest_pose.origin.lerp(Vector2(inspect_center_x, inspect_center_y), raised_blend)
			var current_h: float = lerpf(preferred_height, inspect_h, raised_blend)
			var current_rot: float = lerpf(rest_pose.get_rotation(), 0.0, raised_blend)

			if is_point_in_card(local_point, current_center, current_rot, current_h):
				# If pointer is in the upper raised body above all resting cards, maintain inspection.
				if local_point.y < -20.0:
					return _target_index
				# In the resting card vertical span, allow steering into other resting cards.
				for i: int in range(count - 1, -1, -1):
					if i == _target_index:
						continue
					var other_pose: Transform2D = layout_pose(i, count, size.x, preferred_height)
					if is_point_in_card(local_point, other_pose.origin, other_pose.get_rotation(), preferred_height):
						return i
				return _target_index

	# 2. Resting fan picking: iterate top-to-bottom visual order (right-to-left in left-to-right stacking).
	for i: int in range(count - 1, -1, -1):
		var pose: Transform2D = layout_pose(i, count, size.x, preferred_height)
		if is_point_in_card(local_point, pose.origin, pose.get_rotation(), preferred_height):
			return i

	return -1

## Convenience global coordinate picker.
func pick_card_at_global(global_point: Vector2) -> int:
	return pick_card_at(get_global_transform().affine_inverse() * global_point)

## Returns the current hover state machine enum.
func get_hover_state() -> HoverState:
	return _hover_state

## Returns the currently targeted or hovered card index (-1 for none).
func get_hovered_index() -> int:
	return _target_index

## Returns the current visual blend ratio for a given card [0.0..1.0].
func get_card_blend(index: int) -> float:
	if index >= 0 and index < _card_blends.size():
		return _card_blends[index]
	return 0.0

## Programmatic / deterministic inspection contract (used by tests & captures).
func set_inspected_card(index: int, blend: float = 1.0) -> void:
	if face_down:
		return
	selected_index = index
	_target_index = index
	var count: int = clampi(display_count, 0, 10)
	for i: int in range(count):
		if i < _card_blends.size():
			_card_blends[i] = blend if i == index else 0.0
	_apply_card_transforms()
	_update_hover_state()
	set_process(false)

func _texture(parent: Control, texture: Texture2D, dimensions: Vector2) -> TextureRect:
	var image: TextureRect = TextureRect.new()
	image.texture = texture
	image.size = dimensions
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	return image
