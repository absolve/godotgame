extends ATWeapon
## Shock 武器脚本（场景继承 weapon.tscn 基类；覆写 set_firing/_physics_process 为持续武器）
## 对应原项目 window.AT.Shock（awesome_tanks_2.js L21715~21746，extends Laser）
##
## 无子弹，武器内置（shock.tscn）：
##   Ray     (RayCast2D) —— 从炮口沿瞄准方向找最近命中点(墙/障碍/敌人…)，
##                          主光束画到该点；与 H5 一致，谁最近挡谁。
##   Chain   (Area2D + CircleShape) —— 放在主光束末端(首个导电体)身上，检测其周围
##                          是否还有敌人/油桶（半径 = chain_radius，H5: 4e4 → 200px）；
##   Beam / Arc1..Arc3 (Line2D) —— 主光束 + 最多 3 条链电弧。帧图按段长取
##                          short/medium/long，两帧贴图 30fps 交替 + alpha 抖动 = 闪电动画。
##
## 行为（H5 同款）：
##   - 持续武器：按住期间每物理帧结算一次；弹药按 drain_per_sec 消耗。
##   - 主射线命中的最近体若是“可导电者”（team!=我方 的敌人坦克/炮塔/生成器，
##     或无 team 的油桶，见 conducts_current），则受 damage 并成为链起点 a；
##     命中的是墙/crate/砖（不导电）→ 只画主光束到该点，不造成伤害也不链（绝缘）。
##   - 从 a 起在 Chain 范围内反复找“离 a 最近、未电过、a→它 无遮挡”的目标放电，
##     上限 chain_max_hops（H5 targets.length<4 → 首目标 + 最多 3 跳 = 至多 4 个）。
##   - 主光束 muzzle→a；每条链电弧 a→目标，电弧各自独立动画。

class_name ATWeaponShock

const TEX_SHORT_0: Texture2D = preload("res://sprites/atlas/game_242.png")
const TEX_SHORT_1: Texture2D = preload("res://sprites/atlas/game_243.png")
const TEX_MED_0: Texture2D = preload("res://sprites/atlas/game_244.png")
const TEX_MED_1: Texture2D = preload("res://sprites/atlas/game_245.png")
const TEX_LONG_0: Texture2D = preload("res://sprites/atlas/game_248.png")
const TEX_LONG_1: Texture2D = preload("res://sprites/atlas/game_249.png")

@export var beamRange := 900.0       # 无命中时的最大射线范围
@export var chainRadius := 200.0     # 链检测半径（H5: distanceSq < 4e4 → 200px）
@export var chainMaxHops := 3       # 首目标外最多再电几个（H5 targets.length<4）
@export var drainPerSec := 60.0     # 持续耗弹（H5 每物理帧 1 发 ≈ 60/s）

@onready var ray: RayCast2D = $Ray
@onready var chain: Area2D = $Chain
@onready var shape: CollisionShape2D = $Chain/Shape
@onready var lines: Array[Line2D] = [$Beam, $Arc1, $Arc2, $Arc3]

var wasFiring := false
var flicker := 0.0


func _ready() -> void:
	super._ready()
	id = "shock"
	canFire = false
	for ln in lines:
		ln.visible = false
	# 链检测形状独立副本：避免多实例共享场景 sub_resource
	if shape.shape != null:
		shape.shape = (shape.shape as CircleShape2D).duplicate()
	chain.monitoring = false


func setFiring(on: bool) -> void:
	if on:
		if ammo <= 0:
			outOfAmmo.emit(self)
			return
		canFire = true
	else:
		canFire = false


# ============================================================
# 单帧放电：主射线命中 + 链目标搜索 + 伤害 + 绘制
# ============================================================
func dischargeFrame() -> void:
	var aim := getAimAngle()
	#var dir := Vector2.from_angle(aim)
	var muzzle: Vector2 = tank.getTurretPosition(muzzleOffset) \
		if tank.has_method("getTurretPosition") else global_position

	ray.global_position = muzzle
	ray.rotation = aim
	ray.force_raycast_update()

	if not ray.is_colliding():
		# H5：射线未命中(空场/超范围)则无光束、无放电
		hideLines()
		return
	var end: Vector2 = ray.get_collision_point()
	var first: Node = ray.get_collider()

	# 主光束画到最近命中点（墙/障碍/敌人 都挡光）
	var mainLen := clampf((end - muzzle).length(), 1.0, beamRange)
	showLine(0, muzzle, end, mainLen)

	# 主射线命中：H5 只要命中体有 onBulletHit 就先电一次——
	# 敌人坦克/炮塔/生成器、以及可破坏障碍(crate/砖/油桶)都会受伤；
	# 只有“导电体”(敌人/油桶 conducts_current) 才进一步作为链起点 a。
	var a: Node2D = null
	if first != null and first != tank and first is Node2D:
		if damageable(first):
			doHit(first)
			if chainable(first):
				a = first as Node2D

	# 链检测区放到 a 身上（主激光“末端”）
	if a != null:
		var circle := shape.shape as CircleShape2D
		if circle != null:
			circle.radius = chainRadius
		chain.global_position = a.global_position
		chain.rotation = 0.0
		chain.monitoring = true

	# 从 a 找附近可传导目标放电（最近优先 + 视线校验），每跳画一条电弧
	var hopsUsed := 0
	if a != null:
		var targetIds: Array = [a.get_instance_id()]
		for hop in chainMaxHops:
			if hopsUsed + 1 >= lines.size():
				break
			var h := findNext(a, targetIds)
			if h == null:
				break
			doHit(h)
			targetIds.append(h.get_instance_id())
			showLine(hopsUsed + 1, a.global_position, h.global_position, \
				clampf((h.global_position - a.global_position).length(), 1.0, beamRange))
			hopsUsed += 1

	# 隐藏未用到的电弧（主光束 index0 保持）
	for i in range(hopsUsed + 1, lines.size()):
		lines[i].visible = false


