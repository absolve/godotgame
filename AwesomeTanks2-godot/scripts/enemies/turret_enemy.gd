extends ATEnemy
## TurretEnemy —— 固定炮塔形态场景（scenes/enemies/TurretEnemy.tscn）
## 对应原项目 window.AT.Turret：底座 + 可旋转炮塔，不移动，共 8 种武器（数据见 ATEnemyTypes.TURRETS）
##
## 为什么只有 1 个炮塔场景：8 种炮塔结构完全相同，仅底座/炮塔贴图、武器与数值不同，
## 因此合并为一个形态场景，关卡生成时按瓦片调用 apply_type() 应用对应数据。
##
## 场景结构：
##   TurretEnemy (ATTurretEnemy)
##   ├─ BaseSprite    —— 底座贴图（apply_type 里按类型设置）
##   ├─ TurretSprite  —— 炮塔贴图（apply_type 里按类型设置）
##   ├─ BodySprite    —— 隐藏（炮塔无车体）
##   └─ Weapon        —— apply_type 运行时按类型实例化的武器场景
## 转向/开火行为等状态机接入后再补，本类目前只保证表现与数据正确。

class_name ATTurretEnemy

@onready var _base_sprite: Sprite2D = get_node_or_null("BaseSprite")


func _ready() -> void:
	super._ready()
	# 固定炮塔无车体：隐藏车体精灵（可见的是底座 + 炮塔）
	_body_sprite.visible = false
	move_speed = 0.0   # 不可移动（move() 亦为 no-op），让"能否移动"的判定统一看 move_speed
	burn_damage = 4.0  # H5：固定炮塔被点燃每帧 4 点（L21890 new Fire(this, 4)）
	if _base_sprite != null:
		_base_sprite.visible = _base_sprite.texture != null
	# 炮塔暂不跑通用坦克 AI（原地转向由自身 _physics_process 处理）；
	# 后续给炮塔单独做 Attack/Patrol 状态时再启用状态机
	if ai != null:
		ai.enabled = false


## 按类型数据表应用：贴图（底座/炮塔）、数值、武器
## def 同 ATEnemyTypes.TURRETS 的每一项；须在节点入树后调用（依赖 @onready 与 add_child）
func apply_type(def: Dictionary) -> void:
	if def.is_empty():
		return
	# 数值
	enemy_id = str(def.get("id", ""))
	max_health = float(def.get("max_health", max_health))
	health = max_health
	points = int(def.get("points", points))
	view_distance = float(def.get("view_distance", view_distance))
	shoot_range = view_distance
	shoot_angle = float(def.get("shoot_angle", shoot_angle))
	turret_speed = float(def.get("turret_speed", 3.0)) * ATEnemyTypes.RAD2DEG
	# 贴图：底座 + 炮塔
	var turret_key := str(def.get("turret", ""))
	var base_key := str(def.get("base", ""))
	if _base_sprite != null:
		var base_path := ATEnemyTypes.TURRET_TEX + base_key + ".png.tres"
		if ResourceLoader.exists(base_path):
			_base_sprite.texture = load(base_path)
			_base_sprite.visible = true
	_build_turret_frames(turret_key)
	# 武器：按类型实例化武器场景并覆盖 CPU 参数
	_setup_weapon(str(def.get("weapon", "")), def.get("params", {}))


func _build_turret_frames(turret_key: String) -> void:
	var path := ATEnemyTypes.TURRET_TEX + turret_key + ".png.tres"
	if not ResourceLoader.exists(path):
		return
	var frames := SpriteFrames.new()
	# 新建的 SpriteFrames 自带一个空的 "default" 动画，直接 add 会报"已存在"
	if not frames.has_animation("default"):
		frames.add_animation("default")
	frames.set_animation_speed("default", 1.0)
	frames.set_animation_loop("default", false)
	frames.add_frame("default", load(path))
	_turret_sprite.sprite_frames = frames
	_turret_sprite.play("default")


func _setup_weapon(weapon_key: String, params: Dictionary) -> void:
	if weapon_key == "":
		return
	var path := ATEnemyTypes.WEAPON_DIR + weapon_key + ".tscn"
	if not ResourceLoader.exists(path):
		push_warning("TurretEnemy: 武器场景缺失 " + path)
		return
	# 先清掉旧武器（apply_type 可重复调用）
	for child in get_children():
		if child is ATWeapon:
			child.queue_free()
	weapons.clear()
	weapon = null
	var w: Node = (load(path) as PackedScene).instantiate()
	w.name = "Weapon"
	add_child(w)
	for key in params:
		if key in w:
			w.set(key, params[key])
	_collect_weapons()


## 视觉兜底：tank_key 为空（形态场景）时不做任何加载，等 apply_type 指定类型
func _configure_enemy_visuals() -> void:
	if tank_key == "":
		return
	super._configure_enemy_visuals()


func _physics_process(delta: float) -> void:
	# 不跑移动 AI：只更新后坐力偏移（转向/开火由后续状态机驱动）
	_update_turret_recoil(delta)
	if level != null and is_instance_valid(level.player):
		var aim: float = (level.player.global_position - global_position).angle()
		rotate_turret(aim, delta)


func _has_line_of_sight() -> bool:
	# TODO: 状态机接入时用 RayCast2D 检测玩家
	return false


func move(_dir: Vector2) -> void:
	pass   # 固定炮塔不移动
