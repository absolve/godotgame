extends ATTank
## Player —— 玩家坦克（继承 ATTank）
## - 视觉：车体 body_0/1 履带动画；炮塔按当前武器切换 game/player/<weapon>.png 动画，
##   切换瞬间 0.5→1 弹性放大（对应 H5 changeWeapon 的 Elastic tween + weapon_change.mp3）
## - 武器：_setup_weapons() 按存档等级从 scenes/weapons/* 实例化已拥有武器

class_name ATPlayer

var autoAim: bool = false
var autoAimTarget: Node2D = null

## 关卡引用（Level._spawn_player 注入；用于按关卡序号算点燃时长，H5 (55+40×index)/60 秒）
var level: Node = null
## 操作锁：关卡结算（清场/阵亡）后由 Level 置 true —— 收回驾驶/开火/换武器
## （H5 是 summaryAlert 存在时 player.stopFire()；这里连驾驶一起锁，
##   否则会出现"关卡已经结束还能开车打枪"）
var controlLocked: bool = false
## 正在制导的火箭（H5 player.follow）：非空时不能开车（镜头在导弹上），
## 导弹一没（命中/引爆）就自动清空、控制权还回来（由 Level.clear_guided_rocket 处理）
var follow: Node2D = null

# ---------- 黑雾视野（见 updateFogReveal） ----------
## 每帧从炮口发射的射线数（正前方 + 左右各半个间隔，合计 FOG_CONE_DEG 度）
const FOG_RAY_COUNT: int = 3
## 这三条射线张开的角度（度）
const FOG_CONE_DEG: float = 45.0
## 出生时向四周发射多少条射线清雾（长度按视野距离；0 = 不扫）
@export var fogSpawnSweepRays: int = 72
## 出生扫描重发几次（黑雾瓦片进物理空间比第一帧晚，多扫几帧把漏的补上）
@export var fogSpawnSweepFrames: int = 3
## 出生扫描剩余帧数（-1 = 还没开始）
var fogSpawnFramesLeft: int = -1

const DIR_WEAPONS = "res://scenes/weapons/"

# 槽位顺序与 Settings.WEAPON_KEYS + mines 一致（索引 9 = mines）
const SLOT_KEYS: Array[String] = [
	"minigun", "shotgun", "ricochet", "flamethrower", "cannon",
	"shock", "rockets", "laser", "railgun", "mines",
]


func _ready() -> void:
	# team 必须在 super._ready() 之前设置：基类按 team 决定碰撞层（PLAYER / ENEMY）
	team = Constants.Team.PLAYER
	super._ready()
	name = "player"
	applyUpgrades()
	setupWeapons()


func applyUpgrades() -> void:
	var g: Dictionary = Game.current["game"]
	moveSpeed = Settings.SPEED_LEVELS[int(g["speed"])]
	turretSpeed = Settings.TURRET_LEVELS[int(g["turret"])]
	viewAngle = Settings.VIEW_ANGLE_LEVELS[int(g["sight"])]
	viewDistance = Settings.VIEW_DISTANCE_LEVELS[int(g["sight"])]
	maxHealth = Settings.ARMOR_LEVELS[int(g["armor"])]
	health = maxHealth


