extends ATBullet
## ATRicochetBullet —— 反弹弹（Ricochet）：碰墙反弹若干次，撞敌/超时消失
## 对应 H5 Ricochet（L21509~21527）：
##   每次**撞墙弹一下** = ricochet_bounce.mp3 + 一种命中特效（场景里的 impactFx）+ alertSound；
##   击中单位 = 结算伤害（玩家弹按蓄力伤害）+ 同一种特效，次数用完就消失；
##   飞行途中还会随机冒火花（H5 每帧 50% 概率 2 个）——见 REMAINING_FEATURES 待办。

class_name ATRicochetBullet

var maxBounces: int = 4
var bounces: int = 0


func onHit(other: Node) -> void:
	if isOwner(other):
		return
	if other.has_method("onBulletHit"):
		var otherTeam: int = other.team if "team" in other else Constants.Team.CPU
		if otherTeam != team:
			other.onBulletHit(damage, null, self)
			die(true)
		else:
			die(false)
		return
	# 撞墙反弹：H5 是 ricochet_bounce.mp3 + 命中特效，并且同样 alertSound
	if bounces >= maxBounces:
		die(true)
		return
	bounces += 1
	Audio.playSfx("ricochet_bounce.mp3")
	Fx.spawnNamed(impactFx, global_position, get_parent())
	alertOnHit()
	reflectOff(other)


func reflectOff(other: Node) -> void:
	var incoming := Vector2.RIGHT.rotated(rotation)
	var normal := Vector2.ZERO
	if other is Node2D:
		var toCenter := global_position - (other as Node2D).global_position
		if toCenter.length() > 0.01:
			normal = toCenter.normalized()
	if normal == Vector2.ZERO:
		normal = -incoming
	var reflected := incoming - 2.0 * incoming.dot(normal) * normal
	rotation = reflected.angle()
	global_position += reflected * 6.0  # 避免卡墙
	speed *= 0.92
