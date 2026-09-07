extends ATTank
## Player —— 玩家坦克（继承 ATTank）
## - 视觉：车体 body_0/1 履带动画；炮塔按当前武器切换 game/player/<weapon>.png 动画，
##   切换瞬间 0.5→1 弹性放大（对应 H5 changeWeapon 的 Elastic tween + weapon_change.mp3）
## - 武器：_setup_weapons() 按存档等级从 scenes/weapons/* 实例化已拥有武器

class_name ATPlayer

var auto_aim: bool = false
var auto_aim_target: Node2D = null

const DIR_WEAPONS = "res://scenes/weapons/"

# 槽位顺序与 Settings.WEAPON_KEYS + mines 一致（索引 9 = mines）
const SLOT_KEYS: Array[String] = [
	"minigun", "shotgun", "ricochet", "flamethrower", "cannon",
	"shock", "rockets", "laser", "railgun", "mines",
]


func _ready() -> void:
	super._ready()
	team = Constants.Team.PLAYER
	name = "player"
	_apply_upgrades()
	_setup_weapons()


func _apply_upgrades() -> void:
	var g: Dictionary = Game.current["game"]
	move_speed = Settings.SPEED_LEVELS[int(g["speed"])]
	turret_speed = Settings.TURRET_LEVELS[int(g["turret"])]
	view_angle = Settings.VIEW_ANGLE_LEVELS[int(g["sight"])]
	view_distance = Settings.VIEW_DISTANCE_LEVELS[int(g["sight"])]
	max_health = Settings.ARMOR_LEVELS[int(g["armor"])]
	health = max_health


## 根据存档生成武器节点：level >=0 即拥有；minigun 默认必有
func _setup_weapons() -> void:
	var g: Dictionary = Game.current["game"]
	weapons = []
	weapons.resize(SLOT_KEYS.size())
	for i in SLOT_KEYS.size():
		var key: String = SLOT_KEYS[i]
		var level: int = int(g.get(key + "Level", -1))
		if key == "minigun":
			level = maxi(level, 0)
		if level < 0:
			continue
		var scene_path := DIR_WEAPONS + key + ".tscn"
		if not ResourceLoader.exists(scene_path):
			continue
		var w: Node = (load(scene_path) as PackedScene).instantiate()
		w.set("tank", self)
		w.set("team", Constants.Team.PLAYER)
		if "id" in w:
			w.id = key
		# 弹药（minigun 无限；其余按 AMMO_LIMITS/存档设置——场景默认是无限，需显式改为有限）
		if Settings.AMMO_LIMITS.has(key):
			var limit: int = int(Settings.AMMO_LIMITS[key])
			w.max_ammo = limit
			w.ammo = int(g.get(key + "Ammo", limit))
		# 等级参数注入（WEAPON_STATS 表后续接入后生效；无则用场景默认值）
		var params: Dictionary = _level_params(key, level)
		if not params.is_empty() and w.has_method("apply_params"):
			w.apply_params(params)
		add_child(w)
		w.name = key
		weapons[i] = w
	# 默认装备 minigun
	if not weapons.is_empty() and weapons[0] != null:
		weapon = weapons[0]
		weapon_index = 0
		if weapon.has_method("activate"):
			weapon.activate()
		switch_turret("minigun")


## 按 Settings.WEAPON_STATS 取该武器当前等级参数（damage/rate/life/spawn_count）
func _level_params(key: String, level: int) -> Dictionary:
	var out: Dictionary = {}
	var stats: Variant = Settings.WEAPON_STATS.get(key, {})
	if not stats is Dictionary:
		return out
	for prop in stats:
		if prop == "velocity":
			continue  # 火箭速度因子与像素换算待统一，速度沿用场景默认值
		var arr = stats[prop]
		if arr is Array and arr.size() > level:
			out[prop] = arr[level]
	return out


# ============================================================
# 换武器表现（切炮塔动画 + 弹性缩放 + 声音在基类播放）
# ============================================================
func _on_weapon_changed(_index: int) -> void:
	var key := ""
	if weapon != null and "id" in weapon:
		key = str(weapon.id)
	switch_turret(key)
	_animate_turret_switch()


func _animate_turret_switch() -> void:
	# 以炮塔中心为基准 0.5→1 弹性放大（近似 H5 Elastic.Out；AnimatedSprite2D 默认绕节点中心缩放）
	var tw := create_tween()
	_turret_sprite.scale = Vector2(0.5, 0.5)
	tw.tween_property(_turret_sprite, "scale", Vector2.ONE, 0.45) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


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
	# 鼠标瞄准（持续跟随）
	#var aim := (get_global_mouse_position() - global_position).angle()
	#rotate_turret(aim, delta)
	_turret_sprite.look_at(get_global_mouse_position())
	if not alive:
		return
	# 移动
	var dir := Vector2.ZERO
	dir.x = Input.get_axis("move_left", "move_right")
	dir.y = Input.get_axis("move_up", "move_down")
	if dir != Vector2.ZERO:
		move(dir.normalized())
	else:
		velocity = velocity.lerp(Vector2.ZERO, 0.2)
		
	# 开火
	if Input.is_action_pressed("fire"):
		#print(1)
		start_fire()
	else:
		stop_fire()
	# 切武器
	if Input.is_action_just_pressed("next_weapon"):
		next_weapon()
	if Input.is_action_just_pressed("prev_weapon"):
		prevWeapon()
