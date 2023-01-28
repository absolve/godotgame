extends "res://scripts/object.gd"

var preStatus
var status=constants.hammerThrow
var dir=constants.left
var xSpeed=10
var spriteIndex=0

onready var ani=$ani

func _ready():
	type=constants.hammer
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	gravity=constants.hammerGravity
	maxYVel=constants.enemyMaxVel
	pass


func _update(delta):
	if status==constants.hammerThrow:
		if dir==constants.left:
			xVel=-xSpeed
		elif dir==constants.right:
			xVel=xSpeed
		
		
		pass
	pass

func pause():
	preStatus=status
	status=constants.stop
#	active=false
	ani.stop()

func resume():
	status=preStatus
	ani.play()
#	if status!=constants.dead&&status!=constants.deadJump:
#		active=true	
