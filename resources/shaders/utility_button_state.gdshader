shader_type canvas_item;
uniform float saturation : hint_range(0.0, 1.0) = 1.0;
varying vec4 tint;
void vertex() {
	tint = COLOR;
}
void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	float luminance = dot(pixel.rgb, vec3(0.2126, 0.7152, 0.0722));
	COLOR = tint * vec4(mix(vec3(luminance), pixel.rgb, saturation), pixel.a);
}
