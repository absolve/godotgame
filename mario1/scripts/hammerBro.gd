extends "res://scripts/enemy.gd"

onready var ani=$ani
var preStatus
var xSpeed=70
var ySpeed=450
var timer=0
var throwDelay=120
var prepareDelay=30
var startX=0 #一开始出现的位置
var acceleration=90
var moveLeft=true
var jumpTimer=0
var jumpDelay=120
var jumpDir="" #跳跃的方向
var jumpStartY=0 #开始跳跃时的位置

var hammer=preload("res://scenes/hammer.tscn")

func _ready():
	randomize()
	mask=[constants.fireball,constants.box,constants.brick
		,constants.platform,constants.pipe,constants.koopa,constants.goomba,
		constants.beetle]
	type=constants.hammerBro
	rect=Rect2(Vector2(-14,-25),Vector2(28,50))
	ani.position.y-=10
	gravity=constants.hammerBroGravity
	maxYVel=constants.enemyMaxVel
	status=constants.hammerBroIdle
	startX=position.x
#	debug=true
	if dir==constants.right:
		xVel=xSpeed
	else:
		xVel=-xSpeed	
	throwDelay=30+randi()%100
	

func _update(delta):
	if status==constants.hammerBroIdle:
		timer+=1
		if timer>throwDelay:
			timer=0
			throwDelay=30+randi()%90
			throwHammer()
			
		if timer<prepareDelay:
			animation('idle')
		else:
			animation('walk')
		
		jumpTimer+=1
		if jumpTimer>jumpDelay: #在屏幕中间随机向上获向下
			jumpTimer=0
			jumpDelay=100+randi()%30
			if position.y<=32*3:
				jumpDir=constants.down
				jumpStartY=position.y
			elif position.y>=32*10:
				jumpDir=constants.up
			else:
				if randi()%5>=2:
					jumpDir=constants.down	
					jumpStartY=position.y
				else:
					jumpDir=constants.up
			
			if jumpDir==constants.up:
				yVel=-ySpeed
			elif jumpDir==constants.down:
				yVel=ySpeed/2
				
		
		if jumpDir==constants.up:
			if yVel>0:
				jumpDir=""
		elif jumpDir==constants.down:		
			if abs(jumpStartY-position.y)>rect.size.y+32:
				jumpDir=""
				
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
		if Game.getMario().size()>0:
			var m= Game.getMario()[0]
			if is_instance_valid(m)&& m.status!=constants.deadJump:
				if m.position.x>position.x:
					dir=constants.right
					ani.flip_h=true
				else:
					dir=constants.left
					ani.flip_h=false	
	elif status==constants.deadJump:
		yVel+=gravity*delta	
		position.y+=yVel*delta	


func startDeathJump(_dir=constants.left):
	dir=_dir
	ani.position.y=0
	.startDeathJump()
	animation('idle')
	ani.playing=false
	ani.flip_v=true
	ani.frame=0
	_dead=true
	active=false
	

func throwHammer():
	var temp=hammer.instance()
	temp.position=position
	temp.dir=dir
	temp.spriteIndex=spriteIndex
	
	Game.addObj(temp)
	

func jumpedOn():
	startDeathJump()

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


func rightCollide(obj):
#	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe:
#		if jumpDir!='':
#			return false
#		else:
#			return true	
	return false	
	
func leftCollide(obj):
#	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe:
#		if jumpDir!='':
#			return false
#		else:
#			return true		
	return false	
	
func floorCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe:
		if obj.type==constants.box&&obj.status==constants.bumped:
			Game.addScore(position,200)
			if position.x>=obj.position.x:
				startDeathJump(constants.right)
			else:
				startDeathJump()
		if jumpDir==constants.down:
			return false
		return true
	

func ceilcollide(obj):#上方的判断
	if obj.type==constants.goomba||obj.type==constants.koopa||obj.type==constants.beetle:
		if jumpDir==constants.up:
			return false
		return true	
			
