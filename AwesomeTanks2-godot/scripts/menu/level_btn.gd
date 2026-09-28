extends TextureButton
## LevelBtn — 关卡选择按钮
##
## 底图不再带数字：res://sprites/atlas/level_btn_{normal,active,disabled}.png
## （由 tools/extract_level_buttons.py 从原图集 menu/levels.png 里把数字擦掉得到），
## 关卡号改由子节点 NumLabel 动态绘制，所以关卡数不再被烘焙进贴图的 1~15 限制住。

signal clicked(level_num: int)

## 三种状态对应的无数字底图
const BASE_TEXTURES := {
	"normal": "res://sprites/atlas/level_btn_normal.png",
	"active": "res://sprites/atlas/level_btn_active.png",
	"disabled": "res://sprites/atlas/level_btn_disabled.png",
}

## 数字墨色（取自原画）
const INK_COLORS := {
	"normal": Color8(74, 78, 1),
	"active": Color8(199, 54, 1),
	"disabled": Color8(120, 84, 71),
}

## 数字左上角的立体高光（取自原画）
const HIGHLIGHT := Color8(255, 254, 187)

## 位数 → 字号（1~2 位对齐原画约 32px 高，位数更多时自动缩小以免顶到边框）
const FONT_SIZE_BY_DIGITS := {1: 38, 2: 38, 3: 28}

@export var level_num: int = 1

@onready var player: AnimationPlayer = $player
@onready var _num_label: Label = $NumLabel


func _ready() -> void:
	button_down.connect(_on_down)
	button_up.connect(_on_up)
	resized.connect(_sync_pivot)
	_sync_pivot()


func refresh_state(unlocked: int) -> void:
	# unlocked = 已通关关卡数（0 表示还没玩过第 1 关）
	var state_key := "normal"
	if level_num - 1 == unlocked:
		state_key = "active"
	elif level_num - 1 > unlocked:
		state_key = "disabled"
		disabled = true
	else:
		disabled = false
	var tex: Texture2D = load(BASE_TEXTURES[state_key])
	texture_normal = tex
	texture_hover = tex
	texture_pressed = tex
	texture_disabled = tex
	stretch_mode = TextureButton.STRETCH_KEEP
	ignore_texture_size = true
	_apply_number(state_key)


## 把关卡号画到按钮上（底图本身不含数字，所以可以任意多位）
func _apply_number(state_key: String) -> void:
	if _num_label == null:
		return
	var text := str(level_num)
	_num_label.text = text
	_num_label.add_theme_color_override("font_color", INK_COLORS[state_key])
	_num_label.add_theme_color_override("font_shadow_color", HIGHLIGHT)

	var digits := text.length()
	var font_size: int = FONT_SIZE_BY_DIGITS.get(digits, 28 - (digits - 3) * 6)
	_num_label.add_theme_font_size_override("font_size", maxi(font_size, 12))


## 缩放动画以按钮中心为轴（尺寸由容器决定，所以尺寸变化时都要同步）
func _sync_pivot() -> void:
	pivot_offset = size / 2.0


func _on_down() -> void:
	if not disabled:
		#Audio.play_button_down()
		Audio.play_sfx("level.mp3")


func _on_up() -> void:
	if not disabled:
		clicked.emit(level_num - 1)


func _on_mouse_entered() -> void:
	if !disabled:
		player.play("zoomIn")


func _on_mouse_exited() -> void:
	if !disabled:
		player.play("zoomOut")
