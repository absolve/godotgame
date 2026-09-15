extends ATBullet
## FlameBullet —— 火焰弹（对应 H5 Flamethrower 的子弹表现，awesome_tanks_2.js L21748~21753）
##
## H5 的火焰"不是动画帧序列"，而是每一发火焰团**逐帧随机**变化：
##   alpha  = clamp(10 × 已存活比例, 0, 1) − 0.2×随机   （出生前 10% 寿命内渐显）
##   scale  = 0.2 + min(0.8, 已存活比例 / 0.15)          （前 15% 寿命从 0.2 长到 1.0）
##   rotation / 贴图（flame_0/flame_1）= 每帧随机
##   命中任何东西：喷 3 个烟（不是火花）后消失；寿命耗尽：消散粒子
## 注意：本节点自身的 rotation 表示飞行方向（基类用它算位移），
##       随机旋转施加在子精灵 Sprite 上，保证飞向不变。

class_name ATBulletFlame

const TEX_FLAME: Array[Texture2D] = [
	preload("res://sprites/game/projectiles/flame_0.png.tres"),
	preload("res://sprites/game/projectiles/flame_1.png.tres"),
]

## H5：scale 在前 15% 寿命内由 0.2 长到 1.0
const GROW_PORTION := 0.15
const GROW_FROM := 0.2
## H5：alpha 在前 10% 寿命内由 0 涨到 1（系数 10 = 1/0.1）
const ALPHA_RATE := 10.0
const ALPHA_JITTER := 0.2

@onready var _flame: Sprite2D = $Sprite

var _life_max: float = 1.0


func _ready() -> void:
	super._ready()
	_life_max = maxf(life, 0.001)
	_update_flame()   # 出生第一帧就是"小而透明"（H5 从 0.2 倍长起）


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_flame()


## 逐帧随机表现：渐显 + 长大 + 随机取图/旋转（H5 L21748~21753）
func _update_flame() -> void:
	if _flame == null or not is_inside_tree():
		return
	var elapsed := 1.0 - clampf(life / _life_max, 0.0, 1.0)
	_flame.scale = Vector2.ONE * (GROW_FROM + minf(1.0 - GROW_FROM, elapsed / GROW_PORTION))
	_flame.modulate.a = maxf(0.0, clampf(ALPHA_RATE * elapsed, 0.0, 1.0) - ALPHA_JITTER * randf())
	_flame.rotation = randf() * TAU
	_flame.texture = TEX_FLAME[randi() % TEX_FLAME.size()]


## 命中任何东西：H5 火焰撞墙/命中目标都是喷 3 个烟（不爆火花、不播命中音）
func _on_contact_effects() -> void:
	if not is_inside_tree():
		return
	Fx.smoke(global_position, get_parent())
