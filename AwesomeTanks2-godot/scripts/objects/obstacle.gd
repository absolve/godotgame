extends StaticBody2D
## Obstacle — 可破坏障碍物基类（砖墙/木箱/板条箱/油桶）
## 对应原项目 window.AT.Obstacle：受击闪光（H5 flashElement）+ 被毁爆炸特效/音效

class_name ATObstacle

var health: float = 30.0
var max_health: float = 30.0
var destructible: bool = true
var tile_type: int = Constants.Tile.EMPTY
var conducts_current: bool = false  # H5 conductsCurrent：crate/木箱/砖默认绝缘；油桶(barrel)导电=true
## 关卡引用（由 Level._spawn_object_at 注入；血量按关卡序号缩放，H5 this.level.index/number）
var level: Node = null

# —— 火焰点燃（H5：只有木板与油桶会着火；crate/砖/门/秘密墙不燃）——
## 被点燃时每物理帧的灼烧伤害（H5：油桶 new Fire(this, 1)）
@export var burn_damage_flat: float = 0.0
## 按"本次直击伤害"的比例点燃（H5：木板 new Fire(this, .25 * damage)）
@export var burn_damage_ratio: float = 0.0
## 是否把火蔓延给相邻木板（H5：木板会连锁烧穿木墙）
@export var spreads_fire: bool = false

signal destroyed(obstacle)

# 不同类型被毁时的音效（barrel 自带爆炸覆写）
const DEATH_SFX: Dictionary = {
	Constants.Tile.BRICKS_1: "bricks.mp3",
	Constants.Tile.BRICKS_2: "bricks.mp3",
	Constants.Tile.CRATE: "crate_kill.mp3",
}

var _flash_tween: Tween = null
## 头顶血条（scenes/objects/lifebar.tscn，各障碍物场景里实例化；H5 Obstacle 构造函数同款）
@onready var _lifebar: ATLifebar = get_node_or_null("Lifebar") as ATLifebar


func _ready() -> void:
	collision_layer = 1 << (Constants.Layer.OBSTACLE - 1)
	collision_mask = Constants.layer_mask([Constants.Layer.PLAYER, Constants.Layer.ENEMY, Constants.Layer.PROJECTILE])
	_apply_health_for_type()


## 血量按关卡序号缩放（H5 各障碍物构造函数）：
##   油桶 25+4×index、木箱 20+8×index、木板/门/砖墙 25+10×number、厚砖墙 75+30×number
## （index 从 0 开始，number = index + 1；本项目瓦片类型由 Level 写入 tile_type）
func _apply_health_for_type() -> void:
	var index := _level_index()
	match tile_type:
		Constants.Tile.BARREL:
			health = 25.0 + 4.0 * index
		Constants.Tile.CRATE:
			health = 20.0 + 8.0 * index
		Constants.Tile.WOOD, Constants.Tile.GATE, Constants.Tile.BRICKS_1:
			health = 25.0 + 10.0 * (index + 1)
		Constants.Tile.BRICKS_2:
			health = 75.0 + 30.0 * (index + 1)
		_:
			health = max_health
	max_health = health


func _level_index() -> int:
	if level != null and is_instance_valid(level) and "level_index" in level:
		return int(level.get("level_index"))
	return 0


func on_bullet_hit(damage: float, _src: Node, _bullet: Node) -> void:
	if not destructible:
		return
	_try_ignite(damage, _src)
	health -= damage
	_flash_hit()
	# H5 Obstacle.onBulletHit：命中就显示血条（0.833s 无受击自动隐藏）
	if _lifebar != null:
		_lifebar.show_bar()
	if health <= 0:
		_die()


## 被火焰命中 → 点燃（直击伤害照常结算，点燃额外按帧掉血；不燃的物体 burn 值为 0）
func _try_ignite(damage: float, src: Node) -> void:
	var burn := burn_damage_flat + burn_damage_ratio * damage
	if burn <= 0.0:
		return
	ATBurning.attach_from(self, burn, src, -1.0, spreads_fire)


## 受击闪光：子 Sprite 泛白后 0.12s 淡回（等价 H5 flashElement 的 tint 闪烁）
func _flash_hit() -> void:
	for child in get_children():
		if child is ATBurning:
			continue   # 火焰贴图不参与受击泛白（点燃每帧都调用本函数）
		if child is Sprite2D or child is AnimatedSprite2D:
			var sprite: CanvasItem = child
			if _flash_tween != null and _flash_tween.is_valid():
				_flash_tween.kill()
			sprite.modulate = Color(3, 3, 3, 1)
			_flash_tween = create_tween()
			_flash_tween.tween_property(sprite, "modulate", Color.WHITE, 0.12)


func _die() -> void:
	destroyed.emit(self)
	var sfx: String = DEATH_SFX.get(tile_type, "")
	if sfx != "":
		Audio.play_sfx(sfx)
	Fx.smoke(global_position, get_parent())
	queue_free()
