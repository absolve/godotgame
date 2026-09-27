extends Node2D

const AUTO_FREE_AFTER := 1.2
@onready var particles=$Particles

func _ready() -> void:
	z_index=10
	var life := AUTO_FREE_AFTER
	if "lifetime" in particles and particles is CPUParticles2D:
		life = maxf(AUTO_FREE_AFTER, particles.lifetime + 0.2)
		particles.emitting=true
	await get_tree().create_timer(life).timeout
	queue_free()
