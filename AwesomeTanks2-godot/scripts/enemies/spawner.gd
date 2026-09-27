extends ATEnemy
## Spawner —— 敌人生成器形态场景（scenes/enemies/Spawner.tscn）
## 对应原项目 window.AT.Spawner（awesome_tanks_2.js L22299~22362）：固定不动、周期性产出敌人，
## 共 7 种（数据见 ATEnemyTypes.SPAWNERS）。
##
## 为什么只有 1 个生成器场景：7 种生成器结构完全相同，仅贴图（spawners/<kind>.png）、
## 血量、分数与产出表不同，因此合并为一个形态场景 + 一张数据表，关卡生成时按瓦片
## 调用 apply_kind() 应用对应数据。
##
## 场景结构：
##   Spawner (ATSpawner)
##   ├─ BodySprite     —— 生成器本体贴图（apply_kind 按 kind 设置；半血换 _damaged 图）
##   ├─ TurretSprite   —— 隐藏（生成器无炮塔）
##   ├─ Progress       —— 右上角产出进度贴图（progress_[6-已产出]）
##   └─ Lifebar        —— 头顶血条（来自 Enemy.tscn）
##
## 产出规则（H5）：血量 > 0、冰冻中不产出；初始延迟 1+random 秒，每产出 1 只 +250/60s；
## 场上存活 < 4 只、累计产出 < 6 只；从 spawn_types 里**随机抽取并移除**（6 只不重复）；
## 自己那一格被别的坦克占着就不产出（下帧重试）。

class_name ATSpawner

## H5：一个生成器最多产出 6 只（spawned < 6）
const MAX_SPAWNED := 6
const ENEMY_SCENE_DIR := "res://scenes/enemies/"
const DAMAGED_TEX := "res://sprites/game/spawners/%d_damaged.png.tres"
const PROGRESS_TEX := "res://sprites/game/spawners/progress_%d.png.tres"

@export var spawn_interval: float = 4.17    # 产出间隔（秒；H5 每产 1 只 +250/60s）
@export var max_alive: int = 4              # 场上同时存活上限（H5: aliveCount() < 4）
@export var enemy_kind: int = 0             # 0..6 → SPAWNER_1..7
@export var spawn_types: PackedStringArray = PackedStringArray()

@onready var _progress: Sprite2D = get_node_or_null("Progress")

var _timer: float = 0.0
## 已产出的坦克（**含已阵亡**：H5 this.tanks / spawned 同款，掉币数量与分数都按总产出算）
var _spawned: Array[Node2D] = []
var _half_destructed: bool = false


func _ready() -> void:
	super._ready()
	# 生成器不移动也不开火：隐藏炮塔、停用 AI 状态机（生成行为由自身计时驱动）
	_turret_sprite.visible = false
	if ai != null:
		ai.enabled = false
	move_speed = 0.0
	velocity = Vector2.ZERO
	burn_damage = 0.5   # H5：生成器被点燃每帧 0.5 点（L22330 new Fire(this, .5)）
	# H5：生成器属于 ENEMY_SPAWNER 碰撞组，只和玩家/子弹碰（坦克能压过去，见 ATTank._my_mask）
	collision_layer = 1 << (Constants.Layer.ENEMY_SPAWNER - 1)
	collision_mask = Constants.layer_mask([Constants.Layer.PLAYER, Constants.Layer.PROJECTILE])
	_timer = 1.0 + randf()   # H5 spawnDelay = 1 + random


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
	_update_progress()
	_update_points()


func _build_body_frames(kind: int, damaged: bool = false) -> void:
	var path := (DAMAGED_TEX % kind) if damaged else (ATEnemyTypes.SPAWNER_TEX + str(kind) + ".png.tres")
	if not ResourceLoader.exists(path):
		return
	var frames := SpriteFrames.new()
	#frames.add_animation("default")
	frames.set_animation_speed("default", 1.0)
	frames.set_animation_loop("default", false)
	frames.add_frame("default", load(path))
	_body_sprite.sprite_frames = frames
	_body_sprite.play("default")


## 受击：半血换破坏贴图（H5 onBulletHit 尾部），受击音用生成器专用音
func on_bullet_hit(damage: float, src_weapon: Node, bullet: Node) -> void:
	super.on_bullet_hit(damage, src_weapon, bullet)
	_check_half_destructed()


## H5 L22330：生成器连火焰直击都不播命中音，只有 spawner_hit_1~3
func _play_hit_sound(src: Node) -> void:
	if src == null or not is_instance_valid(src) or src is ATBurning or src is ATLaserWeapon \
			or src is ATWeaponFlamethrower:
		return
	Audio.play_spawner_hit()


# ============================================================
# 半血破坏形态（H5：换 _damaged 贴图 + 冒烟 + 震屏 + 爆炸音）
# ============================================================
func _check_half_destructed() -> void:
	if _half_destructed or not alive or health <= 0.0 or health >= max_health * 0.5:
		return
	_half_destructed = true
	_build_body_frames(enemy_kind, true)
	for _i in 3:
		Fx.smoke(global_position, get_parent())    # H5 spawnSmoke(..., 10)（每个节点 3 粒烟）
	if level != null and is_instance_valid(level):
		level.shake_camera(6.0)
	Audio.play_sfx("explosion.mp3", 1.25)


