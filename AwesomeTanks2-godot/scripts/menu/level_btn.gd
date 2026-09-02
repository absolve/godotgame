extends TextureButton
## LevelBtn — 关卡选择按钮
## 根据 level_num 动态加载 normal/active/disabled 三种贴图
## 贴图路径: res://sprites/menu/levels/buttons/{state}/{level_num}.png.tres

signal clicked(level_num: int)

@export var level_num: int = 1


func _ready() -> void:
	button_down.connect(_on_down)
	button_up.connect(_on_up)


func refresh_state(unlocked: int) -> void:
	# unlocked = 已通关关卡数（0 表示还没玩过第 1 关）
	var state_dir := "normal"
	if level_num - 1 == unlocked:
		state_dir = "active"
	elif level_num - 1 > unlocked:
		state_dir = "disabled"
		disabled = true
	else:
		disabled = false
	var tex_path := "res://sprites/menu/levels/buttons/%s/%d.png.tres" % [state_dir, level_num]
	var tex := load(tex_path)
	texture_normal = tex
	texture_hover = tex
	texture_pressed = tex
	texture_disabled = tex
	stretch_mode = TextureButton.STRETCH_KEEP
	ignore_texture_size = true


func _on_down() -> void:
	if not disabled:
		Audio.play_button_down()


func _on_up() -> void:
	if not disabled:
		clicked.emit(level_num - 1)
