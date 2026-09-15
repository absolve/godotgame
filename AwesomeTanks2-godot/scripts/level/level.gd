extends Node2D
## Level —— 关卡场景根脚本（本场景唯一逻辑脚本；对应原项目 window.AT.Level）
##
## 设计约定：
##   - 关卡内 UI（HUD 底栏 + 暂停/放弃/帮助/结算弹窗）都布置在 Level.tscn 中；
##     可复用组件（血瓶、武器槽、各弹窗）是独立 .tscn 场景被实例化，
##     它们只维护自身视觉并发出信号，所有游戏流程/状态判断都在本根脚本。
##   - 瓦片地图解析/静态墙构建（原 tile_map.gd）已合并进本脚本，
##     场景中不再单独挂 TileMap 脚本。
##
## HUD 坐标约定与 H5 一致：原点 = 屏幕底部中心，y 向上为负。

signal level_started
signal enemy_killed(points: int)
signal player_killed
signal level_complete(success: bool, profit: int)

# 武器槽顺序（与场景中 Slot_<key> 实例一一对应）
const SLOT_KEYS: Array[String] = [
	"minigun", "shotgun", "ricochet", "flamethrower", "cannon",
	"shock", "rockets", "laser", "railgun", "mines",
]

# 弹窗脚本（供类型化引用）
const PauseAlertScript := preload("res://scripts/ui/pause_alert.gd")
const AbandonAlertScript := preload("res://scripts/ui/abandon_alert.gd")
const HelpAlertScript := preload("res://scripts/ui/help_alert.gd")
const SummaryAlertScript := preload("res://scripts/ui/summary_alert.gd")

# 音乐/音效图标（存档状态切换 on/off 帧）
const TEX_MUSIC_ON: Texture2D = preload("res://sprites/game/hud/music_on.png.tres")
const TEX_MUSIC_OFF: Texture2D = preload("res://sprites/game/hud/music_off.png.tres")
const TEX_SOUND_ON: Texture2D = preload("res://sprites/game/hud/sound_on.png.tres")
const TEX_SOUND_OFF: Texture2D = preload("res://sprites/game/hud/sound_off.png.tres")

# 主题地板贴图（平铺背景）
const TEX_FLOOR: Dictionary = {
	Constants.gameTheme.GRASS: preload("res://sprites/game/grass.png.tres"),
	Constants.gameTheme.SNOW: preload("res://sprites/game/snow.png.tres"),
	Constants.gameTheme.DESERT: preload("res://sprites/game/desert.png.tres"),
}

# 墙体贴图（随机选）
const TEX_WALLS: Array = [
	preload("res://sprites/game/wall_0.png.tres"),
	preload("res://sprites/game/wall_1.png.tres"),
	preload("res://sprites/game/wall_2.png.tres"),
]
const TEX_SECRET: Texture2D = preload("res://sprites/game/secret.png.tres")

@onready var _objects_layer: Node2D = $ObjectsLayer
@onready var _top_layer: Node2D = $TopLayer
@onready var customCamera: Camera2D = $customCamera

# HUD 节点引用（均在 Level.tscn 中静态布置）
@onready var _bottom: Control = $HUD/HudRoot/Bottom
@onready var _health_vial: Control = $HUD/HudRoot/Bottom/HealthVial
@onready var _pause_icon: TextureButton = $HUD/HudRoot/Bottom/PauseIcon
@onready var _music_icon: TextureButton = $HUD/HudRoot/Bottom/MusicIcon
@onready var _sound_icon: TextureButton = $HUD/HudRoot/Bottom/SoundIcon
@onready var _profit_bg: TextureRect = $HUD/HudRoot/Bottom/Profit
@onready var _profit_value: Label = $HUD/HudRoot/Bottom/Profit/Value
@onready var _fight: TextureRect = $HUD/HudRoot/Bottom/Fight

# 弹窗（HUD CanvasLayer 内实例，常驻 ALWAYS，暂停中仍可交互）
@onready var _pause_alert: PauseAlertScript = $HUD/PauseAlert
@onready var _abandon_alert: AbandonAlertScript = $HUD/AbandonAlert
@onready var _help_alert: HelpAlertScript = $HUD/HelpAlert
@onready var _summary_alert: SummaryAlertScript = $HUD/SummaryAlert

