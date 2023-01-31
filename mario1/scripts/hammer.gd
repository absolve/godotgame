extends "res://scripts/object.gd"

var preStatus
var status=constants.hammerThrow
var dir=constants.left
var xSpeed=110
var spriteIndex=0
var ySpend=340
var rotate
onready var ani=$ani

func _ready():
	type=constants.hammer
	rect=Rect2(Vector2(-8,-8),Vector2(16,16))
	gravity=constants.hammerGravity
	maxYVel=constants.enemyMaxVel
#	debug=true
	ani.position.y+=5
	yVel=-ySpend
	if dir==constants.right:
		ani.flip_h=true
	
	if spriteIndex==0:
		ani.play("0")
	elif spriteIndex==1:	
		ani.play("1")	
	pass


func _update(delta):
	if status==constants.hammerThrow:
		if dir==constants.left:
			xVel=-xSpeed
		elif dir==constants.right:
			xVel=xSpeed
		rotation_degrees+=25
		if rotation_degrees>360:
			rotation_degrees=0
		pass
	pass

func pause():
	preStatus=status
	status=constants.stop
	ani.stop()

func resume():
	status=preStatus
	ani.play()

 
