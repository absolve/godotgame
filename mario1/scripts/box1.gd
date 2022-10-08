extends "res://scripts/object.gd"
"""
箱子会出现各种道具 如果是花会判断mario的大小变成蘑菇
"""

var status=constants.resting
var oldPos=0
var content=constants.empty  #里面的内容
#var mainScene
var spriteIndex=0  #打开后的颜色 0 是普通颜色 1 蓝色 2灰色  3金币盒子
var _visible=true #是否可见
var coin6Num=1  #多个硬币的数量
#var destroy=false #没有东西的时候是否被摧毁
#var maxXVel=0
#var maxYVel=0
#var isOnFloor=false
var needDestroy=false
var coinsNum=0 #硬币数量

onready var ani=$ani
var brick=preload("res://scenes/brickPiece.tscn")
var item=preload("res://scenes/item.tscn")
var coin=preload("res://scenes/coin.tscn")

func _ready():
	maxYVel=constants.marioMaxYVel
	active=false
#	gravity=constants.boxGravity
	type=constants.box
#	debug=true
#	collisionShow=true
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))	
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
	if _visible==false:
		visible=false

	print('coins12'.split('coins',false))

	if content.begins_with('coins'):
		var temp = content.split('coins',false)
		if temp.size()>0&&temp[0].is_valid_integer():
			coinsNum=temp[0].to_int()
		else:
			coinsNum=1
	print(coinsNum)

func _update(delta):
	if status==constants.resting:
#		resting(delta)
		pass
	elif status==constants.bumped:
		bumped(delta)
	elif status==constants.opened:
#		opened(delta)
		pass
	pass

func resting(delta):
	pass
	
func bumped(delta):
	yVel+=constants.boxGravity*delta

	if position.y>oldPos:
		position.y=oldPos
		yVel=0
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
				if content==constants.fireflower:
					if Game.getMario().size()>0:
						if !Game.getMario()[0].big:
							temp.type=constants.mushroom
				Game.addObj(temp)
#				SoundsUtil.playItem()
			elif content.begins_with('coins'):
				if coinsNum>0:
					status=constants.resting	
					return	
			elif content==constants.empty || content=='':
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
		if needDestroy:
			if abs(oldPos-position.y)>3:
				destroy()
				add4Brick()
				SoundsUtil.playBrickBreak()
				status=constants.empty
		position.y+=yVel*delta		
	pass

func opened(delta):
	pass
	
func startBumped(isBig=false):
	print('startBumped')
	yVel=-200
	status=constants.bumped
	if !_visible:
		ani.play("opened")
		_visible=true
		visible=true
	if content==constants.coin:
		var temp=coin.instance()
		temp.position=position
		temp.position.y=position.y-getSizeY()/2
		Game.addObj(temp)
		Game.addCoin(self,1)
		Game.addScore(Vector2(position.x,position.y-getSizeY()/2),200)
		SoundsUtil.playCoin()
	elif content.begins_with('coins') && coinsNum>0:	
#		coin6Num+=1
		coinsNum-=1
		var temp=coin.instance()
		temp.position=position
		temp.position.y=position.y-getSizeY()/2
		Game.addObj(temp)
		Game.addCoin(self,1)
		Game.addScore(Vector2(position.x,position.y-getSizeY()/2),200)
		SoundsUtil.playCoin()
	elif content==constants.mushroom||content==constants.mushroom1up||\
			content==constants.star||content==constants.fireflower:	
			SoundsUtil.playItem()	
	elif content==constants.empty||content=='':
		if isBig && isDestructible():
			needDestroy=true
		elif isDestructible():
			SoundsUtil.playBrickHit()	
		pass
	pass		

#空的盒子
func isDestructible():
	if (content==constants.empty||content=='')&&spriteIndex in [0,1,2]:
		return true
	else:
		return false
	pass

func destroy():
	visible=false
	destroy=true
#	queue_free()

func add4Brick():
	var temp1 = brick.instance()
	temp1.position=Vector2(position.x-8,position.y-8)
	temp1.spriteIndex=spriteIndex
	temp1.yVel=-600
	Game.addObj(temp1)
	var temp2=brick.instance()
	temp2.position=Vector2(position.x-8,position.y+8)
	temp2.spriteIndex=spriteIndex
	temp2.yVel=-500
	Game.addObj(temp2)
	var temp3=brick.instance()
	temp3.position=Vector2(position.x+8,position.y-8)
	temp3.dir=constants.right
	temp3.spriteIndex=spriteIndex
	temp3.yVel=-600
	Game.addObj(temp3)
	var temp4=brick.instance()
	temp4.position=Vector2(position.x+8,position.y+8)
	temp4.dir=constants.right
	temp4.spriteIndex=spriteIndex
	temp4.yVel=-500
	Game.addObj(temp4)
