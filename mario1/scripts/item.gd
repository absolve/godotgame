extends "res://scripts/object.gd"

var status=constants.growing
var dir=constants.right
var oldPos=0
const speed=100  #速度
const jumpSpeed=460
var spriteIndex=0 #0 1 是蘑菇
#var content=constants.mushroom  #内容
onready var ani=$ani
var isOnFloor=true #是否在地面上


func _ready():
#	type=constants.mushroom
#	debug=true
	rect=Rect2(Vector2(-13,-15),Vector2(26,30))	
	gravity=constants.enemyGravity
	oldPos=position.y
	yVel=-50
	if dir==constants.left:
		xVel=-speed
	else:
		xVel=speed
#	xVel=-speed	
#	ani.playing=true
	if type==constants.mushroom:
		ani.play("mush_room")
	elif type==	constants.star:
		ani.play("star")
	elif type==constants.mushroom1up:
		ani.play("1up")
	elif type==constants.fireflower:
		ani.play("fire_flower")	
	pass

func _update(delta):
	if status==constants.growing:
		growing(delta)
		pass
	elif status==constants.moving:	
		moving(delta)
	elif status==constants.stop:
		stop(delta)	
	elif status==constants.jumping:
		jumping(delta)
	pass

func growing(delta):
	if oldPos-position.y>=rect.size.y:
		status=constants.moving
		if type==constants.fireflower:
			status=constants.stop
		elif type==constants.star:
			yVel=-jumpSpeed
			status=constants.jumping	
	else:	
		position.y+=yVel*delta	
	pass
	
func moving(delta):
	yVel+=gravity*delta

	position.x+=xVel*delta
	if !isOnFloor:	
		position.y+=yVel*delta		
	pass

func stop(delta):
	
	pass

func jumping(delta):
	yVel+=gravity*delta
	position.x+=xVel*delta
	position.y+=yVel*delta	
	pass

func turnLeft():
	xVel=-speed
	pass

func turnRight():
	xVel=speed	

func pause():
	ani.stop()

func resume():
	ani.play()	
	
