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


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	level_index = Game.consume_pending_level_index()
	level_data = ATLevels.get_level(level_index)
	difficulty_mult = Settings.DIFFICULTIES[int(Game.current["game"]["difficulty"])] \
		if int(Game.current["game"]["difficulty"]) >= 0 else 1.0
	parse(level_data)
	_spawn_objects()
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
			row_arr.append(Constants.CHAR_TO_TILE.get(ch, Constants.Tile.EMPTY))
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


func _process(delta: float) -> void:
	if get_tree().paused:
		return
	if freeze_time > 0:
		freeze_time -= delta
		if freeze_time <= 0:
			_unfreeze_enemies()
	_refresh_hud()


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
	# 2) 障碍物（油桶/木箱/门/木板/砖墙）
	if OBJECT_SCENES.has(tile):
		var obj: Node2D = (OBJECT_SCENES[tile] as PackedScene).instantiate()
		obj.position = pos
		if "tile_type" in obj:
			obj.tile_type = tile
		_objects_layer.add_child(obj)
		return
	# 3) 敌人（敌人场景族就绪后按 tile 映射对应派生场景）
	if Constants.is_enemy(tile):
		# TODO: 敌人/炮塔/生成器/Boss 场景接入后在这里创建
		return


## 生成玩家并绑定 HUD/相机/结算信号
func _spawn_player(pos: Vector2, x: int, y: int) -> void:
	if player != null:
		return
	var p: Node2D = SCENE_PLAYER.instantiate()
	p.position = pos
	_objects_layer.add_child(p)
	occupy_tile(x, y)
	customCamera.position = pos      # 出生点置于镜头中心
	customCamera.target = p
	bind_player(p)
	p.killed.connect(on_player_killed)


# ============================================================
# 战斗循环
# ============================================================
func on_enemy_killed(enemy: Node2D) -> void:
	enemies_alive -= 1
	if enemies_alive <= 0 and is_instance_valid(player):
		_show_summary(true)


func on_player_killed() -> void:
	_show_summary(false)


func shake_camera(amount: float) -> void:
	# TODO: 相机震动（用 Tween 偏移 _camera.offset）
	pass


func freeze_enemies(duration: float) -> void:
	freeze_time = duration


func _unfreeze_enemies() -> void:
	for e in enemies:
		if is_instance_valid(e) and e.has_method("unfreeze"):
			e.unfreeze()


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
