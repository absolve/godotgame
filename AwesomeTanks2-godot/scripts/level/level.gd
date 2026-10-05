extends Node2D
## Level —— 关卡场景根脚本（本场景唯一逻辑脚本；对应原项目 window.AT.Level）
##
## 设计约定：
##   - 关卡内 UI（HUD 底栏 + 暂停/放弃/帮助/结算弹窗）都布置在 level.tscn 中；
##     可复用组件（血瓶、武器槽、各弹窗）是独立 .tscn 场景被实例化，
##     它们只维护自身视觉并发出信号，所有游戏流程/状态判断都在本根脚本。
##   - 瓦片地图解析/静态墙构建（原 tile_map.gd）已合并进本脚本，
##     场景中不再单独挂 TileMap 脚本。
##
## HUD 坐标约定与 H5 一致：原点 = 屏幕底部中心，y 向上为负。

signal levelStarted
signal enemyKilled(points: int)
signal playerKilled
signal levelComplete(success: bool, profit: int)

# 武器槽顺序（与场景中 Slot_<key> 实例一一对应）
const SLOT_KEYS: Array[String] = [
	"minigun", "shotgun", "ricochet", "flamethrower", "cannon",
	"shock", "rockets", "laser", "railgun", "mines",
]

# 弹窗脚本（供类型化引用）
const PAUSE_ALERT_SCRIPT := preload("res://scripts/ui/pause_alert.gd")
const ABANDON_ALERT_SCRIPT := preload("res://scripts/ui/abandon_alert.gd")
const HELP_ALERT_SCRIPT := preload("res://scripts/ui/help_alert.gd")
const SUMMARY_ALERT_SCRIPT := preload("res://scripts/ui/summary_alert.gd")

# 音乐/音效图标（存档状态切换 on/off 帧）
const TEX_MUSIC_ON: Texture2D = preload("res://sprites/game/hud/music_on.png.tres")
const TEX_MUSIC_OFF: Texture2D = preload("res://sprites/game/hud/music_off.png.tres")
const TEX_SOUND_ON: Texture2D = preload("res://sprites/game/hud/sound_on.png.tres")
const TEX_SOUND_OFF: Texture2D = preload("res://sprites/game/hud/sound_off.png.tres")

# 主题地板贴图（平铺背景）
const TEX_FLOOR: Dictionary = {
	Constants.GameTheme.GRASS: preload("res://sprites/game/grass.png.tres"),
	Constants.GameTheme.SNOW: preload("res://sprites/game/snow.png.tres"),
	Constants.GameTheme.DESERT: preload("res://sprites/game/desert.png.tres"),
}

# 墙体贴图（随机选）
const TEX_WALLS: Array = [
	preload("res://sprites/game/wall_0.png.tres"),
	preload("res://sprites/game/wall_1.png.tres"),
	preload("res://sprites/game/wall_2.png.tres"),
]
const TEX_SECRET: Texture2D = preload("res://sprites/game/secret.png.tres")

@onready var objectsLayer: Node2D = $ObjectsLayer
@onready var bonusLayer: Node2D = $BonusLayer      # 奖励拾取物（画在坦克下面，H5 groundLayer 同）
@onready var topLayer: Node2D = $TopLayer
@onready var customCamera: Camera2D = $customCamera

# HUD 节点引用（均在 level.tscn 中静态布置）
@onready var bottom: Control = $HUD/HudRoot/Bottom
@onready var healthVial: Control = $HUD/HudRoot/Bottom/HealthVial
@onready var pauseIcon: TextureButton = $HUD/HudRoot/Bottom/PauseIcon
@onready var musicIcon: TextureButton = $HUD/HudRoot/Bottom/MusicIcon
@onready var soundIcon: TextureButton = $HUD/HudRoot/Bottom/SoundIcon
@onready var profitBg: TextureRect = $HUD/HudRoot/Bottom/Profit
@onready var profitValue: Label = $HUD/HudRoot/Bottom/Profit/Value
@onready var fight: TextureRect = $HUD/HudRoot/Bottom/Fight
## 入场黑屏（H5 camera.flash(0, 250)：整屏黑 → 250ms 淡入）
@onready var flash: ColorRect = $HUD/HudRoot/Flash

# 弹窗（HUD CanvasLayer 内实例，常驻 ALWAYS，暂停中仍可交互）
@onready var pauseAlert: PAUSE_ALERT_SCRIPT = $HUD/PauseAlert
@onready var abandonAlert: ABANDON_ALERT_SCRIPT = $HUD/AbandonAlert
@onready var helpAlert: HELP_ALERT_SCRIPT = $HUD/HelpAlert
@onready var summaryAlert: SUMMARY_ALERT_SCRIPT = $HUD/SummaryAlert

var levelIndex: int = 0
var levelData: Array = []
var player: Node = null
var enemies: Array[Node2D] = []
var enemiesAlive: int = 0
var points: int = 0
var profit: float = 0.0
var freezeTime: float = 0.0
var freeCamera: bool = false
var difficultyMult: float = 1.0

# ---- 瓦片地图（原 tile_map.gd 合并而来） ----
var tiles: Array = [] # tiles[y][x] = Tile 枚举
var mapWidth: int = 0
var mapHeight: int = 0
var mapTheme: int = 0 # Constants.GameTheme
var occupancy: Array = [] # 动态对象占据标记（tiles 同尺寸）

