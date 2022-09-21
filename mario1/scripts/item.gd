extends "res://scripts/object.gd"

var status=constants.growing
var dir=constants.right
var oldPos=0
const speed=100  #速度
const jumpSpeed=460
var spriteIndex=0 #0 1 是蘑菇
#var content=constants.mushroom  #内容
onready var ani=$ani
#var isOnFloor=true #是否在地面上


func _ready():
#	type=constants.mushroom
#	debug=true
	mask=[constants.box,constants.brick,constants.platform,constants.goomba,constants.koopa,constants.mario]
	maxYVel=constants.marioMaxYVel 
	active=false
	rect=Rect2(Vector2(-13,-15),Vector2(26,30))	
#	gravity=constants.enemyGravity
	oldPos=position.y
	yVel=-50
#	if dir==constants.left:
#		xVel=-speed
#	else:
#		xVel=speed

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
	elif status==constants.moving:	
		moving(delta)
	elif status==constants.stop:
		stop(delta)	
	elif status==constants.jumping:
		jumping(delta)
	pass

func growing(delta):
	if oldPos-position.y>=rect.size.y:
		gravity=constants.enemyGravity
		active=true
		if type==constants.fireflower:
			status=constants.stop
			active=false
			gravity=0
		elif type==constants.star:
			yVel=-jumpSpeed
			status=constants.jumping	
		status=constants.moving	
#		if dir==constants.left:
#			xVel=-speed
#		else:
#			xVel=speed
#	else:	
#		position.y+=yVel*delta	
	pass
	
func moving(delta):
#	yVel+=gravity*delta

#	position.x+=xVel*delta
#	if !isOnFloor:	
#		position.y+=yVel*delta		
	if dir==constants.left:
		xVel=-speed
	else:
		xVel=speed
		
	pass

func startJump():
	yVel=-jumpSpeed
	pass

func stop(delta):
	
	pass

func jumping(delta):
	if dir==constants.left:
		xVel=-speed
	else:
		xVel=speed
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
	
func rightCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box:
		dir=constants.left
		return true
	pass
	
func leftCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box:
		dir=constants.right
		return true
	pass
	
func floorCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box:
		if type==constants.star:
			yVel=-jumpSpeed
		return true
	pass	

