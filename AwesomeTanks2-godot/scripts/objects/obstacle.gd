extends StaticBody2D
## Obstacle — 可破坏障碍物基类（砖墙/木箱/板条箱/油桶）
## 对应原项目 window.AT.Obstacle / Bricks / Wood / Crate / Barrel

class_name ATObstacle

var health: float = 30.0
var max_health: float = 30.0
var destructible: bool = true
var tile_type: int = ATConst.Tile.EMPTY

signal destroyed(obstacle)

func _ready() -> void:
	collision_layer = 1 << (ATConst.Layer.OBSTACLE - 1)
	collision_mask = ATConst.layer_mask([ATConst.Layer.PLAYER, ATConst.Layer.ENEMY, ATConst.Layer.PROJECTILE])

func on_bullet_hit(damage: float, _src: Node, _bullet: Node) -> void:
	if not destructible:
		return
	health -= damage
	if health <= 0:
		_die()

func _die() -> void:
	destroyed.emit(self)
	# TODO: 碎片粒子
	queue_free()