var fog: ATFog = null       # 黑雾（scenes/level/fog.tscn，_ready 中实例化）
var fogFrame: int = 0      # 惰性更新计数（约每 3 帧发射一次视野射线）

## 寻路网格（scripts/level/pathfinder.gd；敌人 AI 用它绕开墙/障碍）
var pathfinder: ATPathfinder = null

var slotNodes: Array = []
var lastHpRatio: float = -1.0
var profitTween: Tween = null
var fightTween: Tween = null
var summarySuccess: bool = false
var summaryShown: bool = false    # 结算只触发一次（H5: summaryAlert || …）
var resultPersisted: bool = false     # 关卡结束的存档写回只做一次（H5 shutdown 同）

# 关卡对象场景（玩家 + 障碍物瓦片 → 场景，_spawn_objects 直接按瓦片添加）
const SCENE_PLAYER := preload("res://scenes/player.tscn")
const SCENE_BONUS := preload("res://scenes/objects/bonus.tscn")
## 死亡灰度着色器（H5 grayscaleShader）
const PRELOAD_GRAYSCALE: Shader = preload("res://shaders/grayscale.gdshader")
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

var enemySceneCache: Dictionary = {}
var turretScene: PackedScene = null
var spawnerScene: PackedScene = null


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	levelIndex = Game.consumePendingLevelIndex()
	levelData = ATLevels.getLevel(levelIndex)
	difficultyMult = Settings.DIFFICULTIES[int(Game.current["game"]["difficulty"])] \
		if int(Game.current["game"]["difficulty"]) >= 0 else 1.0
	parse(levelData)
	setupPathfinder()
	spawnObjects()
	setupFog()
	collectHudNodes()
	syncAudioIcons()
	connectPopups()
	levelStarted.emit()
	Audio.playMusic("music_game.mp3")
	playIntro()


func connectPopups() -> void:
	pauseAlert.continuePressed.connect(resumeGame)
	pauseAlert.musicToggled.connect(onMusicSet)
	pauseAlert.soundToggled.connect(onSoundSet)
	abandonAlert.confirmed.connect(onAbandonConfirmed)
	abandonAlert.canceled.connect(onAbandonCanceled)
	helpAlert.closed.connect(onHelpClosed)
	summaryAlert.continuePressed.connect(onSummaryContinue)


# ============================================================
# 瓦片地图：解析 ASCII 关卡 → 网格 + 静态墙（原 tile_map.gd）
# ============================================================
## 解析关卡数据（来自 ATLevels.LEVELS 的元素：名称/主题/若干行字符）
func parse(levelDataInput: Array) -> void:
	#var name: String = level_data[0]
	mapTheme = Constants.THEME_NAMES.get(levelDataInput[1], Constants.GameTheme.GRASS)
	var rows: Array = levelDataInput.slice(2)
	mapHeight = rows.size()
	mapWidth = 0
	for r in rows:
		mapWidth = max(mapWidth, (r as String).length())
	tiles.clear()
	occupancy.clear()
	for y in range(mapHeight):
		var rowArr: Array = []
		var occRow: Array = []
		var rowStr: String = rows[y]
		for x in range(mapWidth):
			var ch: String = " " if x >= rowStr.length() else rowStr[x]
			var tile: int = int(Constants.CHAR_TO_TILE.get(ch, Constants.Tile.EMPTY))
			rowArr.append(tile)
			occRow.append(false)
		tiles.append(rowArr)
		occupancy.append(occRow)
	buildStaticTiles()


## 构建静态瓦片：主题地板 + 墙体 + 秘密墙（每格一个 StaticBody2D + Sprite2D）
func buildStaticTiles() -> void:
	var staticLayer := get_node_or_null("StaticLayer")
	if staticLayer == null:
		return
	# 清空旧节点（保留 parse 前可能已存在的子节点）
	for c in staticLayer.get_children():
		c.queue_free()

	var ts := Settings.TILE_SIZE

	# 1. 主题地板背景（TextureRect 平铺整个关卡）
	var floor1 = TextureRect.new()
	floor1.name = "Floor"
	floor1.position = Vector2.ZERO
	floor1.size = Vector2(mapWidth * ts, mapHeight * ts)
	floor1.texture = TEX_FLOOR.get(mapTheme, TEX_FLOOR[Constants.GameTheme.GRASS])
	floor1.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	floor1.texture_repeat = TextureRect.TEXTURE_REPEAT_ENABLED
	floor1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	staticLayer.add_child(floor1)

	# 2. 逐格构建静态墙 + 秘密墙
	for y in range(mapHeight):
		for x in range(mapWidth):
			var t: int = tiles[y][x]
			if not Constants.isStaticWall(t):
				continue
			var pos := cellCenter(x, y)
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
			staticLayer.add_child(body)


# ============================================================
# 寻路（敌人 AI 用；网格来自 scripts/level/pathfinder.gd）
# ============================================================
## 按解析后的地图建立寻路网格：静态墙/秘密墙不可通行。
## 可破坏障碍物在生成时标记、被摧毁时解除，所以炸开后路径会重新打通。
func setupPathfinder() -> void:
	pathfinder = ATPathfinder.new()
	pathfinder.setup(mapWidth, mapHeight, Settings.TILE_SIZE)
	for y in range(mapHeight):
		for x in range(mapWidth):
			if Constants.isStaticWall(tiles[y][x]):
				pathfinder.setSolid(x, y, true)


