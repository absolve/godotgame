extends StaticBody2D
## Obstacle — 可破坏障碍物基类（砖墙/木箱/板条箱/油桶）
## 对应原项目 window.AT.Obstacle：受击闪光（H5 flashElement）+ 被毁爆炸特效/音效

class_name ATObstacle

var health: float = 30.0
var max_health: float = 30.0
var destructible: bool = true
var tile_type: int = Constants.Tile.EMPTY
var conducts_current: bool = false  # H5 conductsCurrent：crate/木箱/砖默认绝缘；油桶(barrel)导电=true

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


func _ready() -> void:
	collision_layer = 1 << (Constants.Layer.OBSTACLE - 1)
	collision_mask = Constants.layer_mask([Constants.Layer.PLAYER, Constants.Layer.ENEMY, Constants.Layer.PROJECTILE])


func on_bullet_hit(damage: float, _src: Node, _bullet: Node) -> void:
	if not destructible:
		return
	_try_ignite(damage, _src)
	health -= damage
	_flash_hit()
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
	Fx.explosion(global_position, get_parent())
	queue_free()
