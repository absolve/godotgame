extends "res://scripts/object.gd"

var spriteIndex=0
onready var ani=$ani

func _ready():
	type=constants.axe
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	ani.play("default")
	pass