var level_index: int = 0
var level_data: Array = []
var player: Node = null
var enemies: Array[Node2D] = []
var enemies_alive: int = 0
var points: int = 0
var profit: float = 0.0
var freeze_time: float = 0.0
var free_camera: bool = false
var difficulty_mult: float = 1.0

# ---- 瓦片地图（原 tile_map.gd 合并而来） ----
var tiles: Array = [] # tiles[y][x] = Tile 枚举
var map_width: int = 0
var map_height: int = 0
var map_theme: int = 0 # Constants.gameTheme
var occupancy: Array = [] # 动态对象占据标记（tiles 同尺寸）

var _fog: ATFog = null       # 黑雾（scenes/level/fog.tscn，_ready 中实例化）
var _fog_frame: int = 0      # 惰性更新计数（约每 3 帧发射一次视野射线）

## 寻路网格（scripts/level/pathfinder.gd；敌人 AI 用它绕开墙/障碍）
var pathfinder: ATPathfinder = null

var _slot_nodes: Array = []
var _last_hp_ratio: float = -1.0
var _profit_tween: Tween = null
var _fight_tween: Tween = null
var _summary_success: bool = false

# 关卡对象场景（玩家 + 障碍物瓦片 → 场景，_spawn_objects 直接按瓦片添加）
const SCENE_PLAYER := preload("res://scenes/Player.tscn")
const OBJECT_SCENES: Dictionary = {
	Constants.Tile.BARREL: preload("res://scenes/objects/barrel.tscn"),
	Constants.Tile.CRATE: preload("res://scenes/objects/crate.tscn"),
	Constants.Tile.GATE: preload("res://scenes/objects/gate.tscn"),
	Constants.Tile.WOOD: preload("res://scenes/objects/wood.tscn"),
	Constants.Tile.BRICKS_1: preload("res://scenes/objects/bricks.tscn"),
	Constants.Tile.BRICKS_2: preload("res://scenes/objects/bricks.tscn"),
}

# 敌人瓦片 → 敌人场景名（scenes/enemies/<名>.tscn）。
# 坦克 9 种与 Boss 7 种差异较大，各自独立场景；炮塔 8 种、生成器 7 种只是
# 贴图/武器/数值不同，合并为两个"形态场景"（TurretEnemy / Spawner），
# 类型数据见 scripts/enemies/enemy_types.gd。
const ENEMY_DIR := "res://scenes/enemies/"
const ENEMY_NAMES: Dictionary = {
	# 移动坦克 9 种
	Constants.Tile.TANK_MINIGUN: "EnemyMinigun",
	Constants.Tile.TANK_SHOTGUN: "EnemyShotgun",
	Constants.Tile.TANK_CANNON: "EnemyCannon",
	Constants.Tile.TANK_ROCKETS: "EnemyRockets",
	Constants.Tile.TANK_LASER: "EnemyLaser",
	Constants.Tile.TANK_RICOCHET: "EnemyRicochet",
	Constants.Tile.TANK_FLAMETHROWER: "EnemyFlamethrower",
	Constants.Tile.TANK_RAILGUN: "EnemyRailgun",
	Constants.Tile.TANK_KAMIKAZE: "EnemyKamikaze",
	# Boss 7 种
	Constants.Tile.BOSS_SHOTGUN: "BossShotgun",
	Constants.Tile.BOSS_CANNON: "BossCannon",
	Constants.Tile.BOSS_ROCKETS: "BossRockets",
	Constants.Tile.BOSS_LASER: "BossLaser",
	Constants.Tile.BOSS_RICOCHET: "BossRicochet",
	Constants.Tile.BOSS_RAILGUN: "BossRailgun",
	Constants.Tile.BOSS_FLAMETHROWER: "BossFlamethrower",
}

var _enemy_scene_cache: Dictionary = {}
var _turret_scene: PackedScene = null
var _spawner_scene: PackedScene = null


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	level_index = Game.consume_pending_level_index()
	level_data = ATLevels.get_level(level_index)
	difficulty_mult = Settings.DIFFICULTIES[int(Game.current["game"]["difficulty"])] \
		if int(Game.current["game"]["difficulty"]) >= 0 else 1.0
	parse(level_data)
	_setup_pathfinder()
	_spawn_objects()
	_setup_fog()
	_collect_hud_nodes()
	_sync_audio_icons()
	_connect_popups()
	level_started.emit()
	Audio.play_music("music_game.mp3")


