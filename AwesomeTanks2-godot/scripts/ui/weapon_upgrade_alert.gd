extends Control
## WeaponUpgradeAlert —— 点击武器卡弹出的 购买/升级/补弹 弹窗（对应 H5 BuyUpgradeAlert）
## 未拥有：显示描述 + BUY 按钮；已拥有：显示等级灯 + UPGRADE 按钮 + 弹药条/REFILL（minigun 除外）

signal purchased(key: String, is_refill: bool)  # 购买/补弹成功（外部刷钱闪烁+对应武器卡闪烁）
signal failed(key: String, is_refill: bool)     # 钱不够

# H5 BuyUpgradeAlert 里的武器说明文本
const DESCRIPTIONS: Dictionary = {
	"minigun": "Low damage.\nInfinite ammo.",
	"shotgun": "Moderate\nspread damage.",
	"ricochet": "Hold fire button\nto charge.\nBounces off walls.",
	"flamethrower": "Sets enemies\non fire, dealing\nextra damage.",
	"cannon": "Great firepower,\nsplash damage.",
	"shock": "Electrocutes\nmultiple enemies.",
	"rockets": "Guided rockets.\nWhen fired,\nfollows mouse cursor.",
	"laser": "Great damage.\nUninterrupted\nfirepower.",
	"railgun": "Piercing projectiles.\nGreat damage.",
	"mines": "Set with \"R\" key.\nMines won't damage\nyour tank.",
}

const TEX_PIP_ON: Texture2D = preload("res://sprites/menu/upgrades/parts/buttons/on.png.tres")
const TEX_PIP_OFF: Texture2D = preload("res://sprites/menu/upgrades/parts/buttons/off.png.tres")
const TEX_BUY := [
	preload("res://sprites/menu/upgrades/parts/buttons/buy_normal.png.tres"),
	preload("res://sprites/menu/upgrades/parts/buttons/buy_hover.png.tres"),
	preload("res://sprites/menu/upgrades/parts/buttons/buy_down.png.tres"),
]
const TEX_UPGRADE := [
	preload("res://sprites/menu/upgrades/parts/buttons/upgrade_normal.png.tres"),
	preload("res://sprites/menu/upgrades/parts/buttons/upgrade_hover.png.tres"),
	preload("res://sprites/menu/upgrades/parts/buttons/upgrade_down.png.tres"),
]

# Panel(451x296) 内坐标（由 H5 弹窗中心坐标系换算而来）
const POS_BUY: Vector2 = Vector2(164, 218)     # BUY 按钮（未拥有 / minigun）
const POS_UPGRADE: Vector2 = Vector2(26, 218)  # UPGRADE 按钮（已拥有，靠左）
const AMMO_BAR_X: float = 365.5
const AMMO_BAR_BOTTOM: float = 173.0
const AMMO_BAR_MAX_H: float = 65.0

@onready var _title: Label = $Center/Panel/Title
@onready var _desc: Label = $Center/Panel/Desc
@onready var _icon: TextureRect = $Center/Panel/Icon
@onready var _pips: Array[TextureRect] = [
	$Center/Panel/Pip0, $Center/Panel/Pip1, $Center/Panel/Pip2, $Center/Panel/Pip3, $Center/Panel/Pip4,
]
@onready var _price: Label = $Center/Panel/Price
@onready var _buy_btn: TextureButton = $Center/Panel/BuyBtn
@onready var _refill_btn: TextureButton = $Center/Panel/RefillBtn
@onready var _ammo_title: Label = $Center/Panel/AmmoTitle
@onready var _ammo_price: Label = $Center/Panel/AmmoPrice
@onready var _ammo_bg: TextureRect = $Center/Panel/AmmoBg
@onready var _ammo_bar: TextureRect = $Center/Panel/AmmoBar

var _weapon_key: String = ""
var _level: int = -1


func _ready() -> void:
	visible = false
	_buy_btn.pressed.connect(_on_buy_pressed)
	_refill_btn.pressed.connect(_on_refill_pressed)
	$Center/Panel/CloseBtn.pressed.connect(_on_close_pressed)


func open(key: String) -> void:
	_weapon_key = key
	_title.text = key
	_desc.text = DESCRIPTIONS.get(key, "")
	var icon_path := "res://sprites/menu/upgrades/parts/%s.png.tres" % key
	_icon.texture = load(icon_path) if ResourceLoader.exists(icon_path) else null
	refresh()
	visible = true


