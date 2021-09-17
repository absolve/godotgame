extends "res://scripts/object.gd"

const speed=40
const slidingSpeed=80
var status=constants.walking
var dir=constants.left
onready var ani=$ani

func _ready():
	debug=true
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	gravity=constants.marioGravity
	pass

func _update(delta):
	if status==constants.walking:
		
		pass
	elif status==constants.sliding:
		
		pass
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

func shellSliding(delta):
	yVel+=gravity*delta
	if dir==constants.left:
		xVel=-slidingSpeed
	else:
		xVel=slidingSpeed	
	position.x+=xVel*delta
	position.y+=yVel*delta
	pass
