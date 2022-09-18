extends "res://scripts/object.gd"
"""
大的金币
"""
onready var ani=$ani
var status=constants.empty
#var isOnFloor=true

func _ready():
	type=constants.bigCoin
#	debug=true
	rect=Rect2(Vector2(-10,-15),Vector2(20,30))	
	ani.play('coin')
	pass

func turnLeft():
	pass

func turnRight():
	pass
