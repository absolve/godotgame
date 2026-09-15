class_name ATBurning
extends Sprite2D
## ATBurning —— 点燃/灼烧组件（对应原项目 window.AT.Fire，awesome_tanks_2.js L21064~21087）
##
## 场景：scenes/fx/burning.tscn（根节点就是本类，贴图运行时从 fire_0..3 随机取）
## 用法（不做叠加，同一目标同时只会有一处火）：
##     ATBurning.attach(目标, 每帧伤害, 时长, 火力所属队伍)
##     ATBurning.is_burning(目标) / ATBurning.extinguish(目标)
##
## H5 行为要点：
##   - 挂在被点燃单位身上，**每个物理帧**调用一次 `目标.on_bullet_hit(伤害, self, null)`；
##     也就是"每帧掉血"，由各目标类型决定每帧伤害（敌坦克/Boss 2、炮塔 4、生成器 0.5、
##     玩家 2、油桶 1、木板 0.25×武器直击伤害）；
##   - 时长默认 (85 + 30×随机)/60 ≈ 1.42~1.92s（玩家被点燃时由 (55+40×关卡序号)/60 给定）；
##   - 已在燃烧的目标不会被再次点燃（不叠加，只能等烧完再续）；
##   - 表现：fire_0..3 随机取图 + 随机旋转 + 随机锚点抖动 + alpha 0.5~1.0 随机，
##     每 2 帧刷新一次；最后 0.2s 淡出；
##   - 木板（wood）：每 0.9~1.1s 向上下左右四格的木板各打 1 点并点燃它们（连锁烧穿木墙）；
##   - 被点燃会解冻（由目标侧调用 unfreeze），而冰冻会灭火（目标 freeze 时调用 extinguish）。

## 火焰贴图（4 帧，随机取，不是顺序动画）
const TEX_FIRE: Array[Texture2D] = [
	preload("res://sprites/game/fire_0.png.tres"),
	preload("res://sprites/game/fire_1.png.tres"),
	preload("res://sprites/game/fire_2.png.tres"),
	preload("res://sprites/game/fire_3.png.tres"),
]
const SCENE := preload("res://scenes/fx/burning.tscn")

## 燃烧表现刷新间隔（帧）——H5 用 step 计数，等价每 2 帧刷一次
const REFRESH_FRAMES := 2
## 末尾淡出时长（秒）——H5: min(1, time / .2)
const FADE_TIME := 0.2
## 每帧伤害（由 attach 传入；作为默认值给场景预览用）
@export var damage_per_frame: float = 2.0
## 是否向相邻木板蔓延（只有木板开启）
@export var spreads_fire: bool = false

## 火焰命中色（H5 hitColor = 16755200 = #FFB300），受击闪光照用
var hit_color: Color = Color(1.0, 0.70196, 0.0)
## 是否属于"火焰来源"（供目标判断能否被点燃，与武器的 ignites 同义）
var ignites: bool = true
## 火力所属队伍（避免同队互烧）
var team: int = -1

var _time: float = 0.0
var _frame: int = 0
var _spread_timer: float = 0.0
var _target: Node2D = null


# ============================================================
# 对外接口
# ============================================================
## 点燃目标（正在燃烧则返回 null = 不叠加）；duration < 0 用 H5 默认随机时长
static func attach(target: Node2D, damage: float, duration: float = -1.0,
		from_team: int = -1, spread: bool = false) -> ATBurning:
	if target == null or not is_instance_valid(target) or not target.is_inside_tree():
		return null
	if is_burning(target):
		return null
	var fire: ATBurning = SCENE.instantiate()
	fire.damage_per_frame = damage
	fire.spreads_fire = spread
	fire.team = from_team
	fire._time = duration if duration > 0.0 else (85.0 + 30.0 * randf()) / 60.0
	target.add_child(fire)
	return fire


## 命中来源是否属于"会点燃的火焰"（H5: instanceof Flamethrower || instanceof Fire），
## 且与受击方不同队（H5 敌坦克只被玩家火焰点燃，避免同伴互烧）
static func is_flame_source(src: Node, my_team: int) -> bool:
	if src == null or not is_instance_valid(src):
		return false
	if not ("ignites" in src) or not bool(src.get("ignites")):
		return false
	var st = src.get("team")
	return st == null or int(st) != my_team


