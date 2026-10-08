extends ATBullet
## ATCannonBullet —— 加农炮弹：命中（敌人/墙/障碍）即范围爆炸（音效+特效+范围伤害）

class_name ATCannonBullet

## H5 炮弹爆炸半径固定 75（L21563/21565），不是武器配的 radius
var radius: float = 75.0
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
