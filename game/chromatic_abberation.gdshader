// chromatic aberration
//---------------------------------

shader_type canvas_item;
render_mode unshaded;

uniform float amount = 0.0;
uniform sampler2D screen_texture : hint_screen_texture;

const float scale = 10.0;
const float r_phase = 0.0;
const float g_phase = PI*2.0/3.0;
const float b_phase = PI*4.0/3.0;

void fragment()
{
	float dist = distance(vec2(0.5,0.5), SCREEN_UV);
	float scaled_amount = amount * scale;
	vec2 r_disp = vec2(sin(TIME+r_phase), cos(TIME+r_phase) * 2.0) * scaled_amount * dist;
	vec2 g_disp = vec2(sin(TIME+g_phase) * 2.0, cos(TIME+g_phase)) * scaled_amount * dist;
	vec2 b_disp = vec2(sin(TIME+b_phase), cos(TIME+b_phase) * -2.0) * scaled_amount * dist;
	float r = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*r_disp), 0.0).r;
	float g = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*g_disp), 0.0).g;
	float b = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*b_disp), 0.0).b;
	
	COLOR = vec4(r, g, b, 1.0);
}