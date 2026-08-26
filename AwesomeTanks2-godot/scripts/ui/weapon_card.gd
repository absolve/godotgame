extends TextureButton
## UpgradeableWeapon —— 单张武器升级卡（对应 H5 同名类）
## 卡片本身就是按钮：单击=购买/升级；长按≈333ms=补弹（仅拥有且非 minigun）
## 子节点在场景中预建（Icon/Title/Pip0-4/AmmoBg/AmmoBar/Price），mouse_filter=IGNORE 不拦截点击

signal clicked(key: String)
signal refill_held(key: String)

const TEX_PIP_OFF: Texture2D = preload("res://sprites/menu/upgrades/parts/buttons/off.png.tres")
const TEX_PIP_ON: Texture2D = preload("res://sprites/menu/upgrades/parts/buttons/on.png.tres")

const HOLD_TIME: float = 0.333

@export var weapon_key: String = ""

@onready var _icon: TextureRect = $Icon
@onready var _title: Label = $Title
@onready var _pips: Array[TextureRect] = [$Pip0, $Pip1, $Pip2, $Pip3, $Pip4]
@onready var _price: Label = $Price
@onready var _ammo_bg: TextureRect = $AmmoBg
@onready var _ammo_bar: TextureRect = $AmmoBar

var _level: int = -1
var _holding: bool = false
var _hold_fired: bool = false
var _hold_left: float = 0.0


func _ready() -> void:
	button_down.connect(_on_down)
	button_up.connect(_on_up)
	if weapon_key != "":
		setup(weapon_key)


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
