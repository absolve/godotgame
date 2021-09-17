extends "res://scripts/object.gd"

var dir=constants.left
const speed=55
onready var ani=$ani

func _ready():
	gravity=constants.marioGravity
	type=constants.brickPiece
	debug=true
	if dir==constants.right:
		ani.flip_h=true
	
	pass

func _update(delta):
	if dir==constants.right:
		xVel=speed
	elif dir==constants.left:
		xVel=-speed
	yVel+=gravity*delta
	position.x+=xVel*delta
	position.y+=yVel*delta	
	pass


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass # Replace with function body.
