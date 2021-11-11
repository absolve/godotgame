extends "res://scripts/object.gd"

var status=constants.resting
var oldPos=0
var content="coin"
onready var ani=$ani
var brick=preload("res://scenes/brickPiece.tscn")
var mainScene
var spriteIndex=0  #打开后的颜色 0 是普通颜色 1 蓝色 2灰色  3金币盒子
var _visible=true #是否可见

func _ready():
	gravity=constants.boxGravity
	type=constants.box
	debug=true
	self.rect=Rect2(Vector2(-16,-16),Vector2(32,32))	
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
		status=constants.opened
		
		if spriteIndex==0:
			ani.play("opened")
		elif spriteIndex==1:
			ani.play("opened_blue")
		elif spriteIndex==2:	
			ani.play("opened_grey")
		else:
			ani.play("opened")	
#		var temp1 = brick.instance()
#		temp1.position=Vector2(position.x-rect.size.x/2,position.y-rect.size.y/2)
#		mainScene.add_child(temp1)
#		var temp2=brick.instance()
#		temp2.position=Vector2(position.x-rect.size.x/2,position.y+rect.size.y/2)
#		mainScene.add_child(temp2)
#		var temp3=brick.instance()
#		temp3.position=Vector2(position.x+rect.size.x/2,position.y-rect.size.y/2)
#		temp3.dir=constants.right
#		mainScene.add_child(temp3)
#		var temp4=brick.instance()
#		temp4.position=Vector2(position.x+rect.size.x/2,position.y+rect.size.y/2)
#		temp4.dir=constants.right
#		mainScene.add_child(temp4)
	else:
		position.y+=yVel*delta		
	pass

func opened(delta):
	pass
	
func startBumped():
	yVel=-200
	status=constants.bumped
	pass		
