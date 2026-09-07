extends ATBullet
## ATRocket —— 火箭弹（Rockets）：朝目标转向追踪、命中/撞墙范围爆炸
## 对应原项目 window.AT.Rocket（爆炸：音效+特效+范围伤害）

class_name ATRocket

var radius: float = 85.0
var turn_rate: float = 3.0        # 度/帧
var target: Node2D = null
var smoke_timer: float = 0.0
var _exploded := false


func setup(team_: int, damage_: float, speed_: float, life_: float, color_: Color, alert_: float) -> void:
	super.setup(team_, damage_, speed_, life_, color_, alert_)


func set_target(node: Node2D) -> void:
	target = node


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_instance_valid(target):
		var desired := (target.global_position - global_position).angle()
		var diff := wrapf(desired - rotation, -PI, PI)
		rotation += clamp(diff, -deg_to_rad(turn_rate), deg_to_rad(turn_rate))
	smoke_timer -= delta
	if smoke_timer <= 0:
		smoke_timer = 0.03
		# TODO: 生成尾烟粒子（可挂 SmokeParticles 子节点）


func _on_hit(other: Node) -> void:
	if _is_owner(other):
		return
	_explode()


func _die(_hit_something: bool) -> void:
	_explode()


func _explode() -> void:
	if _exploded or not is_inside_tree():
		return
	_exploded = true
	ATBullet.explode(self, global_position, radius, damage, team)
	queue_free()
