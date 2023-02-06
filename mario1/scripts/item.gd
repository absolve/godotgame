extends "res://scripts/object.gd"

var preStatus
var status=constants.growing
var dir=constants.right
var oldPos=0
const speed=110  #速度
const jumpSpeed=300
var spriteIndex=0 #0 1 是蘑菇
#var content=constants.mushroom  #内容
onready var ani=$ani
#var isOnFloor=true #是否在地面上


func _ready():
#	type=constants.mushroom
#	debug=true
	mask=[constants.box,constants.brick,constants.platform,constants.goomba,
		constants.koopa,constants.pipe]
	maxYVel=constants.marioMaxYVel 
	active=false
	rect=Rect2(Vector2(-13,-15),Vector2(26,30))	
#	gravity=constants.enemyGravity
	oldPos=position.y
	yVel=-40
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
		if spriteIndex==1:
			ani.play("1up_1")
		else:	
			ani.play("1up")
	elif type==constants.fireflower:
		ani.play("fire_flower")	

func _update(delta):
	if status==constants.growing:
		growing(delta)
	elif status==constants.moving:	
		moving(delta)
	elif status==constants.stop:
#		stop(delta)	
		pass
	elif status==constants.jumping:
		jumping(delta)
	pass

func growing(delta):
	if oldPos-position.y>rect.size.y:
		gravity=constants.enemyGravity
		active=true
		if type==constants.fireflower:
			status=constants.stop
#			active=false
			gravity=0
			xVel=0
			yVel=0
		elif type==constants.star:
			yVel=-jumpSpeed
			status=constants.jumping	
		if type!=constants.fireflower:
			status=constants.moving	
#		if dir==constants.left:
#			xVel=-speed
#		else:
#			xVel=speed
	else:	
		position.y+=yVel*delta	
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

#func stop(delta):
#	pass

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
	preStatus=status
	status=constants.stop
	active=false
	ani.stop()

func resume():
	status=preStatus
	if status!=constants.growing:
		active=true
	ani.play()	
	
func rightCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe:
		dir=constants.left
		return true
	pass
	
func leftCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe:
		dir=constants.right
		return true
	pass
	
func floorCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe:
		if obj.type==constants.box&&!obj._visible:
			return false
		if type==constants.star:
			yVel=-jumpSpeed
		if type!=constants.fireflower &&obj.type==constants.box&& obj.status==constants.bumped:
			yVel=-jumpSpeed
			if position.x<obj.position.x && dir==constants.right:
				dir=constants.left
			elif position.x>=obj.position.x && dir==constants.left:
				dir=constants.right
		return true
	pass	

