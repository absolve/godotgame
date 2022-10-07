extends "res://scripts/object.gd"

onready var ani=$ani

func _ready():
	randomize()
	active=false
	position.x=position.x-50+randi()%90
	position.y=200-randi()%50
	ani.play("boom")
	yield(ani,"animation_finished")
	queue_free()
	pass