## 障碍物占格：标记不可通行，并在被摧毁（queue_free 前发 destroyed）时解除
func markObstacleTile(obj: Node2D, x: int, y: int) -> void:
	if pathfinder == null:
		return
	pathfinder.setSolid(x, y, true)
	if obj is ATObstacle:
		(obj as ATObstacle).destroyed.connect(onObstacleDestroyed.bind(x, y))


func onObstacleDestroyed(obstacle: Node, x: int, y: int) -> void:
	if pathfinder != null:
		pathfinder.setSolid(x, y, false)


## 世界坐标寻路（给外部/调试用；无寻路器时返回空数组 = 不可达）
func findPath(fromWorld: Vector2, toWorld: Vector2) -> PackedVector2Array:
	if pathfinder == null:
		return PackedVector2Array()
	return pathfinder.findPath(fromWorld, toWorld)


## 两点间是否可直线通行（格子级判定）
func isLineWalkable(fromWorld: Vector2, toWorld: Vector2) -> bool:
	return pathfinder != null and pathfinder.isLineWalkable(fromWorld, toWorld)


# 坐标换算（瓦片 <-> 像素）
func tileToPx(coord: int) -> float:
	return (coord + 0.5) * Settings.TILE_SIZE


func pxToTile(px: float) -> int:
	return int(px / Settings.TILE_SIZE)


func cellCenter(x: int, y: int) -> Vector2:
	return Vector2(tileToPx(x), tileToPx(y))


# 占位查询（动态对象占据后标记）
func isTileFree(x: int, y: int) -> bool:
	if x < 0 or x >= mapWidth or y < 0 or y >= mapHeight:
		return false
	if Constants.isStaticWall(tiles[y][x]):
		return false
	return not occupancy[y][x]


## 能不能往这一格"塞一个会走路的单位"（生成器挑落点、奖励小敌人找空地等）：
## 在 is_tile_free 之上再排除**可破坏障碍物与固定单位**（油桶/木箱/木板/砖墙/炮塔/生成器）
## —— 它们没写进 occupancy，但都是实体，单位塞进去会卡住。
## （H5 是 isTileFree + objects[y][x] === null 两个都查）
func isTileClearForUnit(x: int, y: int) -> bool:
	if not isTileFree(x, y):
		return false
	return pathfinder == null or not pathfinder.isSolid(x, y)


func occupyTile(x: int, y: int) -> void:
	if x >= 0 and x < mapWidth and y >= 0 and y < mapHeight:
		occupancy[y][x] = true


func freeTile(x: int, y: int) -> void:
	if x >= 0 and x < mapWidth and y >= 0 and y < mapHeight:
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
func collectHudNodes() -> void:
	slotNodes.clear()
	for key in SLOT_KEYS:
		slotNodes.append(bottom.get_node("Slot_" + key))


## 玩家生成后由本关卡调用（后续 _spawn_player 实现时接入）
func bindPlayer(p: Node) -> void:
	player = p
	lastHpRatio = -1.0
	refreshHud()


## 按玩家位置/炮塔朝向刷新黑雾：
##   1) 清掉玩家脚下周围一圈黑雾瓦片（能看到自己）；
##   2) 按炮塔方向发射扇形视野射线清雾（射线与墙/黑雾碰撞，墙后不生效）。
func updateFog() -> void:
	if fog == null or player == null or not is_instance_valid(player):
		return
	var ts := Settings.TILE_SIZE
	# 玩家正在制导火箭：视野跟着导弹（H5 updateFog：player.follow 时只揭开导弹周围那一圈）
	if "follow" in player:
		var r = player.get("follow")
		if r is Node2D and is_instance_valid(r):
			fog.clearArea(int((r as Node2D).global_position.x / ts),
				int((r as Node2D).global_position.y / ts), fog.clearRadiusTiles)
			return
	var px := int(player.global_position.x / ts)
	var py := int(player.global_position.y / ts)
	fog.clearArea(px, py, fog.clearRadiusTiles)
	var viewAngle := float(player.get("viewAngle")) if "viewAngle" in player else PI / 4.0
	var viewDist := float(player.get("viewDistance")) if "viewDistance" in player else 300.0
	var aim: float = player.getTurretRotation() if player.has_method("getTurretRotation") \
		else float(player.rotation)
	fog.revealFov(player.global_position, aim, viewAngle, viewDist)


## 地图加载完成后创建黑雾：实例化 fog.tscn 并逐格铺满整张地图
func setupFog() -> void:
	fog = (preload("res://scenes/level/fog.tscn") as PackedScene).instantiate()
	fog.name = "Fog"
	add_child(fog)
	fog.z_index = 100   # 盖在静态层/物体层之上
	fog.configure(0, 0, mapWidth, mapHeight)
	fog.buildTiles()
	# 出生点先清一圈：本帧物理空间可能还没登记新瓦片，随后每 3 帧的
	# _update_fog 会再补一次（清掉缓存确保一定发射线）
	updateFog()
	fog.invalidateCache()


