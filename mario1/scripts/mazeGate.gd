extends "res://scripts/object.gd"

var gateId=0 #门的类型
var mazeId=0  
var vaild=true	#是否有效

func _ready():
	debug=true
	type=constants.mazeGate
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	pass
