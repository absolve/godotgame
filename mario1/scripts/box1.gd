extends "res://scripts/object.gd"

var status=constants.resting
var oldPos=0
var content=constants.empty  #里面的内容
#var mainScene
var spriteIndex=0  #打开后的颜色 0 是普通颜色 1 蓝色 2灰色  3金币盒子
var _visible=true #是否可见
var coin6Num=1  #多个硬币的数量 最大6

onready var ani=$ani
var brick=preload("res://scenes/brickPiece.tscn")
var item=preload("res://scenes/item.tscn")
var coin=preload("res://scenes/coin.tscn")

func _ready():
	gravity=constants.boxGravity
	type=constants.box
	debug=true
	self.rect=Rect2(Vector2(-15,-15),Vector2(30,30))	
	oldPos=position.y
	ani.playing=true
	if spriteIndex==0:
		ani.play("box")
	elif spriteIndex==1:
		ani.play("box_blue")
	elif spriteIndex==2:
		ani.play("box_grey")
	elif spriteIndex==3:	
		ani.play("default")
	pass

func _update(delta):
	if status==constants.resting:
		resting(delta)
	elif status==constants.bumped:
		bumped(delta)
	elif status==constants.opened:
		opened(delta)
	pass

func resting(delta):
	pass
	
func bumped(delta):
	yVel+=gravity*delta

	if position.y>oldPos:
		position.y=oldPos
		if content==constants.empty&&spriteIndex==3: #变成打开状态
			status=constants.opened	
			ani.play("opened")	
		else:	
			print(content)
			if content==constants.mushroom||content==constants.mushroom1up||\
					content==constants.star||content==constants.fireflower:	
				var temp=item.instance()
				temp.position=position
				temp.type=content
				Game.addObj2Item(temp)
			elif content==constants.coins6:
				if coin6Num<6:
					status=constants.resting	
					return	
			if spriteIndex==0:
				ani.play("opened")
			elif spriteIndex==1:
				ani.play("opened_blue")
			elif spriteIndex==2:	
				ani.play("opened_grey")
			else:
				ani.play("opened")	
			status=constants.opened	
	else:
		position.y+=yVel*delta		
	pass

func opened(delta):
	
	pass
	
func startBumped():
	yVel=-280
	status=constants.bumped
	if content==constants.coin:
		var temp=coin.instance()
		temp.position=position
		temp.position.y=position.y-getSizeY()/2
		Game.addObj2Other(temp)
	elif content==constants.coins6 && coin6Num<6:	
		coin6Num+=1
		var temp=coin.instance()
		temp.position=position
		temp.position.y=position.y-getSizeY()/2
		Game.addObj2Other(temp)
	pass		

#空的盒子
func isDestructible():
	if content==constants.empty&&spriteIndex in [0,1,2]:
		return true
	else:
		return false
	pass

func destroy():
	queue_free()

func add4Brick():
	var temp1 = brick.instance()
	temp1.position=Vector2(position.x-8,position.y-8)
	temp1.spriteIndex=spriteIndex
	temp1.yVel=-400
	Game.addObj2Other(temp1)
	var temp2=brick.instance()
	temp2.position=Vector2(position.x-8,position.y+8)
	temp2.spriteIndex=spriteIndex
	temp2.yVel=-300
	Game.addObj2Other(temp2)
	var temp3=brick.instance()
	temp3.position=Vector2(position.x+8,position.y-8)
	temp3.dir=constants.right
	temp3.spriteIndex=spriteIndex
	temp3.yVel=-400
	Game.addObj2Other(temp3)
	var temp4=brick.instance()
	temp4.position=Vector2(position.x+8,position.y+8)
	temp4.dir=constants.right
	temp4.spriteIndex=spriteIndex
	temp4.yVel=-300
	Game.addObj2Other(temp4)
