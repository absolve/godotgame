extends ATTank
## Player — 玩家坦克
## 读取 WASD 移动 + 鼠标瞄准/开火；武器槽由 Game 存档驱动。

class_name ATPlayer

var auto_aim: bool = false
var auto_aim_target: Node2D = null

func _ready() -> void:
	super._ready()
	team = ATConst.Team.PLAYER
	name = "player"
	# 根据存档设置性能等级
	var g: Dictionary = Game.current["game"]
	move_speed = Settings.SPEED_LEVELS[g["speed"]]
	turret_speed = Settings.TURRET_LEVELS[g["turret"]]
	view_angle = Settings.VIEW_ANGLE_LEVELS[g["sight"]]
	view_distance = Settings.VIEW_DISTANCE_LEVELS[g["sight"]]
	max_health = Settings.ARMOR_LEVELS[g["armor"]]
	health = max_health
	_setup_weapons()

func _setup_weapons() -> void:
	# TODO: 根据存档的武器等级实例化武器节点（minigun 必有，其余可选）
	# 参考 tank.gd 的 weapons 数组与 Settings.WEAPON_KEYS
	pass

func _unhandled_input(event: InputEvent) -> void:
	if not alive:
		return
	# 移动
	var dir := Vector2.ZERO
	dir.x = Input.get_axis("move_left", "move_right")
	dir.y = Input.get_axis("move_up", "move_down")
	if dir != Vector2.ZERO:
		move(dir.normalized())
	else:
		linear_velocity = linear_velocity.lerp(Vector2.ZERO, 0.2)
	# 瞄准
	if event is InputEventMouseMotion:
		var aim := (get_global_mouse_position() - global_position).angle()
		rotate_turret(aim, get_process_delta_time())
	# 开火
	if Input.is_action_pressed("fire"):
		start_fire()
	else:
		stop_fire()
	# 切武器
	if Input.is_action_just_pressed("next_weapon"):
		next_weapon()

func _process(delta: float) -> void:
	super._process(delta)
	# 鼠标瞄准（持续跟随）
	var aim := (get_global_mouse_position() - global_position).angle()
	rotate_turret(aim, delta)
