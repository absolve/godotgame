extends ATBullet
## ATRicochetBullet —— 反弹弹（Ricochet）：碰墙反弹若干次，撞敌/超时消失
## 对应 H5 Ricochet：撞墙发 ricochet_bounce 并持续反弹，达到次数后火花消失。

class_name ATRicochetBullet

var max_bounces: int = 4
var _bounces: int = 0


func _on_hit(other: Node) -> void:
	if _is_owner(other):
		return
	if other.has_method("on_bullet_hit"):
		var other_team: int = other.team if "team" in other else Constants.Team.CPU
		if other_team != team:
			other.on_bullet_hit(damage, null, self)
			_die(true)
		else:
			_die(false)
		return
	# 撞墙反弹
	if _bounces >= max_bounces:
		_die(true)
		return
	_bounces += 1
	Audio.play_sfx("ricochet_bounce.mp3")
	Fx.spark(global_position, get_parent())
	_reflect_off(other)


func _reflect_off(other: Node) -> void:
	var incoming := Vector2.RIGHT.rotated(rotation)
	var normal := Vector2.ZERO
	if other is Node2D:
		var to_center := global_position - (other as Node2D).global_position
		if to_center.length() > 0.01:
			normal = to_center.normalized()
	if normal == Vector2.ZERO:
		normal = -incoming
	var reflected := incoming - 2.0 * incoming.dot(normal) * normal
	rotation = reflected.angle()
	global_position += reflected * 6.0  # 避免卡墙
	speed *= 0.92
