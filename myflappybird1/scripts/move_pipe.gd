extends Node2D

#水管
const pipes = preload("res://stages/pipe.tscn")
#屏幕的大小
const width=144
const GROUND_HEIGHT = 56
const OFFSET_Y      = 55
const PIPE_WIDTH    = 26
const OFFSET_X      = 65
#水管的数组
var list = []

func _ready():
	randomize()
	
	var p1 = pipes.instance()
	var pos1 = Vector2()
	pos1.x = width+PIPE_WIDTH
	pos1.y = rand_range(0+OFFSET_Y, get_viewport_rect().size.height-GROUND_HEIGHT-OFFSET_Y)
	p1.set_pos(pos1)
	var p2 = pipes.instance()
	pos1.x+= PIPE_WIDTH+OFFSET_X
	pos1.y = rand_range(0+OFFSET_Y, get_viewport_rect().size.height-GROUND_HEIGHT-OFFSET_Y)
	p2.set_pos(pos1)
	var p3 = pipes.instance()
	pos1.x+= PIPE_WIDTH+OFFSET_X
	pos1.y = rand_range(0+OFFSET_Y, get_viewport_rect().size.height-GROUND_HEIGHT-OFFSET_Y)
	p3.set_pos(pos1)
	get_node("child").add_child(p1)
	get_node("child").add_child(p2)
	get_node("child").add_child(p3)
	list.append(p1)
	list.append(p2)
	list.append(p3)
	
	var bird = game.get_main_node().get_node("bird")
	if bird:
		bird.connect("state_changed",self,"_on_bird_state_changed")

func _on_bird_state_changed(bird):
	if bird.get_state()==2:
		set_pause()


#暂停所有水管
func set_pause():
	for d in list:
		d.set_state(0)
	
#开始移动
func set_start():
	for d in list:
		d.set_state(1)
	

