extends Control
## StatsLayer —— Upgrades 菜单“Stats”统计弹窗（对应 H5 gui.StatsAlert）
##
## 弹窗背景 stats.png(514x573) 与 H5 原图逐字节一致，标题/行说明文字都已印在图内，
## 这里只负责叠加动态内容：
##   - 7 行统计数字（绿色，右对齐同一列，H5 addLabel）+ 生涯总金币（金色大字，H5 formatMoney）
##   - 底部两排共 9 个成就奖章（完成=彩色、未完成=灰色），悬停/点击弹出说明气泡
##     （H5 createAchievement + showHint，气泡 5 秒后 250ms 淡出）
##
## 坐标换算：H5 StatsAlert 以 600x600 舞台中心(0,0)为原点，Godot 面板以左上角为原点，
## 面板 514x573 → 面板本地坐标 = (257 + dx, 286.5 + dy)。

const FONT: Font = preload("res://fonts/gunplay.ttf")

const PANEL_W: float = 514.0
const PANEL_H: float = 573.0
const PANEL_CX: float = PANEL_W / 2.0  # 257
const PANEL_CY: float = PANEL_H / 2.0  # 286.5

# 数字列右边缘 x（H5 addLabel/add.text 的 x=205，锚点右对齐）
const VALUE_RIGHT_X: float = PANEL_CX + 205.0

# 统计行：字段名 -> H5 dy（相对舞台中心的纵向偏移；行间距约 30px）
const STAT_ROWS: Array = [
	["tanksDestroyed", -181],
	["turretsDestroyed", -150],
	["spawnersDestroyed", -119],
	["wallsDestroyed", -89],
	["coinsCollected", -60],
	["barrelsExploded", -29],
	["cratesDestroyed", -1],
]

# 成就奖章：{name, dx, dy}（H5 createAchievement，锚点在图标底边中点）
const ACHIEVEMENTS: Array = [
	{"name": "hunter", "dx": -183, "dy": 186},
	{"name": "destroyer", "dx": -91, "dy": 186},
	{"name": "dodger", "dx": 1, "dy": 186},
	{"name": "treasurer", "dx": 93, "dy": 186},
	{"name": "ultracombo", "dx": 185, "dy": 186},
	{"name": "gotcha", "dx": -133, "dy": 270},
	{"name": "fired", "dx": -41, "dy": 270},
	{"name": "nailed", "dx": 51, "dy": 270},
	{"name": "survivor", "dx": 143, "dy": 270},
]

# H5 说明气泡中心在 (15, 72)，出现后 5 秒开始淡出
const HINT_POS: Vector2 = Vector2(PANEL_CX + 15.0, PANEL_CY + 72.0)
const HINT_KEEP_SEC: float = 5.0

const TEX_DIR := "res://sprites/menu/upgrades/parts/achievements/"

const COLOR_VALUE := Color("#AAC641")  # 统计数字（H5 addLabel fill）
const COLOR_MONEY := Color("#FFB600")  # 总金币（H5 金色）

@onready var _panel: Control = $Center2/Panel2
@onready var _close_btn: TextureButton = $Center2/Panel2/CloseBtn2

var _value_labels: Dictionary = {}      # 统计字段 -> Label
var _money_label: Label = null
var _medal_buttons: Dictionary = {}     # 成就名 -> TextureButton
var _medal_anchors: Dictionary = {}     # 成就名 -> 底边中点（面板本地坐标）
var _hint: TextureRect = null
var _hint_tween: Tween = null


func _ready() -> void:
	_build_ui()
	_close_btn.pressed.connect(_on_close_pressed)
	refresh()


# ============================================================
# UI 构建（一次性）
# ============================================================
func _build_ui() -> void:
	# 7 行统计数字（右对齐）
	for row in STAT_ROWS:
		var label := _make_value_label(float(row[1]))
		_panel.add_child(label)
		_value_labels[row[0]] = label
	# 生涯总收入（金色大字，H5 单独一行、锚点右上）
	_money_label = _make_money_label()
	_panel.add_child(_money_label)
	# 成就奖章
	for a in ACHIEVEMENTS:
		var name: String = a["name"]
		_medal_anchors[name] = Vector2(
			PANEL_CX + float(a["dx"]),
			PANEL_CY + float(a["dy"])
		)
		var btn := TextureButton.new()
		btn.name = "Medal_" + name
		btn.focus_mode = Control.FOCUS_NONE
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.pressed.connect(_on_medal_pressed.bind(name))
		btn.mouse_entered.connect(_on_medal_hovered.bind(name))
		btn.mouse_exited.connect(_hide_hint)
		_panel.add_child(btn)
		_medal_buttons[name] = btn
	# 说明气泡（贴图运行时切换）
	_hint = TextureRect.new()
	_hint.name = "Hint"
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_hint.visible = false
	_panel.add_child(_hint)


