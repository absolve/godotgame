extends "res://scripts/object.gd"

var spriteIndex=0
onready var ani=$ani

func _ready():
	active=false
	debug=true
	rect=Rect2(Vector2(-16,-31),Vector2(32,62))
	type=constants.jumpingBoard
	if spriteIndex==0:
		ani.play("0")
	elif spriteIndex==1:
		ani.play("1")	
	else:
		ani.play("0")	
	ani.stop()
	pass