func _connect_popups() -> void:
	_pause_alert.continue_pressed.connect(_resume_game)
	_pause_alert.music_toggled.connect(_on_music_set)
	_pause_alert.sound_toggled.connect(_on_sound_set)
	_abandon_alert.confirmed.connect(_on_abandon_confirmed)
	_abandon_alert.canceled.connect(_on_abandon_canceled)
	_help_alert.closed.connect(_on_help_closed)
	_summary_alert.continue_pressed.connect(_on_summary_continue)


# ============================================================
# 瓦片地图：解析 ASCII 关卡 → 网格 + 静态墙（原 tile_map.gd）
# ============================================================
## 解析关卡数据（来自 ATLevels.LEVELS 的元素：名称/主题/若干行字符）
func parse(_level_data: Array) -> void:
	#var name: String = level_data[0]
	map_theme = Constants.THEME_NAMES.get(_level_data[1], Constants.gameTheme.GRASS)
	var rows: Array = _level_data.slice(2)
	map_height = rows.size()
	map_width = 0
	for r in rows:
		map_width = max(map_width, (r as String).length())
	tiles.clear()
	occupancy.clear()
	for y in range(map_height):
		var row_arr: Array = []
		var occ_row: Array = []
		var row_str: String = rows[y]
		for x in range(map_width):
			var ch: String = " " if x >= row_str.length() else row_str[x]
			var tile: int = int(Constants.CHAR_TO_TILE.get(ch, Constants.Tile.EMPTY))
			row_arr.append(tile)
			occ_row.append(false)
		tiles.append(row_arr)
		occupancy.append(occ_row)
	_build_static_tiles()


## 构建静态瓦片：主题地板 + 墙体 + 秘密墙（每格一个 StaticBody2D + Sprite2D）
func _build_static_tiles() -> void:
	var static_layer := get_node_or_null("StaticLayer")
	if static_layer == null:
		return
	# 清空旧节点（保留 parse 前可能已存在的子节点）
	for c in static_layer.get_children():
		c.queue_free()

	var ts := Settings.TILE_SIZE

	# 1. 主题地板背景（TextureRect 平铺整个关卡）
	var floor1 = TextureRect.new()
	floor1.name = "Floor"
	floor1.position = Vector2.ZERO
	floor1.size = Vector2(map_width * ts, map_height * ts)
	floor1.texture = TEX_FLOOR.get(map_theme, TEX_FLOOR[Constants.gameTheme.GRASS])
	floor1.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	floor1.texture_repeat = TextureRect.TEXTURE_REPEAT_ENABLED
	floor1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	static_layer.add_child(floor1)

	# 2. 逐格构建静态墙 + 秘密墙
	for y in range(map_height):
		for x in range(map_width):
			var t: int = tiles[y][x]
			if not Constants.is_static_wall(t):
				continue
			var pos := cell_center(x, y)
			var body := StaticBody2D.new()
			body.position = pos
			body.collision_layer = 1 << (Constants.Layer.WALL - 1)
			body.collision_mask = 0
			var shape := RectangleShape2D.new()
			shape.size = Vector2(ts, ts)
			var cs := CollisionShape2D.new()
			cs.shape = shape
			body.add_child(cs)
			var sprite := Sprite2D.new()
			sprite.centered = true
			if t == Constants.Tile.SECRET:
				sprite.texture = TEX_SECRET
			else:
				sprite.texture = TEX_WALLS[randi() % TEX_WALLS.size()]
			body.add_child(sprite)
			static_layer.add_child(body)


# ============================================================
# 寻路（敌人 AI 用；网格来自 scripts/level/pathfinder.gd）
# ============================================================
## 按解析后的地图建立寻路网格：静态墙/秘密墙不可通行。
## 可破坏障碍物在生成时标记、被摧毁时解除，所以炸开后路径会重新打通。
func _setup_pathfinder() -> void:
	pathfinder = ATPathfinder.new()
	pathfinder.setup(map_width, map_height, Settings.TILE_SIZE)
	for y in range(map_height):
		for x in range(map_width):
			if Constants.is_static_wall(tiles[y][x]):
				pathfinder.set_solid(x, y, true)


