extends TextureButton
## UpgradeableWeapon —— 单张武器升级卡（对应 H5 同名类）
## 卡片本身就是按钮：单击=购买/升级；长按≈333ms=补弹（仅拥有且非 minigun）
## 内部子节点全部在代码里构建，mouse_filter=IGNORE 不拦截点击

signal clicked(key: String)
signal refill_held(key: String)

const FONT: Font = preload("res://fonts/gunplay.ttf")
const TEX_FRAME: Texture2D = preload("res://sprites/menu/upgrades/parts/frame.png.tres")
const TEX_PIP_OFF: Texture2D = preload("res://sprites/menu/upgrades/parts/buttons/off.png.tres")
const TEX_PIP_ON: Texture2D = preload("res://sprites/menu/upgrades/parts/buttons/on.png.tres")
const TEX_AMMO_BG: Texture2D = preload("res://sprites/menu/upgrades/parts/ammo_small.png.tres")
const TEX_AMMO_BAR: Texture2D = preload("res://sprites/menu/upgrades/parts/ammo_bar.png.tres")

const HOLD_TIME: float = 0.333

@export var weapon_key: String = ""

var _icon: TextureRect
var _title: Label
var _pips: Array[TextureRect] = []
var _price: Label
var _ammo_bg: TextureRect
var _ammo_bar: TextureRect

var _level: int = -1
var _holding: bool = false
var _hold_fired: bool = false
var _hold_left: float = 0.0

# 5 个等级灯的相对坐标（自下而上：0..4）
const PIP_POSITIONS: Array[Vector2] = [
	Vector2(62, 63),
	Vector2(62, 52),
	Vector2(62, 42),
	Vector2(62, 32),
	Vector2(62, 21),
]


func _ready() -> void:
	texture_normal = TEX_FRAME
	texture_hover = TEX_FRAME
	texture_pressed = TEX_FRAME
	custom_minimum_size = Vector2(93, 79)
	size = Vector2(93, 79)
	stretch_mode = TextureButton.STRETCH_KEEP
	_build_ui()
	button_down.connect(_on_down)
	button_up.connect(_on_up)
	if weapon_key != "":
		setup(weapon_key)


func _build_ui() -> void:
	# 武器图标
	_icon = TextureRect.new()
	_icon.position = Vector2(8, 20)
	_icon.size = Vector2(50, 50)
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(_icon)

	# 标题
	_title = Label.new()
	_title.position = Vector2(0, 4)
	_title.size = Vector2(93, 16)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title.add_theme_font_override("font", FONT)
	_title.add_theme_font_size_override("font_size", 12)
	_title.add_theme_color_override("font_color", Color(0.91, 0.7, 0.0, 1))
	add_child(_title)

	# 5 个等级灯
	_pips.clear()
	for pos in PIP_POSITIONS:
		var pip := TextureRect.new()
		pip.position = pos
		pip.size = Vector2(15, 14)
		pip.scale = Vector2(0.5, 0.5)
		pip.texture = TEX_PIP_OFF
		pip.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pip.visible = false
		add_child(pip)
		_pips.append(pip)

	# 弹药背景
	_ammo_bg = TextureRect.new()
	_ammo_bg.position = Vector2(73, 22)
	_ammo_bg.size = Vector2(12, 48)
	_ammo_bg.texture = TEX_AMMO_BG
	_ammo_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_ammo_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ammo_bg.visible = false
	add_child(_ammo_bg)

	# 弹药条
	_ammo_bar = TextureRect.new()
	_ammo_bar.position = Vector2(75, 23)
	_ammo_bar.size = Vector2(10, 45)
	_ammo_bar.texture = TEX_AMMO_BAR
	_ammo_bar.stretch_mode = TextureRect.STRETCH_SCALE
	_ammo_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ammo_bar.visible = false
	add_child(_ammo_bar)

	# 价格文本
	_price = Label.new()
	_price.position = Vector2(0, 84)
	_price.size = Vector2(93, 22)
	_price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_price.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_price.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_price.add_theme_font_override("font", FONT)
	_price.add_theme_font_size_override("font_size", 20)
	_price.add_theme_color_override("font_color", Color(0.91, 0.7, 0.0, 1))
	add_child(_price)


func setup(key: String) -> void:
	weapon_key = key
	var icon_path := "res://sprites/menu/upgrades/parts/%s.png.tres" % key
	if ResourceLoader.exists(icon_path):
		_icon.texture = load(icon_path)
	_title.text = key.capitalize()
	refresh()


func refresh() -> void:
	_level = Game.get_weapon_level(weapon_key)
	# 等级灯：拥有(level>=0)时显示，level>=i 的亮 on
	for i in range(_pips.size()):
		_pips[i].visible = _level >= 0
		_pips[i].texture = TEX_PIP_ON if i < _level else TEX_PIP_OFF
	# 价格：未拥有→购买价；0..4→下一级升级价；5→MAX
	if _level < 0:
		_price.text = _format_money(int(Settings.PRICES[weapon_key][0]))
	elif _level < 5:
		_price.text = _format_money(int(Settings.PRICES[weapon_key][_level + 1]))
	else:
		_price.text = "MAX"
	# 弹药条：仅非 minigun 且拥有时显示，高度按百分比从底向上长
	var show_ammo: bool = weapon_key != "minigun" and _level >= 0
	if show_ammo:
		var p: float = Game.get_ammo_percent(weapon_key)
		var h: float = max(44.0 * p, 1.0)
		_ammo_bar.size = Vector2(10, h)
		_ammo_bar.position = Vector2(75, 68.0 - h)
		_ammo_bg.visible = true
		_ammo_bar.visible = true
	else:
		_ammo_bg.visible = false
		_ammo_bar.visible = false
	# minigun 满级后禁用
	disabled = (weapon_key == "minigun" and _level >= 5)


func _on_down() -> void:
	Audio.play_button_down()
	_holding = true
	_hold_fired = false
	_hold_left = HOLD_TIME


func _on_up() -> void:
	_holding = false
	if not _hold_fired:
		clicked.emit(weapon_key)


func _process(delta: float) -> void:
	if not _holding or _hold_fired:
		return
	_hold_left -= delta
	if _hold_left <= 0.0:
		_hold_fired = true
		if _level >= 0 and weapon_key != "minigun":
			refill_held.emit(weapon_key)


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
