extends "res://scripts/object.gd"

onready var list=$len
var status=constants.platformIdle
var lens=5
var acceleration=100
var platformImg=preload("res://sprites/platform.png")
var platformImg1=preload("res://sprites/platformbonus.png")
var spriteIndex=0
var objCount=0	#平台上的个数
var linkPlatform  #连接平台

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
		
		position.y+=xVel*delta
		pass
	elif status==constants.platformFall:
		pass	
	pass
