extends Node2D

onready var ani=$ani

func _ready():
	ani.play("default")
	yield(ani,"animation_finished")
	queue_free()
	pass
