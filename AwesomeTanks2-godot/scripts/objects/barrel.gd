extends ATObstacle
## Barrel — 油桶（被击毁时范围爆炸，连锁伤害）
## 对应原项目 window.AT.Barrel

var explode_radius: float = 90.0
var explode_damage: float = 60.0

func _ready() -> void:
	super._ready()
	health = 1.0
	max_health = 1.0

func _die() -> void:
	_explode()
	super._die()

func _explode() -> void:
	Audio.play_sfx("explosion.mp3")
	# TODO: 范围内对象 + 链式引爆其它油桶
