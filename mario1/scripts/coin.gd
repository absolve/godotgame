extends "res://scripts/object.gd"

var status=constants.spin
#var isOnFloor=false
onready var ani=$ani

func _ready():
#	maxYVel=constants.marioMaxYVel
	gravity=constants.boxGravity
	debug=true
	yVel=-600
	active=false
	ani.play("default")
	pass

func _update(delta):
	if status==constants.spin:
		spinning(delta)
		pass
		
func spinning(delta):
	yVel+=gravity*delta
	position.y+=yVel*delta
	if yVel>400:
#		Game.addScore(position,200)
		queue_free()
	pass		
