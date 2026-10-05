extends EnemyState
## Frozen —— 冰冻（对应 H5 冰冻道具：freezeEnemies → 各敌人 onFreeze）
##   行为：完全停止：不开火、不移动、炮塔不转；收到 unfreeze() 后回到 Idle。
## 视觉（冰壳贴图/解冻特效）后续再加。

func enter(msg: Dictionary = {}) -> void:
	fire(false)
	stopMoving()


func physicsUpdate(delta: float) -> void:
	# 冰冻期间什么都不做（保持静止）
	stopMoving()


func exit() -> void:
	pass
