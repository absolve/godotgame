shader_type canvas_item;
// HitFlash —— 受击泛白闪光（车身/炮塔共用）
// flash_amount 1→0 由 hit_flash.gd 用 Tween 驱动；flash_color 可自定义（默认白）
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 color = mix(tex.rgb, flash_color.rgb, flash_amount);
	COLOR = vec4(color, tex.a);
}