## 障碍物占格：标记不可通行，并在被摧毁（queue_free 前发 destroyed）时解除
func _mark_obstacle_tile(obj: Node2D, x: int, y: int) -> void:
	if pathfinder == null:
		return
	pathfinder.set_solid(x, y, true)
	if obj is ATObstacle:
		(obj as ATObstacle).destroyed.connect(_on_obstacle_destroyed.bind(x, y))


func _on_obstacle_destroyed(_obstacle: Node, x: int, y: int) -> void:
	if pathfinder != null:
		pathfinder.set_solid(x, y, false)


## 世界坐标寻路（给外部/调试用；无寻路器时返回空数组 = 不可达）
func find_path(from_world: Vector2, to_world: Vector2) -> PackedVector2Array:
	if pathfinder == null:
		return PackedVector2Array()
	return pathfinder.find_path(from_world, to_world)


## 两点间是否可直线通行（格子级判定）
func is_line_walkable(from_world: Vector2, to_world: Vector2) -> bool:
	return pathfinder != null and pathfinder.is_line_walkable(from_world, to_world)


# 坐标换算（瓦片 <-> 像素）
func tile_to_px(coord: int) -> float:
	return (coord + 0.5) * Settings.TILE_SIZE


func px_to_tile(px: float) -> int:
	return int(px / Settings.TILE_SIZE)


func cell_center(x: int, y: int) -> Vector2:
	return Vector2(tile_to_px(x), tile_to_px(y))


# 占位查询（动态对象占据后标记）
func is_tile_free(x: int, y: int) -> bool:
	if x < 0 or x >= map_width or y < 0 or y >= map_height:
		return false
	if Constants.is_static_wall(tiles[y][x]):
		return false
	return not occupancy[y][x]


func occupy_tile(x: int, y: int) -> void:
	if x >= 0 and x < map_width and y >= 0 and y < map_height:
		occupancy[y][x] = true


func free_tile(x: int, y: int) -> void:
	if x >= 0 and x < map_width and y >= 0 and y < map_height:
		occupancy[y][x] = false


## 遍历所有非空瓦片，按类型回调（用于实例化对象）
# func for_each_object(callback: Callable) -> void:
# 	for y in range(map_height):
# 		for x in range(map_width):
# 			var t: int = tiles[y][x]
# 			if t != Constants.Tile.EMPTY and not Constants.is_static_wall(t):
# 				callback.call(t, x, y)


# ============================================================
# HUD（场景树静态节点）
# ============================================================
func _collect_hud_nodes() -> void:
	_slot_nodes.clear()
	for key in SLOT_KEYS:
		_slot_nodes.append(_bottom.get_node("Slot_" + key))


## 玩家生成后由本关卡调用（后续 _spawn_player 实现时接入）
func bind_player(p: Node) -> void:
	player = p
	_last_hp_ratio = -1.0
	_refresh_hud()


func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	if freeze_time > 0:
		freeze_time -= delta
		if freeze_time <= 0:
			_unfreeze_enemies()
	_refresh_hud()
	# 迷雾惰性更新（H5 updateFogLazy：约每 3 帧一次）
	_fog_frame += 1
	if _fog != null and player != null and is_instance_valid(player) \
			and _fog_frame % 3 == 0:
		_update_fog()


## 按玩家位置/炮塔朝向刷新黑雾：
##   1) 清掉玩家脚下周围一圈黑雾瓦片（能看到自己）；
##   2) 按炮塔方向发射扇形视野射线清雾（射线与墙/黑雾碰撞，墙后不生效）。
func _update_fog() -> void:
	if _fog == null or player == null or not is_instance_valid(player):
		return
	var ts := Settings.TILE_SIZE
	var px := int(player.global_position.x / ts)
	var py := int(player.global_position.y / ts)
	_fog.clear_area(px, py, _fog.clear_radius_tiles)
	var view_angle := float(player.get("view_angle")) if "view_angle" in player else PI / 4.0
	var view_dist := float(player.get("view_distance")) if "view_distance" in player else 300.0
	var aim: float = player.get_turret_rotation() if player.has_method("get_turret_rotation") \
		else float(player.rotation)
	_fog.reveal_fov(player.global_position, aim, view_angle, view_dist)


