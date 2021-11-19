extends "res://scripts/object.gd"

onready var ani=$ani
var playerId=0
var dir=constants.right
var rotate
var status=constants.fly

func _ready():
	debug=true
	type=constants.fireball
	rect=Rect2(Vector2(-4,-4),Vector2(8,8))
	gravity=constants.marioGravity
	if dir==constants.left:
		xVel=-100
	else:
		xVel=100
		
		
	pass

func _update(delta):
	if status==constants.fly:
		pass
	elif status==constants.boom:	
		pass
	pass

func boom():
	ani.play()
	status=constants.boom
