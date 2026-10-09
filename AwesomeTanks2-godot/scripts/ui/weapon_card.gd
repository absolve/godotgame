extends ATMenuCard
## UpgradeableWeapon —— 单张武器升级卡（对应 H5 同名类）
## 卡片本身就是按钮：单击 = 购买/升级；长按 ≈333ms = 补弹（仅拥有且非 minigun）
## 点击/长按/闪烁等公共逻辑见 ATMenuCard；子节点在 weapon_card.tscn 中定义，mouse_filter=IGNORE

const TEX_PIP_ON: Texture2D = preload("res://sprites/menu/upgrades/parts/buttons/on.png.tres")
const TEX_PIP_OFF: Texture2D = preload("res://sprites/menu/upgrades/parts/buttons/off.png.tres")

@export var weaponKey: String = ""

@onready var icon: TextureRect = $Icon
@onready var title: Label = $Title
@onready var pips: Array[TextureRect] = [$Pip0, $Pip1, $Pip2, $Pip3, $Pip4]
@onready var ammoBg: TextureRect = $AmmoBg
@onready var ammoBar: TextureProgressBar = $AmmoBar


func cardKey() -> String:
	return weaponKey


## 这张卡支持"按住补弹"
func supportsHold() -> bool:
	return true


## 未拥有或 minigun 不补弹
func canRefill() -> bool:
	return weaponLevel >= 0 and weaponKey != "minigun"


func setup(key: String) -> void:
	weaponKey = key
	icon.texture = Game.loadTextureOrNull("res://sprites/menu/upgrades/parts/%s.png.tres" % key)
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
	# 弹药条：仅非 minigun 且拥有时显示；AmmoBar 是固定的 TextureProgressBar（10×44），
	# 只改 value（0..44 整格像素，从下往上），不再每帧改 size/position（那会抖）
	var showAmmo: bool = weaponKey != "minigun" and weaponLevel >= 0
	if showAmmo:
		var p: float = clampf(Game.getAmmoPercent(weaponKey), 0.0, 1.0)
		var px := roundf(p * ammoBar.max_value)
		if px > 0.0:
			px = maxf(px, 1.0)          # H5: max(44 * pct, 1)
		ammoBar.value = px
		ammoBg.visible = true
		ammoBar.visible = true
	else:
		ammoBg.visible = false
		ammoBar.visible = false
	# minigun 满级后禁用
	disabled = (weaponKey == "minigun" and weaponLevel >= 5)


## 弹药条闪烁：补弹成功（对应 H5 flashElement）
func flashAmmo() -> void:
	FlashFx.flash(ammoBar)