## 地图加载完成后创建黑雾：实例化 fog.tscn 并逐格铺满整张地图
func _setup_fog() -> void:
	_fog = (preload("res://scenes/level/fog.tscn") as PackedScene).instantiate()
	_fog.name = "Fog"
	add_child(_fog)
	_fog.z_index = 100   # 盖在静态层/物体层之上
	_fog.configure(0, 0, map_width, map_height)
	_fog.build_tiles()
	# 出生点先清一圈：本帧物理空间可能还没登记新瓦片，随后每 3 帧的
	# _update_fog 会再补一次（清掉缓存确保一定发射线）
	_update_fog()
	_fog.invalidate_cache()


## 每帧同步血瓶 / 武器槽（幂等；数据没变化时开销可忽略）
func _refresh_hud() -> void:
	if player == null or not is_instance_valid(player):
		return
	# 血瓶
	var hp := 0.0
	if "health" in player and "max_health" in player:
		hp = clampf(float(player.health) / maxf(float(player.max_health), 1.0), 0.0, 1.0)
	if absf(hp - _last_hp_ratio) > 0.001:
		_last_hp_ratio = hp
		_health_vial.call("set_ratio", hp)
	# 武器槽
	var weapons: Array = player.weapons if "weapons" in player else []
	var index: int = int(player.weapon_index) if "weapon_index" in player else -1
	for i in _slot_nodes.size():
		var w = weapons[i] if i < weapons.size() else null
		var owned: bool = w != null
		var pct := -1.0
		if owned and "max_ammo" in w and float(w.max_ammo) < 999999.0:
			pct = clampf(float(w.ammo) / maxf(float(w.max_ammo), 1.0), 0.0, 1.0)
		_slot_nodes[i].call("refresh", owned, owned and index == i, pct)


# ============================================================
# 暂停 / 菜单(放弃) / 帮助 / 结算 —— 流程状态机
# ============================================================
func _on_hud_pause_pressed() -> void:
	if _abandon_alert.visible or _help_alert.visible or _summary_alert.visible:
		return
	if get_tree().paused:
		_resume_game()
	else:
		_pause()

func _pause() -> void:
	get_tree().paused = true
	Audio.play_button_down()
	_pause_alert.open()

func _resume_game() -> void:
	get_tree().paused = false
	_pause_alert.close()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_hud_pause_pressed()
		get_viewport().set_input_as_handled()


func _on_hud_menu_pressed() -> void:
	if _abandon_alert.visible or _help_alert.visible or _summary_alert.visible \
			or _pause_alert.visible:
		return
	Audio.play_button_down()
	get_tree().paused = true
	_abandon_alert.open()


func _on_abandon_confirmed() -> void:
	get_tree().paused = false
	_abandon_alert.close()
	abandon()


func _on_abandon_canceled() -> void:
	get_tree().paused = false
	_abandon_alert.close()


func _on_hud_help_pressed() -> void:
	if _abandon_alert.visible or _help_alert.visible or _summary_alert.visible \
			or _pause_alert.visible:
		return
	Audio.play_button_down()
	get_tree().paused = true
	_help_alert.open()


func _on_help_closed() -> void:
	_help_alert.close()
	get_tree().paused = false


func _on_hud_music_pressed() -> void:
	Audio.play_button_down()
	_on_music_set(not bool(Game.current["game"].get("music", true)))


func _on_hud_sound_pressed() -> void:
	Audio.play_button_down()
	_on_sound_set(not bool(Game.current["game"].get("sound", true)))


func _on_music_set(on: bool) -> void:
	Audio.set_music_enabled(on)
	_sync_audio_icons()


func _on_sound_set(on: bool) -> void:
	Audio.set_sound_enabled(on)
	_sync_audio_icons()


## 同步 HUD 主栏图标与暂停面板开关的状态
func _sync_audio_icons() -> void:
	var game: Dictionary = Game.current.get("game", {})
	var music_on := bool(game.get("music", true))
	var sound_on := bool(game.get("sound", true))
	_music_icon.texture_normal = TEX_MUSIC_ON if music_on else TEX_MUSIC_OFF
	_sound_icon.texture_normal = TEX_SOUND_ON if sound_on else TEX_SOUND_OFF
	if is_instance_valid(_pause_alert):
		_pause_alert.set_audio_states(music_on, sound_on)


