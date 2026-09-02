extends ATBullet
## Rocket — 火箭弹：追踪玩家、范围爆炸
## 对应原项目 window.AT.Rocket（带烟雾尾迹 + 引爆半径）

class_name ATRocket

var radius: float = 85.0
var target: Node2D = null
var smoke_timer: float = 0.0

func setup(team_: int, damage_: float, speed_: float, life_: float, color_: Color, alert_: float) -> void:
	super.setup(team_, damage_, speed_, life_, color_, alert_)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	# 追踪：朝目标转向（移动 + 寿命由基类 _physics_process 处理）
	if is_instance_valid(target):
		var desired := (target.global_position - global_position).angle()
		var diff := wrapf(desired - rotation, -PI, PI)
		rotation += clamp(diff, -deg_to_rad(3.0), deg_to_rad(3.0))
	# 烟雾尾迹
	smoke_timer -= delta
	if smoke_timer <= 0:
		smoke_timer = 0.03
		# TODO: spawn 烟雾粒子
	

func _die(hit_something: bool) -> void:
	if hit_something:
		_explode()
	queue_free()

func _explode() -> void:
	# 范围伤害：对所有范围内敌人生成伤害
	Audio.play_sfx("explosion.mp3")
	# TODO: 爆炸粒子 + 范围内对象扣血
