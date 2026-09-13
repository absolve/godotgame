class_name EnemyState
extends State
## EnemyState —— 敌人状态基类（所有具体敌人状态都 extends 本类）
##
## 提供状态内常用的判定/动作工具，具体状态只写"这个状态做什么"：
##   enemy()           —— 取宿主敌人（ATEnemy）
##   player()          —— 取玩家（可能为空）
##   player_distance() —— 到玩家距离（px，玩家无效时返回 INF）
##   can_see_player()  —— 是否看见玩家（H5 searchForPlayer 简化版：近距/视野角/距离/视线）
##   aim_at_player()   —— 炮塔转向玩家，返回是否已对准
##   aim_at()          —— 炮塔转向指定角度
##   fire(on)          —— 开火/停火（武器内部按 rate 节流）
##   navigate_to()     —— 朝目标点寻路移动（绕开墙/障碍）
##   move_towards()    —— 朝目标点直线移动（速度由敌人 move_speed 决定）
##   stop_moving()     —— 停止移动
##
## 注意：actor 由 StateMachine 在 _ready 注入，故不要在自己的 _ready 里访问它，
## 需要时用 enemy() 现取（enter/physics_update 阶段一定可用）。

## 宿主敌人
func enemy() -> ATEnemy:
	return actor as ATEnemy


func player() -> Node2D:
	var e := enemy()
	if e == null or e.level == null:
		return null
	var p = e.level.get("player")
	if p is Node2D and is_instance_valid(p):
		return p
	return null


func player_distance() -> float:
	var p := player()
	var e := enemy()
	if p == null or e == null:
		return INF
	return e.global_position.distance_to(p.global_position)


## 看见玩家：H5 Tank.searchForPlayer 的简化移植
##   距离 < 60px 直接算看见；超过视野距离/超出视野角/有遮挡则看不见
func can_see_player() -> bool:
	var e := enemy()
	var p := player()
	if e == null or p == null:
		return false
	var d := e.global_position.distance_to(p.global_position)
	if d < 60.0:
		return true
	if d > e.view_distance:
		return false
	var aim := (p.global_position - e.global_position).angle()
	var facing := e.get_turret_rotation()
	if absf(wrapf(aim - facing, -PI, PI)) > maxf(e.view_angle, 0.1):
		return false
	return line_of_sight(p.global_position)


## 到指定点之间是否没有墙/障碍遮挡
func line_of_sight(to: Vector2) -> bool:
	var e := enemy()
	if e == null:
		return false
	var space := e.get_world_2d().direct_space_state
	if space == null:
		return true
	var q := PhysicsRayQueryParameters2D.new()
	q.from = e.global_position
	q.to = to
	q.collision_mask = Constants.layer_mask([Constants.Layer.WALL, Constants.Layer.OBSTACLE])
	var exclude: Array[RID] = []
	if e is CollisionObject2D:
		exclude.append((e as CollisionObject2D).get_rid())
	q.exclude = exclude
	return space.intersect_ray(q).is_empty()


## 炮塔转向指定世界角度（限制转速的平滑转向）
func aim_at(angle: float, delta: float) -> void:
	var e := enemy()
	if e != null:
		e.rotate_turret(angle, delta)


## 炮塔转向玩家，返回是否已经对准（角度误差在 shoot_angle 内）
func aim_at_player(delta: float) -> bool:
	var e := enemy()
	var p := player()
	if e == null or p == null:
		return false
	var aim := (p.global_position - e.global_position).angle()
	e.rotate_turret(aim, delta)
	var facing := e.get_turret_rotation()
	return absf(wrapf(aim - facing, -PI, PI)) <= deg_to_rad(maxf(e.shoot_angle, 1.0))


## 开火/停火（持续武器如激光/电枪也适用）
func fire(on: bool) -> void:
	var e := enemy()
	if e == null:
		return
	if on:
		e.start_fire()
	else:
		e.stop_fire()


## 朝目标点寻路移动（能直线到达就直冲，被墙/障碍挡住则走 A* 路径绕开）
func navigate_to(target: Vector2) -> void:
	var e := enemy()
	if e == null or e.move_speed <= 0.0:
		return
	e.navigate_to(target)


## 朝目标点直线移动（不寻路；坦克按 move_speed 推进，炮塔/生成器会忽略）
func move_towards(target: Vector2) -> void:
	var e := enemy()
	if e == null or e.move_speed <= 0.0:
		return
	var dir := (target - e.global_position)
	if dir.length() < 1.0:
		stop_moving()
		return
	e.move(dir.normalized())


func stop_moving() -> void:
	var e := enemy()
	if e == null:
		return
	e.move(Vector2.ZERO)
	e.velocity = Vector2.ZERO
