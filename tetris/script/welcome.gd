extends Control
# 俄罗斯方块 开始界面 - Godot 4
# 操作: 点击「开始游戏」进入

func _ready() -> void:
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(PRESET_FULL_RECT)
	vbox.offset_left = 40
	vbox.offset_top = 80
	vbox.offset_right = -40
	vbox.offset_bottom = -80
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)

	var title := Label.new()
	title.text = "俄罗斯方块"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	title.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(title)

	var spacer1 := Control.new()
	spacer1.custom_minimum_size = Vector2(0, 50)
	vbox.add_child(spacer1)

	var btn := Button.new()
	btn.text = "开始游戏"
	btn.custom_minimum_size = Vector2(220, 60)
	btn.add_theme_font_size_override("font_size", 22)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.pressed.connect(_on_start)
	vbox.add_child(btn)

	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 50)
	vbox.add_child(spacer2)

	var hint := Label.new()
	hint.text = "← → / A D: 左右移动\n↑ / W: 旋转\n↓ / S: 软降\n空格: 硬降\nESC: 返回主菜单"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 16)
	hint.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(hint)


func _on_start() -> void:
	get_tree().change_scene_to_file("res://scene/game.tscn")
