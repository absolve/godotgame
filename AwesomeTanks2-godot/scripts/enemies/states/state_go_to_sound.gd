extends EnemyState
## GoToSound —— 调查声音
##   行为：朝声音点寻路移动（绕开墙/障碍），到达附近或超时后回到 Idle；途中看见玩家 → GoToPlayer。
## 复杂功能（警戒链广播、声音记忆）后续再加。

@export var arrive_distance: float = 40.0   # 到达判定距离（px）
@export var timeout: float = 6.0            # 最长时间（秒），超过则放弃

var _target: Vector2 = Vector2.ZERO


func enter(msg: Dictionary = {}) -> void:
	_target = msg.get("pos", Vector2.ZERO)
	fire(false)


func physics_update(delta: float) -> void:
	var e := enemy()
	if e == null:
		return
	if can_see_player():
		transition_to("GoToPlayer")
		return
	if state_time > timeout or e.global_position.distance_to(_target) <= arrive_distance:
		transition_to("Idle")
		return
	navigate_to(_target)
	# 炮塔朝移动方向，边走边找目标
	aim_at((_target - e.global_position).angle(), delta)


func exit() -> void:
	stop_moving()
