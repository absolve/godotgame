extends ATBullet
## ATCannonBullet —— 加农炮弹：命中（敌人/墙/障碍）即范围爆炸（音效+特效+范围伤害）

class_name ATCannonBullet

var radius: float = 90.0
var _exploded := false


func _on_hit(other: Node) -> void:
	if _is_owner(other):
		return
	_explode()


func _die(_hit_something: bool) -> void:
	# 寿命耗尽同样引爆（保证飞到头也会炸）
	_explode()


func _explode() -> void:
	if _exploded or not is_inside_tree():
		return
	_exploded = true
	ATBullet.explode(self, global_position, radius, damage, team)
	queue_free()