## 每帧同步血瓶 / 武器槽（幂等；数据没变化时开销可忽略）
func refreshHud() -> void:
	if player == null or not is_instance_valid(player):
		return
	# 血瓶
	var hp := 0.0
	if "health" in player and "maxHealth" in player:
		hp = clampf(float(player.health) / maxf(float(player.maxHealth), 1.0), 0.0, 1.0)
	if absf(hp - lastHpRatio) > 0.001:
		lastHpRatio = hp
		healthVial.call("setRatio", hp)
	# 武器槽
	var weapons: Array = player.weapons if "weapons" in player else []
	var index: int = int(player.weaponIndex) if "weaponIndex" in player else -1
	for i in slotNodes.size():
		var w = weapons[i] if i < weapons.size() else null
		var owned: bool = w != null
		var pct := -1.0
		if owned and "maxAmmo" in w and float(w.maxAmmo) < 999999.0:
			pct = clampf(float(w.ammo) / maxf(float(w.maxAmmo), 1.0), 0.0, 1.0)
		slotNodes[i].call("refresh", owned, owned and index == i, pct)


# ============================================================
# 暂停 / 菜单(放弃) / 帮助 / 结算 —— 流程状态机
# ============================================================
func onHudPausePressed() -> void:
	if abandonAlert.visible or helpAlert.visible or summaryAlert.visible:
		return
	if get_tree().paused:
		resumeGame()
	else:
		pause()

func pause() -> void:
	get_tree().paused = true
	Audio.playButtonDown()
	pauseAlert.open()

func resumeGame() -> void:
	get_tree().paused = false
	pauseAlert.close()


func onHudMenuPressed() -> void:
	if abandonAlert.visible or helpAlert.visible or summaryAlert.visible \
			or pauseAlert.visible:
		return
	Audio.playButtonDown()
	get_tree().paused = true
	abandonAlert.open()


func onAbandonConfirmed() -> void:
	get_tree().paused = false
	abandonAlert.close()
	abandon()


func onAbandonCanceled() -> void:
	get_tree().paused = false
	abandonAlert.close()


func onHudHelpPressed() -> void:
	if abandonAlert.visible or helpAlert.visible or summaryAlert.visible \
			or pauseAlert.visible:
		return
	Audio.playButtonDown()
	get_tree().paused = true
	helpAlert.open()


func onHelpClosed() -> void:
	helpAlert.close()
	get_tree().paused = false


func onHudMusicPressed() -> void:
	Audio.playButtonDown()
	onMusicSet(not bool(Game.current["game"].get("music", true)))


func onHudSoundPressed() -> void:
	Audio.playButtonDown()
	onSoundSet(not bool(Game.current["game"].get("sound", true)))


func onMusicSet(on: bool) -> void:
	Audio.setMusicEnabled(on)
	syncAudioIcons()


func onSoundSet(on: bool) -> void:
	Audio.setSoundEnabled(on)
	syncAudioIcons()


## 同步 HUD 主栏图标与暂停面板开关的状态
func syncAudioIcons() -> void:
	var game: Dictionary = Game.current.get("game", {})
	var musicOn := bool(game.get("music", true))
	var soundOn := bool(game.get("sound", true))
	musicIcon.texture_normal = TEX_MUSIC_ON if musicOn else TEX_MUSIC_OFF
	soundIcon.texture_normal = TEX_SOUND_ON if soundOn else TEX_SOUND_OFF
	if is_instance_valid(pauseAlert):
		pauseAlert.setAudioStates(musicOn, soundOn)


# ---------- 结算 ----------
## 结算流程（H5 enemyKilled / playerKilled → SummaryAlert）：
##   清场/阵亡的那一刻**收回玩家操作权**（H5: summaryAlert 存在时 player.stopFire()，
##   这里连驾驶一起锁 —— 否则会出现"关卡已经结束还能开车打枪"），
##   但**不暂停世界**（H5 的 enemyKilled/playerKilled 都不设 gamePaused）：
##   残留子弹、爆炸、掉落的金币继续演/继续被吸走，面板照 H5 的 2s 时序淡入，
##   4.5s 后自动继续（胜利）或等玩家点 CONTINUE（失败）。
func showSummary(success: bool) -> void:
	if summaryShown:
		return                      # 只结一次（避免玩家先死又清场等重复触发）
	summaryShown = true
	summarySuccess = success
	Game.finishLevel(levelIndex, points, success)
	levelComplete.emit(success, int(profit))
	Audio.stopMusic()              # H5: SummaryAlert 构造时停音乐
	Audio.playSfx("level_won.mp3" if success else "level_lost.mp3")
	if is_instance_valid(player):
		if "invincible" in player:
			player.invincible = true    # H5: 胜利后玩家无敌（残留子弹打不死，避免"赢了又死"）
		if "controlLocked" in player:
			player.set("controlLocked", true)   # 收回操作权（不让关卡结束后继续打）
		if player.has_method("stopFire"):
			player.call("stopFire")
	summaryAlert.open(success, int(profit))


func onSummaryContinue() -> void:
	get_tree().paused = false       # 兜底：世界在结算期间本来就不暂停（H5 同）
	persistLevelResult()         # H5 shutdown：收益入账 + 弹药写回 + save
	if summarySuccess:
		Game.changeScene(Settings.SCENE_LEVEL_SELECT)
	else:
		Game.changeScene(Settings.SCENE_UPGRADES)


