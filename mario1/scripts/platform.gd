extends 'res://scripts/object.gd'

var status=constants.moveDown
#onready var ani=$ani
onready var list=$len
var spriteIndex=0
var speed=50  #速度
var lens=5
var platformImg=preload("res://sprites/platform.png")
var winHeight
var platformType=""
#var isOnFloor=false #是否在地面上
var dir=constants.up

func _ready():
	mask=[constants.mario,constants.mushroom,constants.star,constants.mushroom1up]
	active=false
	winHeight=ProjectSettings.get_setting("display/window/size/height")
	type=constants.platform
	gravity=0
	maxYVel=constants.marioMaxYVel
	
#	debug=true
	if status==constants.moveDown:
		yVel=speed
	elif status==constants.moveUp:	
		yVel=-speed
	elif status==constants.upAndDown||status==constants.leftAndRight:
		pass
	
	
	rect=Rect2(Vector2(-32*lens/2,-8),Vector2(32*lens,16))
#	rect=Rect2(-32*lens/2,0,32*lens,16)	
	for i in range(lens):
		var temp=Sprite.new()
		temp.texture=platformImg
		temp.centered=false
		temp.position=Vector2(-32*lens/2+i*32,-8)
		list.add_child(temp)
		
#	print(lens)	
#	print(getRight())	
#	print(getRect().position,getRect().size)
	pass

func _update(delta):
	if status==constants.moveDown || status==constants.moveUp:
		for i in Game.getObj().get_children():
			if i.type==constants.mario&&i.status!=constants.jump:
				if i.getRight()>position.x-rect.size.x/2&&i.getLeft()<position.x+rect.size.x/2:
#					print(i.getRight(),' ',getRight())
					if i.getBottom()>position.y-rect.size.y/2-0.1&&\
						i.getBottom()<position.y-rect.size.y/2+0.1:
						i.position.y=position.y-i.getSizeY()/2+yVel*delta
						
		position.y+=yVel*delta	
		if position.y>winHeight&&status==constants.moveDown:
			position.y=-8
		elif status==constants.moveUp&&position.y<0:
			position.y=winHeight+8
	elif status==constants.upAndDown: 
		if dir==constants.up:
			yVel-=0.6
			if yVel<-speed:
				dir=constants.down
		elif dir==constants.down:	
			yVel+=0.6
			if yVel>speed:
				dir=constants.up
		for i in Game.getObj().get_children():
			if i.type==constants.mario&&i.status!=constants.jump:
				if i.getRight()>position.x-rect.size.x/2&&i.getLeft()<position.x+rect.size.x/2:
					if i.getBottom()>position.y-rect.size.y/2-0.1&&\
						i.getBottom()<position.y-rect.size.y/2+0.1:
						i.position.y=position.y-i.getSizeY()/2+yVel*delta
		position.y+=yVel*delta			
		pass
	elif status==constants.leftAndRight:
		if dir==constants.left:
			xVel-=1
			if xVel<-speed:
				dir=constants.right
		elif dir==constants.right:
			xVel+=1
			if xVel>speed:
				dir=constants.left
		for i in Game.getObj().get_children():
			if i.type==constants.mario&&i.status!=constants.jump:
				if i.getRight()>position.x-rect.size.x/2&&i.getLeft()<position.x+rect.size.x/2:
					if i.getBottom()>position.y-rect.size.y/2-0.1&&\
						i.getBottom()<position.y-rect.size.y/2+0.1:
						i.position.y=position.y-i.getSizeY()/2+yVel*delta
#					print(i.getBottom(),getTop())
					if i.xVel==0 && i.getBottom()==position.y:
						i.position.x+=xVel*delta
		
		position.x+=xVel*delta
	pass



func rightCollide(obj):
	return false
	
func leftCollide(obj):
	return false

func floorCollide(obj):
	
	return false	

func ceilcollide(obj):
	return false		
