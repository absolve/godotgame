extends "res://scripts/object.gd"

var dir=constants.left
const speed=90
onready var ani=$ani
var spriteIndex=0
var rotate=0

func _ready():
	active=false
	maxYVel=constants.marioMaxYVel
	gravity=constants.enemyGravity
	type=constants.brickPiece
	debug=true
	if dir==constants.right:
		ani.flip_h=true
	if spriteIndex==0:
		ani.play('brick')
	elif spriteIndex==1:
		ani.play('brick_blue')	
	elif spriteIndex==2:
		ani.play('brick_grey')		
	
	pass

func _update(delta):
	if dir==constants.right:
		xVel=speed
	elif dir==constants.left:
		xVel=-speed
	yVel+=gravity*delta
	position.x+=xVel*delta
	position.y+=yVel*delta	
	rotate+=30
	if rotate>360:
		rotate=0
	rotation_degrees=deg2rad(rotate)
	pass


#func _on_VisibilityNotifier2D_screen_exited():
#	queue_free()
#	pass # Replace with function body.
