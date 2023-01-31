extends "res://scripts/enemy.gd"

onready var ani=$ani
var preStatus
var xSpeed=70
var timer=0
var throwDelay=120
var prepareDelay=30
var startX=0 #一开始出现的位置
var acceleration=90
var moveLeft=true

func _ready():
	mask=[constants.fireball,constants.box,constants.brick
		,constants.platform,constants.pipe,constants.koopa,constants.goomba,
		constants.beetle]
	type=constants.hammerBro
	rect=Rect2(Vector2(-16,-25),Vector2(32,50))
	ani.position.y-=8
	gravity=constants.hammerBroGravity
	maxYVel=constants.enemyMaxVel
	status=constants.hammerBroIdle
	startX=position.x
	debug=true
	if dir==constants.right:
		xVel=xSpeed
	else:
		xVel=-xSpeed	
	pass

func _update(delta):
	if status==constants.hammerBroIdle:
		timer+=1
		if timer>throwDelay:
			timer=0
		
		if timer<prepareDelay:
			animation('idle')
		else:
			animation('walk')
		
		if xVel>0:
			if xVel>xSpeed:
				moveLeft=true
			if !moveLeft:
				xVel+=acceleration*delta
			else:
				xVel+=-acceleration*delta	
		else:
			if xVel<-xSpeed:
				moveLeft=false
			if moveLeft:
				xVel-=acceleration*delta	
			else:
				xVel+=acceleration*delta
#		if xVel<-xSpeed:
#			xVel+=acceleration*delta
#		elif xVel>xSpeed:
#			xVel+=-acceleration*delta
#		else:
#			if xVel>0:
#				xVel+=acceleration*delta
#			else:
#				xVel+=-acceleration*delta	
#		if position.x<startX-32*2:
#			xVel=xSpeed
#		elif position.x>startX+32*2:
#			xVel=-xSpeed		
	
	pass


func throwHammer():
	
	pass


func pause():
	preStatus=status
	status=constants.stop
	active=false
	ani.stop()

func resume():
	status=preStatus
	ani.play()
	if !_dead:
		active=true

func animation(type):
	if type=='walk':
		if spriteIndex==0:
			ani.play("walk_0")
		elif spriteIndex==1:
			ani.play("walk_1")
	elif type=='idle':
		if spriteIndex==0:
			ani.play("idle_0")
		elif spriteIndex==1:
			ani.play("idle_1")	
			
	if dir==constants.left:
		ani.flip_h=false
	else:
		ani.flip_h=true	
	pass


func rightCollide(obj):
	
	pass
	
func floorCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe:
		
		return true
	pass	
