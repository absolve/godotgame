extends 'res://scripts/object.gd'

var status=constants.moveDown
#onready var ani=$ani
onready var list=$len
var spriteIndex=0
var speed=10
var lens=2
var platformImg=preload("res://sprites/platform.png")
var winHeight
var platformType=""
#var isOnFloor=false #是否在地面上

func _ready():
	mask=[constants.mario,constants.mushroom,constants.star,constants.mushroom1up]
	active=false
	winHeight=ProjectSettings.get_setting("display/window/size/height")
	type=constants.platform
	debug=true
	if status==constants.moveDown:
		yVel=speed
	elif status==constants.moveUp:	
		yVel=-speed
	rect=Rect2(Vector2(-32*lens/2,-8),Vector2(32*lens,16))
#	rect=Rect2(-32*lens/2,0,32*lens,16)	
	for i in range(lens):
		var temp=Sprite.new()
		temp.texture=platformImg
		temp.centered=false
		temp.position=Vector2(i*32,0)
		list.add_child(temp)
		pass
	print(lens)	
	print(getRight())	
	print(getRect().position,getRect().size)
	pass

func _update(delta):
	if status==constants.moveDown || status==constants.moveUp:
		for i in Game.getObj().get_children():
			if i.type==constants.mario&&i.status!=constants.jump:
				if i.getRight()>getLeft()&&i.getLeft()<getRight():
#					print(i.getRight(),' ',getRight())
					if i.getBottom()>getTop()-0.1&&i.getBottom()<getTop()+0.1:
						i.position.y=position.y-i.getSizeY()/2+yVel*delta
						
		position.y+=yVel*delta	
		if position.y>winHeight&&status==constants.moveDown:
			position.y=-16
	pass

#func getLeft():
#	return position.x
#
#func getRight():
#	return 	position.x+rect.size.x

#func getTop():
#	return position.y
#
#func getBottom():
#	return position.y+rect.size.y

#func getCenterX():
#	return position.x-rect.size.x/2
#
#func getCenterY():
#	return position.y-rect.size.y/2

#func getRect():
#	var temp =rect
#	temp.position+=position
#	temp.size=Vector2(32*lens*2,position.y)
#	return temp
	

func rightCollide(obj):
	return false
	
func leftCollide(obj):
	return false

func floorCollide(obj):
	
	return false	

func ceilcollide(obj):
	return false		
