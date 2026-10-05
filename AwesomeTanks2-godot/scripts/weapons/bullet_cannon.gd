extends ATBullet
## ATCannonBullet —— 加农炮弹：命中（敌人/墙/障碍）即范围爆炸（音效+特效+范围伤害）

class_name ATCannonBullet

var radius: float = 90.0
var exploded := false


func onHit(other: Node) -> void:
	if isOwner(other):
		return
	explode()


func die(hitSomething: bool) -> void:
	# 寿命耗尽同样引爆（保证飞到头也会炸）
	explode()


func explode() -> void:
	if exploded or not is_inside_tree():
		return
	exploded = true
	ATBullet.explodeAt(self, global_position, radius, damage, team)
	queue_free()
