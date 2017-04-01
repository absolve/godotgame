extends Node2D

#移动的背景
const bg_scn = preload("res://stages/bg.tscn")
const bg_width = 168

func _ready():
	createbg()
	pass

func createbg():
	var bg1 = bg_scn.instance()
	bg1.set_pos(get_pos())
	get_node("child").add_child(bg1)
	#var bg2 = bg_scn.instance()
	#bg2.set_pos(get_pos()+Vector2(bg_width,0))
	pass 

	
