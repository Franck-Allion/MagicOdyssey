class_name RarityGemTreatment
extends RefCounted
## Reusable frame-v03 treatment: assign to a frame TextureRect with full 0..1 UVs.
## The frame is drawn once; native alpha is preserved, with no additive overlay.
## Atlas/cropped frames must first provide equivalent full-frame UV coordinates.

const SHADER: Shader = preload("res://resources/shaders/card_rarity_gems.gdshader")
const MASK: Texture2D = preload("res://assets/textures/cards/frame_v03_gem_mask.svg")
const TOKENS: GDScript = preload("res://scripts/presentation/ui_design_tokens.gd")

static func create_material(rarity: StringName) -> ShaderMaterial:
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
			# Amethyst violet: saturated, vivid violet hue from token
			pigment = Color.from_hsv(color.h, 0.92, 1.0)
			specular = Color.from_hsv(color.h, 0.50, 1.0)
			inner_light = 0.13
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
	treatment.set_shader_parameter("gem_mask", MASK)
	treatment.set_shader_parameter("gemstone_color", pigment)
	treatment.set_shader_parameter("specular_color", specular)
	treatment.set_shader_parameter("inner_light", inner_light)
	return treatment
