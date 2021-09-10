extends "res://scripts/object.gd"

var status=constants.resting
var oldPos=0
var content="coin"
onready var ani=$ani

func _ready():
	gravity=constants.boxGravity
	type=constants.box
	debug=true
	self.rect=Rect2(Vector2(-16,-16),Vector2(32,32))	
	oldPos=position.y
	ani.playing=true
	pass

func _update(delta):
	if status==constants.resting:
		resting(delta)
	elif status==constants.bumped:
		bumped(delta)
	elif status==constants.opened:
		opened(delta)
	pass

func resting(delta):
	pass
	
func bumped(delta):
	yVel+=gravity*delta
	
	if position.y>oldPos:
		position.y=oldPos
		status=constants.opened
		ani.play("opened")
	else:
		position.y+=yVel*delta		
	pass

func opened(delta):
	pass
	
func startBumped():
	yVel=-200
	status=constants.bumped
	pass		