# ---------- 结算 ----------
func _show_summary(success: bool) -> void:
	_summary_success = success
	Game.finish_level(level_index, points, success)
	level_complete.emit(success, int(profit))
	get_tree().paused = true
	Audio.stop_music()
	Audio.play_sfx("level_won.mp3" if success else "level_lost.mp3")
	_summary_alert.open(success, int(profit))


func _on_summary_continue() -> void:
	get_tree().paused = false
	if _summary_success:
		Game.change_scene(Settings.SCENE_LEVEL_SELECT)
	else:
		Game.change_scene(Settings.SCENE_UPGRADES)


# ---------- 开打前/战斗中的小动画（供流程接入） ----------
func _show_profit(amount: int) -> void:
	if _profit_tween != null and _profit_tween.is_valid():
		_profit_tween.kill()
	_profit_value.text = _format_money(amount)
	_profit_bg.visible = true
	_profit_bg.position = Vector2(-118.0, -65.0)
	_profit_tween = create_tween()
	_profit_tween.tween_property(_profit_bg, "position", Vector2(-118.0, -95.0), 0.3) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_profit_tween.tween_interval(1.4)
	_profit_tween.tween_property(_profit_bg, "position", Vector2(-118.0, -65.0), 0.3) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_profit_tween.tween_callback(func() -> void: _profit_bg.visible = false)


func _show_fight() -> void:
	if _fight_tween != null and _fight_tween.is_valid():
		_fight_tween.kill()
	_fight.visible = true
	_fight.position = Vector2(-105.0, -700.0)
	_fight_tween = create_tween()
	_fight_tween.tween_interval(0.5)
	_fight_tween.tween_property(_fight, "position:y", -450.0, 0.6) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	_fight_tween.chain().tween_property(_fight, "position:y", 100.0, 0.5) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	_fight_tween.tween_callback(func() -> void: _fight.visible = false)


# ============================================================
# 关卡对象实例化（直接按瓦片添加）
# ============================================================
func _spawn_objects() -> void:
	# for_each_object(_spawn_object_at)
	for y in range(map_height):
		for x in range(map_width):
			var t: int = tiles[y][x]
			if t != Constants.Tile.EMPTY and not Constants.is_static_wall(t):
				_spawn_object_at.call(t, x, y)


func _spawn_object_at(tile: int, x: int, y: int) -> void:
	var pos := cell_center(x, y)
	# 1) 玩家出生点
	if tile == Constants.Tile.PLAYER:
		_spawn_player(pos, x, y)
		return
	# 2) 障碍物（油桶/木箱/门/木板/砖墙）——它们挡视野射线（物理层 OBSTACLE）
	if OBJECT_SCENES.has(tile):
		var obj: Node2D = (OBJECT_SCENES[tile] as PackedScene).instantiate()
		obj.position = pos
		if "tile_type" in obj:
			obj.tile_type = tile
		_objects_layer.add_child(obj)
		_mark_obstacle_tile(obj, x, y)
		return
	# 3) 敌人：坦克/Boss 走独立场景；炮塔/生成器走形态场景 + 类型数据
	if ENEMY_NAMES.has(tile) or ATEnemyTypes.TILE_TURRET.has(tile) \
			or ATEnemyTypes.TILE_SPAWNER.has(tile):
		_spawn_enemy_by_tile(tile, pos, x, y)
		return


