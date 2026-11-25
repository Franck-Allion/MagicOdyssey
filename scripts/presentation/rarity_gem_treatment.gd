class_name RarityGemTreatment
extends RefCounted
## Reusable frame-v03 treatment: assign to a frame TextureRect with full 0..1 UVs.
## The frame is drawn once; native alpha is preserved, with no additive overlay.
## Atlas/cropped frames must first provide equivalent full-frame UV coordinates.

const SHADER: Shader = preload("res://resources/shaders/card_rarity_gems.gdshader")
const MASK: Texture2D = preload("res://assets/textures/cards/frame_v03_gem_mask.svg")
const SPELL_MASK: Texture2D = preload("res://assets/textures/cards/frame_spell_v01_gem_mask.svg")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")

## Canonical emerald green hue (Colombian beryl hue ~150°, ART-002-T03C)
const EMERALD_PIGMENT_HUE: float = 0.415

static func create_material(rarity: StringName, _force_emerald_epic: bool = true, custom_mask: Texture2D = null) -> ShaderMaterial:
	var color: Color = TOKENS.color_token(rarity)
	var pigment: Color
	var specular: Color
	var inner_light: float

	match rarity:
		&"common":
			# Pure neutral white / quartz crystal; completely achromatic
			pigment = Color(1.0, 1.0, 1.0)
			specular = Color(1.0, 1.0, 1.0)
			inner_light = 0.04
		&"uncommon":
			# Sapphire blue: high chroma, pure azure/sapphire hue from token
			pigment = Color.from_hsv(color.h, 0.88, 1.0)
			specular = Color.from_hsv(color.h, 0.45, 1.0)
			inner_light = 0.10
		&"rare":
			# Ruby red: vivid ruby crimson from token
			pigment = Color.from_hsv(color.h, 0.90, 1.0)
			specular = Color.from_hsv(color.h, 0.45, 1.0)
			inner_light = 0.10
		&"epic":
			# Canonical emerald green: Colombian beryl hue ~150° (ART-002-T03C)
			pigment = Color.from_hsv(EMERALD_PIGMENT_HUE, 0.90, 1.0)
			specular = Color.from_hsv(EMERALD_PIGMENT_HUE, 0.45, 1.0)
			inner_light = 0.12
		&"legendary":
			# Luminous gold: warm, radiant golden yellow from token
			pigment = Color.from_hsv(color.h, 0.82, 1.0)
			specular = Color.from_hsv(color.h, 0.35, 1.0)
			inner_light = 0.16
		_:
			pigment = Color(1.0, 1.0, 1.0)
			specular = Color(1.0, 1.0, 1.0)
			inner_light = 0.04

	var treatment: ShaderMaterial = ShaderMaterial.new()
	treatment.shader = SHADER
	var mask_to_use: Texture2D = custom_mask if custom_mask != null else MASK
	treatment.set_shader_parameter("gem_mask", mask_to_use)
	treatment.set_shader_parameter("gemstone_color", pigment)
	treatment.set_shader_parameter("specular_color", specular)
	treatment.set_shader_parameter("inner_light", inner_light)
	return treatment

## Backward compatibility alias for create_material(&"epic")
static func create_emerald_epic_material() -> ShaderMaterial:
	return create_material(&"epic")
