class_name ATMenuCard
extends TextureButton
## ATMenuCard —— 升级界面卡片基类（属性卡 StatCard / 武器卡 UpgradeableWeapon 共用）
##
## 卡片本身就是按钮，公共部分都在这里：
##   · 按下播按键音，松开发 clicked（支持长按的子类：按住约 333ms 触发 refillHeld 且不再算点击）
##   · 整卡闪烁 flash() / 价签闪烁 flashPrice()（对应 H5 flashElement）
##
## 子类负责：
##   · cardKey() 返回自己的 key（武器 key / 属性 key）
##   · setup(key) 初始化（图标等）、refresh() 刷新内容
##   · 需要"按住补弹"的再覆写 supportsHold() / canRefill()
## 子节点（$Icon / $Price / $AmmoBar …）各自在 scenes/stat_card.tscn、scenes/weapon_card.tscn 里定义。

signal clicked(key: String)
signal refillHeld(key: String)

## 长按判定时间（H5 约 333ms）
const HOLD_TIME: float = 0.333

@onready var priceLabel: Label = $Price

var weaponLevel: int = 0
var holding: bool = false
var holdFired: bool = false
var holdLeft: float = 0.0


func _ready() -> void:
	button_down.connect(onDown)
	button_up.connect(onUp)
	if cardKey() != "":
		setup(cardKey())


## 子类覆写：这张卡对应的 key
func cardKey() -> String:
	return ""


## 子类覆写：按 key 初始化（图标、标题等）。场景里没写 key 时由菜单调用。
func setup(_key: String) -> void:
	pass


## 子类覆写：是否支持"按住补弹"
func supportsHold() -> bool:
	return false


## 子类覆写：当前状态是否允许补弹（例如未拥有或 minigun 就不允许）
func canRefill() -> bool:
	return weaponLevel >= 0


func onDown() -> void:
	Audio.playButtonDown()
	holding = true
	holdFired = false
	holdLeft = HOLD_TIME


func onUp() -> void:
	holding = false
	if not holdFired:
		clicked.emit(cardKey())


func _process(delta: float) -> void:
	if not holding or holdFired or not supportsHold():
		return
	holdLeft -= delta
	if holdLeft <= 0.0:
		holdFired = true
		if canRefill():
			refillHeld.emit(cardKey())


# ---------- 闪烁提示（对应 H5 flashElement） ----------
## 整卡闪烁：购买/升级成功
func flash() -> void:
	FlashFx.flash(self)


## 价签闪烁：钱不够
func flashPrice() -> void:
	FlashFx.flash(priceLabel)