func refresh() -> void:
	if _weapon_key == "":
		return
	_level = Game.get_weapon_level(_weapon_key)
	var maxed: bool = _level >= 5
	# 等级灯：拥有时显示，level>=i 的亮
	for i in range(_pips.size()):
		_pips[i].visible = _level >= 0
		_pips[i].texture = TEX_PIP_ON if i < _level else TEX_PIP_OFF
	# 购买/升级按钮
	_buy_btn.visible = not maxed
	if not maxed:
		var frames: Array = TEX_UPGRADE if _level >= 0 else TEX_BUY
		_buy_btn.texture_normal = frames[0]
		_buy_btn.texture_hover = frames[1]
		_buy_btn.texture_pressed = frames[2]
		_buy_btn.position = POS_UPGRADE if (_level >= 0 and _weapon_key != "minigun") else POS_BUY
	# 价格：未拥有→购买价；0..4→下一级升级价；5→MAX
	if maxed:
		_price.text = "MAX"
	else:
		_price.text = _format_money(int(Settings.PRICES[_weapon_key][_level + 1]))
	# 弹药区（仅非 minigun 且已拥有时显示）
	var show_ammo: bool = _weapon_key != "minigun" and _level >= 0
	_refill_btn.visible = false
	_ammo_title.visible = show_ammo
	_ammo_price.visible = show_ammo
	_ammo_bg.visible = show_ammo
	_ammo_bar.visible = show_ammo
	if show_ammo:
		_refresh_ammo()


func _refresh_ammo() -> void:
	var p: float = Game.get_ammo_percent(_weapon_key)
	var h: float = max(AMMO_BAR_MAX_H * p, 1.0)
	_ammo_bar.size = Vector2(16, h)
	_ammo_bar.position = Vector2(AMMO_BAR_X, AMMO_BAR_BOTTOM - h)
	if p < 1.0:
		_refill_btn.visible = true
		_ammo_price.text = _format_money(int(Settings.AMMO_PRICES.get(_weapon_key, 0)))
	else:
		_ammo_price.text = "MAX"


# ---------- 购买/升级（对应 H5 weaponUpgrade 回调） ----------
func _on_buy_pressed() -> void:
	Audio.play_button_down()
	var level: int = Game.get_weapon_level(_weapon_key)
	if level >= 5:
		return
	var price: int = int(Settings.PRICES[_weapon_key][level + 1])
	if Game.spend(price):
		if level < 0:
			Game.set_weapon_level(_weapon_key, 0)
			Game.set_weapon_ammo(_weapon_key, int(Settings.AMMO_LIMITS.get(_weapon_key, 0)))
		else:
			Game.set_weapon_level(_weapon_key, level + 1)
		Game.save()
		Audio.play_sfx("buy.mp3")
		refresh()
		FlashFx.flash(_icon)
		if _level > 0:
			FlashFx.flash(_pips[_level - 1])
		purchased.emit(_weapon_key, false)
	else:
		Audio.play_sfx("not_available.mp3")
		FlashFx.flash(_price)
		failed.emit(_weapon_key, false)


# ---------- 补弹（对应 H5 ammoBuy 回调） ----------
func _on_refill_pressed() -> void:
	Audio.play_button_down()
	var ammo: int = Game.get_weapon_ammo(_weapon_key)
	var limit: int = int(Settings.AMMO_LIMITS.get(_weapon_key, 0))
	if ammo >= limit:
		return
	var price: int = int(Settings.AMMO_PRICES.get(_weapon_key, 0))
	if Game.spend(price):
		Game.set_weapon_ammo(_weapon_key, mini(limit, ammo + int(Settings.AMMO_AMOUNT.get(_weapon_key, 0))))
		Game.save()
		Audio.play_sfx("buy.mp3")
		_refresh_ammo()
		FlashFx.flash(_ammo_bar)
	
		purchased.emit(_weapon_key, true)
	else:
		Audio.play_sfx("not_available.mp3")
		FlashFx.flash(_ammo_price)
		failed.emit(_weapon_key, true)


func _on_close_pressed() -> void:
	Audio.play_button_down()
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