# ---------- 关卡开始动画（H5: camera.flash(0,250) + hud.showFightMessage） ----------
## 入场：黑屏 250ms 淡入（H5 camera.flash(0, 250)），随后播 FIGHT 横幅；
## 横幅播放期间镜头不跟随玩家（H5: fightMessageComplete 才 updateCamera）
func playIntro() -> void:
	customCamera.frozen = true
	flash.visible = true
	flash.color = Color(0.0, 0.0, 0.0, 1.0)
	var tw := create_tween()
	tw.tween_property(flash, "color:a", 0.0, 0.25)
	tw.tween_callback(func() -> void: flash.visible = false)
	showFight()


# ---------- 开打前/战斗中的小动画（供流程接入） ----------
func showProfit(amount: int) -> void:
	if profitTween != null and profitTween.is_valid():
		profitTween.kill()
	profitValue.text = Game.formatMoney(amount)
	profitBg.visible = true
	profitBg.position = Vector2(-118.0, -65.0)
	profitTween = create_tween()
	profitTween.tween_property(profitBg, "position", Vector2(-118.0, -95.0), 0.3) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	profitTween.tween_interval(1.4)
	profitTween.tween_property(profitBg, "position", Vector2(-118.0, -65.0), 0.3) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	profitTween.tween_callback(func() -> void: profitBg.visible = false)


## FIGHT 横幅（H5 hud.showFightMessage，L23111~L23123）：
##   延迟 0.5s → 0.6s 上升进场 → 停留 1.3s → 0.5s 下滑出屏 → 隐藏并恢复镜头跟随
func showFight() -> void:
	if fightTween != null and fightTween.is_valid():
		fightTween.kill()
	fight.visible = true
	fight.position = Vector2(-105.0, -700.0)
	fightTween = create_tween()
	fightTween.tween_interval(0.5)
	fightTween.tween_property(fight, "position:y", -450.0, 0.6) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	fightTween.tween_interval(1.3)          # H5: 第二段 tween 带 1300ms delay → 横幅停留
	fightTween.tween_property(fight, "position:y", 100.0, 0.5) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fightTween.tween_callback(func() -> void:
		fight.visible = false
		customCamera.frozen = false)


# ============================================================
# 关卡对象实例化（直接按瓦片添加）
# ============================================================
func spawnObjects() -> void:
	# for_each_object(_spawn_object_at)
	for y in range(mapHeight):
		for x in range(mapWidth):
			var t: int = tiles[y][x]
			if t != Constants.Tile.EMPTY and not Constants.isStaticWall(t):
				spawnObjectAt.call(t, x, y)


func spawnObjectAt(tile: int, x: int, y: int) -> void:
	var pos := cellCenter(x, y)
	# 1) 玩家出生点
	if tile == Constants.Tile.PLAYER:
		spawnPlayer(pos, x, y)
		return
	# 2) 障碍物（油桶/木箱/门/木板/砖墙）——它们挡视野射线（物理层 OBSTACLE）
	if OBJECT_SCENES.has(tile):
		var obj: Node2D = (OBJECT_SCENES[tile] as PackedScene).instantiate()
		obj.position = pos
		if "tileType" in obj:
			obj.tileType = tile
		# 血量按关卡序号算（H5：油桶 25+4×index 等）→ 注入关卡引用
		if "level" in obj:
			obj.level = self
		objectsLayer.add_child(obj)
		markObstacleTile(obj, x, y)
		# 木箱被摧毁 → 掉落奖励（H5 Crate.kill → spawnBonus(getRandomBonus(), x, y, 15)）
		if tile == Constants.Tile.CRATE and obj is ATObstacle:
			(obj as ATObstacle).destroyed.connect(onCrateDestroyed.bind(Vector2i(x, y)))
		return
	# 3) 敌人：坦克/Boss 走独立场景；炮塔/生成器走形态场景 + 类型数据
	if ENEMY_NAMES.has(tile) or ATEnemyTypes.TILE_TURRET.has(tile) \
			or ATEnemyTypes.TILE_SPAWNER.has(tile):
		spawnEnemyByTile(tile, pos, x, y)
		return


## 按瓦片实例化敌人，登记到 enemies 并接击杀信号
##   - 坦克/Boss：各自独立场景（场景里已带贴图/数值/武器）
##   - 炮塔/生成器：同一个形态场景，入树后按类型数据 applyType/applyKind
func spawnEnemyByTile(tile: int, pos: Vector2, x: int, y: int) -> void:
	var e: Node2D = null
	var isTurret: bool = ATEnemyTypes.TILE_TURRET.has(tile)
	var isSpawner: bool = ATEnemyTypes.TILE_SPAWNER.has(tile)
	if isTurret:
		if turretScene == null:
			turretScene = load(ATEnemyTypes.TURRET_SCENE) as PackedScene
		e = turretScene.instantiate()
	elif isSpawner:
		if spawnerScene == null:
			spawnerScene = load(ATEnemyTypes.SPAWNER_SCENE) as PackedScene
		e = spawnerScene.instantiate()
	else:
		var scene := enemySceneFor(tile)
		if scene == null:
			push_warning("Level: 敌人场景缺失: ", ENEMY_NAMES.get(tile, "?"))
			return
		e = scene.instantiate()
	e.position = pos
	if "level" in e:
		e.level = self
	#_objects_layer.add_child(e)
	# add_child 用 deferred（避免在 _ready 阶段给正在建子节点的父节点加子节点时报错），
	# 那么 applyType/applyKind 也必须一起 deferred：延迟调用按入队顺序执行，
	# 先入树（@onready 变量就绪）再 apply，否则 _body_sprite 还是 null（贴图/武器都会设不上）
	objectsLayer.call_deferred("add_child",e)
	# 形态场景：入树后（@onready 就绪）再应用类型数据（贴图/数值/武器）
	if isTurret:
		e.call_deferred("applyType", ATEnemyTypes.TURRETS[ATEnemyTypes.TILE_TURRET[tile]])
	elif isSpawner:
		e.call_deferred("applyKind", int(ATEnemyTypes.TILE_SPAWNER[tile]))
	enemies.append(e)
	enemiesAlive += 1
	if e.has_signal("killed"):
		e.killed.connect(onEnemyUnitKilled.bind(e))
	# 固定单位（炮塔/生成器）永远占着那一格 → 记为不可通行，敌人会绕开它；
	# 被摧毁时解除（移除单位的逻辑接入后同样适用）
	if (isTurret or isSpawner) and pathfinder != null:
		pathfinder.setSolid(x, y, true)
		if e.has_signal("killed"):
			e.killed.connect(onStaticUnitKilled.bind(x, y))


