// 场景过渡擦除遮罩（移植自 machine-TD shader/transition.gdshader）
// factor: 0 = 完全透明，1 = 完全覆盖。
// 擦除方向由 gradient_texture 决定（场景里是自下而上的竖直渐变），
// 形状/软边由 shape_texture + shape_feathering 决定，颜色是 base_color。
shader_type canvas_item;

uniform vec4 base_color : source_color;
uniform vec2 node_resolution;

uniform float factor : hint_range(0.0, 1.0, 0.01) = 0.54;
uniform float width = 0.4;

group_uniforms gradient;
uniform sampler2D gradient_texture;
uniform bool gradient_fixed = false;

group_uniforms shape;
uniform sampler2D shape_texture;
uniform float shape_tiling = 32.0;
uniform float shape_rotation = 0.0;
uniform vec2 shape_scroll = vec2(0.0);
uniform float shape_feathering : hint_range(0.0, 1.0, 0.01) = 0.00;
uniform float shape_treshold : hint_range(0.0, 2.0, 0.01) = 1.0;

float gradient(vec2 uv, vec2 fixed_uv, bool fixed){
	float value = 0.0;
	if(fixed){
		value = texture(gradient_texture, fixed_uv).r;
	} else {
		value = texture(gradient_texture, uv).r;
	}
	return value;
}

vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

void fragment() {
	float progress = mix(-width, 1.0, factor);
	float aspect = node_resolution.y / node_resolution.x;

	vec2 aspect_uv = ((UV-vec2(0.0,0.5)) * vec2(1.0, aspect))+vec2(0.0,0.5);

	float value = clamp((gradient(UV, aspect_uv, gradient_fixed) - progress) / (width), 0.0, 1.0);

	vec2 tiled_uv = rotate(mod((aspect_uv + vec2(TIME)*shape_scroll) * shape_tiling, 1.0), vec2(0.5), radians(shape_rotation));
	float shape_value = 1.0 - texture(shape_texture, tiled_uv).r;

	shape_value = mix(shape_feathering * 0.5, 1.0 - shape_feathering * 0.5, shape_value);
	float shaped_gradient = smoothstep(value - (shape_feathering * 0.5), value + (shape_feathering * 0.5), shape_treshold - shape_value);

	COLOR.rgb = base_color.rgb;
	COLOR.a = shaped_gradient;
}
