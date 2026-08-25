// 反向 alpha（镂空/遮罩用）— 移植自 inverse_alpha.frag
shader_type canvas_item;

void fragment() {
	vec4 f = texture(TEXTURE, UV);
	COLOR.rgb = f.rgb;
	COLOR.a = (1.0 - f.a) * COLOR.a;
}
