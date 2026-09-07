extends Node2D
## FxBurst —— 一次性粒子特效（spark/puff/explosion 共用），播放完自动销毁

const AUTO_FREE_AFTER := 1.2


func _ready() -> void:
	var child := get_child(0) if get_child_count() > 0 else null
	var life := AUTO_FREE_AFTER
	if child != null and "lifetime" in child and child is CPUParticles2D:
		life = maxf(AUTO_FREE_AFTER, (child as CPUParticles2D).lifetime + 0.2)
		child.emitting=true
	await get_tree().create_timer(life).timeout
	queue_free()
