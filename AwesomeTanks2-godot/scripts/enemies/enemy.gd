extends ATTank
## Enemy —— 敌人基类（玩家与敌人共用 ATTank 的移动/受击/后坐力；本类补敌人专属参数、武器与 AI）
##
## 场景结构（scenes/Enemy.tscn = tank.tscn + 本脚本 + 节点状态机）：
##   Enemy (CharacterBody2D, ATEnemy)
##   ├─ Body / BodySprite / TurretSprite   —— 来自 tank.tscn
##   ├─ BaseSprite (Sprite2D)              —— 固定炮塔的底座贴图（默认隐藏）
##   ├─ <Weapon> (scenes/weapons/*.tscn)   —— 敌人武器：作为子节点实例，本类在 _ready 收集
##   └─ StateMachine (scripts/fsm)         —— 敌人 AI（Idle / GoToSound / GoToPlayer / Frozen）
##
## 「每种敌人一个场景」的约定（scenes/enemies/*.tscn 都实例化本场景并覆盖属性）：
##   - 基本参数（血量/速度/视野/分数/开火角…）直接写在各敌人场景的导出属性里；
##   - 车体与炮塔贴图写在各敌人场景的 SpriteFrames 上（可放多帧动画）；
##   - 武器用「武器场景实例」挂成子节点，并在场景里覆盖 CPU 专用参数（damage/rate/…）；
##   - 被合并的同类敌人（炮塔/生成器）用形态场景 + apply_type/apply_kind 在运行时套数据。
## 本类只做兜底：若场景没给 SpriteFrames，才用 tank_key 按命名规则加载。

class_name ATEnemy

# —— 敌人基本参数（各敌人场景覆盖）——
## 敌人类型标识（如 "minigun"/"boss_shotgun"，供日志/成就/掉落判断）
@export var enemy_id: String = ""
## 贴图前缀（仅兜底用：sprites/game/tanks/<tank_key>_body_0/1.png + <tank_key>.png）
@export var tank_key: String = "minigun"
## 击杀得分
@export var points: int = 100
## 是否为 Boss（体型/血量另有差异）
@export var is_boss: bool = false
## 开火角度容差（度）：炮塔与目标夹角小于它才开火（H5 shootAngle）
@export var shoot_angle: float = 10.0
## 开火距离（px）：进入该距离内才考虑开火（H5 shootRange）
@export var shoot_range: float = 150.0
## 警戒/联动半径（px）：同伴开枪时互相唤醒（H5 alertOthers 的 4e4 → 200px）
@export var alert_radius: float = 200.0
## 重算路径的最小间隔（秒）——避免每帧跑 A*（见 navigate_to）
@export var repath_interval: float = 0.45
## 路径点到达判定距离（px）
@export var waypoint_reach: float = 14.0

## 节点式状态机（scenes/Enemy.tscn 里的 StateMachine 子节点）
@onready var ai: StateMachine = get_node_or_null("StateMachine") as StateMachine

var alerted: bool = false
var level: Node2D = null            # 指向 Level，用于查询瓦片/玩家
var alerted_time: float = 0.0       # 剩余警戒时间（H5 _alerted = 2.5s）


func _ready() -> void:
	super._ready()
	team = Constants.Team.CPU
	health = max_health
	_collect_weapons()
	_configure_enemy_visuals()


## 收集挂在敌人场景里的武器子节点（武器 = 独立场景实例），并注入坦克/队伍
func _collect_weapons() -> void:
	weapons.clear()
	for child in get_children():
		if child is ATWeapon:
			var w: ATWeapon = child
			w.tank = self
			w.team = team
			weapons.append(w)
	if not weapons.is_empty():
		weapon = weapons[0]
		weapon_index = 0


## 视觉兜底：场景里已设置 SpriteFrames 就用场景的（每类敌人一场景，贴图写在场景里）；
## 未设置且 tank_key 非空时才按命名规则加载（形态场景 tank_key 为空，等 apply_type 指定类型）。
func _configure_enemy_visuals() -> void:
	if tank_key == "":
		return
	var base := "res://sprites/game/tanks/" + tank_key
	if _body_sprite.sprite_frames == null:
		configure_body_animation([base + "_body_0.png.tres", base + "_body_1.png.tres"])
	if _turret_sprite.sprite_frames == null:
		configure_turret_frames({ "default": [base + ".png.tres"] })
		switch_turret("default")


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if alerted_time > 0.0:
		alerted_time -= delta
		alerted = alerted_time > 0.0
	if _repath_timer > 0.0:
		_repath_timer -= delta


# ============================================================
# 移动 / 寻路（基于 Level 的 ATPathfinder；无寻路时退化为直线推进）
# ============================================================
var _path: PackedVector2Array = PackedVector2Array()
var _path_index: int = 0
var _path_goal_cell: Vector2i = Vector2i(-1, -1)
var _repath_timer: float = 0.0


