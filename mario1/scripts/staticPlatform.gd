extends "res://scripts/object.gd"

onready var list=$len
var status=constants.platformIdle
var lens=3
var acceleration=100
var platformImg=preload("res://sprites/platform.png")
var platformImg1=preload("res://sprites/platformbonus.png")
var spriteIndex=0  #1的话就是
var objCount=0	#平台上的个数
var linkPlatform  #连接平台
var xSpeed=80
var startMove=false
var side=constants.left


func _ready():
	active=false
	type=constants.staticPlatform
	rect=Rect2(Vector2(-32*lens/2,-8),Vector2(32*lens,16))
	for i in range(lens):
		var temp=Sprite.new()
		if spriteIndex==0:
			temp.texture=platformImg
		elif spriteIndex==1:
			temp.texture=platformImg1	
		temp.centered=false
		temp.position=Vector2(-32*lens/2+i*32,-8)
		list.add_child(temp)
	pass


func _update(delta):
	if status==constants.platformIdle:
		objCount=0
		for i in Game.getObj().get_children():
			if i.type==constants.mario&&i.status!=constants.jump:
				if i.getRight()>position.x-rect.size.x/2&&i.getLeft()<position.x+rect.size.x/2:
					if i.getBottom()>position.y-rect.size.y/2-0.1&&\
						i.getBottom()<position.y-rect.size.y/2+0.1:
						i.position.y=position.y-i.getSizeY()/2+yVel*delta
						objCount+=1
						
		if linkPlatform!=null:
			if side==constants.left:
				linkPlatform.leftCount=objCount	
			elif side==constants.right:
				linkPlatform.rightCount=objCount	
		position.y+=yVel*delta
	elif status==constants.platformFall:
		yVel+=acceleration*delta
		position.y+=yVel*delta
		pass
	elif status==constants.justRight:
		for i in Game.getObj().get_children():
			if i.type==constants.mario&&i.status!=constants.jump:
				if i.getRight()>position.x-rect.size.x/2&&i.getLeft()<position.x+rect.size.x/2:
					if i.getBottom()>position.y-rect.size.y/2-0.1&&\
						i.getBottom()<position.y-rect.size.y/2+0.1:
						i.position.y=position.y-i.getSizeY()/2+yVel*delta
						if !startMove:
							startMove=true
							xVel=xSpeed
					if i.xVel==0 && i.getBottom()==position.y:
						i.position.x+=xVel*delta
						
		position.x+=xVel*delta	