func onStaticUnitKilled(x: int, y: int) -> void:
	if pathfinder != null:
		pathfinder.setSolid(x, y, false)


## 取敌人场景（带缓存）；找不到返回 null
func enemySceneFor(tile: int) -> PackedScene:
	var nameKey: String = ENEMY_NAMES.get(tile, "")
	if nameKey == "":
		return null
	if enemySceneCache.has(nameKey):
		return enemySceneCache[nameKey]
	var path := ENEMY_DIR + nameKey + ".tscn"
	if not ResourceLoader.exists(path):
		return null
	var ps: PackedScene = load(path)
	enemySceneCache[nameKey] = ps
	return ps


func onEnemyUnitKilled(e: Node2D) -> void:
	dropCoinsForEnemy(e)      # 敌人只掉金币（H5：坦克/炮塔/Boss/生成器各不同数量）
	playEnemyDeathEffects(e)  # 烟 + 爆炸粒子 + 震屏（H5 Tank.kill / Turret.kill）
	onEnemyKilled(e)
	# H5 kill()：结算完就把单位从场上移除（生成器产出的坦克也走这里）
	if e != null and is_instance_valid(e):
		e.queue_free()


## 敌人死亡表现（H5 Tank.kill：spawnSmoke + explosionEmitter + shakeCamera）
func playEnemyDeathEffects(e: Node2D) -> void:
	if e == null or not is_instance_valid(e):
		return
	Fx.smoke(e.global_position, objectsLayer)
	Fx.explosion(e.global_position, objectsLayer)
	shakeCamera(8.0)


## 运行时登记一个敌人（H5 createTank：进 enemies、计数 +1、接击杀信号）。
## 生成器产出的坦克走这里；关卡数据里的敌人由 _spawn_enemy_by_tile 内联同一套逻辑。
func registerEnemy(e: Node2D) -> void:
	if e == null:
		return
	enemies.append(e)
	enemiesAlive += 1
	if e.has_signal("killed"):
		e.killed.connect(onEnemyUnitKilled.bind(e))


## 枪声传出去（H5 alertSound，L23841）：半径内的敌人切 GoToSound 去调查开枪的位置。
## 由玩家武器按 sound_alert_radius 调用（H5 只有玩家武器的 onShot 会 alertSound，敌人武器不会）。
func alertSound(pos: Vector2, radius: float) -> void:
	if radius <= 0.0:
		return
	for e in enemies:
		if not is_instance_valid(e) or not (e is Node2D) or not e.has_method("onAlerted"):
			continue
		if pos.distance_squared_to((e as Node2D).global_position) <= radius * radius:
			e.onAlerted(pos)


## 玩家发射制导火箭：镜头交给导弹、玩家不能开车、迷雾跟着导弹
## （H5：武器里 tank.follow = rocket，Level.updateCamera / updateFog 都优先看 player.follow）
func setGuidedRocket(rocket: Node2D) -> void:
	if is_instance_valid(player):
		player.set("follow", rocket)
	if customCamera != null:
		customCamera.target = rocket


## 制导结束（命中/引爆/切武器/阵亡）：镜头与操作权还给玩家
func clearGuidedRocket(rocket: Node2D) -> void:
	if is_instance_valid(player) and player.get("follow") == rocket:
		player.set("follow", null)
	if customCamera != null and is_instance_valid(player):
		customCamera.target = player


## 玩家生成并绑定 HUD/相机/结算信号
func spawnPlayer(pos: Vector2, x: int, y: int) -> void:
	if player != null:
		return
	var p: Node2D = SCENE_PLAYER.instantiate()
	p.position = pos
	objectsLayer.add_child(p)
	# 注入关卡引用（玩家被火焰点燃的时长按关卡序号算，H5 (55+40×index)/60）
	if "level" in p:
		p.set("level", self)
	occupyTile(x, y)
	customCamera.position = pos      # 出生点置于镜头中心
	customCamera.target = p
	bindPlayer(p)
	p.killed.connect(onPlayerKilled)


