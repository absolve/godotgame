extends TextureButton
## WeaponSlot — 关卡 HUD 武器槽组件（对应 H5 gui.Weapon）
## 每个实例一种武器：@export weapon_key 决定图标（normal 与 *_active 两帧）。
## refresh(owned, active, ammo_pct) 驱动视觉：
##   - 未拥有：半透明 + 禁用；拥有且当前武器：切 *_active 高亮帧
##   - 有限弹药武器在右缘显示细弹药条（底部锚定，高度=31*pct）

const DIR_HUD := "res://sprites/game/hud/"
const AMMO_ANCHOR := Vector2(51, 37)  # 弹药条右下角（H5）
const AMMO_SIZE := Vector2(7, 31)

@export var weapon_key := "minigun"

@onready var _bar: TextureRect = $AmmoBar

var _base: Texture2D = null
var _active: Texture2D = null


func _ready() -> void:
	_base = _tex(DIR_HUD + weapon_key + ".png.tres")
	_active = _tex(DIR_HUD + weapon_key + "_active.png.tres")
	if _active == null:
		_active = _base  # 部分武器(如 mines)没有单独 active 帧
	refresh(false, false, -1.0)


func refresh(owned: bool, active: bool, ammo_pct: float) -> void:
	disabled = not owned
	modulate.a = 1.0 if owned else 0.5

	var tex := _active if (owned and active) else _base
	if tex != null and texture_normal != tex:
		texture_normal = tex
		texture_hover = tex
		texture_pressed = tex

	if ammo_pct < 0.0 or _base == null:
		_bar.visible = false
	else:
		_bar.visible = true
		var h := AMMO_SIZE.y * clampf(ammo_pct, 0.0, 1.0)
		_bar.size = Vector2(AMMO_SIZE.x, maxf(h, 1.0) if h > 0.0 else 0.0)
		_bar.position = Vector2(AMMO_ANCHOR.x - AMMO_SIZE.x, AMMO_ANCHOR.y - _bar.size.y)


static func _tex(path: String) -> Texture2D:
	return load(path) if ResourceLoader.exists(path) else null
