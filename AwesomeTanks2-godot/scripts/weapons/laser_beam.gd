extends Node2D
## LaserBeam — 激光束（持续射线，即时命中）
## 对应原项目 window.AT.Laser（用 raycast 检测命中对象）
## 与子弹不同：不发实体，每帧射线判定。

class_name ATLaserBeam

var team: int = Constants.Team.CPU
var damage: float = 10.0
var hit_color: Color = Color(1, 0, 0)
var sound_alert_radius: float = 0.0
var _length: float = 400.0

@onready var _ray: RayCast2D = $RayCast2D
@onready var _line: Line2D = $Line2D

func setup(team_: int, damage_: float, _speed: float, _life: float, color_: Color, alert_: float) -> void:
	team = team_
	damage = damage_
	hit_color = color_
	sound_alert_radius = alert_

func _physics_process(delta: float) -> void:
	_ray.force_raycast_update()
	var end: Vector2 = _ray.target_position
	if _ray.is_colliding():
		var p := _ray.get_collision_point() - global_position
		end = p
		var collider := _ray.get_collider()
		if collider and collider.has_method("on_bullet_hit"):
			var ot: int = collider.team if "team" in collider else Constants.Team.CPU
			if ot != team:
				collider.on_bullet_hit(damage * delta, null, self)
	_line.clear()
	_line.add_point(Vector2.ZERO)
	_line.add_point(end)
