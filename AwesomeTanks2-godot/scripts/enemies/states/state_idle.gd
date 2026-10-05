extends EnemyState
## Idle —— 待机/巡视（H5 StateIdle + patrol 的基础版）
##   行为：原地缓慢巡视炮塔（每 sweep_interval 秒换一个朝向），
##         看见玩家 → GoToPlayer；听到声音 → GoToSound。
## 复杂功能（沿路点巡逻移动、警戒链、自动瞄准辅助等）后续再加到本状态里。

@export var sweepInterval: float = 2.0    # 每个巡视朝向保持的时长（秒）
@export var sweepStepDeg: float = 90.0   # 每次巡视转过的角度（H5 patrol 每 90°）

var targetAngle: float = 0.0
var sweepTimer: float = 0.0


func enter(msg: Dictionary = {}) -> void:
	var e := enemy()
	if e != null:
		targetAngle = e.getTurretRotation()
	sweepTimer = sweepInterval
	stopMoving()
	fire(false)


func physicsUpdate(delta: float) -> void:
	var e := enemy()
	if e == null:
		return
	# 看见玩家 → 进入追击
	if canSeePlayer():
		transitionTo("GoToPlayer")
		return
	# 巡视：计时到点就换一个朝向，炮塔平滑转过去
	sweepTimer -= delta
	if sweepTimer <= 0.0:
		sweepTimer = sweepInterval
		targetAngle += deg_to_rad(sweepStepDeg)
	aimAt(targetAngle, delta)


func exit() -> void:
	fire(false)