## 按"火焰来源"给目标点火：来源不是火焰 → 不点；单位还要不同队；已在燃烧 → 不叠加（H5 同）
## （无 team 的目标 = 木箱/木板/油桶这类物体，任何一方的火焰都能点燃）
static func attach_from(target: Node2D, damage: float, src: Node,
		duration: float = -1.0, spread: bool = false) -> ATBurning:
	if src == null or not is_instance_valid(src):
		return null
	if not ("ignites" in src) or not bool(src.get("ignites")):
		return null
	var has_team: bool = "team" in target
	if has_team and not is_flame_source(src, int(target.get("team"))):
		return null
	var src_team := -1
	var st = src.get("team")
	if st != null:
		src_team = int(st)
	return attach(target, damage, duration, src_team, spread)


static func is_burning(target: Node) -> bool:
	return find_fire(target) != null


static func find_fire(target: Node) -> ATBurning:
	if target == null or not is_instance_valid(target):
		return null
	for child in target.get_children():
		if child is ATBurning:
			return child
	return null


## 灭火（冰冻时调用）
static func extinguish(target: Node) -> void:
	var fire := find_fire(target)
	if fire != null:
		fire.stop()


## 立即熄灭（不播淡出，直接消失）
func stop() -> void:
	_time = 0.0
	var p := get_parent()
	if p != null:
		p.remove_child(self)   # 立刻脱离目标：is_burning 马上变 false
	queue_free()


# ============================================================
# 生命周期：每帧结算伤害 + 表现
# ============================================================
func _ready() -> void:
	z_index = 20                     # 盖在被点燃单位本体之上
	_target = get_parent() as Node2D
	position = Vector2.ZERO
	_spread_timer = 0.9 + 0.2 * randf()   # H5: spreadTimer = .9 + .2*rand
	texture = TEX_FIRE[randi() % TEX_FIRE.size()]
	_refresh_look()


func _physics_process(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		queue_free()
		return
	# 目标已死（坦克 alive=false）→ 灭火，避免继续对尸体结算
	if "alive" in _target and not bool(_target.get("alive")):
		queue_free()
		return
	_time -= delta
	if _time <= 0.0:
		queue_free()
		return
	# 每帧结算一次灼烧（H5：Fire.update 里直接调用目标的 onBulletHit）
	if _target.has_method("on_bullet_hit"):
		_target.on_bullet_hit(damage_per_frame, self, null)
	# 表现：每 2 帧随机取图/旋转/抖动一次，末尾 0.2s 淡出
	_frame += 1
	if _frame % REFRESH_FRAMES == 0:
		_refresh_look()
	# 木板蔓延
	if spreads_fire:
		_spread_timer -= delta
		if _spread_timer <= 0.0:
			_spread_timer = 0.9 + 0.2 * randf()
			_spread_fire_to_wood()


func _refresh_look() -> void:
	texture = TEX_FIRE[randi() % TEX_FIRE.size()]
	rotation = randf() * TAU
	# H5: anchor.set(.45 + .1*rand, .45 + .1*rand) → 锚点抖动 ≈ 贴图尺寸的 ±5%
	var w := 62.0
	var h := 54.0
	if texture != null:
		w = float(texture.get_width())
		h = float(texture.get_height())
	offset = Vector2((randf() - 0.5) * 0.1 * w, (randf() - 0.5) * 0.1 * h)
	var fade := minf(1.0, _time / FADE_TIME) if _time > 0.0 else 0.0
	modulate.a = (0.5 + 0.5 * randf()) * fade


# ============================================================
# 木板蔓延（H5 Fire.spread：四邻格里的木板各受 1 点并点燃）
# ============================================================
func _spread_fire_to_wood() -> void:
	if _target == null or not is_instance_valid(_target):
		return
	var space := _target.get_world_2d().direct_space_state
	if space == null:
		return
	var ts := float(Settings.TILE_SIZE)
	var origin := _target.global_position
	var shape := CircleShape2D.new()
	shape.radius = 2.0
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.collision_mask = Constants.layer_mask([Constants.Layer.OBSTACLE])
	for dir in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		query.transform = Transform2D(0.0, origin + dir * ts)
		for hit in space.intersect_shape(query, 4):
			var obj := hit.get("collider") as Node
			if obj == null or obj == _target or not is_instance_valid(obj):
				continue
			if not obj is ATObstacle:
				continue
			# 只有木板会烧起来（H5 spread 只对 Wood 生效）
			if int((obj as ATObstacle).tile_type) != Constants.Tile.WOOD:
				continue
			obj.on_bullet_hit(1.0, self, null)
