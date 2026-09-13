extends ATEnemy
## Spawner —— 敌人生成器形态场景（scenes/enemies/Spawner.tscn）
## 对应原项目 window.AT.Spawner：固定不动、周期性产出敌人，共 7 种（数据见 ATEnemyTypes.SPAWNERS）
##
## 为什么只有 1 个生成器场景：7 种生成器结构完全相同，仅贴图（spawners/<kind>.png）、
## 血量、分数与产出表不同，因此合并为一个形态场景 + 一张数据表，关卡生成时按瓦片
## 调用 apply_kind() 应用对应数据。
##
## 场景结构：
##   Spawner (ATSpawner)
##   ├─ BodySprite  —— 生成器本体贴图（apply_kind 里按 kind 设置；半血换 _damaged 图待做）
##   └─ TurretSprite —— 隐藏（生成器无炮塔）
## 产出逻辑（附近空格实例化 spawn_types 里的敌人 + 冷却）待敌人 AI 阶段一起补。

class_name ATSpawner

@export var spawn_interval: float = 4.17    # 产出间隔（秒；H5 每产 1 只 +250/60s）
@export var max_alive: int = 4              # 场上同时存活上限（H5: aliveCount() < 4）
@export var enemy_kind: int = 0             # 0..6 → SPAWNER_1..7
@export var spawn_types: PackedStringArray = PackedStringArray()

var _timer: float = 0.0
var _spawned: Array[Node2D] = []


func _ready() -> void:
	super._ready()
	# 生成器不移动也不开火：隐藏炮塔、停用 AI 状态机（生成行为由自身计时驱动）
	_turret_sprite.visible = false
	if ai != null:
		ai.enabled = false
	move_speed = 0.0
	velocity = Vector2.ZERO


## 按 kind 应用数据（贴图/血量/分数/产出表）；须在节点入树后调用
func apply_kind(kind: int) -> void:
	enemy_kind = kind
	var def: Dictionary = ATEnemyTypes.SPAWNERS.get(kind, {})
	enemy_id = "spawner_%d" % (kind + 1)
	tank_key = "spawner_%d" % (kind + 1)
	if not def.is_empty():
		max_health = float(def.get("max_health", max_health))
		health = max_health
		points = int(def.get("points", points))
		var types: Array = def.get("spawn_types", [])
		spawn_types = PackedStringArray(types)
	_build_body_frames(kind)


func _build_body_frames(kind: int) -> void:
	var path := ATEnemyTypes.SPAWNER_TEX + str(kind) + ".png.tres"
	if not ResourceLoader.exists(path):
		return
	var frames := SpriteFrames.new()
	#frames.add_animation("default")
	frames.set_animation_speed("default", 1.0)
	frames.set_animation_loop("default", false)
	frames.add_frame("default", load(path))
	_body_sprite.sprite_frames = frames
	_body_sprite.play("default")


func _physics_process(delta: float) -> void:
	# 不跑移动 AI；只推进产出计时（产出逻辑待实现）
	_timer -= delta
	if _timer <= 0.0:
		_timer = spawn_interval
		_try_spawn()


func _try_spawn() -> void:
	_spawned = _spawned.filter(func(e: Node2D) -> bool: return is_instance_valid(e))
	if _spawned.size() >= max_alive:
		return
	if spawn_types.is_empty():
		return
	# TODO: 在附近空格实例化 spawn_types 里的敌人（需要敌人 AI 就绪后一起接）
	#   H5 规则：每产出 1 只就从列表随机抽取并移除，共 6 只不重复


## 视觉兜底：kind 已在场景里确定时才加载；否则等 apply_kind 指定
func _configure_enemy_visuals() -> void:
	if _body_sprite.sprite_frames != null:
		return
	_build_body_frames(enemy_kind)
