extends "res://scripts/object.gd"

var spriteIndex=0
onready var ani=$ani

func _ready():
	type=constants.bg
	active=false
	debug=false
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	if spriteIndex>=0&&spriteIndex<=76:
		ani.play(str(spriteIndex))

	else:
		ani.play("0")	
	pass


