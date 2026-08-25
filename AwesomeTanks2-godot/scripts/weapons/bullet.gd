extends RigidBody2D
## Bullet — 通用子弹（移植自原项目 Phaser.Sprite 子弹）
## 子类：Rocket(追踪)/Laser(射线)/Mine(地雷) 覆盖 update/bullet_hit。

class_name ATBullet

var team: int = ATConst.Team.CPU
var damage: float = 10.0
var speed: float = 600.0
var life: float = 1.0
var hit_color: Color = Color.WHITE
var sound_alert_radius: float = 0.0

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	gravity_scale = 0.0
	linear_damp = 0.0
	contact_monitor = true
	max_contacts_reported = 2
	var shape := CircleShape2D.new()
	shape.radius = 5.0
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	collision_layer = 1 << (ATConst.Layer.PROJECTILE - 1)
	collision_mask = ATConst.layer_mask([ATConst.Layer.WALL, ATConst.Layer.OBSTACLE, ATConst.Layer.PLAYER, ATConst.Layer.ENEMY])
	body_entered.connect(_on_hit)

func setup(team_: int, damage_: float, speed_: float, life_: float, color_: Color, alert_: float) -> void:
	team = team_
	damage = damage_
	speed = speed_
	life = life_
	hit_color = color_
	sound_alert_radius = alert_
	linear_velocity = Vector2.RIGHT.rotated(rotation) * speed

func _process(delta: float) -> void:
	life -= delta
	if life <= 0:
		_die(false)

func _on_hit(other: Node) -> void:
	# 判断对方阵营
	if other.has_method("on_bullet_hit"):
		var other_team: int = other.team if "team" in other else ATConst.Team.CPU
		if other_team != team:
			other.on_bullet_hit(damage, null, self)
	_die(true)

func _die(_hit_something: bool) -> void:
	# TODO: 火花粒子 + 警报音
	queue_free()
