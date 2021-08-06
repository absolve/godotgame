extends Node2D


onready var mario=$mario1

func _ready():
	pass # Replace with function body.


func _process(delta):
	mario._update(delta)
	pass