## 根据存档生成武器节点：level >=0 即拥有；minigun 默认必有
func setupWeapons() -> void:
	var g: Dictionary = Game.current["game"]
	weapons = []
	weapons.resize(SLOT_KEYS.size())
	for i in SLOT_KEYS.size():
		var key: String = SLOT_KEYS[i]
		var weaponLevel: int = int(g.get(key + "Level", -1))
		if key == "minigun":
			weaponLevel = maxi(weaponLevel, 0)
		if weaponLevel < 0:
			continue
		var scenePath := DIR_WEAPONS + key + ".tscn"
		if not ResourceLoader.exists(scenePath):
			continue
		var w: Node = (load(scenePath) as PackedScene).instantiate()
		w.set("tank", self)
		w.set("team", Constants.Team.PLAYER)
		if "id" in w:
			w.id = key
		# 弹药（minigun 无限；其余按 AMMO_LIMITS/存档改成有限弹——场景默认是"无限弹"）
		if Settings.AMMO_LIMITS.has(key):
			var limit: int = int(Settings.AMMO_LIMITS[key])
			w.infiniteAmmo = false
			w.maxAmmo = limit
			w.ammo = int(g.get(key + "Ammo", limit))
		# 等级参数注入（WEAPON_STATS 表后续接入后生效；无则用场景默认值）
		var params: Dictionary = levelParams(key, weaponLevel)
		if not params.is_empty() and w.has_method("applyParams"):
			w.applyParams(params)
		add_child(w)
		w.name = key
		weapons[i] = w
	# 默认装备 minigun
	if not weapons.is_empty() and weapons[0] != null:
		weapon = weapons[0]
		weaponIndex = 0
		if weapon.has_method("activate"):
			weapon.activate()
		switchTurret("minigun")


## 按 Settings.WEAPON_STATS 取该武器当前等级参数（damage/rate/life/spawnCount）
func levelParams(key: String, weaponLevel: int) -> Dictionary:
	var out: Dictionary = {}
	var stats: Variant = Settings.WEAPON_STATS.get(key, {})
	if not stats is Dictionary:
		return out
	for prop in stats:
		if prop == "velocity":
			continue  # 火箭速度因子与像素换算待统一，速度沿用场景默认值
		var arr = stats[prop]
		if arr is Array and arr.size() > weaponLevel:
			out[prop] = arr[weaponLevel]
	return out


# ============================================================
# 换武器表现（切炮塔动画 + 弹性缩放 + 声音在基类播放）
# ============================================================
func onWeaponChanged(_index: int) -> void:
	var key := ""
	if weapon != null and "id" in weapon:
		key = str(weapon.id)
	switchTurret(key)
	animateTurretSwitch()


func animateTurretSwitch() -> void:
	# 以炮塔中心为基准 0.5→1 弹性放大（近似 H5 Elastic.Out；AnimatedSprite2D 默认绕节点中心缩放）
	var tw := create_tween()
	turretSprite.scale = Vector2(0.5, 0.5)
	tw.tween_property(turretSprite, "scale", Vector2.ONE, 0.45) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# ============================================================
# 受击 / 点燃（H5：玩家被火焰命中会着火，时长随关卡序号增长）
# ============================================================
func onBulletHit(damage: float, srcWeapon: Node, bullet: Node) -> void:
	super.onBulletHit(damage, srcWeapon, bullet)
	if not alive or invincible:
		return
	tryIgnite(srcWeapon)


## 燃烧时长 = (55 + 40×关卡序号)/60 秒（H5 L22561）；点燃本身在 ATTank.tryIgnite
func igniteDuration() -> float:
	var index := 0
	if level != null and is_instance_valid(level) and "levelIndex" in level:
		index = int(level.get("levelIndex"))
	return (55.0 + 40.0 * float(index)) / 60.0


func kill() -> void:
	# H5 player.kill：this.follow && (this.follow.requestKill = !0) —— 阵亡时把在飞的导弹引爆
	if is_instance_valid(follow) and follow.has_method("detonate"):
		follow.call("detonate")
	follow = null
	super.kill()


