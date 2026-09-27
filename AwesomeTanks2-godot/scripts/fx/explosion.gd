extends Node2D


const AUTO_FREE_AFTER := 1.2

@onready var smoke=$Smoke
@onready var ani=$ani


func _ready() -> void:
	z_index=10
	ani.play("default")
	var life := AUTO_FREE_AFTER
	if  "lifetime" in smoke and smoke is CPUParticles2D:
		life = maxf(AUTO_FREE_AFTER, smoke.lifetime + 0.2)
		smoke.emitting=true
	await get_tree().create_timer(life).timeout
	queue_free()
