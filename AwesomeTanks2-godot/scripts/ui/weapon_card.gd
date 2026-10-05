extends TextureButton
## UpgradeableWeapon —— 单张武器升级卡（对应 H5 同名类）
## 卡片本身就是按钮：单击=购买/升级；长按≈333ms=补弹（仅拥有且非 minigun）
## 子节点在场景 weapon_card.tscn 中定义，mouse_filter=IGNORE 不拦截点击

signal clicked(key: String)
signal refillHeld(key: String)

const TEX_PIP_ON: Texture2D = preload("res://sprites/menu/upgrades/parts/buttons/on.png.tres")
const TEX_PIP_OFF: Texture2D = preload("res://sprites/menu/upgrades/parts/buttons/off.png.tres")

const HOLD_TIME: float = 0.333

@export var weaponKey: String = ""

@onready var icon: TextureRect = $Icon
@onready var title: Label = $Title
@onready var pips: Array[TextureRect] = [$Pip0, $Pip1, $Pip2, $Pip3, $Pip4]
@onready var priceLabel: Label = $Price
@onready var ammoBg: TextureRect = $AmmoBg
@onready var ammoBar: TextureRect = $AmmoBar

var weaponLevel: int = -1
var holding: bool = false
var holdFired: bool = false
var holdLeft: float = 0.0


func _ready() -> void:
	button_down.connect(onDown)
	button_up.connect(onUp)
	if weaponKey != "":
		setup(weaponKey)


func setup(key: String) -> void:
	weaponKey = key
	var iconPath := "res://sprites/menu/upgrades/parts/%s.png.tres" % key
	if ResourceLoader.exists(iconPath):
		icon.texture = load(iconPath)
	title.text = key.capitalize()
	refresh()


func refresh() -> void:
	weaponLevel = Game.getWeaponLevel(weaponKey)
	# 等级灯：拥有(level>=0)时显示，level>=i 的亮 on
	for i in range(pips.size()):
		pips[i].visible = weaponLevel >= 0
		pips[i].texture = TEX_PIP_ON if i < weaponLevel else TEX_PIP_OFF
	# 价格：未拥有→购买价；0..4→下一级升级价；5→MAX
	if weaponLevel < 0:
		priceLabel.text = Game.formatMoney(int(Settings.PRICES[weaponKey][0]))
	elif weaponLevel < 5:
		priceLabel.text = Game.formatMoney(int(Settings.PRICES[weaponKey][weaponLevel + 1]))
	else:
		priceLabel.text = "MAX"
	# 弹药条：仅非 minigun 且拥有时显示，高度按百分比从底向上长
	var showAmmo: bool = weaponKey != "minigun" and weaponLevel >= 0
	if showAmmo:
		var p: float = Game.getAmmoPercent(weaponKey)
		var h: float = max(44.0 * p, 1.0)
		ammoBar.size = Vector2(10, h)
		ammoBar.position = Vector2(75, 68.0 - h)
		ammoBg.visible = true
		ammoBar.visible = true
	else:
		ammoBg.visible = false
		ammoBar.visible = false
	# minigun 满级后禁用
	disabled = (weaponKey == "minigun" and weaponLevel >= 5)


func onDown() -> void:
	Audio.playButtonDown()
	holding = true
	holdFired = false
	holdLeft = HOLD_TIME


func onUp() -> void:
	holding = false
	if not holdFired:
		clicked.emit(weaponKey)


# ---------- 闪烁提示（对应 H5 flashElement） ----------
func flash() -> void:
	FlashFx.flash(self)        # 整卡：购买/升级成功


func flashPrice() -> void:
	FlashFx.flash(priceLabel)      # 价签：钱不够


func flashAmmo() -> void:
	FlashFx.flash(ammoBar)   # 弹药条：补弹成功


func _process(delta: float) -> void:
	if not holding or holdFired:
		return
	holdLeft -= delta
	if holdLeft <= 0.0:
		holdFired = true
		if weaponLevel >= 0 and weaponKey != "minigun":
			refillHeld.emit(weaponKey)
