extends "res://scripts/object.gd"
"""
城堡旗帜 
旗帜默认位置会在地图中位置偏移向下一个方块
"""

var status=constants.empty
const speed=80
var oldYpos=0
var spriteIndex=0

func _ready():
	type=constants.castleFlag
	active=false
	yVel=-speed
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	oldYpos=position.y
	position.y+=getSizeY()
	print('oldYpos',oldYpos)
	pass

func rising():
	status=constants.rising

func _update(delta):
	if status==constants.rising:
		position.y+=yVel*delta
		if abs(position.y-oldYpos) >=getSizeY():
			Game.emit_signal("flagRising")
			position.y=oldYpos-getSizeY()
			status=constants.empty
			yVel=0
			
		pass
	pass
