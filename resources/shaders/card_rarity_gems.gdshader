shader_type canvas_item;
render_mode unshaded;

// A source-space mask, independent of card size. Never key by blue hue: the
// midnight-blue metal and cloth must remain identical to the approved master.
uniform sampler2D gem_mask : filter_linear, repeat_disable;
uniform vec4 gemstone_color : source_color = vec4(1.0);
uniform float inner_light : hint_range(0.0, 0.1) = 0.02;

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
	float body = pow(clamp(facet * 1.65, 0.0, 1.0), 0.78);
	vec3 pigment = gemstone_color.rgb;
	vec3 crystal = pigment * (0.035 + body * 0.83);
	// Internal light stays inside the crystal, never forming a halo on the bezel.
	crystal += pigment * inner_light * smoothstep(0.06, 0.24, facet);
	// Keep the narrow, painted white glints and their original facet geometry.
	float specular = smoothstep(0.42, 0.88, facet);
	crystal = mix(crystal, vec3(0.98, 0.99, 1.0), specular * 0.88);
	COLOR = vec4(mix(source.rgb, crystal, coverage), source.a) * item_modulate;
}
