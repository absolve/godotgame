extends ATObstacle
## Bricks — 砖墙（BRICKS_1 / BRICKS_2 两种）
## 贴图在 _ready 中根据 tile_type 随机选 bricks_0 或 bricks_1

const TEX_BRICKS: Array = [
	preload("res://sprites/game/bricks_0.png.tres"),
	preload("res://sprites/game/bricks_1.png.tres"),
]

func _ready() -> void:
	super._ready()
	var sprite := $BodySprite as Sprite2D
	sprite.texture = TEX_BRICKS[randi() % TEX_BRICKS.size()]
	# BRICKS_1 比 BRICKS_2 稍硬一些
	if tile_type == Constants.Tile.BRICKS_1:
		health = 35.0
		max_health = 35.0
	else:
		health = 25.0
		max_health = 25.0


## 砖墙不燃，且被火焰打只吃 1 点直击伤害（H5 L21122：e instanceof Flamethrower && (t = 1)）
## —— 火焰对砖墙几乎无效，它的输出在"烧木板 / 烧单位"上
func on_bullet_hit(damage: float, src: Node, bullet: Node) -> void:
	if src != null and is_instance_valid(src) and "ignites" in src and bool(src.get("ignites")):
		damage = 1.0
	super.on_bullet_hit(damage, src, bullet)
