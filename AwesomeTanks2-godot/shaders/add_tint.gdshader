// 加法染色（受击闪白）— 移植自 add_tint.frag
// 用法：sprite.material = ShaderMaterial; sprite.tint 设为负色，tint=0 时全白
shader_type canvas_item;

void fragment() {
	vec4 f = texture(TEXTURE, UV);
	float a = clamp(COLOR.a, 0.00001, 1.0);
	COLOR.rgb = f.rgb * COLOR.a + clamp(1.0 - COLOR.rgb / a, 0.0, 1.0) * COLOR.a * f.a;
	COLOR.a = f.a * COLOR.a;
}
