extends EnemyState
## Idle —— 待机/巡视（H5 StateIdle + patrol 的基础版）
##   行为：原地缓慢巡视炮塔（每 sweep_interval 秒换一个朝向），
##         看见玩家 → GoToPlayer；听到声音 → GoToSound。
## 复杂功能（沿路点巡逻移动、警戒链、自动瞄准辅助等）后续再加到本状态里。

@export var sweep_interval: float = 2.0    # 每个巡视朝向保持的时长（秒）
@export var sweep_step_deg: float = 90.0   # 每次巡视转过的角度（H5 patrol 每 90°）

var _target_angle: float = 0.0
var _sweep_timer: float = 0.0


func enter(_msg: Dictionary = {}) -> void:
	var e := enemy()
	if e != null:
		_target_angle = e.get_turret_rotation()
	_sweep_timer = sweep_interval
	stop_moving()
	fire(false)


func physics_update(delta: float) -> void:
	var e := enemy()
	if e == null:
		return
	# 看见玩家 → 进入追击
	if can_see_player():
		transition_to("GoToPlayer")
		return
	# 巡视：计时到点就换一个朝向，炮塔平滑转过去
	_sweep_timer -= delta
	if _sweep_timer <= 0.0:
		_sweep_timer = sweep_interval
		_target_angle += deg_to_rad(sweep_step_deg)
	aim_at(_target_angle, delta)


func exit() -> void:
	fire(false)
