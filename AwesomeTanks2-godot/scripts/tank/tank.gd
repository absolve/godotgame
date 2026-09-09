extends CharacterBody2D
## Tank —— 坦克基类（玩家与敌人共用；对应原项目 window.AT.Tank）
##
## 视觉结构（见 scenes/tanks/tank.tscn）：
##   BodySprite    = AnimatedSprite2D（车体：body_0/1 两帧履带动画 "move"）
##   TurretSprite  = AnimatedSprite2D（炮塔：每种武器一个动画帧集，切换武器即换动画）
## 各子类在 _ready 里通过 configure_body_animation()/configure_turret_frames() 提供贴图，
## 再靠 play_tracks() 播放履带、switch_turret(key) 切炮塔动画。

class_name ATTank

signal killed

@onready var _body_sprite: AnimatedSprite2D = $BodySprite
@onready var _turret_sprite: AnimatedSprite2D = $TurretSprite
@onready var _body: CollisionShape2D = $Body
#@onready var _hit_flash: Node = $BodySprite/HitFlash  # 受击闪光组件（基座场景自带，全坦克共用）

# 物理参数（由子类根据升级等级设置）
var move_speed: float = 150.0
var turret_speed: float = 240.0     # 度/秒
var max_health: float = 100.0
var health: float = 100.0
var view_angle: float = 90.0
var view_distance: float = 300.0

var team: int = Constants.Team.CPU
var weapon_index: int = 0
var weapons: Array = []             # 武器节点数组（可为 null 占位）
var weapon: Node = null
var invincible: bool = false
var alive: bool = true
var conducts_current: bool = true   # H5 conductsCurrent：坦克(敌人/玩家/炮塔/生成器)导电（Shock 链）

# 炮塔后坐力（H5 recoil：武器开火时 tank.recoil=3~5，炮塔沿炮管反方向偏移后衰减）
var _recoil: float = 0.0
var kill_delay: float = 0.12

# 后坐力衰减速度（px/s；H5 每帧 -0.3 @60fps ≈ 18/s）
const RECOIL_DECAY_PER_SEC: float = 18.0

var _material: ShaderMaterial = null
var _tween: Tween = null





func _ready() -> void:
	# 圆形碰撞（可在场景给 CollisionShape2D 预设，这里兜底重建）
	var shape := CircleShape2D.new()
	shape.radius = 22.0
	(_body as CollisionShape2D).shape = shape
	collision_layer = _my_layer()
	collision_mask = _my_mask()
	_body_sprite.material = _material

func _my_layer() -> int:
	return 1 << (Constants.Layer.PLAYER - 1) if team == Constants.Team.PLAYER else 1 << (Constants.Layer.ENEMY - 1)

func _my_mask() -> int:
	# 坦克碰墙 + 障碍物 + 对方队伍
	return Constants.layer_mask([Constants.Layer.WALL, Constants.Layer.OBSTACLE, Constants.Layer.ENEMY_SPAWNER, Constants.Layer.PLAYER, Constants.Layer.ENEMY])

func _physics_process(delta: float) -> void:
	# 炮塔后坐力恢复 + 炮管反方向偏移
	_update_turret_recoil(delta)
	if not alive:
		_body_sprite.stop()
		return
	# 车体朝速度方向旋转 + 履带动画
	#var v := velocity
	var speed := velocity.length()
	if speed > 1.0:
		var target := velocity.angle()
		var diff := wrapf(target - _body_sprite.rotation, -PI, PI)
		var step = deg_to_rad(8.0) * clamp(speed / max(move_speed, 1.0), 0.0, 1.0)
		_body_sprite.rotation += clamp(diff, -step, step)
		_play_tracks()
	else:
		_stop_tracks()
	move_and_slide()

# ============================================================
# 移动 / 炮塔
# ============================================================
func move(dir: Vector2) -> void:
	velocity = dir * move_speed

func rotate_turret(target_angle: float, delta: float) -> void:
	var cur := _turret_sprite.rotation
	var diff := wrapf(target_angle - cur, -PI, PI)
	var step := deg_to_rad(turret_speed) * delta
	_turret_sprite.rotation = cur + clamp(diff, -step, step)

func get_turret_position(offset: float) -> Vector2:
	var r := _turret_sprite.rotation
	return global_position + Vector2(cos(r), sin(r)) * offset


## 炮塔当前朝向角（用于 Fog 视野扇形等）
func get_turret_rotation() -> float:
	if _turret_sprite != null:
		return _turret_sprite.rotation
	return rotation


# ============================================================
# 视觉动画（车体履带 / 炮塔切武器）
# ============================================================
## 子类提供车体贴图路径 [frame0, frame1]，构建 "move" 动画（20fps 循环，H5 同款）
## （玩家已用场景内 SpriteFrames；敌人子类仍调用此接口，故保留）
func configure_body_animation(frame_paths: Array[String]) -> void:
	var frames := SpriteFrames.new()
	frames.add_animation("move")
	frames.set_animation_speed("move", 20.0)
	frames.set_animation_loop("move", true)
	for p in frame_paths:
		var tex := load(p) as Texture2D
		if tex != null:
			frames.add_frame("move", tex)
	_body_sprite.sprite_frames = frames
	_body_sprite.stop()
	_body_sprite.frame = 0

