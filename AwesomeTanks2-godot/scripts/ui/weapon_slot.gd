extends TextureButton
## WeaponSlot — 关卡 HUD 武器槽组件（对应 H5 gui.Weapon）
## 每个实例一种武器：@export weapon_key 决定图标（normal 与 *_active 两帧）。
## refresh(owned, active, ammo_pct) 驱动视觉：
##   - 未拥有：半透明 + 禁用；拥有且当前武器：切 *_active 高亮帧
##   - 有限弹药武器在右缘显示细弹药条：AmmoBar 是固定 7×31 的 TextureProgressBar，
##     从下往上填充（H5 的 bar_ammo_small：锚点在右下、高度 = 31×百分比）。
##
## 为什么用 TextureProgressBar：以前是 TextureRect + 每帧改 size/position 去"撑高"，
## 位置和高度都是小数，配合项目里的最近邻过滤（project.godot:
## rendering/textures/canvas_textures/default_texture_filter=0）会让条子顶边闪烁；
## 现在控件矩形固定不动，只改 value（0..31，整数步进 = 正好一格像素），
## 既不会抖，也保持原来的像素观感。

const DIR_HUD := "res://sprites/game/hud/"

@export var weaponKey := "minigun"

@onready var bar: TextureProgressBar = $AmmoBar

var base: Texture2D = null
var activeTexture: Texture2D = null


func _ready() -> void:
	base = Game.loadTextureOrNull(DIR_HUD + weaponKey + ".png.tres")
	activeTexture = Game.loadTextureOrNull(DIR_HUD + weaponKey + "_active.png.tres")
	if activeTexture == null:
		activeTexture = base  # 部分武器(如 mines)没有单独 active 帧
	refresh(false, false, -1.0)


func refresh(owned: bool, active: bool, ammoPct: float) -> void:
	disabled = not owned
	modulate.a = 1.0 if owned else 0.5

	# 当前该用哪一帧（拥有的当前武器用 *_active 高亮帧）
	var frame: Texture2D = activeTexture if (owned and active) else base
	if frame != null and texture_normal != frame:
		texture_normal = frame
		texture_hover = frame
		texture_pressed = frame

	if ammoPct < 0.0 or base == null:
		bar.visible = false
	else:
		bar.visible = true
		# 条子图案正好 31 像素高：按整格像素取整，避免小数边界在最近邻过滤下闪；
		# 有弹药时至少给 1 像素（对应旧写法里的 max(h, 1.0)）
		var px := roundf(clampf(ammoPct, 0.0, 1.0) * bar.max_value)
		if px > 0.0:
			px = maxf(px, 1.0)
		bar.value = px
