extends "res://scripts/object.gd"

var spriteIndex=0
onready var ani=$ani

func _ready():
	type=constants.brick
	debug=true
	rect=Rect2(Vector2(-15,-15),Vector2(30,30))
	if spriteIndex >=0&&spriteIndex<=13:
		ani.play(str(spriteIndex))
	else:
		ani.play("0")	
	pass 

func _update(delta):
	pass

