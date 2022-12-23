extends "res://scripts/object.gd"

onready var lens=$len

var length=0  #长度 length*32 每增加1长度x32
var spriteIndex=0
var vine1=preload("res://sprites/vine1.png")
var vine2=preload("res://sprites/vine2.png")
var vine3=preload("res://sprites/vine3.png")
var vine4=preload("res://sprites/vine4.png")
var status=constants.growing
var speed=70  #上升的速度
var startY=0 #开始的位置
var level='' #跳到的关卡
var subLevel='' #关卡的位置

func _ready():
	active=false
	debug=true
	type=constants.vine
	rect=Rect2(Vector2(-4,-16),Vector2(8,32))
	var temp=Sprite.new()
	temp.texture=vine1
	temp.position=Vector2(0,lens.get_child_count()*32)
	lens.add_child(temp)
	yVel=-speed
	startY=position.y
	pass

func getCenterY():
	return position.y+rect.size.y/2-16
	
func getTop():
	return position.y-16

func getBottom():
	return position.y+lens.get_child_count()*32-16

func addVine():
#	print('addVine')
	var temp=Sprite.new()
	temp.texture=vine2
	temp.position=Vector2(0,lens.get_child_count()*32)
	lens.add_child(temp)
#	rect=Rect2(Vector2(-16,-16),Vector2(32,lens.get_child_count()*32))
	rect.size.y+=32
	pass


func _update(delta):
	if status==constants.growing:
		if position.y-16<0:
			status=constants.empty
			
		position.y+=yVel*delta
		if length>0:
			if lens.get_child_count()<length:
				if position.y+lens.get_child_count()*32-16<startY-16:
					addVine()
			else:
				print("vineEnd")
				status=constants.empty
				Game.emit_signal("vineEnd")		
		elif position.y+lens.get_child_count()*32-16<startY-16:
			addVine()
			
	if debug:
		update()
	pass
