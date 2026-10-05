extends ATEnemy
## TurretEnemy —— 固定炮塔形态场景（scenes/enemies/turret_enemy.tscn）
## 对应原项目 window.AT.Turret：底座 + 可旋转炮塔，不移动，共 8 种武器（数据见 ATEnemyTypes.TURRETS）
##
## 为什么只有 1 个炮塔场景：8 种炮塔结构完全相同，仅底座/炮塔贴图、武器与数值不同，
## 因此合并为一个形态场景，关卡生成时按瓦片调用 applyType() 应用对应数据。
##
## 场景结构：
##   TurretEnemy (ATTurretEnemy)
##   ├─ BaseSprite    —— 底座贴图（applyType 里按类型设置）
##   ├─ TurretSprite  —— 炮塔贴图（applyType 里按类型设置）
##   ├─ BodySprite    —— 隐藏（炮塔无车体）
##   └─ Weapon        —— applyType 运行时按类型实例化的武器场景
## 转向/开火行为等状态机接入后再补，本类目前只保证表现与数据正确。

class_name ATTurretEnemy

@onready var baseSprite: Sprite2D = get_node_or_null("BaseSprite")


func _ready() -> void:
	super._ready()
	# 固定炮塔无车体：隐藏车体精灵（可见的是底座 + 炮塔）
	bodySprite.visible = false
	moveSpeed = 0.0   # 不可移动（move() 亦为 no-op），让"能否移动"的判定统一看 move_speed
	burnDamage = 4.0  # H5：固定炮塔被点燃每帧 4 点（L21890 new Fire(this, 4)）
	if baseSprite != null:
		baseSprite.visible = baseSprite.texture != null
	# 炮塔暂不跑通用坦克 AI（原地转向由自身 _physics_process 处理）；
	# 后续给炮塔单独做 Attack/Patrol 状态时再启用状态机
	if ai != null:
		ai.enabled = false


## 按类型数据表应用：贴图（底座/炮塔）、数值、武器
## def 同 ATEnemyTypes.TURRETS 的每一项；须在节点入树后调用（依赖 @onready 与 add_child）
func applyType(def: Dictionary) -> void:
	if def.is_empty():
		return
	# 数值
	enemyId = str(def.get("id", ""))
	maxHealth = float(def.get("max_health", maxHealth))
	health = maxHealth
	points = int(def.get("points", points))
	viewDistance = float(def.get("view_distance", viewDistance))
	shootRange = viewDistance
	shootAngle = float(def.get("shoot_angle", shootAngle))
	turretSpeed = float(def.get("turret_speed", 3.0)) * ATEnemyTypes.RAD2_DEG
	# 贴图：底座 + 炮塔
	var turretKey := str(def.get("turret", ""))
	var baseKey := str(def.get("base", ""))
	if baseSprite != null:
		var basePath := ATEnemyTypes.TURRET_TEX + baseKey + ".png.tres"
		if ResourceLoader.exists(basePath):
			baseSprite.texture = load(basePath)
			baseSprite.visible = true
	buildTurretFrames(turretKey)
	# 武器：按类型实例化武器场景并覆盖 CPU 参数
	setupWeapon(str(def.get("weapon", "")), def.get("params", {}))


func buildTurretFrames(turretKey: String) -> void:
	var path := ATEnemyTypes.TURRET_TEX + turretKey + ".png.tres"
	if not ResourceLoader.exists(path):
		return
	var frames := SpriteFrames.new()
	# 新建的 SpriteFrames 自带一个空的 "default" 动画，直接 add 会报"已存在"
	if not frames.has_animation("default"):
		frames.add_animation("default")
	frames.set_animation_speed("default", 1.0)
	frames.set_animation_loop("default", false)
	frames.add_frame("default", load(path))
	turretSprite.sprite_frames = frames
	turretSprite.play("default")


func setupWeapon(weaponKey: String, params: Dictionary) -> void:
	if weaponKey == "":
		return
	var path := ATEnemyTypes.WEAPON_DIR + weaponKey + ".tscn"
	if not ResourceLoader.exists(path):
		push_warning("TurretEnemy: 武器场景缺失 " + path)
		return
	# 先清掉旧武器（applyType 可重复调用）
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
	collectWeapons()


## 视觉兜底：tankKey 为空（形态场景）时不做任何加载，等 applyType 指定类型
func configureEnemyVisuals() -> void:
	if tankKey == "":
		return
	super.configureEnemyVisuals()


func hasLineOfSight() -> bool:
	# TODO: 状态机接入时用 RayCast2D 检测玩家
	return false


func move(dir: Vector2) -> void:
	pass   # 固定炮塔不移动


func _physics_process(delta: float) -> void:
	# 不跑移动 AI：只更新后坐力偏移（转向/开火由后续状态机驱动）
	updateTurretRecoil(delta)
	if level != null and is_instance_valid(level.player):
		var aim: float = (level.player.global_position - global_position).angle()
		rotateTurret(aim, delta)
