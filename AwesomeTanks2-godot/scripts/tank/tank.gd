extends RigidBody2D
## Tank — 坦克基类（玩家与敌人共用）
## 对应原项目 window.AT.Tank：车体精灵 + 炮塔精灵 + 武器组。
##
## 玩家继承此类实现输入；敌人继承此类挂载 AI 状态机。

class_name ATTank

signal killed

@onready var _body_sprite: Sprite2D = $BodySprite
@onready var _turret_sprite: Sprite2D = $TurretSprite
@onready var _body: CollisionShape2D = $Body

# 物理参数（由子类根据升级等级设置）
var move_speed: float = 150.0
var turret_speed: float = 240.0     # 度/秒
var max_health: float = 100.0
var health: float = 100.0
var view_angle: float = 90.0
var view_distance: float = 300.0

var team: int = ATConst.Team.CPU
var weapon_index: int = 0
var weapons: Array = []             # 武器节点数组（可为 null 占位）
var weapon: Node = null
var hit_flash: float = 0.0
var hit_color: Color = Color.WHITE
var invincible: bool = false
var alive: bool = true

# 炮塔后坐力
var _recoil: float = 0.0
var _turret_offset: Vector2 = Vector2.ZERO
var kill_delay: float = 0.12

func _ready() -> void:
	gravity_scale = 0.0
	linear_damp = 0.0
	angular_damp = 0.0
	contact_monitor = true
	max_contacts_reported = 4
	# 圆形碰撞
	var shape := CircleShape2D.new()
	shape.radius = 22.0
	(_body as CollisionShape2D).shape = shape
	collision_layer = _my_layer()
	collision_mask = _my_mask()

func _my_layer() -> int:
	return 1 << (ATConst.Layer.PLAYER - 1) if team == ATConst.Team.PLAYER else 1 << (ATConst.Layer.ENEMY - 1)

func _my_mask() -> int:
	# 坦克碰墙 + 障碍物 + 对方队伍
	return ATConst.layer_mask([ATConst.Layer.WALL, ATConst.Layer.OBSTACLE, ATConst.Layer.ENEMY_SPAWNER, ATConst.Layer.PLAYER, ATConst.Layer.ENEMY])

func _process(delta: float) -> void:
	# 受击闪光衰减
	hit_flash = max(0.0, hit_flash - delta / 0.2)
	var tint := _lerp_color(Color.WHITE, hit_color, hit_flash)
	_body_sprite.modulate = tint
	_turret_sprite.modulate = tint
	# 后坐力恢复
	_recoil = max(0.0, _recoil - 0.3)
	_turret_sprite.position = -Vector2(cos(_turret_sprite.rotation), sin(_turret_sprite.rotation)) * _recoil

func _physics_process(_delta: float) -> void:
	if not alive:
		return
	_turn_body_to_velocity()
	_sync_turret()

# ============================================================
# 移动 / 炮塔
# ============================================================
func move(dir: Vector2) -> void:
	linear_velocity = dir * move_speed

func rotate_turret(target_angle: float, delta: float) -> void:
	var cur := _turret_sprite.rotation
	var diff := wrapf(target_angle - cur, -PI, PI)
	var step := deg_to_rad(turret_speed) * delta
	_turret_sprite.rotation = cur + clamp(diff, -step, step)

func _turn_body_to_velocity() -> void:
	var v := linear_velocity
	var speed := v.length()
	if speed > 1.0:
		var target := v.angle()
		var diff := wrapf(target - _body_sprite.rotation, -PI, PI)
		var step = deg_to_rad(8.0) * clamp(speed / max(move_speed, 1.0), 0.0, 1.0)
		_body_sprite.rotation += clamp(diff, -step, step)

func _sync_turret() -> void:
	_turret_sprite.position = Vector2.ZERO - Vector2(cos(_turret_sprite.rotation), sin(_turret_sprite.rotation)) * _recoil

func get_turret_position(offset: float) -> Vector2:
	var r := _turret_sprite.rotation
	return global_position + Vector2(cos(r), sin(r)) * offset

# ============================================================
# 武器
# ============================================================
func change_weapon(index: int) -> void:
	if index < 0 or index >= weapons.size():
		return
	if weapons[index] == null or weapons[index] == weapon:
		return
	if weapon and weapon.has_method("deactivate"):
		weapon.deactivate()
	weapon_index = index
	weapon = weapons[index]
	if weapon and weapon.has_method("activate"):
		weapon.activate()
	# TODO: 切换炮塔贴图 + 弹性动画 + 音效
	Audio.play_sfx("weapon_change.mp3")

func next_weapon() -> void:
	if weapons.is_empty():
		return
	var i := weapon_index
	for _step in range(weapons.size()):
		i = posmod(i + 1, weapons.size())
		if weapons[i] != null:
			change_weapon(i)
			return

func start_fire() -> void:
	if weapon and weapon.has_method("start_fire"):
		weapon.start_fire()

func stop_fire() -> void:
	if weapon and weapon.has_method("stop_fire"):
		weapon.stop_fire()

# ============================================================
# 受击 / 死亡
# ============================================================
func on_bullet_hit(damage: float, src_weapon: Node, _bullet: Node) -> void:
	if invincible:
		return
	health -= damage
	hit_flash = 1.0
	hit_color = src_weapon.hit_color if "hit_color" in src_weapon else Color.WHITE
	if health <= 0 and alive:
		_kill()

func _kill() -> void:
	alive = false
	if weapon and weapon.has_method("stop_fire"):
		weapon.stop_fire()
	killed.emit()
	# TODO: 爆炸粒子 + 灰度着色器 + 相机震动 + 音效
	Audio.play_sfx("explosion.mp3", 2.0)

func freeze() -> void:
	# TODO: 冰冻效果
	pass

func unfreeze() -> void:
	pass

# ============================================================
# 工具
# ============================================================
func _lerp_color(a: Color, b: Color, t: float) -> Color:
	return a.lerp(b, clamp(t, 0.0, 1.0))
