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
	debug=true
	if dir==constants.right:
		xVel=xSpeed
	else:
		xVel=-xSpeed	
	throwDelay=30+randi()%100
	
	pass

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
			if m.status!=constants.deadJump:
				if m.position.x>position.x:
					dir=constants.right
					ani.flip_h=true
				else:
					dir=constants.left
					ani.flip_h=false	
	
	pass


func throwHammer():
	var temp=hammer.instance()
	temp.position=position
	temp.dir=dir
	temp.spriteIndex=spriteIndex
	
	Game.addObj(temp)
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
