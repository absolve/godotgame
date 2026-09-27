class_name ATBonus
extends Area2D
## Bonus —— 奖励拾取物（金币 / 医疗包 / 冻结 / 炸弹 / 弹药）
## 对应原项目 window.AT.bonus（H5 L20949~L21029 / L23813~L23818）
##
## 一个场景 + AnimatedSprite2D 多动画区分类型（动画名 = ATBonusTypes.anim_name(kind, weapon_key)），
## 想给某个奖励加帧动画（比如金币转圈）直接在 bonus_frames.tres 里加帧即可，本脚本不用改。
##
## 行为照 H5：
##   - **不参与物理**：坐标自己积分（所以会穿墙、也不跟子弹碰撞），挂在 Level 的 BonusLayer（坦克底下）
##   - **Area2D 负责"玩家靠近"**：玩家进入 attract_radius → 开始磁吸；离开 → 停下
##   - 拾取半径 pickup_radius；**敌人全清后**吸附半径变成 vacuum_radius（H5: 2000px 全场吸金币）
##   - 寿命 life 秒，最后 FADE_TIME 秒淡出；金币掉落时原地弹一下（随机初速 + 阻尼）
##
## 本脚本只做"视觉 + 磁吸 + 拾取判定"，拾取效果（加血/加弹药/冻结/算钱/爆炸）全部由 Level 处理：
##   picked_up(bonus) → Level 结算；expired(bonus) → Level 处理炸弹自爆（以后要做对象池也接这里）

signal picked_up(bonus: ATBonus)
signal expired(bonus: ATBonus)

## 玩家进入这个半径 → 开始被吸引（同步到 Shape 的圆半径）
@export var attract_radius: float = 60.0
## 到这个距离 → 拾取（H5: 900 = 30²）
@export var pickup_radius: float = 30.0
## 吸引速度 px/s（H5: 300）
@export var attract_speed: float = 300.0
## 存活时间（秒；H5: 9833 + 833×rand，这里固定 10s，炸弹由数据表覆盖成 1s）
@export var life: float = 10.0
## 敌人全清后的吸附半径（H5: 4e6 = 2000px）
@export var vacuum_radius: float = 2000.0

var kind: int = ATBonusTypes.Kind.COIN
var weapon_key: String = ""
var amount: int = 0

var _level: Node = null
var _near: bool = false          # Area2D 报告的"玩家在吸附范围内"
var _attracted: bool = false
var _t: float = 0.0
var _vel: Vector2 = Vector2.ZERO

@onready var _anim: AnimatedSprite2D = $Anim
@onready var _fire: Sprite2D = $Fire
@onready var _shape: CollisionShape2D = $Shape


func _ready() -> void:
	# 只感知玩家：自己不占层（没有东西需要探测拾取物）
	#collision_layer = 0
	collision_mask = Constants.layer_mask([Constants.Layer.PLAYER])
	monitorable = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# 每个实例一份 Shape（避免多实例共享场景子资源）
	#if _shape.shape != null:
		#_shape.shape = (_shape.shape as CircleShape2D).duplicate()
	_t = life
	#set_physics_process(false)     # setup() 之前不跑逻辑


## 由 Level 在 add_child 之后调用（@onready 已就绪）：设定类型/关卡引用 + 掉落表现
func setup(kind_: int, level_: Node, weapon_key_: String = "", amount_: int = 0) -> void:
	kind = kind_
	_level = level_
	weapon_key = weapon_key_
	amount = amount_
	_near = false
	_attracted = false
	_t = ATBonusTypes.life_of(kind, life)
	_apply_radius()
	_apply_look()
	#set_physics_process(true)


# ============================================================
# 表现
# ============================================================
func _apply_radius() -> void:
	if _shape != null and _shape.shape is CircleShape2D:
		(_shape.shape as CircleShape2D).radius = maxf(attract_radius, pickup_radius)


func _apply_look() -> void:
	if _anim != null:
		_anim.play(ATBonusTypes.anim_name(kind, weapon_key))
	if _fire != null:
		_fire.visible = kind == ATBonusTypes.Kind.BOMB
	if kind == ATBonusTypes.Kind.COIN:
		# H5：金币随机大小/朝向 + 随机初速（掉一堆时才会散开）
		var s := 1.2 + 0.7 * randf()
		scale = Vector2(s, s)
		rotation = randf() * TAU
		_vel = Vector2(randf_range(-300.0, 300.0), randf_range(-300.0, 300.0))
	else:
		scale = Vector2.ONE
		rotation = 0.0
		_vel = Vector2.ZERO


# ============================================================
# 每帧：寿命 → 吸附 → 拾取
# ============================================================
func _physics_process(delta: float) -> void:
	_t -= delta
	if _t <= 0.0:
		expired.emit(self)
		queue_free()
		return
	modulate.a = clampf(_t / ATBonusTypes.FADE_TIME, 0.0, 1.0)
	if kind == ATBonusTypes.Kind.BOMB and _fire != null:
		# 炸弹引线火花：每帧随机抖动（H5 同）
		_fire.rotation = randf() * TAU
		_fire.scale = Vector2.ONE * (0.5 + randf() * 0.5)
		_fire.modulate.a = 0.5 + 0.5 * randf()

	var p := _player()
	if p == null:
		return
	var to_player := p.global_position - global_position
	var dist := to_player.length()
	if dist <= maxf(pickup_radius, 1.0):
		picked_up.emit(self)
		queue_free()
		return
	if _near or _in_vacuum(dist):
		# 磁吸：直接给速度（不是加速度），H5 同
		_attracted = true
		_vel = to_player.normalized() * attract_speed
	elif _attracted:
		_attracted = false        # 玩家跑出范围 → 停住，不再追
		_vel = Vector2.ZERO
	elif _vel != Vector2.ZERO:
		_vel *= 0.75              # 掉落散开的初速快速衰减（视觉上"弹一下"）
	global_position += _vel * delta


func _on_body_entered(body: Node) -> void:
	if body == _player():
		_near = true


func _on_body_exited(body: Node) -> void:
	if body == _player():
		_near = false


# ============================================================
# 环境查询
# ============================================================
func _player() -> Node2D:
	if _level == null or not is_instance_valid(_level):
		return null
	var p = _level.get("player")
	if p is Node2D and is_instance_valid(p) and bool(p.get("alive")):
		return p
	return null


## 敌人全清 → 全场吸附（H5: enemiesAlive === 0 时吸附半径变 4e6 = 2000px）
func _in_vacuum(dist: float) -> bool:
	if _level == null or not is_instance_valid(_level):
		return false
	return int(_level.get("enemies_alive")) == 0 and dist <= vacuum_radius
