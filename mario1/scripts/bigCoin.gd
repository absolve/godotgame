extends "res://scripts/object.gd"
"""
大的金币
"""
onready var ani=$ani
var status=constants.empty
#var isOnFloor=true

func _ready():
	mask=[constants.box]
	type=constants.bigCoin
#	debug=true
	rect=Rect2(Vector2(-10,-15),Vector2(20,30))	
	ani.play('coin')
	pass


func floorCollide(obj):
	if obj.type==constants.box:
		print('2121')
		if obj.status==constants.bumped:
			SoundsUtil.playCoin()
			active=false
			destroy=true
		pass
	pass