func _make_value_label(dy: float) -> Label:
	var l := Label.new()
	l.offset_left = 150.0
	l.offset_right = VALUE_RIGHT_X
	l.offset_top = PANEL_CY + dy - 20.0
	l.offset_bottom = PANEL_CY + dy + 20.0
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", 28)
	l.add_theme_color_override("font_color", COLOR_VALUE)
	return l


func _make_money_label() -> Label:
	var l := Label.new()
	var top: float = PANEL_CY + 10.0  # H5 anchor(1, 0)：顶部右对齐
	l.offset_left = 150.0
	l.offset_right = VALUE_RIGHT_X
	l.offset_top = top
	l.offset_bottom = top + 48.0
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	l.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", 34)
	l.add_theme_color_override("font_color", COLOR_MONEY)
	return l


# ============================================================
# 数据刷新（每次打开弹窗时调用）
# ============================================================
func open() -> void:
	refresh()
	visible = true


func refresh() -> void:
	var stats: Dictionary = Game.current.get("stats", {})
	for key in _value_labels:
		_value_labels[key].text = str(int(stats.get(key, 0)))
	if _money_label != null:
		_money_label.text = _format_money(int(stats.get("moneyEarned", 0)))
	_refresh_medals()


func _refresh_medals() -> void:
	for name in _medal_buttons:
		var btn: TextureButton = _medal_buttons[name]
		var suffix := "" if Game.is_achievement_completed(name) else "_disabled"
		var tex := load(TEX_DIR + name + suffix + ".png.tres") as Texture2D
		btn.texture_normal = tex
		btn.texture_pressed = tex
		btn.texture_hover = tex
		_place_medal(btn, name, tex)


## 奖章锚点 = 底边中点（对应 H5 anchor(0.5,1)），贴图尺寸变化时按实际尺寸重排
func _place_medal(btn: TextureButton, name: String, tex: Texture2D) -> void:
	var anchor: Vector2 = _medal_anchors[name]
	var s := Vector2(71.0, 82.0)
	if tex != null:
		s = tex.get_size()
	btn.size = s
	btn.position = Vector2(anchor.x - s.x * 0.5, anchor.y - s.y)


# ============================================================
# 奖章交互 → 说明气泡
# ============================================================
func _on_medal_hovered(name: String) -> void:
	_show_hint(name)


func _on_medal_pressed(name: String) -> void:
	_show_hint(name)


func _show_hint(name: String) -> void:
	var tex := load(TEX_DIR + name + "_hint.png.tres") as Texture2D
	if tex == null:
		return
	_hint.texture = tex
	var s: Vector2 = tex.get_size()
	_hint.size = s
	_hint.position = HINT_POS - s * 0.5
	_hint.modulate.a = 1.0
	_hint.visible = true
	if _hint_tween != null and _hint_tween.is_valid():
		_hint_tween.kill()
	_hint_tween = create_tween()
	_hint_tween.tween_interval(HINT_KEEP_SEC)
	_hint_tween.tween_property(_hint, "modulate:a", 0.0, 0.25)
	_hint_tween.tween_callback(_hint.hide)


func _hide_hint() -> void:
	if _hint_tween != null and _hint_tween.is_valid():
		_hint_tween.kill()
	_hint_tween = null
	_hint.visible = false
	_hint.modulate.a = 1.0


# ============================================================
# 关闭
# ============================================================
func _on_close_pressed() -> void:
	Audio.play_button_down()
	_hide_hint()
	visible = false


static func _format_money(v: int) -> String:
	if v >= 1000000000:
		return "$%.3fb" % (v / 1000000000.0)
	if v >= 100000000:
		return "$%.1fm" % (v / 1000000.0)
	if v >= 1000000:
		return "$%.2fm" % (v / 1000000.0)
	if v >= 100000:
		return "$%.1fk" % (v / 1000.0)
	return "$%d" % v
