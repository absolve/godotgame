// 灰度（死亡效果）— 移植自 grayscale.frag（NTSC 权重）
shader_type canvas_item;

void fragment() {
	vec4 f = texture(TEXTURE, UV);
	float luma = dot(f.rgb, vec3(0.299, 0.587, 0.114));
	COLOR = vec4(vec3(luma), f.a);
}
