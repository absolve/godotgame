extends TextureButton
## WeaponSlot — 关卡 HUD 武器槽组件（对应 H5 gui.Weapon）
## 每个实例一种武器：@export weapon_key 决定图标（normal 与 *_active 两帧）。
## refresh(owned, active, ammo_pct) 驱动视觉：
##   - 未拥有：半透明 + 禁用；拥有且当前武器：切 *_active 高亮帧
##   - 有限弹药武器在右缘显示细弹药条（底部锚定，高度=31*pct）

const DIR_HUD := "res://sprites/game/hud/"
const AMMO_ANCHOR := Vector2(51, 37)  # 弹药条右下角（H5）
const AMMO_SIZE := Vector2(7, 31)

@export var weaponKey := "minigun"

@onready var bar: TextureRect = $AmmoBar

var base: Texture2D = null
var activeTexture: Texture2D = null


func _ready() -> void:
	base = tex(DIR_HUD + weaponKey + ".png.tres")
	activeTexture = tex(DIR_HUD + weaponKey + "_active.png.tres")
	if activeTexture == null:
		activeTexture = base  # 部分武器(如 mines)没有单独 active 帧
	refresh(false, false, -1.0)


func refresh(owned: bool, active: bool, ammoPct: float) -> void:
	disabled = not owned
	modulate.a = 1.0 if owned else 0.5

	var tex := activeTexture if (owned and active) else base
	if tex != null and texture_normal != tex:
		texture_normal = tex
		texture_hover = tex
		texture_pressed = tex

	if ammoPct < 0.0 or base == null:
		bar.visible = false
	else:
		bar.visible = true
		var h := AMMO_SIZE.y * clampf(ammoPct, 0.0, 1.0)
		bar.size = Vector2(AMMO_SIZE.x, maxf(h, 1.0) if h > 0.0 else 0.0)
		bar.position = Vector2(AMMO_ANCHOR.x - AMMO_SIZE.x, AMMO_ANCHOR.y - bar.size.y)


static func tex(path: String) -> Texture2D:
	return load(path) if ResourceLoader.exists(path) else null
