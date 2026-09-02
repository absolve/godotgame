extends ATEnemy
## Spawner — 敌人生成器（固定位置，周期性产出敌人）
## 对应原项目 window.AT.Spawner（7 种颜色对应不同敌人类型）。

class_name ATSpawner

@export var spawn_interval: float = 3.0
@export var max_alive: int = 3
@export var enemy_kind: int = 0      # 0-6 对应 SPAWNER_1..7

var _timer: float = 0.0
var _spawned: Array[Node2D] = []

func _ready() -> void:
	super._ready()
	# 生成器不可移动（CharacterBody2D 不调用 move，velocity 保持为 0）

func _physics_process(delta: float) -> void:
	# 不调用 super（不跑 AI），只管生成
	_timer -= delta
	if _timer <= 0:
		_timer = spawn_interval
		_try_spawn()

func _try_spawn() -> void:
	_spawned = _spawned.filter(func(e): return is_instance_valid(e))
	if _spawned.size() >= max_alive:
		return
	# TODO: 实例化敌人节点放在附近空格
	pass