## 按瓦片实例化敌人，登记到 enemies 并接击杀信号
##   - 坦克/Boss：各自独立场景（场景里已带贴图/数值/武器）
##   - 炮塔/生成器：同一个形态场景，入树后按类型数据 apply_type/apply_kind
func _spawn_enemy_by_tile(tile: int, pos: Vector2, x: int, y: int) -> void:
	var e: Node2D = null
	var is_turret: bool = ATEnemyTypes.TILE_TURRET.has(tile)
	var is_spawner: bool = ATEnemyTypes.TILE_SPAWNER.has(tile)
	if is_turret:
		if _turret_scene == null:
			_turret_scene = load(ATEnemyTypes.TURRET_SCENE) as PackedScene
		e = _turret_scene.instantiate()
	elif is_spawner:
		if _spawner_scene == null:
			_spawner_scene = load(ATEnemyTypes.SPAWNER_SCENE) as PackedScene
		e = _spawner_scene.instantiate()
	else:
		var scene := _enemy_scene_for(tile)
		if scene == null:
			push_warning("Level: 敌人场景缺失: ", ENEMY_NAMES.get(tile, "?"))
			return
		e = scene.instantiate()
	e.position = pos
	if "level" in e:
		e.level = self
	_objects_layer.add_child(e)
	# 形态场景：入树后（@onready 就绪）再应用类型数据（贴图/数值/武器）
	if is_turret:
		e.call("apply_type", ATEnemyTypes.TURRETS[ATEnemyTypes.TILE_TURRET[tile]])
	elif is_spawner:
		e.call("apply_kind", int(ATEnemyTypes.TILE_SPAWNER[tile]))
	enemies.append(e)
	enemies_alive += 1
	if e.has_signal("killed"):
		e.killed.connect(_on_enemy_unit_killed.bind(e))
	# 固定单位（炮塔/生成器）永远占着那一格 → 记为不可通行，敌人会绕开它；
	# 被摧毁时解除（移除单位的逻辑接入后同样适用）
	if (is_turret or is_spawner) and pathfinder != null:
		pathfinder.set_solid(x, y, true)
		if e.has_signal("killed"):
			e.killed.connect(_on_static_unit_killed.bind(x, y))


func _on_static_unit_killed(x: int, y: int) -> void:
	if pathfinder != null:
		pathfinder.set_solid(x, y, false)


## 取敌人场景（带缓存）；找不到返回 null
func _enemy_scene_for(tile: int) -> PackedScene:
	var name_key: String = ENEMY_NAMES.get(tile, "")
	if name_key == "":
		return null
	if _enemy_scene_cache.has(name_key):
		return _enemy_scene_cache[name_key]
	var path := ENEMY_DIR + name_key + ".tscn"
	if not ResourceLoader.exists(path):
		return null
	var ps: PackedScene = load(path)
	_enemy_scene_cache[name_key] = ps
	return ps


func _on_enemy_unit_killed(e: Node2D) -> void:
	on_enemy_killed(e)


## 生成玩家并绑定 HUD/相机/结算信号
func _spawn_player(pos: Vector2, x: int, y: int) -> void:
	if player != null:
		return
	var p: Node2D = SCENE_PLAYER.instantiate()
	p.position = pos
	_objects_layer.add_child(p)
	# 注入关卡引用（玩家被火焰点燃的时长按关卡序号算，H5 (55+40×index)/60）
	if "level" in p:
		p.set("level", self)
	occupy_tile(x, y)
	customCamera.position = pos      # 出生点置于镜头中心
	customCamera.target = p
	bind_player(p)
	p.killed.connect(on_player_killed)


# ============================================================
# 战斗循环
# ============================================================
func on_enemy_killed(_enemy: Node2D) -> void:
	enemies_alive -= 1
	if enemies_alive <= 0 and is_instance_valid(player):
		_show_summary(true)


func on_player_killed() -> void:
	_show_summary(false)


func shake_camera(_amount: float) -> void:
	# TODO: 相机震动（用 Tween 偏移 _camera.offset）
	pass


## 冰冻全部敌人（H5 freezeEnemies：敌人进入 Frozen 状态，持续 duration 秒）
func freeze_enemies(duration: float) -> void:
	freeze_time = duration
	for e in enemies:
		if is_instance_valid(e) and e.has_method("freeze"):
			e.freeze()
	Audio.play_sfx("freeze.mp3", 1.3)


func _unfreeze_enemies() -> void:
	for e in enemies:
		if is_instance_valid(e) and e.has_method("unfreeze"):
			e.unfreeze()
	Audio.play_sfx("unfreeze.mp3", 1.25)


func abandon() -> void:
	Game.change_scene(Settings.SCENE_UPGRADES)


static func _format_money(v: int) -> String:
	if v >= 1000000000:
		return "$%.3fb" % (v / 1000000000.0)
	if v >= 100000000:
		return "$%.1fm" % (v / 1000000.0)
	if v >= 1000000:
		return "$%.2fm" % (v / 1000000.0)
	if v >= 100000:
		return "$%.1fk" % (v / 1000.0)
	return "$%d" % v
