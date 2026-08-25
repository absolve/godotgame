extends Node2D
## Level — 关卡控制器（对应原项目 window.AT.Level）
## 职责：加载关卡数据、实例化玩家/敌人/对象、运行战斗循环、结算。

signal level_started
signal enemy_killed(points: int)
signal player_killed
signal level_complete(success: bool, profit: int)

@onready var _tile_map: ATTileMap = $TileMap
@onready var _objects_layer: Node2D = $ObjectsLayer
@onready var _top_layer: Node2D = $TopLayer
@onready var _hud: CanvasLayer = $HUD
@onready var _camera: Camera2D = $Camera2D

var level_index: int = 0
var level_data: Array = []
var player: Node2D = null
var enemies: Array[Node2D] = []
var enemies_alive: int = 0
var points: int = 0
var profit: float = 0.0
var freeze_time: float = 0.0
var free_camera: bool = false
var difficulty_mult: float = 1.0

# 预加载场景（待创建后填入实际路径）
# const PlayerScene := preload("res://scenes/Player.tscn")
# const EnemyScene := preload("res://scenes/Enemy.tscn")

func _ready() -> void:
	level_index = Game.consume_pending_level_index()
	level_data = ATLevels.get_level(level_index)
	difficulty_mult = Settings.DIFFICULTIES[int(Game.current["game"]["difficulty"])] \
		if int(Game.current["game"]["difficulty"]) >= 0 else 1.0
	_tile_map.parse(level_data)
	_spawn_objects()
	level_started.emit()
	Audio.play_music("music_game.mp3")

func _spawn_objects() -> void:
	_tile_map.for_each_object(_spawn_object_at)

func _spawn_object_at(tile: int, x: int, y: int) -> void:
	var pos := _tile_map.cell_center(x, y)
	match tile:
		ATConst.Tile.PLAYER:
			_spawn_player(pos)
		ATConst.Tile.BARREL:
			_spawn_object("barrel", pos)
		ATConst.Tile.CRATE:
			_spawn_object("crate", pos)
		ATConst.Tile.GATE:
			_spawn_object("gate", pos)
		ATConst.Tile.BRICKS_1, ATConst.Tile.BRICKS_2, ATConst.Tile.WOOD:
			_spawn_object("bricks", pos)
		# 生成器 / 炮塔 / Boss / 坦克 -> _spawn_enemy
		_:
			if ATConst.is_enemy(tile):
				_spawn_enemy(tile, pos)

# TODO: 实例化各类节点（场景文件就绪后取消注释）
func _spawn_player(pos: Vector2) -> void:
	pass

func _spawn_enemy(tile: int, pos: Vector2) -> void:
	enemies_alive += 1

func _spawn_object(kind: String, pos: Vector2) -> void:
	pass

# ============================================================
# 战斗循环
# ============================================================
func _process(delta: float) -> void:
	if freeze_time > 0:
		freeze_time -= delta
		if freeze_time <= 0:
			_unfreeze_enemies()

func on_enemy_killed(enemy: Node2D) -> void:
	enemies_alive -= 1
	if enemies_alive <= 0 and is_instance_valid(player):
		_show_summary(true)

func on_player_killed() -> void:
	_show_summary(false)

func shake_camera(amount: float) -> void:
	# TODO: 相机震动（用 Tween 偏移 _camera.offset）
	pass

func _on_pause_pressed() -> void:
	get_tree().paused = not get_tree().paused
	Audio.play_button_down()
	# TODO: 弹出暂停面板（继续/退出到升级菜单）

func freeze_enemies(duration: float) -> void:
	freeze_time = duration

func _unfreeze_enemies() -> void:
	for e in enemies:
		if is_instance_valid(e) and e.has_method("unfreeze"):
			e.unfreeze()

func _show_summary(success: bool) -> void:
	Game.finish_level(level_index, points, success)
	level_complete.emit(success, int(profit))
	# TODO: 显示结算面板，成功 -> 下一关/升级菜单，失败 -> 升级菜单

func abandon() -> void:
	Game.change_scene(Settings.SCENE_UPGRADES)
