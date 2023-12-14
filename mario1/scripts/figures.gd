extends "res://scripts/object.gd"

var spriteIndex=0 #0公主 1蘑菇人
onready var ani=$ani

func _ready():
	type=constants.figures
	rect=Rect2(Vector2(-24,-16),Vector2(48,32))
#	if spriteIndex==0:
	ani.position.y-=11	
	ani.play(str(spriteIndex))
	pass
