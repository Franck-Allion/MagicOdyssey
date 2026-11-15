shader_type canvas_item;
render_mode unshaded;
// Clip only the illustration corners under the approved frame's rounded aperture.
// The source artwork and its transparent aperture are never modified.
void fragment() {
	vec2 q = abs(UV - vec2(0.5)) - vec2(0.28);
	float distance_to_edge = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - 0.22;
	float coverage = 1.0 - smoothstep(-fwidth(distance_to_edge), fwidth(distance_to_edge), distance_to_edge);
	vec4 portrait = texture(TEXTURE, UV);
	COLOR = vec4(portrait.rgb, portrait.a * coverage);
}
