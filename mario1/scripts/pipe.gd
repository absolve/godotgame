extends "res://scripts/object.gd"

var spriteIndex=0
var rotate=0  #旋转角度
onready var ani=$ani
var pipeType=constants.empty
var pipeNo=0  #用来标记当前水管入口 也是出口
var dir=constants.down

func _ready():
	type=constants.pipe
#	debug=true
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	if spriteIndex >=0&&spriteIndex<=30:
		ani.play(str(spriteIndex))
	else:
		ani.play("0")	
	ani.rotate(deg2rad(rotate))
	pass


