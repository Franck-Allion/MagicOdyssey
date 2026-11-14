shader_type canvas_item;
render_mode unshaded;

// Original analytic reservoir: no Unity source or textures are distributed.
uniform float fill_ratio : hint_range(0.0, 1.0) = 1.0;
uniform float clock_seconds = 0.0;
uniform float wave_amplitude : hint_range(0.0, 0.04) = 0.012;
uniform float wave_frequency : hint_range(1.0, 30.0) = 12.0;
uniform float animation_speed : hint_range(0.0, 3.0) = 1.0;
uniform float response = 0.0;
uniform float restoration = 0.0;
uniform float is_mana = 0.0;
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
	float w1 = sin(p.x * wave_frequency + t * 1.8) * wave_amplitude * envelope;
	float w2 = sin(p.x * wave_frequency * 1.63 - t * 1.27 + 1.9) * wave_amplitude * 0.48 * envelope;
	float front = smoothstep(surface + w1 - aa, surface + w1 + aa, UV.y);
	float back = smoothstep(surface + w2 - aa, surface + w2 + aa, UV.y);
	float wet = max(front, back) * step(0.00001, fill_ratio);
	float depth = clamp((UV.y - surface) / max(0.75 * fill_ratio, 0.001), 0.0, 1.0);
	float roundness = sqrt(max(0.0, 1.0 - r * r / (0.375 * 0.375)));
	vec3 fluid = liquid_color.rgb * mix(1.35, 0.22, depth) * (0.45 + 0.65 * roundness);
	fluid += liquid_color.rgb * 0.12 * sin(p.x * 22.0 + p.y * 13.0 + t * 0.7) * roundness;
	fluid += liquid_color.rgb * 0.28 * abs(front - back);
	float meniscus = exp(-abs(UV.y - surface - w1) * 410.0) * step(0.00001, fill_ratio) * step(fill_ratio, 0.99999);
	fluid += mix(liquid_color.rgb, vec3(1.0), 0.38) * meniscus * 0.7;
	// Seven analytic bubbles; stable seeds, no noise textures or CPU particles.
	for (int i = 0; i < 7; i++) {
		float seed = float(i);
		vec2 center = vec2(0.5 + sin(seed * 19.3) * 0.29 + sin(t + seed) * 0.009,
			0.9 - fract(seed * 0.173 + t * (0.027 + seed * 0.003)) * 0.8);
		float d = length(UV - center);
		float br = 0.004 + fract(seed * 0.37) * 0.008;
		float bubble = (1.0 - smoothstep(aa, aa * 2.0, abs(d - br))) * 0.23;
		fluid += mix(liquid_color.rgb, vec3(0.7, 0.86, 1.0), 0.45) * bubble;
	}
	vec3 reservoir = mix(enamel_color.rgb * (0.6 + roundness), fluid, wet);
	// Broad soft reflection plus thin curved specular arcs, also visible when empty.
	float soft = exp(-dot((p - vec2(-0.13, -0.16)) * vec2(8.0, 13.0), (p - vec2(-0.13, -0.16)) * vec2(8.0, 13.0)));
	float arc = band(length(p - vec2(0.025, 0.025)), 0.323, 0.006, aa) * (1.0 - smoothstep(-0.22, 0.08, p.y)) * (1.0 - smoothstep(-0.24, 0.12, p.x));
	float bottom_arc = band(r, 0.354, 0.002, aa) * smoothstep(0.1, 0.32, p.y);
	reservoir += vec3(0.65, 0.78, 0.88) * (soft * 0.26 + arc * 0.65 + bottom_arc * 0.3);
	reservoir += liquid_color.rgb * response * (0.18 + restoration * 0.14) * roundness;
	float shimmer = exp(-pow((p.x + p.y * 0.45 - (0.5 - response)) * 23.0, 2.0));
	reservoir += vec3(0.35, 0.66, 1.0) * shimmer * response * restoration * is_mana * 0.35;
	vec3 color = mix(housing, reservoir, glass);
	COLOR = vec4(color, outer);
}