## 子类提供 炮塔动画名 -> 贴图路径（每种武器一帧），构建切换用的动画集
func configure_turret_frames(anim_map: Dictionary) -> void:
	var frames := SpriteFrames.new()
	for anim_name in anim_map:
		var paths: Array = anim_map[anim_name]
		frames.add_animation(str(anim_name))
		frames.set_animation_speed(str(anim_name), 1.0)
		frames.set_animation_loop(str(anim_name), false)
		for p in paths:
			var tex := load(p) as Texture2D
			if tex != null:
				frames.add_frame(str(anim_name), tex)
	_turret_sprite.sprite_frames = frames

## 显示某武器的炮塔动画（找不到就切回默认）
func switch_turret(anim_name: String) -> void:
	if _turret_sprite.sprite_frames == null:
		return
	if _turret_sprite.sprite_frames.has_animation(anim_name):
		_turret_sprite.play(anim_name)
	elif _turret_sprite.sprite_frames.has_animation("default"):
		_turret_sprite.play("default")

func _play_tracks() -> void:
	if _body_sprite.sprite_frames != null and _body_sprite.sprite_frames.has_animation("move") \
			and not _body_sprite.is_playing():
		_body_sprite.play("move")

func _stop_tracks() -> void:
	if _body_sprite.is_playing():
		_body_sprite.stop()
		_body_sprite.frame = 0

# ============================================================
# 武器
# ============================================================
func change_weapon(index: int) -> void:
	if index < 0 or index >= weapons.size():
		return
	if weapons[index] == null or weapons[index] == weapon:
		return
	if weapon and weapon.has_method("deactivate"):
		weapon.deactivate()
	weapon_index = index
	weapon = weapons[index]
	if weapon and weapon.has_method("activate"):
		weapon.activate()
	_on_weapon_changed(index)
	Audio.play_sfx("weapon_change.mp3")

## 换武器时的表现钩子：子类（玩家）切炮塔动画 + 弹性动画
func _on_weapon_changed(_index: int) -> void:
	pass

func next_weapon() -> void:
	if weapons.is_empty():
		return
	var i := weapon_index
	for _step in range(weapons.size()):
		i = posmod(i + 1, weapons.size())
		if weapons[i] != null:
			change_weapon(i)
			return

func prevWeapon():
	if weapons.is_empty():
		return
	var i := weapon_index
	for _step in range(weapons.size()):
		i = posmod(i - 1, weapons.size())
		if weapons[i] != null:
			change_weapon(i)
			return
	
func start_fire() -> void:
	if weapon and weapon.has_method("set_firing"):
		weapon.set_firing(true)

func stop_fire() -> void:
	if weapon and weapon.has_method("set_firing"):
		weapon.set_firing(false)

# ============================================================
# 受击 / 死亡
# ============================================================
func on_bullet_hit(damage: float, src_weapon: Node, _bullet: Node) -> void:
	if invincible:
		return
	health -= damage
	_flash_hit(src_weapon.hit_color if src_weapon != null and "hit_color" in src_weapon else Color.WHITE)
	if health <= 0 and alive:
		_kill()


## 触发受击闪光（由 BodySprite/HitFlash 着色器组件统一播放）
func _flash_hit(color := Color.WHITE) -> void:
	flash(color)

func _kill() -> void:
	alive = false
	if weapon and weapon.has_method("set_firing"):
		weapon.set_firing(false)
	killed.emit()
	Audio.play_sfx("explosion.mp3", 2.0)

func freeze() -> void:
	# TODO: 冰冻效果（冰覆盖层/减速）
	pass

func unfreeze() -> void:
	pass

## 触发一次受击闪光
func flash(color := Color.WHITE, duration := 0.2) -> void:
	if _material == null:
		return
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_material.set_shader_parameter("flash_color", color)
	_material.set_shader_parameter("flash_amount", 1.0)
	_tween = create_tween()
	_tween.tween_method(_set_amount, 1.0, 0.0, duration)


func _set_amount(v: float) -> void:
	if _material != null:
		_material.set_shader_parameter("flash_amount", v)

## 触发炮塔后坐力（H5 recoil setter：只取较大值，连续射击保持峰值）
func apply_recoil(strength: float) -> void:
	if strength > _recoil:
		_recoil = strength

## 后坐力恢复 + 炮塔精灵按炮管反方向偏移（delta 驱动，消除帧率相关）
func _update_turret_recoil(delta: float) -> void:
	if _turret_sprite == null:
		return
	_recoil = maxf(_recoil - RECOIL_DECAY_PER_SEC * delta, 0.0)
	if _recoil <= 0.0:
		if not _turret_sprite.position.is_zero_approx():
			_turret_sprite.position = Vector2.ZERO
		return
	# 炮管反方向偏移（旋转在精灵自身坐标系，cos/sin 即炮口朝向的反向）
	var r := _turret_sprite.rotation
	_turret_sprite.position = -Vector2(cos(r), sin(r)) * _recoil