## 朝目标点移动（自动寻路）。返回是否正在推进。
##   直线可走 → 直接朝目标推进（快路径，手感也更自然）
##   被墙/障碍挡住 → 用 ATPathfinder 的 A* 路径绕过（按 repath_interval 重算）
func navigate_to(target: Vector2) -> bool:
	if move_speed <= 0.0:
		return false
	var pf := _pathfinder()
	if pf == null:
		move_towards_point(target)
		return true
	# 1) 快路径：视线（格子直线）通畅就直接冲
	if pf.is_line_walkable(global_position, target):
		_reset_path()
		move_towards_point(target)
		return true
	# 2) 需要绕路：目标格变化或到达重算间隔时重新 A*
	var goal := pf.world_to_cell(target)
	if _path.is_empty() or goal != _path_goal_cell or _repath_timer <= 0.0:
		_repath_timer = repath_interval
		_path_goal_cell = goal
		_path = pf.smooth_path(pf.find_path(global_position, target), global_position)
		_path_index = 0
	if _path.is_empty():
		# 连部分路径都没有（起点格异常，如站在实体格里）：硬顶过去，别原地发呆
		move_towards_point(target)
		return false
	# 3) 跟随路径点
	var wp := _path[_path_index]
	while _path_index < _path.size() - 1 \
			and global_position.distance_to(wp) <= waypoint_reach:
		_path_index += 1
		wp = _path[_path_index]
	if global_position.distance_to(wp) <= waypoint_reach:
		move(Vector2.ZERO)
		return true
	move_towards_point(wp)
	return true


## 只朝一个点直线推进（不寻路）
func move_towards_point(target: Vector2) -> void:
	var dir := target - global_position
	if dir.length() <= 1.0:
		move(Vector2.ZERO)
		return
	move(dir.normalized())


func _reset_path() -> void:
	_path = PackedVector2Array()
	_path_index = 0
	_path_goal_cell = Vector2i(-1, -1)


func _pathfinder() -> ATPathfinder:
	if level == null:
		return null
	return level.get("pathfinder") as ATPathfinder


## 当前是否有绕路路径（调试用）
func has_path() -> bool:
	return not _path.is_empty()


## 切到指定 AI 状态（状态名见 scenes/Enemy.tscn 的 StateMachine 子节点）
func set_ai_state(state_name: String, msg: Dictionary = {}) -> void:
	if ai != null:
		ai.transition_to(state_name, msg)


## 当前 AI 状态名（无状态机返回空串）
func ai_state_name() -> String:
	if ai != null and ai.current_state != null:
		return str(ai.current_state.name)
	return ""


## 巡逻：尝试朝玩家方向移动并开火，返回是否看到玩家（由状态机驱动，保留给外部调用）
func patrol(_see_player: bool) -> bool:
	return ai_state_name() == "GoToPlayer"


## 警戒链：通知附近同伴（H5 alertOthers：半径内敌人一起警觉）
func alert_others() -> void:
	if level == null:
		return
	for e in level.enemies:
		if is_instance_valid(e) and e != self and e.has_method("on_alerted"):
			if global_position.distance_squared_to((e as Node2D).global_position) \
					<= alert_radius * alert_radius:
				e.on_alerted(global_position)


## 听到声音：去调查（正在追击玩家时不受影响，H5 同）
func on_alerted(from_pos: Vector2) -> void:
	alerted_time = 2.5
	alerted = true
	var cur := ai_state_name()
	if cur == "GoToPlayer" or cur == "Frozen":
		return
	set_ai_state("GoToSound", {"pos": from_pos})


func on_player_in_sight() -> void:
	set_ai_state("GoToPlayer")


func on_bullet_hit(damage: float, src_weapon: Node, bullet: Node) -> void:
	super.on_bullet_hit(damage, src_weapon, bullet)
	alerted_time = 2.5
	alerted = true
	if alive:
		_try_ignite(src_weapon)


# ============================================================
# 火焰点燃（H5：命中体 onBulletHit 里 instanceof Flamethrower/Fire 就挂 window.AT.Fire）
# ============================================================
## 被点燃时每物理帧受到的灼烧伤害（H5：敌坦克/Boss = 2，炮塔 = 4，生成器 = 0.5）
@export var burn_damage: float = 2.0
## 燃烧时长（秒）；< 0 时用 H5 默认 (85 + 30×随机)/60
@export var burn_duration: float = -1.0


## 被火焰命中 → 点燃（已在燃烧则不叠加），并解冻（H5 同：火烧到冰就化）
func _try_ignite(src: Node) -> void:
	if not ATBurning.is_flame_source(src, team):
		return
	if ai_state_name() == "Frozen":
		unfreeze()
	ATBurning.attach_from(self, burn_damage, src, burn_duration)


# ============================================================
# 冰冻（冰冻道具/电击效果调用；对应 H5 onFreeze/onUnfreeze）
# ============================================================
func freeze() -> void:
	ATBurning.extinguish(self)   # H5 onFreeze：fire.time = 0（冰冻灭火）
	set_ai_state("Frozen")


func unfreeze() -> void:
	if ai_state_name() == "Frozen":
		set_ai_state("Idle")


func _kill() -> void:
	if ai != null:
		ai.enabled = false   # 死亡后停止 AI（不再移动/开火）
	super._kill()
