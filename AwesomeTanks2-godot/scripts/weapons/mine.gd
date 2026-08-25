extends Area2D
## Mine — 地雷（放下后延时引爆，敌人/玩家触发即爆炸）
## 对应原项目 window.AT.Mine

class_name ATMine

var team: int = ATConst.Team.PLAYER
var damage: float = 80.0
var radius: float = 85.0
var armed: bool = false
var arm_delay: float = 0.5

@onready var _shape: CollisionShape2D = $Shape

func _ready() -> void:
	monitoring = false
	collision_layer = 0
	collision_mask = ATConst.layer_mask([ATConst.Layer.PLAYER, ATConst.Layer.ENEMY])
	body_entered.connect(_on_trigger)

func setup(team_: int, damage_: float, _speed: float, _life: float, _color: Color, _alert: float) -> void:
	team = team_
	damage = damage_

func _process(delta: float) -> void:
	if not armed:
		arm_delay -= delta
		if arm_delay <= 0:
			armed = true
			monitoring = true

func _on_trigger(_body: Node) -> void:
	if not armed:
		return
	_explode()

func _explode() -> void:
	Audio.play_sfx("explosion.mp3")
	# TODO: 爆炸粒子 + 范围伤害
	queue_free()
