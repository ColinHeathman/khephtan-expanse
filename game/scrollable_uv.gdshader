shader_type canvas_item;
render_mode blend_mix;

uniform vec2 offset = vec2(0.000000, 0.000000);

void fragment() {
	COLOR = texture(TEXTURE, mod(offset + UV, 1.0));
}
