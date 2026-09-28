extends ATBullet
## ATRocket —— 火箭弹（Rockets），对应原项目 window.AT.Rocket（L20783~20835）
##
## 玩家发射的火箭是**制导弹**：
##   - 用鼠标瞄准方向（H5 followMouse：朝鼠标世界坐标转向，每帧最多转 0.2×min(|Δ|, 0.3π)）；
##   - 发射瞬间由 Level 把"制导权"记到玩家身上（player.follow）→ 镜头跟着导弹、
##     玩家不能开车、迷雾跟着导弹（这些都在 Level/ATPlayer 里处理，见 set_guided_rocket）；
##   - 速度从 0 起步逐渐加速到武器给的 speed（H5: speed += acceleration×dt，封顶 maxSpeed）；
##   - 命中/寿命到/被玩家再按一次开火引爆 → 范围爆炸，并把镜头/操作权还给玩家。
## 敌方发射的火箭是普通追踪弹：朝玩家转向（H5 followPlayer，中间隔墙就不追了）。
##
## 爆炸：音效 + 爆炸特效 + 半径伤害（复用 ATBullet.explode，对应 H5 explosions.explode）

class_name ATRocket

## 加速到最高速所需时间（秒）。H5 是用加速度+质量模拟，这里等价成"从 0 加速到 speed"
const RAMP_TIME := 1.5
## 玩家制导：每秒能转的角度系数（H5 每帧 0.2×min(|Δ|,0.3π)，60fps 下 ≈ 12×0.3π/秒）
const MOUSE_TURN := 12.0
## 敌方追踪：每秒转向速度（H5 rotateToPoint(..., 5) ≈ 5°/帧 ≈ 300°/s）
const CPU_TURN_SPEED := 300.0
## 尾烟间隔（秒；H5: smokeTime += 1/6）
const SMOKE_INTERVAL := 1.0 / 6.0

## 爆炸半径（H5: explosions.explode(x, y, 75, damage, team)）
@export var radius: float = 85.0

var target: Node2D = null          # 敌方追踪目标（H5 followPlayer）
var _speed: float = 0.0            # 当前速度（H5: this.speed，从 0 加速）
var _smoke_time: float = 0.0
var _exploded: bool = false
var _level: Node = null            # 关卡（发射者注入的 level，用来交还镜头/迷雾）
var _guiding: bool = false         # 本发是否处于"玩家制导"状态


func _ready() -> void:
	super._ready()
	# owner_actor/owner_weapon 由武器在 add_child 之前就填好了（见 ATWeapon._spawn_bullet）
	_level = owner_actor.get("level") if is_instance_valid(owner_actor) and "level" in owner_actor else null
	if team == Constants.Team.PLAYER:
		_begin_guide()
	elif _player() != null:
		target = _player()          # 敌方火箭追踪玩家（H5 followPlayer）


func _physics_process(delta: float) -> void:
	# 自己管移动（要加速），所以不调用基类：寿命逻辑照抄基类
	life -= delta
	if life <= 0.0:
		_explode()                  # H5：寿命到 → onBulletKilled → 爆炸
		return
	_steer(delta)
	_speed = minf(_speed + speed / maxf(RAMP_TIME, 0.01) * delta, speed)
	global_position += Vector2.RIGHT.rotated(rotation) * _speed * delta
	_trail(delta)


# ============================================================
# 转向
# ============================================================
func _steer(delta: float) -> void:
	if _guiding:
		# 玩家：朝鼠标转（鼠标贴着导弹时不再转，避免原地抖）
		var m := get_global_mouse_position()
		var to_mouse := m - global_position
		if absf(to_mouse.x) > 2.0 and absf(to_mouse.y) > 2.0:
			var diff := wrapf(to_mouse.angle() - rotation, -PI, PI)
			rotation += MOUSE_TURN * minf(absf(diff), 0.3 * PI) * signf(diff) * delta
		return
	# 敌方：朝玩家转，但中间隔了墙/障碍就不追（H5 followPlayer 的 visibilityFilter）
	if not is_instance_valid(target) or not _has_line_of_sight(target.global_position):
		return
	var wanted := wrapf((target.global_position - global_position).angle() - rotation, -PI, PI)
	var step := deg_to_rad(CPU_TURN_SPEED) * delta
	rotation += clampf(wanted, -step, step)


func _has_line_of_sight(to: Vector2) -> bool:
	var space := get_world_2d().direct_space_state
	if space == null:
		return true
	var q := PhysicsRayQueryParameters2D.new()
	q.from = global_position
	q.to = to
	q.collision_mask = Constants.layer_mask([Constants.Layer.WALL, Constants.Layer.OBSTACLE])
	return space.intersect_ray(q).is_empty()


func _trail(delta: float) -> void:
	_smoke_time -= delta
	if _smoke_time <= 0.0:
		_smoke_time = SMOKE_INTERVAL
		# H5：在弹尾 5px 处冒烟
		Fx.smoke(global_position - Vector2.RIGHT.rotated(rotation) * 5.0, get_parent())


# ============================================================
# 制导的接管 / 交还（镜头、玩家操作权、迷雾都由 Level 统一处理）
# ============================================================
func _begin_guide() -> void:
	_guiding = true
	if _level != null and is_instance_valid(_level) and _level.has_method("set_guided_rocket"):
		_level.call("set_guided_rocket", self)


func _release_guide() -> void:
	if not _guiding:
		return
	_guiding = false
	if _level != null and is_instance_valid(_level) and _level.has_method("clear_guided_rocket"):
		_level.call("clear_guided_rocket", self)


## 立刻引爆（H5 requestKill：玩家再按一次开火 / 切武器 / 玩家阵亡）
func detonate() -> void:
	_explode()


# ============================================================
# 命中 / 爆炸
# ============================================================
func _on_hit(other: Node) -> void:
	if _is_owner(other):
		return
	_explode()


## 兜底：万一有谁调基类的 _die（本类自己管寿命/命中），一样走爆炸而不是消散烟
func _die(_hit_something: bool) -> void:
	_explode()


func _explode() -> void:
	if _exploded:
		return
	_exploded = true
	_release_guide()
	if is_inside_tree():
		ATBullet.explode(self, global_position, radius, damage, team)
	queue_free()


func _exit_tree() -> void:
	# 关卡结束/被释放时也要把镜头和操作权还回去，别留在导弹上
	_release_guide()


func _player() -> Node2D:
	if _level == null or not is_instance_valid(_level):
		return null
	var p = _level.get("player")
	if p is Node2D and is_instance_valid(p) and bool(p.get("alive")):
		return p
	return null
