extends TextureButton
## LevelBtn — 关卡选择按钮
##
## 底图不再带数字：res://sprites/atlas/level_btn_{normal,active,disabled}.png
## （由 tools/extract_level_buttons.py 从原图集 menu/levels.png 里把数字擦掉得到），
## 关卡号改由子节点 NumLabel 动态绘制，所以关卡数不再被烘焙进贴图的 1~15 限制住。

signal clicked(levelNum: int)

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

@export var levelNum: int = 1

@onready var player: AnimationPlayer = $player
@onready var numLabel: Label = $NumLabel


func _ready() -> void:
	button_down.connect(onDown)
	button_up.connect(onUp)
	resized.connect(syncPivot)
	syncPivot()


func refreshState(unlocked: int) -> void:
	# unlocked = 已通关关卡数（0 表示还没玩过第 1 关）
	var stateKey := "normal"
	if levelNum - 1 == unlocked:
		stateKey = "active"
	elif levelNum - 1 > unlocked:
		stateKey = "disabled"
		disabled = true
	else:
		disabled = false
	var tex: Texture2D = load(BASE_TEXTURES[stateKey])
	texture_normal = tex
	texture_hover = tex
	texture_pressed = tex
	texture_disabled = tex
	stretch_mode = TextureButton.STRETCH_KEEP
	ignore_texture_size = true
	applyNumber(stateKey)


## 把关卡号画到按钮上（底图本身不含数字，所以可以任意多位）
func applyNumber(stateKey: String) -> void:
	if numLabel == null:
		return
	var text := str(levelNum)
	numLabel.text = text
	numLabel.add_theme_color_override("font_color", INK_COLORS[stateKey])
	numLabel.add_theme_color_override("font_shadow_color", HIGHLIGHT)

	var digits := text.length()
	var fontSize: int = FONT_SIZE_BY_DIGITS.get(digits, 28 - (digits - 3) * 6)
	numLabel.add_theme_font_size_override("font_size", maxi(fontSize, 12))


## 缩放动画以按钮中心为轴（尺寸由容器决定，所以尺寸变化时都要同步）
func syncPivot() -> void:
	pivot_offset = size / 2.0


func onDown() -> void:
	if not disabled:
		#Audio.play_button_down()
		Audio.playSfx("level.mp3")


func onUp() -> void:
	if not disabled:
		clicked.emit(levelNum - 1)


func onMouseEntered() -> void:
	if !disabled:
		player.play("zoomIn")


func onMouseExited() -> void:
	if !disabled:
		player.play("zoomOut")
