extends Node2D

#移动的背景
const bg_scn = preload("res://stages/bg.tscn")
const bg_width = 168

#地面的列表
var list=[]


func _ready():
	createbg(get_pos())
	createbg(get_pos()+Vector2(bg_width,0))
	set_idle()
	var bird = game.get_main_node().get_node("bird")
	if bird:
		bird.connect("state_changed",self,"_on_bird_state_changed")
			
func _on_bird_state_changed(bird):
	if bird.get_state()==2:
		set_pause()	
	
#创建地面
func createbg(pos):
	var bg1 = bg_scn.instance()
	bg1.set_pos(pos)
	get_node("child").add_child(bg1)
	list.append(bg1)

#设置停止
func set_pause():
	for d in list:
		d.set_state(3)
		
#开始移动		
func set_start():
	for d in list:
		d.set_state(1)		
	
#func reset():
#	pos = Vector2(0,0)
#	for i in list:
#		i.set_pos(pos)
#		pos+=Vector2(bg_width,0)
				
#设置缓慢移动
func set_idle():
	for d in list:
		d.set_state(2)
	