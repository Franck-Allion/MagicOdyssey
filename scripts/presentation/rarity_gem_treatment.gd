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
	# Theme colors are designed for readable text. Increase chroma for a small
	# translucent jewel while retaining the normative palette's exact hue.
	var saturation: float = 0.0 if rarity == &"common" else minf(color.s * 1.65, 0.85)
	var pigment: Color = Color.from_hsv(color.h, saturation, 1.0)
	var richness: float = 0.045 if rarity == &"epic" or rarity == &"legendary" else 0.02
	var treatment: ShaderMaterial = ShaderMaterial.new()
	treatment.shader = SHADER
	treatment.set_shader_parameter("gem_mask", MASK)
	treatment.set_shader_parameter("gemstone_color", pigment)
	treatment.set_shader_parameter("inner_light", richness)
	return treatment
