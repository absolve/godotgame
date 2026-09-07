extends ATBullet
## ATRailgunBullet —— 轨道炮（穿透弹）：不因命中敌人消失，直线穿透多个目标，
## 直到寿命结束或撞墙（撞墙时播放火花/命中音）。

class_name ATRailgunBullet


func _on_hit(other: Node) -> void:
	if _is_owner(other):
		return
	if other.has_method("on_bullet_hit"):
		var other_team: int = other.team if "team" in other else Constants.Team.CPU
		if other_team != team:
			other.on_bullet_hit(damage, null, self)
		return
	_die(true)  # 撞墙/障碍结束（带火花 + 命中音）
