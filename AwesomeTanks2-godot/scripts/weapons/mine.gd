extends Area2D
## ATMine —— 地雷（Mines 武器布设物，非飞行弹）
## 放下后延时 0.5s 进入待命；敌人/玩家踩上即范围爆炸（不炸自己阵营）。

class_name ATMine

var team: int = Constants.Team.PLAYER
var damage: float = 80.0
var radius: float = 85.0
var armed: bool = false
var arm_delay: float = 0.5
var owner_actor: Node = null     # 布设者：自己踩自己的雷不引爆
var _exploded := false

@onready var _shape: CollisionShape2D = $Shape


func _ready() -> void:
	monitoring = false
	collision_layer = 1 << (Constants.Layer.PROJECTILE - 1)
	collision_mask = Constants.layer_mask([Constants.Layer.PLAYER, Constants.Layer.ENEMY])
	body_entered.connect(_on_trigger)


func setup(team_: int, damage_: float, radius_: float) -> void:
	team = team_
	damage = damage_
	radius = radius_


func _physics_process(delta: float) -> void:
	if not armed:
		arm_delay -= delta
		if arm_delay <= 0:
			armed = true
			monitoring = true


func _on_trigger(body: Node) -> void:
	if not armed:
		return
	if owner_actor != null and body == owner_actor:
		return
	_explode()


func _explode() -> void:
	if _exploded or not is_inside_tree():
		return
	_exploded = true
	ATBullet.explode(self, global_position, radius, damage, team)
	queue_free()
