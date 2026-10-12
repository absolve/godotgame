extends EnemyState
## GoToPlayer —— 追击并射击玩家
##   行为：走 A* 寻路绕开墙/障碍靠近玩家，**进到自己射程(shootRange)就停下**，不贴脸；
##         炮塔瞄准玩家；对准且视线通畅时开火。
##         看不见玩家超过 lose_sight_time 秒 → 回到 Idle（记忆最后位置）。
## 依据 H5 FollowPlayer（L20708~20710）：
##   只有"看不见玩家"或 `distanceToPlayer > shootRange` 时才继续推进，否则原地不动。
## 各类型敌人的 shootRange 在 scenes/enemies/*.tscn 里配：
##   机枪 100 / 霰弹 125 / 加农 150 / 激光·火箭·电磁 175 / 喷火 200 / 自爆 50。

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
	var canSee := canSeePlayer()
	# 看得见才更新"最后已知位置"：看不见时朝上次看见的地方走（H5 用 target 记录玩家瓦片）
	if canSee:
		lastKnown = p.global_position

	# 看不见玩家：累计到上限就放弃追击（H5 FollowPlayer: forgetTime >= 4 → Idle）。
	# 被惊动（alerted，刚挨打/被同伴喊话）期间算"知道玩家在哪"，不掉计数，
	# 所以挨了打一定会朝你追过来（H5 里被击中会直接切 GoToPlayer 且 10s 才放弃）。
	if canSee or e.alerted:
		noSightTime = 0.0
	else:
		noSightTime += delta
		if noSightTime > loseSightTime:
			transitionTo("Idle")
			return

	# 移动（H5 FollowPlayer L20710）：只有"看不见玩家"或"距离 > 自己的射程"才继续推进，
	# 进了射程就停下 —— 这样敌人不会一路紧贴玩家（原来的 60px 硬阈值就是贴脸的元凶）。
	var dist := e.global_position.distance_to(p.global_position)
	if e.moveSpeed > 0.0 and ((not canSee) or dist > e.shootRange):
		navigateTo(lastKnown if not canSee else p.global_position)
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
