extends "res://scripts/object.gd"

const speed=40
var status=constants.walking
var dir=constants.left
onready var ani=$ani

func _ready():
	debug=true
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	gravity=constants.marioGravity
	ani.playing=true
	pass

func _update(delta):
	if status==constants.walking:
		walking(delta)
	elif status==constants.dead:
		dead(delta)	
	pass
	
func walking(delta):
	yVel+=gravity*delta
	if dir==constants.left:
		xVel=-speed
	else:
		xVel=speed	
	position.x+=xVel*delta
	position.y+=yVel*delta
	
	
	pass
	
func dead(delta):
	pass
