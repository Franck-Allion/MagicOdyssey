shader_type canvas_item;
render_mode unshaded;
// Approved source interior is alpha 251..254. Make its solid paint opaque at
// presentation time; preserve genuine exterior transparency and soft edges.
void fragment() {
	vec4 paint = texture(TEXTURE, UV);
	if (paint.a >= 0.98) {
		paint.a = 1.0;
	}
	COLOR = paint;
}
