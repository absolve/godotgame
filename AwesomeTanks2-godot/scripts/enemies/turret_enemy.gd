extends ATEnemy
## TurretEnemy — 固定炮塔（无车体，仅旋转炮管攻击玩家）
## 对应原项目 window.AT.Turret（8 种武器）。

class_name ATTurretEnemy

func _ready() -> void:
	super._ready()
	# 固定不动（CharacterBody2D 不调用 move，velocity 保持为 0）

func _physics_process(delta: float) -> void:
	# 不调用 super 的 AI 巡逻；只旋转炮塔朝玩家
	if level and is_instance_valid(level.player):
		var aim = (level.player.global_position - global_position).angle()
		rotate_turret(aim, delta)
		if _has_line_of_sight():
			start_fire()

func _has_line_of_sight() -> bool:
	# TODO: RayCast2D 检测玩家
	return false

func move(_dir: Vector2) -> void:
	pass   # 固定
