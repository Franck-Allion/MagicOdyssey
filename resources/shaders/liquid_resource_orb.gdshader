shader_type canvas_item;
render_mode unshaded;

// Original analytic reservoir: no Unity source or textures are distributed.
uniform float fill_ratio : hint_range(0.0, 1.0) = 1.0;
uniform float clock_seconds = 0.0;
uniform float wave_amplitude : hint_range(0.0, 0.04) = 0.003;
uniform float wave_frequency : hint_range(1.0, 30.0) = 12.0;
uniform float animation_speed : hint_range(0.0, 3.0) = 1.0;
uniform float surface_tilt = 0.0;
uniform float response = 0.0;
uniform float restoration = 0.0;
uniform float is_mana = 0.0;
// Optional artwork mounting: opponents keep the original procedural presentation.
uniform bool external_housing = false;
uniform vec4 liquid_color : source_color = vec4(0.76, 0.23, 0.23, 1.0);
uniform vec4 bronze_color : source_color = vec4(0.47, 0.39, 0.25, 1.0);
uniform vec4 enamel_color : source_color = vec4(0.047, 0.063, 0.094, 1.0);

float band(float radius, float center, float width, float aa) {
	return 1.0 - smoothstep(width, width + aa, abs(radius - center));
}

void fragment() {
	vec2 p = UV - vec2(0.5);
	float r = length(p);
	float aa = max(fwidth(r), 0.001);
	float t = clock_seconds * animation_speed;
	float glass = 1.0 - smoothstep(0.375 - aa, 0.375 + aa, r);
	float outer = 1.0 - smoothstep(0.479 - aa, 0.479 + aa, r);
	float angle = atan(p.y, p.x);
	float light = clamp(0.48 - p.x * 0.7 - p.y * 0.9, 0.0, 1.0);
	// Turned bronze bevels, inset midnight enamel and engraved radial scoring.
	float bevel = 0.34 + 0.55 * light + 0.20 * sin(r * 530.0);
	float engraving = pow(abs(sin(angle * 36.0)), 18.0) * band(r, 0.433, 0.014, aa);
	vec3 housing = bronze_color.rgb * (bevel - engraving * 0.34);
	housing = mix(housing, enamel_color.rgb * 1.5, band(r, 0.427, 0.012, aa));
	housing += bronze_color.rgb * (band(r, 0.465, 0.003, aa) + band(r, 0.390, 0.003, aa)) * light;
	float studs = pow(max(cos(angle * 8.0), 0.0), 70.0) * band(r, 0.429, 0.008, aa);
	housing = mix(housing, bronze_color.rgb * (0.7 + light), studs);
	// Exact endpoints: waves fade into the top/bottom of the usable glass.
	float envelope = smoothstep(0.0, 0.12, fill_ratio) * smoothstep(0.0, 0.12, 1.0 - fill_ratio);
	float surface = 0.875 - 0.75 * fill_ratio;
	float wall_curve = -0.009 * pow(abs(p.x) / 0.375, 6.0) * envelope;
	float w1 = (sin(p.x * wave_frequency + t * 0.65) * wave_amplitude + p.x * surface_tilt) * envelope + wall_curve;
	float w2 = w1 + sin(p.x * 17.0 - t * 0.8) * 0.0015 * envelope;
	float front = smoothstep(surface + w1 - aa, surface + w1 + aa, UV.y);
	float back = smoothstep(surface + w2 - aa, surface + w2 + aa, UV.y);
	float wet = max(front, back) * step(0.00001, fill_ratio);
	float depth = clamp((UV.y - surface) / max(0.75 * fill_ratio, 0.001), 0.0, 1.0);
	float roundness = sqrt(max(0.0, 1.0 - r * r / (0.375 * 0.375)));
	vec3 pigment = mix(liquid_color.rgb, liquid_color.rgb * liquid_color.rgb, 0.42);
	vec3 fluid = pigment * mix(1.12, 0.24, depth) * (0.55 + 0.45 * roundness);
	float meniscus = exp(-abs(UV.y - surface - w1) * 520.0) * step(0.00001, fill_ratio) * step(fill_ratio, 0.99999);
	fluid += mix(pigment, vec3(0.8), 0.28) * meniscus * 0.65;
	fluid += pigment * exp(-abs(UV.y - surface - w2 - 0.009) * 100.0) * 0.12;
	// Two tiny subordinate bubbles, with unrelated deterministic rise rates.
	for (int i = 0; i < 2; i++) {
		float seed = float(i);
		vec2 center = vec2(0.35 + seed * 0.27, 0.86 - fract(seed * 0.413 + t * (0.018 + seed * 0.009)) * 0.65);
		float d = length(UV - center);
		float bubble = (1.0 - smoothstep(aa, aa * 1.5, abs(d - 0.004))) * 0.07;
		fluid += vec3(0.5, 0.65, 0.8) * bubble;
	}
	vec3 reservoir = mix(enamel_color.rgb * (0.6 + roundness), fluid, wet);
	// Broad soft reflection plus thin curved specular arcs, also visible when empty.
	float soft = exp(-dot((p - vec2(-0.13, -0.16)) * vec2(8.0, 13.0), (p - vec2(-0.13, -0.16)) * vec2(8.0, 13.0)));
	float arc = band(length(p - vec2(0.025, 0.025)), 0.323, 0.006, aa) * (1.0 - smoothstep(-0.22, 0.08, p.y)) * (1.0 - smoothstep(-0.24, 0.12, p.x));
	float bottom_arc = band(r, 0.354, 0.002, aa) * smoothstep(0.1, 0.32, p.y);
	reservoir += vec3(0.65, 0.78, 0.88) * (soft * 0.12 + arc * 0.40 + bottom_arc * 0.18);
	reservoir += liquid_color.rgb * response * 0.035 * roundness * wet;
	float shimmer = exp(-pow((p.x + p.y * 0.45 - (0.5 - response)) * 23.0, 2.0));
	reservoir += vec3(0.35, 0.66, 1.0) * shimmer * response * restoration * is_mana * 0.06;
	vec3 color = mix(housing, reservoir, glass);
	COLOR = vec4(color, outer);
	if (external_housing) {
		COLOR = vec4(reservoir, glass);
	}
}
