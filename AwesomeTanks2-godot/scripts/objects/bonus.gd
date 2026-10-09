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

signal pickedUp(bonus: ATBonus)
signal expired(bonus: ATBonus)

## 玩家进入这个半径 → 开始被吸引（同步到 Shape 的圆半径）
@export var attractRadius: float = 60.0
## 到这个距离 → 拾取（H5: 900 = 30²）
@export var pickupRadius: float = 30.0
## 吸引速度 px/s（H5: 300）
@export var attractSpeed: float = 300.0
## 存活时间（秒；H5: 9833 + 833×rand，这里固定 10s，炸弹由数据表覆盖成 1s）
@export var life: float = 10.0
## 敌人全清后的吸附半径（H5: 4e6 = 2000px）
@export var vacuumRadius: float = 2000.0

var kind: int = ATBonusTypes.Kind.COIN
var weaponKey: String = ""
var amount: int = 0

var weaponLevel: Node = null
var near: bool = false          # Area2D 报告的"玩家在吸附范围内"
var attracted: bool = false
var t: float = 0.0
var vel: Vector2 = Vector2.ZERO

@onready var anim: AnimatedSprite2D = $Anim
@onready var fire: Sprite2D = $Fire
@onready var shape: CollisionShape2D = $Shape


func _ready() -> void:
	# 只感知玩家：自己不占层（没有东西需要探测拾取物）
	#collision_layer = 0
	collision_mask = Constants.layerMask([Constants.Layer.PLAYER])
	monitorable = false
	body_entered.connect(onBodyEntered)
	body_exited.connect(onBodyExited)
	# 每个实例一份 Shape（避免多实例共享场景子资源）
	#if _shape.shape != null:
		#_shape.shape = (_shape.shape as CircleShape2D).duplicate()
	t = life
	#set_physics_process(false)     # setup() 之前不跑逻辑


## 由 Level 在 add_child 之后调用（@onready 已就绪）：设定类型/关卡引用 + 掉落表现
func setup(kind_: int, level_: Node, weaponKeyInput: String = "", amount_: int = 0) -> void:
	kind = kind_
	weaponLevel = level_
	weaponKey = weaponKeyInput
	amount = amount_
	near = false
	attracted = false
	t = ATBonusTypes.lifeOf(kind, life)
	applyRadius()
	applyLook()
	#set_physics_process(true)


# ============================================================
# 表现
# ============================================================
func applyRadius() -> void:
	if shape != null and shape.shape is CircleShape2D:
		(shape.shape as CircleShape2D).radius = maxf(attractRadius, pickupRadius)


func applyLook() -> void:
	if anim != null:
		anim.play(ATBonusTypes.animName(kind, weaponKey))
	if fire != null:
		fire.visible = kind == ATBonusTypes.Kind.BOMB
	if kind == ATBonusTypes.Kind.COIN:
		# H5：金币随机大小/朝向 + 随机初速（掉一堆时才会散开）
		var s := 1.2 + 0.7 * randf()
		scale = Vector2(s, s)
		rotation = randf() * TAU
		vel = Vector2(randf_range(-300.0, 300.0), randf_range(-300.0, 300.0))
	else:
		scale = Vector2.ONE
		rotation = 0.0
		vel = Vector2.ZERO


func onBodyEntered(body: Node) -> void:
	if body == player():
		near = true


func onBodyExited(body: Node) -> void:
	if body == player():
		near = false


# ============================================================
# 环境查询
# ============================================================
func player() -> Node2D:
	return Game.getLevelPlayer(weaponLevel)


## 敌人全清 → 全场吸附（H5: enemiesAlive === 0 时吸附半径变 4e6 = 2000px）
func inVacuum(dist: float) -> bool:
	if weaponLevel == null or not is_instance_valid(weaponLevel):
		return false
	return int(weaponLevel.get("enemiesAlive")) == 0 and dist <= vacuumRadius


# ============================================================
# 每帧：寿命 → 吸附 → 拾取
# ============================================================
func _physics_process(delta: float) -> void:
	t -= delta
	if t <= 0.0:
		expired.emit(self)
		queue_free()
		return
	modulate.a = clampf(t / ATBonusTypes.FADE_TIME, 0.0, 1.0)
	if kind == ATBonusTypes.Kind.BOMB and fire != null:
		# 炸弹引线火花：每帧随机抖动（H5 同）
		fire.rotation = randf() * TAU
		fire.scale = Vector2.ONE * (0.5 + randf() * 0.5)
		fire.modulate.a = 0.5 + 0.5 * randf()

	var p := player()
	if p == null:
		return
	var toPlayer := p.global_position - global_position
	var dist := toPlayer.length()
	if dist <= maxf(pickupRadius, 1.0):
		pickedUp.emit(self)
		queue_free()
		return
	if near or inVacuum(dist):
		# 磁吸：直接给速度（不是加速度），H5 同
		attracted = true
		vel = toPlayer.normalized() * attractSpeed
	elif attracted:
		attracted = false        # 玩家跑出范围 → 停住，不再追
		vel = Vector2.ZERO
	elif vel != Vector2.ZERO:
		vel *= 0.75              # 掉落散开的初速快速衰减（视觉上"弹一下"）
	global_position += vel * delta
