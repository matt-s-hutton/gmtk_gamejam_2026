shader_type spatial;
render_mode blend_add, unshaded, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 fxColor : source_color = vec4(1.0);
uniform float progress = 0.0;
uniform float width = 0.0;
uniform float angle = 45.0;

const vec2 center = vec2(0.5, 0.5);

void fragment() {
	vec2 pos = UV - center;
	float d = length(pos) * 2.0;
	float a = atan(pos.x, pos.y) * 2.0;
	float rad = radians(angle);
	float turnLeftMask  = smoothstep(rad + 0.001, rad - 0.001, a);
	float turnRightMask = smoothstep(-rad - 0.001, -rad + 0.001, a);
	float edge1 = smoothstep(progress + 0.001, progress - 0.001, d);
	float edge2 = smoothstep(progress - 0.4 * width, progress, d);
	ALBEDO = fxColor.rgb;
	ALPHA = edge1 * edge2 * turnLeftMask * turnRightMask * fxColor.a;
}