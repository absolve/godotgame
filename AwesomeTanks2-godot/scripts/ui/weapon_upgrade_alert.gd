extends Control
## WeaponUpgradeAlert —— 点击武器卡弹出的 购买/升级/补弹 弹窗（对应 H5 BuyUpgradeAlert）
## 未拥有：显示描述 + BUY 按钮；已拥有：显示等级灯 + UPGRADE 按钮 + 弹药条/REFILL（minigun 除外）

signal purchased(key: String, isRefill: bool)  # 购买/补弹成功（外部刷钱闪烁+对应武器卡闪烁）
signal failed(key: String, isRefill: bool)     # 钱不够

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
# 弹药条 AmmoBar 的位置/尺寸固定在场景里（365,108 ~ 381,173 = 16×65），
# max_value 就是它的像素高度，脚本只改 value

@onready var title: Label = $Center/Panel/Title
@onready var desc: Label = $Center/Panel/Desc
@onready var icon: TextureRect = $Center/Panel/Icon
@onready var pips: Array[TextureRect] = [
	$Center/Panel/Pip0, $Center/Panel/Pip1, $Center/Panel/Pip2, $Center/Panel/Pip3, $Center/Panel/Pip4,
]
@onready var priceLabel: Label = $Center/Panel/Price
@onready var buyBtn: TextureButton = $Center/Panel/BuyBtn
@onready var refillBtn: TextureButton = $Center/Panel/RefillBtn
@onready var ammoTitle: Label = $Center/Panel/AmmoTitle
@onready var ammoPrice: Label = $Center/Panel/AmmoPrice
@onready var ammoBg: TextureRect = $Center/Panel/AmmoBg
@onready var ammoBar: TextureProgressBar = $Center/Panel/AmmoBar

var weaponKey: String = ""
var weaponLevel: int = -1


func _ready() -> void:
	visible = false
	buyBtn.pressed.connect(onBuyPressed)
	refillBtn.pressed.connect(onRefillPressed)
	$Center/Panel/CloseBtn.pressed.connect(onClosePressed)


func open(key: String) -> void:
	weaponKey = key
	title.text = key
	desc.text = DESCRIPTIONS.get(key, "")
	var iconPath := "res://sprites/menu/upgrades/parts/%s.png.tres" % key
	icon.texture = Game.loadTextureOrNull(iconPath)
	refresh()
	visible = true


func refresh() -> void:
	if weaponKey == "":
		return
	weaponLevel = Game.getWeaponLevel(weaponKey)
	var maxed: bool = weaponLevel >= 5
	# 等级灯：拥有时显示，level>=i 的亮
	for i in range(pips.size()):
		pips[i].visible = weaponLevel >= 0
		pips[i].texture = TEX_PIP_ON if i < weaponLevel else TEX_PIP_OFF
	# 购买/升级按钮
	buyBtn.visible = not maxed
	if not maxed:
		var frames: Array = TEX_UPGRADE if weaponLevel >= 0 else TEX_BUY
		buyBtn.texture_normal = frames[0]
		buyBtn.texture_hover = frames[1]
		buyBtn.texture_pressed = frames[2]
		buyBtn.position = POS_UPGRADE if (weaponLevel >= 0 and weaponKey != "minigun") else POS_BUY
	# 价格：未拥有→购买价；0..4→下一级升级价；5→MAX
	if maxed:
		priceLabel.text = "MAX"
	else:
		priceLabel.text = Game.formatMoney(int(Settings.PRICES[weaponKey][weaponLevel + 1]))
	# 弹药区（仅非 minigun 且已拥有时显示）
	var showAmmo: bool = weaponKey != "minigun" and weaponLevel >= 0
	refillBtn.visible = false
	ammoTitle.visible = showAmmo
	ammoPrice.visible = showAmmo
	ammoBg.visible = showAmmo
	ammoBar.visible = showAmmo
	if showAmmo:
		refreshAmmo()


func refreshAmmo() -> void:
	# AmmoBar 是固定的 TextureProgressBar（16×65，场景里定好位置），只改 value：
	# 0..65 整格像素、从下往上，不再每帧改 size/position（那会抖）
	var p: float = clampf(Game.getAmmoPercent(weaponKey), 0.0, 1.0)
	var px := roundf(p * ammoBar.max_value)
	if px > 0.0:
		px = maxf(px, 1.0)              # H5: max(65 * pct, 1)
	ammoBar.value = px
	if p < 1.0:
		refillBtn.visible = true
		ammoPrice.text = Game.formatMoney(int(Settings.AMMO_PRICES.get(weaponKey, 0)))
	else:
		ammoPrice.text = "MAX"


# ---------- 购买/升级（对应 H5 weaponUpgrade 回调） ----------
func onBuyPressed() -> void:
	Audio.playButtonDown()
	var level: int = Game.getWeaponLevel(weaponKey)
	if level >= 5:
		return
	var price: int = int(Settings.PRICES[weaponKey][level + 1])
	if Game.spend(price):
		if level < 0:
			Game.setWeaponLevel(weaponKey, 0)
			Game.setWeaponAmmo(weaponKey, int(Settings.AMMO_LIMITS.get(weaponKey, 0)))
		else:
			Game.setWeaponLevel(weaponKey, level + 1)
		Game.save()
		Audio.playSfx("buy.mp3")
		refresh()
		FlashFx.flash(icon)
		if weaponLevel > 0:
			FlashFx.flash(pips[weaponLevel - 1])
		purchased.emit(weaponKey, false)
	else:
		Audio.playSfx("not_available.mp3")
		FlashFx.flash(priceLabel)
		failed.emit(weaponKey, false)


# ---------- 补弹（对应 H5 ammoBuy 回调） ----------
func onRefillPressed() -> void:
	Audio.playButtonDown()
	var ammo: int = Game.getWeaponAmmo(weaponKey)
	var limit: int = int(Settings.AMMO_LIMITS.get(weaponKey, 0))
	if ammo >= limit:
		return
	var price: int = int(Settings.AMMO_PRICES.get(weaponKey, 0))
	if Game.spend(price):
		Game.setWeaponAmmo(weaponKey, mini(limit, ammo + int(Settings.AMMO_AMOUNT.get(weaponKey, 0))))
		Game.save()
		Audio.playSfx("buy.mp3")
		refreshAmmo()
		FlashFx.flash(ammoBar)
	
		purchased.emit(weaponKey, true)
	else:
		Audio.playSfx("not_available.mp3")
		FlashFx.flash(ammoPrice)
		failed.emit(weaponKey, true)


func onClosePressed() -> void:
	Audio.playButtonDown()
	visible = false
