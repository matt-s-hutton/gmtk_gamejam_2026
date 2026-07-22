shader_type spatial;
render_mode cull_back, blend_mix, depth_draw_opaque;

uniform float flash : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
	ALBEDO = flash_color.rgb;
	ALPHA = flash_color.a * flash;
}