# ============================================================
# 奖励拾取物（掉落 + 拾取结算；组件 ATBonus 只做表现/磁吸，流程都在这里）
# 掉落来源（H5）：敌人只掉金币，木箱掉加权随机奖励
# ============================================================
## 生成一个拾取物。**所有掉落的唯一入口**（以后要换对象池只改这里）
func spawnBonus(kind: int, pos: Vector2, weaponKey: String = "", amount: int = 0) -> ATBonus:
	var b: ATBonus = SCENE_BONUS.instantiate()
	b.position = pos
	b.pickedUp.connect(onBonusPickedUp)
	b.expired.connect(onBonusExpired)
	# add_child 用 deferred（避免在 _ready 阶段给正在建子节点的父节点加子节点时报错），
	# 那么 setup 也必须一起 deferred：延迟调用按入队顺序执行，先入树（@onready 就绪）
	# 再 setup，否则 bonus.gd 里的 anim/fire/shape 还是 null —— 动画不会切到对应奖励类型
	# （AnimatedSprite2D 会停在场景默认的 coin）、炸弹引线也不显示。
	bonusLayer.call_deferred("add_child", b)
	b.call_deferred("setup", kind, self, weaponKey, amount)
	return b


func dropCoins(pos: Vector2, count: int) -> void:
	for i in maxi(count, 0):
		spawnBonus(ATBonusTypes.Kind.COIN, pos)


## 敌人死亡掉币（数量见 ATBonusTypes.coin_drop_for_enemy）
func dropCoinsForEnemy(e: Node) -> void:
	var count := ATBonusTypes.coinDropForEnemy(e)
	if count <= 0 or not (e is Node2D):
		return
	dropCoins((e as Node2D).global_position, count)


## 木箱被摧毁：加权随机奖励（H5 Crate.getRandomBonus + spawnBonus(..., 15)）
func onCrateDestroyed(crate: Node, cell: Vector2i) -> void:
	if not (crate is Node2D):
		return
	var pos := (crate as Node2D).global_position
	var pick := ATBonusTypes.pickCrateBonus(self, player if is_instance_valid(player) else null)
	match int(pick.get("kind", ATBonusTypes.Kind.COIN)):
		ATBonusTypes.Kind.COIN:
			dropCoins(pos, ATBonusTypes.COIN_PER_CRATE_ROLL)      # 掷中金币 → 一次 15 个
		ATBonusTypes.Kind.AMMO:
			spawnBonus(ATBonusTypes.Kind.AMMO, pos, str(pick.get("weapon_key", "")),
				int(pick.get("amount", 0)))
		ATBonusTypes.Kind.SMALL_ENEMY:
			spawnSmallEnemy(cell)
		_:
			spawnBonus(int(pick.get("kind", ATBonusTypes.Kind.COIN)), pos)


## 小敌人：在木箱附近空格生成一个血量 1/3 的随机坦克（H5 bonus.SmallEnemy）
func spawnSmallEnemy(cell: Vector2i) -> void:
	var target := Vector2i(-1, -1)
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			var c := Vector2i(cell.x + dx, cell.y + dy)
			if isTileClearForUnit(c.x, c.y):
				target = c
				break
		if target.x >= 0:
			break
	if target.x < 0:
		return
	var tankKey := ATBonusTypes.smallEnemyTank(levelIndex)
	var tile: int = int(ATBonusTypes.SMALL_ENEMY_TILE.get(tankKey, -1))
	if tile < 0:
		return
	spawnObjectAt(tile, target.x, target.y)
	# 刚生成的那个敌人就是 enemies 里最后一个 → 血量压到 1/3（H5: setHealth(... * (s ? 1/3 : 1))）
	if not enemies.is_empty():
		var e = enemies[enemies.size() - 1]
		if is_instance_valid(e) and "maxHealth" in e:
			e.maxHealth = maxf(float(e.maxHealth) / 3.0, 1.0)
			e.health = e.maxHealth


## 拾取：加血 / 加弹药 / 冻结 / 记收益（H5 player.onBonusHit + level.collect）
func onBonusPickedUp(b: ATBonus) -> void:
	match b.kind:
		ATBonusTypes.Kind.COIN:
			profit += ATBonusTypes.coinValue(levelIndex, difficultyMult)
			playBonusSfx(b.kind)
			showProfit(int(round(profit)))
			Fx.spark(b.global_position, objectsLayer)      # H5: 拾取星星粒子
		ATBonusTypes.Kind.HEALTH:
			if is_instance_valid(player):
				player.health = minf(float(player.maxHealth), float(player.health) + 0.25 * float(player.maxHealth))
			playBonusSfx(b.kind)
		ATBonusTypes.Kind.FREEZE:
			freezeEnemies(ATBonusTypes.FREEZE_DURATION)      # 冻结时长/音效在里面
		ATBonusTypes.Kind.AMMO:
			giveAmmo(b.weaponKey, b.amount)
		ATBonusTypes.Kind.BOMB:
			explodeBomb(b.global_position)


## 过期：只有炸弹会在寿命到点时炸（H5 炸弹 lifespan = 1s → kill → 爆炸）
func onBonusExpired(b: ATBonus) -> void:
	if b.kind == ATBonusTypes.Kind.BOMB:
		explodeBomb(b.global_position)


## 给弹药：没拥有这把武器就白捡（H5 同）
func giveAmmo(weaponKey: String, amount: int) -> void:
	if not is_instance_valid(player) or amount <= 0:
		return
	var idx := SLOT_KEYS.find(weaponKey)
	var weapons: Array = player.weapons
	var w = weapons[idx] if idx >= 0 and idx < weapons.size() else null
	if w == null or not is_instance_valid(w):
		return
	w.ammo = mini(int(w.ammo) + amount, int(w.maxAmmo))
	playBonusSfx(ATBonusTypes.Kind.AMMO)


