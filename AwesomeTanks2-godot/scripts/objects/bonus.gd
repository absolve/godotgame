extends Area2D
## Bonus — 拾取物（金币/弹药/医疗包/冻结/炸弹）
## 对应原项目 bonuses：coin, ammo_*, health, freeze, bomb

class_name ATBonus

enum Kind { COIN, AMMO, HEALTH, FREEZE, BOMB }

@export var kind: Kind = Kind.COIN
@export var weapon_key: String = ""    # 弹药类用：shotgun/rockets/...
@export var amount: int = 1

func _ready() -> void:
	collision_layer = 1 << (ATConst.Layer.OBSTACLE - 1)
	collision_mask = ATConst.layer_mask([ATConst.Layer.PLAYER])
	body_entered.connect(_pick_up)

func _pick_up(body: Node) -> void:
	if not body.has_method("is_player") and not body.name == "player":
		return
	match kind:
		Kind.COIN:
			Game.add_money(amount)
			Audio.play_sfx("coin.mp3")
		Kind.AMMO:
			var cur := Game.get_weapon_ammo(weapon_key)
			Game.set_weapon_ammo(weapon_key, cur + amount)
			Audio.play_sfx("ammo.mp3")
		Kind.HEALTH:
			if body.has_method("heal"):
				body.heal(amount)
			Audio.play_sfx("health.mp3")
		Kind.FREEZE:
			# 冻结所有敌人
			Audio.play_sfx("freeze.mp3")
		Kind.BOMB:
			# 清屏炸弹
			Audio.play_sfx("bomb.mp3")
	queue_free()
