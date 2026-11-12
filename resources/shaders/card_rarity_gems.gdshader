shader_type canvas_item;
render_mode unshaded;

// A source-space mask, independent of card size. Never key by blue hue: the
// midnight-blue metal and cloth must remain identical to the approved master.
uniform sampler2D gem_mask : filter_linear, repeat_disable;
uniform vec4 gemstone_color : source_color = vec4(1.0);
uniform float inner_light : hint_range(0.0, 0.3) = 0.05;
uniform vec4 specular_color : source_color = vec4(1.0);

varying vec4 item_modulate;

void vertex() {
	// Fragment COLOR already includes TEXTURE in CanvasItem shaders. Carry only
	// the vertex/modulate color so the painted frame is not multiplied twice.
	item_modulate = COLOR;
}

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	float coverage = texture(gem_mask, UV).r;

	// The original crystal is a blue-black faceted stone. Its strongest channel
	// carries the painted cuts, reflected environment, occlusion and speculars.
	float facet = max(source.r, max(source.g, source.b));

	// Deep cuts (facet < 0.08) stay dark to preserve realistic facet geometry and cuts.
	// Mid-tone facets (0.12 - 0.60) get rich body tone and refraction.
	float body = pow(clamp(facet * 1.75, 0.0, 1.0), 0.75);
	vec3 pigment = gemstone_color.rgb;
	vec3 crystal = pigment * (body * 0.90);

	// Internal light: simulates subsurface light trapped inside the crystal volume.
	// Guided by facet depth so it stays inside the stone and does not spill onto bezels.
	crystal += pigment * inner_light * smoothstep(0.06, 0.28, facet);

	// Colored specular reflection: bright facet reflections gleam with the gemstone's
	// own brilliance before reaching the peak specular glint.
	float colored_spec = smoothstep(0.35, 0.75, facet);
	crystal = mix(crystal, specular_color.rgb, colored_spec * 0.45);

	// Narrow, crisp white specular glints at the sharp painted highlights.
	float white_spec = smoothstep(0.66, 0.92, facet);
	crystal = mix(crystal, vec3(0.98, 0.99, 1.0), white_spec * 0.85);

	COLOR = vec4(mix(source.rgb, crystal, coverage), source.a) * item_modulate;
}