## 炸弹：半径伤害，不分敌我（H5 Explosion: 半径 200 / 伤害 150，伤害对玩家和敌人同时生效）
func explodeBomb(pos: Vector2) -> void:
	Audio.playSfx("explosion.mp3", 1.25)
	Fx.explosion(pos, objectsLayer)
	ATBullet.damageInRadius(self, pos, 200.0, 150.0, Constants.Team.CPU)     # 打到玩家
	ATBullet.damageInRadius(self, pos, 200.0, 150.0, Constants.Team.PLAYER)  # 打到敌人


func playBonusSfx(kind: int) -> void:
	var sfx := ATBonusTypes.pickupSfx(kind)
	if str(sfx["file"]) != "":
		Audio.playSfx(str(sfx["file"]), float(sfx["db"]))


# ============================================================
# 战斗循环
# ============================================================
func onEnemyKilled(enemy: Node2D) -> void:
	enemiesAlive -= 1
	# H5 enemyKilled：累计分数（关卡结算/星级用）
	if enemy != null and is_instance_valid(enemy) and "points" in enemy:
		points += int(enemy.points)
	# H5：只有"玩家还活着"且敌人清空才算通关（玩家先死时由死亡结算接管）
	if enemiesAlive <= 0 and is_instance_valid(player) and bool(player.get("alive")):
		showSummary(true)


## 玩家被击败（H5 player.kill + playerKilled，L22562 / L23962）：
##   震屏 15 + 烟 + 爆炸 + 炮塔/车体转灰度（坦克保留在场上），然后弹结算
func onPlayerKilled() -> void:
	if is_instance_valid(player):
		shakeCamera(15.0)
		Fx.smoke(player.global_position, objectsLayer)
		Fx.explosion(player.global_position, objectsLayer)
		setPlayerGrayscale(player)
	showSummary(false)


## 死亡灰度（H5: bodySprite.shader = turretSprite.shader = grayscaleShader）
func setPlayerGrayscale(p: Node) -> void:
	var mat := ShaderMaterial.new()
	mat.shader = PRELOAD_GRAYSCALE
	for path in ["BodySprite", "TurretSprite"]:
		var sp := p.get_node_or_null(path)
		if sp is CanvasItem:
			(sp as CanvasItem).material = mat


func shakeCamera(amount: float) -> void:
	# H5 shakeCamera：只取较大值，相机自己按 30px/s 衰减
	if customCamera != null:
		customCamera.shake(amount)


## 冰冻全部敌人（H5 freezeEnemies：敌人进入 Frozen 状态，持续 duration 秒）
func freezeEnemies(duration: float) -> void:
	freezeTime = duration
	for e in enemies:
		if is_instance_valid(e) and e.has_method("freeze"):
			e.freeze()
	Audio.playSfx("freeze.mp3", 1.3)


func unfreezeEnemies() -> void:
	for e in enemies:
		if is_instance_valid(e) and e.has_method("unfreeze"):
			e.unfreeze()
	Audio.playSfx("unfreeze.mp3", 1.25)


func abandon() -> void:
	persistLevelResult()
	Game.changeScene(Settings.SCENE_UPGRADES)


# ---------- 关卡结束写存档（对应 H5 Level.shutdown） ----------
## H5 在关卡 state 退出时统一做两件事：收益入账 + 把打剩的弹药写回 profile，最后 save 一次。
## 这两件事原来都没做：金币只在结算面板上显示（升级界面看不到钱变多），
## 弹药也从不写回（每关开局都是存档里的满值）。这里一起补上，只做一次。
func persistLevelResult() -> void:
	if resultPersisted:
		return
	resultPersisted = true
	creditProfit()
	saveWeaponAmmo()
	Game.save()                     # H5 shutdown 末尾统一 save（add_money/set_weapon_ammo 都不自己存）


## 收益入账（H5: `profile.game.money += Math.round(this.profit)`）
func creditProfit() -> void:
	var gain := int(round(profit))
	if gain > 0:
		Game.addMoney(gain)


## 弹药写回（H5: `profile.game.<武器>Ammo = player.weapons[i].ammo`，武器槽 1~8 + mines）：
## 无限弹的 minigun 不写（H5 也没写）；有限弹武器写回时由 Game.set_weapon_ammo 按上限 clamp。
func saveWeaponAmmo() -> void:
	if not is_instance_valid(player):
		return
	var weapons: Variant = player.get("weapons")
	if not (weapons is Array):
		return
	for w in (weapons as Array):
		if w == null or not is_instance_valid(w) or not (w is ATWeapon):
			continue
		var wp := w as ATWeapon
		if wp.id == "" or wp.hasInfiniteAmmo():
			continue
		Game.setWeaponAmmo(wp.id, int(wp.ammo))


func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	if freezeTime > 0:
		freezeTime -= delta
		if freezeTime <= 0:
			unfreezeEnemies()
	refreshHud()
	# 迷雾惰性更新（H5 updateFogLazy：约每 3 帧一次）
	fogFrame += 1
	if fog != null and player != null and is_instance_valid(player) \
			and fogFrame % 3 == 0:
		updateFog()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		onHudPausePressed()
		get_viewport().set_input_as_handled()