# ============================================================
# 输入/战斗（沿用原实现）
# ============================================================
func _unhandled_input(_event: InputEvent) -> void:
	#if not alive:
		#return
	## 移动
	#var dir := Vector2.ZERO
	#dir.x = Input.get_axis("move_left", "move_right")
	#dir.y = Input.get_axis("move_up", "move_down")
	#if dir != Vector2.ZERO:
		#move(dir.normalized())
	#else:
		#velocity = velocity.lerp(Vector2.ZERO, 0.2)
	## 瞄准
	#if event is InputEventMouseMotion:
		#var aim := (get_global_mouse_position() - global_position).angle()
		#rotate_turret(aim, get_physics_process_delta_time())
	## 开火
	#if Input.is_action_pressed("fire"):
		#start_fire()
	#else:
		#stop_fire()
	## 切武器
	#if Input.is_action_just_pressed("next_weapon"):
		#next_weapon()
	pass


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	# 鼠标瞄准（持续跟随；制导火箭时玩家也是用鼠标给导弹指方向）
	#var aim := (get_global_mouse_position() - global_position).angle()
	#rotate_turret(aim, delta)
	turretSprite.look_at(get_global_mouse_position())
	# 黑雾：按刚刚定下的炮口方向扫视野（开场几帧先四周扫一圈）
	updateFogReveal()
	if not alive:
		return
	if not is_instance_valid(follow):
		follow = null
	# 关卡已结算：只减速停下，不接受任何操作（炮塔仍跟着鼠标，纯表现）
	if controlLocked:
		velocity = velocity.lerp(Vector2.ZERO, 0.2)
		stopFire()
		return
	# 移动（制导火箭期间不能开车 —— 镜头在导弹上，H5 同）
	if follow != null:
		velocity = velocity.lerp(Vector2.ZERO, 0.2)
	else:
		var dir := Vector2.ZERO
		dir.x = Input.get_axis("move_left", "move_right")
		dir.y = Input.get_axis("move_up", "move_down")
		if dir != Vector2.ZERO:
			move(dir.normalized())
		else:
			velocity = velocity.lerp(Vector2.ZERO, 0.2)

	# 开火（制导期间仍要能按：再按一次 = 引爆导弹，见 ATWeaponRockets.set_firing）
	if Input.is_action_pressed("fire"):
		#print(1)
		startFire()
	else:
		stopFire()
	# 切武器
	if Input.is_action_just_pressed("next_weapon"):
		nextWeapon()
	if Input.is_action_just_pressed("prev_weapon"):
		prevWeapon()


# ============================================================
# 黑雾视野（玩家坦克自己驱动；射线工具在 ATFog.castRay）
# ============================================================
## 1) 每物理帧：从炮口朝 3 个方向（正前方 + 左右各 22.5°，合计约 45°）发射射线，
##    射线只跟墙壁/黑雾碰撞、撞墙即停 → 墙后面的黑雾不会被清掉；看过的格子永久保持亮。
## 2) 出生时：按视野长度向四周发射一圈射线，把出生点周围清一遍
##    （黑雾瓦片进物理空间比第一帧晚，所以前几帧重发几次）。
## 3) 制导火箭期间：视野跟着导弹（H5 updateFog 的 player.follow 分支）。
func updateFogReveal() -> void:
	if level == null or not is_instance_valid(level):
		return
	var f: ATFog = level.get("fog")
	if f == null:
		return
	if follow is Node2D and is_instance_valid(follow):
		f.clearArea(int(follow.global_position.x / f.tileSize),
			int(follow.global_position.y / f.tileSize), f.clearRadiusTiles)
		return
	var dist := viewDistance
	# 出生扫描
	if fogSpawnFramesLeft != 0:
		if fogSpawnFramesLeft < 0:
			fogSpawnFramesLeft = maxi(fogSpawnSweepFrames, 1)
		fogSpawnFramesLeft -= 1
		if fogSpawnSweepRays > 0:
			for i in fogSpawnSweepRays:
				f.castRay(global_position, TAU * float(i) / float(fogSpawnSweepRays), dist)
	# 每帧：炮口方向的 3 条射线
	var half := deg_to_rad(FOG_CONE_DEG) * 0.5
	var step := deg_to_rad(FOG_CONE_DEG) / float(maxi(FOG_RAY_COUNT - 1, 1))
	var aim := getTurretRotation()
	for i in FOG_RAY_COUNT:
		f.castRay(global_position, aim - half + step * float(i), dist)
