extends "res://scripts/object.gd"

var dir=constants.left
const speed=90
onready var ani=$ani
var spriteIndex=0
var rotate=0
var status=constants.empty

func _ready():
#	active=false
	maxYVel=constants.marioMaxYVel
	gravity=constants.enemyGravity
#	gravity=10
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
	if dir==constants.right:
		xVel=speed
	elif dir==constants.left:
		xVel=-speed
	pass

func _update(delta):
#	if dir==constants.right:
#		xVel=speed
#	elif dir==constants.left:
#		xVel=-speed
#	yVel+=gravity*delta
#	position.x+=xVel*delta
#	position.y+=yVel*delta	
	if status!=constants.stop:
		rotate+=20
		if rotate>360:
			rotate=0
		ani.rotation_degrees=rotate
	pass


func pause():
	status=constants.stop
	active=false


func resume():
	status=constants.empty
	active=true
