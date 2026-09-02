extends Node2D
## Weapon — 武器基类（移植自原项目 Weapon extends Phaser.Group）
## 挂在坦克下，负责按射速 spawn 子弹/射线。

class_name ATWeapon

var tank: Node2D = null
var team: int = Constants.Team.CPU
var id: String = ""
var ammo: int = 999999       # minigun 无限
var max_ammo: int = 999999
var damage: float = 10.0
var rate: float = 4.0        # 每秒射次
var life: float = 1.0         # 子弹存活时间（秒）
var velocity: float = 600.0
var spread: float = 0.0
var spawn_count: int = 1
var spawn_distance: float = 20.0
var bullet_frame: String = ""
var bullet_scene: PackedScene = null
var hit_color: Color = Color.WHITE
var sound_alert_radius: float = 0.0

var _fire: bool = false
var _fire_delay: float = 0.0

signal shot(weapon)
signal out_of_ammo(weapon)

func _ready() -> void:
	pass

func activate() -> void: pass
func deactivate() -> void: stop_fire()

func _physics_process(delta: float) -> void:
	if _fire_delay > 0:
		_fire_delay -= delta
	if _fire and _fire_delay <= 0:
		if ammo > 0:
			_shoot()
		if rate > 0:
			_fire_delay += 1.0 / rate

func start_fire() -> void:
	if ammo > 0:
		_fire = true

func stop_fire() -> void:
	_fire = false

func _shoot() -> void:
	var base_angle: float = tank._turret_sprite.rotation if "turret_rotation" in tank else tank.rotation
	for i in spawn_count:
		var t: float = 0.5 if spawn_count == 1 else float(i) / (spawn_count - 1)
		var a: float = base_angle + (randf() * spread - spread / 2.0) if spawn_count == 1 \
			else base_angle - spread / 2.0 + t * spread
		_spawn_bullet(a)
	ammo -= 1
	shot.emit(self)
	if ammo <= 0:
		out_of_ammo.emit(self)

func _spawn_bullet(angle: float) -> void:
	if bullet_scene == null:
		return
	var b: Node2D = bullet_scene.instantiate()
	var pos: Vector2 = tank.get_turret_position(spawn_distance) if tank.has_method("get_turret_position") else tank.global_position
	b.global_position = pos
	b.rotation = angle
	if b.has_method("setup"):
		b.setup(team, damage, velocity, life, hit_color, sound_alert_radius)
	tank.get_parent().add_child(b)
