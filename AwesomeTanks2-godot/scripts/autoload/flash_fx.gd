extends Node

## H5 flashElement 移植：元素瞬间变黑（tint=0x000000），250ms 线性渐变回原色
## 用于升级界面的金额、武器卡、价签、弹药条等闪烁提示

const DURATION: float = 0.25
const FLASH_BRIGHT: float = 3.0  # 非文字节点整体提亮倍数（LDR 下会截断，接近白色）


func flash(node: CanvasItem) -> void:
	# 结束上一次未完成的闪烁，避免多个补间同时写颜色
	if node.has_meta("flash_tween"):
		var old = node.get_meta("flash_tween")
		if old is Tween and old.is_valid():
			old.kill()
	var tw: Tween = node.create_tween()
	if node is Label:
		# 文字：字体色瞬间变白，再渐变回原色
		var label := node as Label
		var original: Color
		if node.has_meta("flash_orig_color"):
			original = node.get_meta("flash_orig_color")
		else:
			original = label.get_theme_color("font_color")
			node.set_meta("flash_orig_color", original)
		label.add_theme_color_override("font_color", Color.WHITE)
		tw.tween_property(label, "theme_override_colors/font_color", original, DURATION)
	else:
		# 非文字：整体瞬间提亮（接近变白），再恢复
		node.modulate = Color(FLASH_BRIGHT, FLASH_BRIGHT, FLASH_BRIGHT, 1.0)
		tw.tween_property(node, "modulate", Color.WHITE, DURATION)
	node.set_meta("flash_tween", tw)
