extends EnemyState
## GoToPlayer —— 追击并射击玩家
##   行为：保持 shoot_range 距离向前推进（走 A* 寻路绕开墙/障碍，直线可达时直冲）；
##         炮塔瞄准玩家；对准且视线通畅时开火。
##         看不见玩家超过 lose_sight_time 秒 → 回到 Idle（并保留最后位置记忆，后续可接 GoToSound）。
## 复杂功能（走位/保持距离、预判射击、自动瞄准）后续再加。

@export var keep_distance: float = 60.0     # 距离小于它就不再前进（避免贴脸）
@export var lose_sight_time: float = 4.0    # 连续看不见玩家的时长上限（H5 FollowPlayer: forgetTime >= 4 放弃）
@export var fire_check_interval: float = 0.15  # 开火判定间隔（秒），节流用

var _no_sight_time: float = 0.0
var _fire_check_timer: float = 0.0
var _last_known: Vector2 = Vector2.ZERO


func enter(_msg: Dictionary = {}) -> void:
	_no_sight_time = 0.0
	var p := player()
	if p != null:
		_last_known = p.global_position


func physics_update(delta: float) -> void:
	var e := enemy()
	if e == null:
		return
	var p := player()
	if p == null:
		transition_to("Idle")
		return
	_last_known = p.global_position

	# 看不见玩家：累计到上限就放弃追击（H5 FollowPlayer: forgetTime >= 4 → Idle）。
	# 被惊动（alerted，刚挨打/被同伴喊话）期间算"知道玩家在哪"，不掉计数，
	# 所以挨了打一定会朝你追过来（H5 里被击中会直接切 GoToPlayer 且 10s 才放弃）。
	if can_see_player() or e.alerted:
		_no_sight_time = 0.0
	else:
		_no_sight_time += delta
		if _no_sight_time > lose_sight_time:
			transition_to("Idle")
			return

	# 移动：贴近到 keep_distance 就停下（寻路绕开墙/障碍）
	var dist := e.global_position.distance_to(p.global_position)
	if dist > keep_distance and e.move_speed > 0.0:
		navigate_to(p.global_position)
	else:
		stop_moving()

	# 炮塔瞄准 + 对准且有视线时开火（H5: 角度误差 ≤ shootAngle 且 lineOfFireClear）
	var aligned := aim_at_player(delta)
	_fire_check_timer -= delta
	if _fire_check_timer <= 0.0:
		_fire_check_timer = fire_check_interval
		var want_fire := aligned and line_of_sight(p.global_position) \
			and dist <= maxf(e.shoot_range, e.view_distance)
		fire(want_fire)


func exit() -> void:
	fire(false)
	stop_moving()