## 在链检测区内找“距 a 最近、未被电过、a→它 无遮挡”的可导电目标
func findNext(a: Node2D, excludeIds: Array) -> Node2D:
	var best: Node2D = null
	var bestD := INF
	for body in chain.get_overlapping_bodies():
		if body == null or body == a or body == tank:
			continue
		if not body is Node2D:
			continue
		if excludeIds.has(body.get_instance_id()):
			continue
		if not chainable(body):
			continue
		var d := (body.global_position - a.global_position).length_squared()
		if d > chainRadius * chainRadius:
			continue
		if not losClear(a, body):
			continue
		if d < bestD:
			bestD = d
			best = body
	return best


## a→target 视线：射线首撞必须是该目标（墙/障碍挡在中间则不可链）
func losClear(a: Node2D, target: Node2D) -> bool:
	var space := a.get_world_2d().direct_space_state
	var q := PhysicsRayQueryParameters2D.new()
	q.from = a.global_position
	q.to = target.global_position
	q.collision_mask = Constants.layerMask([
		Constants.Layer.WALL, Constants.Layer.OBSTACLE,
		Constants.Layer.PLAYER, Constants.Layer.ENEMY, Constants.Layer.ENEMY_SPAWNER,
	])
	# 排除自己所在物理体，避免射线起点自撞
	var exclude := []
	if a is CollisionObject2D:
		exclude.append((a as CollisionObject2D).get_rid())
	if tank != null and tank is CollisionObject2D:
		exclude.append((tank as CollisionObject2D).get_rid())
	q.exclude = exclude
	var hit := space.intersect_ray(q)
	return hit and hit.get("collider") == target


## 可被主射线电伤：有 on_bullet_hit，且 (有 team → team!=我方) 或 (无 team → 可破坏障碍，
## 如 crate/砖/油桶，任意一方都可电坏)。墙(StaticBody 无 on_bullet_hit)不受伤。
func damageable(body: Node) -> bool:
	if body == null or not is_instance_valid(body):
		return false
	if not body.has_method("onBulletHit"):
		return false
	if "team" in body:
		return int(body.team) != team
	return true   # 无 team 的障碍物（crate/砖/油桶）默认可破坏


## 可被电链跳转：H5 findClosestEnemy 只从敌人(坦克/炮塔/生成器)与油桶中找 → conducts_current
## 敌人有 team 且 team!=我方；油桶无 team 但 conducts_current=true；crate/砖 不导电 → 不可链。
func chainable(body: Node) -> bool:
	if not damageable(body):
		return false
	var conducts = body.get("conductsCurrent")
	if conducts == null or not conducts:
		return false
	return true


func doHit(b: Node) -> void:
	if b == null or not is_instance_valid(b):
		return
	b.onBulletHit(damage, self, null)


# ============================================================
# 光束绘制：段长决定用哪组帧图，两帧交替 + alpha 抖动
# ============================================================
func showLine(idx: int, from: Vector2, to: Vector2, len: float) -> void:
	if idx < 0 or idx >= lines.size():
		return
	var ln := lines[idx]
	ln.global_position = from
	ln.rotation = (to - from).angle()
	ln.points = PackedVector2Array([Vector2.ZERO, Vector2(len, 0.0)])
	var texs := texturesForLength(len)
	flicker -= get_physics_process_delta_time()
	if flicker <= 0.0:
		flicker = 1.0 / 30.0
		ln.texture = texs[0] if randi() % 2 == 0 else texs[1]
	#ln.modulate = Color(1, 1, 1, 0.55 + 0.45 * randf())
	ln.visible = true
	

func texturesForLength(len: float) -> Array:
	if len > 300.0:
		return [TEX_LONG_0, TEX_LONG_1]
	if len > 100.0:
		return [TEX_MED_0, TEX_MED_1]
	return [TEX_SHORT_0, TEX_SHORT_1]


func hideLines() -> void:
	for ln in lines:
		ln.visible = false


func finishBurst() -> void:
	if wasFiring:
		Audio.stopShockLoop()
		wasFiring = false
	chain.monitoring = false
	hideLines()


func _physics_process(delta: float) -> void:
	if not canFire:
		finishBurst()
		return
	if ammo <= 0:
		outOfAmmo.emit(self)
		finishBurst()
		return
	if tank == null or not is_instance_valid(tank):
		finishBurst()
		return

	# 一次持续放电开始：只播一次 loop
	if not wasFiring:
		Audio.startShockLoop()
		wasFiring = true
	# 弹药消耗（与 laser 一致，delta 折算）
	if not hasInfiniteAmmo():
		ammo = maxi(0, ammo - int(drainPerSec * delta + 0.5))

	dischargeFrame()
	canFire = false  # 本帧信号已消耗；持续放电由坦克每帧 set_firing(true) 维持
