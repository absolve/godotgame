extends EnemyState
## GoToPlayer —— 追击并射击玩家
##   行为：保持 shoot_range 距离向前推进（走 A* 寻路绕开墙/障碍，直线可达时直冲）；
##         炮塔瞄准玩家；对准且视线通畅时开火。
##         看不见玩家超过 lose_sight_time 秒 → 回到 Idle（并保留最后位置记忆，后续可接 GoToSound）。
## 复杂功能（走位/保持距离、预判射击、自动瞄准）后续再加。

@export var keepDistance: float = 60.0     # 距离小于它就不再前进（避免贴脸）
@export var loseSightTime: float = 4.0    # 连续看不见玩家的时长上限（H5 FollowPlayer: forgetTime >= 4 放弃）
@export var fireCheckInterval: float = 0.15  # 开火判定间隔（秒），节流用

var noSightTime: float = 0.0
var fireCheckTimer: float = 0.0
var lastKnown: Vector2 = Vector2.ZERO


func enter(msg: Dictionary = {}) -> void:
	noSightTime = 0.0
	var p := player()
	if p != null:
		lastKnown = p.global_position


func physicsUpdate(delta: float) -> void:
	var e := enemy()
	if e == null:
		return
	var p := player()
	if p == null:
		transitionTo("Idle")
		return
	lastKnown = p.global_position

	# 看不见玩家：累计到上限就放弃追击（H5 FollowPlayer: forgetTime >= 4 → Idle）。
	# 被惊动（alerted，刚挨打/被同伴喊话）期间算"知道玩家在哪"，不掉计数，
	# 所以挨了打一定会朝你追过来（H5 里被击中会直接切 GoToPlayer 且 10s 才放弃）。
	if canSeePlayer() or e.alerted:
		noSightTime = 0.0
	else:
		noSightTime += delta
		if noSightTime > loseSightTime:
			transitionTo("Idle")
			return

	# 移动：贴近到 keep_distance 就停下（寻路绕开墙/障碍）
	var dist := e.global_position.distance_to(p.global_position)
	if dist > keepDistance and e.moveSpeed > 0.0:
		navigateTo(p.global_position)
	else:
		stopMoving()

	# 炮塔瞄准 + 对准且有视线时开火（H5: 角度误差 ≤ shootAngle 且 lineOfFireClear）
	var aligned := aimAtPlayer(delta)
	fireCheckTimer -= delta
	if fireCheckTimer <= 0.0:
		fireCheckTimer = fireCheckInterval
		var wantFire := aligned and lineOfSight(p.global_position) \
			and dist <= maxf(e.shootRange, e.viewDistance)
		fire(wantFire)


func exit() -> void:
	fire(false)
	stopMoving()