# ============================================================
# 产出（H5 update / spawnTank / aliveCount）
# ============================================================
func _physics_process(delta: float) -> void:
	# 不跑移动 AI：只推进产出计时（H5：血量 > 0、冰冻中、产出已满都不产出）
	if not alive or health <= 0.0 or _spawned.size() >= MAX_SPAWNED:
		return
	if ai_state_name() == "Frozen":
		return
	_timer -= delta
	if _timer > 0.0:
		return
	if _alive_count() < max_alive:
		_try_spawn()


## 产出一只坦克（H5 spawnTank）。成功即重新计时；失败（自己那格被占）留待下帧重试
func _try_spawn() -> void:
	if level == null or not is_instance_valid(level) or spawn_types.is_empty():
		return
	var tx: int = level.px_to_tile(global_position.x)
	var ty: int = level.px_to_tile(global_position.y)
	if not _is_spawn_tile_free(tx, ty):
		return
	# 随机抽取一种，抽到就从表里移除（H5 spawnTypes.splice，6 只不重复）
	var pick := randi() % spawn_types.size()
	var scene_name: String = spawn_types[pick]
	var path := ENEMY_SCENE_DIR + scene_name + ".tscn"
	if not ResourceLoader.exists(path):
		push_warning("Spawner: 敌人场景缺失 " + path)
		spawn_types.remove_at(pick)
		return
	spawn_types.remove_at(pick)
	# 表现（H5：烟 + 冲击波；坦克随后从生成器那一格开出来）
	Fx.smoke(global_position, get_parent())
	Fx.explosion(global_position, get_parent())
	var e := (load(path) as PackedScene).instantiate() as Node2D
	if e == null:
		return
	e.position = level.cell_center(tx, ty)
	if "level" in e:
		e.level = level
	get_parent().add_child(e)
	if e.has_method("flash"):
		e.flash(Color.WHITE)          # H5 ai.Spawn.enter：出生白闪一下
	level.register_enemy(e)
	_spawned.append(e)
	_timer = spawn_interval
	_update_progress()
	_update_points()
	_send_off(e)


## 出生后先离开生成器门口（H5 ai.Spawn：随机挑一个相邻空格开过去，到了再回 Idle）。
## 这里直接复用 GoToSound（同样是"走到某点 → 到达/超时回 Idle、途中看见玩家就追击"）；
## 目标取两格外的空格（没空位再退一格），因为 GoToSound 的到达判定是 40px，
## 只给相邻格的话坦克可能还没走出这一格就停下了，会把生成器门口一直堵着。
func _send_off(tank: Node2D) -> void:
	if tank == null or not is_instance_valid(tank) or not tank.has_method("set_ai_state"):
		return
	var tx: int = level.px_to_tile(global_position.x)
	var ty: int = level.px_to_tile(global_position.y)
	var dirs: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
	var free: Array[Vector2i] = []
	for step in [2, 1]:
		for d in dirs:
			var c := Vector2i(tx + d.x * step, ty + d.y * step)
			if bool(level.is_tile_clear_for_unit(c.x, c.y)):
				free.append(c)
		if not free.is_empty():
			break
	if free.is_empty():
		return
	var cell: Vector2i = free[randi() % free.size()]
	tank.call("set_ai_state", "GoToSound", {"pos": level.cell_center(cell.x, cell.y)})


## 本格能不能产出：H5 用"坦克占格"判断；本项目坦克不维护占格 → 直接看上一只是否还堵在门口
func _is_spawn_tile_free(tx: int, ty: int) -> bool:
	if not bool(level.is_tile_free(tx, ty)):
		return false
	for t in _spawned:
		if not is_instance_valid(t) or not bool(t.get("alive")):
			continue
		if level.px_to_tile(t.global_position.x) == tx and level.px_to_tile(t.global_position.y) == ty:
			return false
	return true


## 场上还活着的产出坦克数（H5 aliveCount）
func _alive_count() -> int:
	var n := 0
	for t in _spawned:
		if is_instance_valid(t) and bool(t.get("alive")):
			n += 1
	return n


## 右上角产出进度贴图（H5 (25,25) + anchor(1,1)：图 = progress_[6-已产出]）
func _update_progress() -> void:
	if _progress == null:
		return
	var path := PROGRESS_TEX % clampi(MAX_SPAWNED - _spawned.size(), 0, MAX_SPAWNED)
	if not ResourceLoader.exists(path):
		return
	_progress.texture = load(path)
	_progress.offset = -(_progress.texture as Texture2D).get_size()   # 右下角对齐


## 分数随已产出数递减（H5 points getter：500 + 200×kind + (6-已产出)×(150+50×kind)）
func _update_points() -> void:
	points = 500 + 200 * enemy_kind + (MAX_SPAWNED - _spawned.size()) * (150 + 50 * enemy_kind)


## 视觉兜底：kind 已在场景里确定时才加载；否则等 apply_kind 指定
func _configure_enemy_visuals() -> void:
	if _body_sprite.sprite_frames != null:
		return
	_build_body_frames(enemy_kind)
