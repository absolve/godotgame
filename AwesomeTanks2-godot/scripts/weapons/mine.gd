extends Area2D
## ATMine —— 地雷（Mines 武器布设物，非飞行弹）
## 放下后延时 0.5s 进入待命；敌人/玩家踩上即范围爆炸（不炸自己阵营）。

class_name ATMine

var team: int = Constants.Team.PLAYER
var damage: float = 80.0
var radius: float = 85.0
var armed: bool = false
var armDelay: float = 0.5
var ownerActor: Node = null     # 布设者：自己踩自己的雷不引爆
var exploded := false

@onready var shape: CollisionShape2D = $Shape


func _ready() -> void:
	monitoring = false
	collision_layer = 1 << (Constants.Layer.PROJECTILE - 1)
	collision_mask = Constants.layerMask([Constants.Layer.PLAYER, Constants.Layer.ENEMY])
	body_entered.connect(onTrigger)


func setup(team_: int, damage_: float, radius_: float) -> void:
	team = team_
	damage = damage_
	radius = radius_


func onTrigger(body: Node) -> void:
	if not armed:
		return
	if ownerActor != null and body == ownerActor:
		return
	explode()


func explode() -> void:
	if exploded or not is_inside_tree():
		return
	exploded = true
	ATBullet.explodeAt(self, global_position, radius, damage, team)
	queue_free()


func _physics_process(delta: float) -> void:
	if not armed:
		armDelay -= delta
		if armDelay <= 0:
			armed = true
			monitoring = true
