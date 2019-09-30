extends StaticBody2D
#水管的脚本

#地面的高度
const GROUND_HEIGHT = 56
const OFFSET_Y      = 55
const PIPE_WIDTH    = 26
const OFFSET_X      = 65
const width=144
#0是停止 1是移动 
const state=0

func _ready():
	set_fixed_process(true)
	#print(get_viewport_rect().size.height)
	randomize()
	#添加到组
	add_to_group(game.GROUP_PIPES)
	#设置状态
	#set_state(1)
	pass

func set_state(s):
	state=s

func _fixed_process(delta):
	#print(rand_range(-10,10))
	if state==0:
		return
	elif state==1:
		set_pos(get_pos()-Vector2(1,0))
		
	if get_pos().x<-PIPE_WIDTH:
		var init_pos = Vector2()
		init_pos.x=(PIPE_WIDTH+OFFSET_X)*3-PIPE_WIDTH
		init_pos.y = rand_range(0+OFFSET_Y, get_viewport_rect().size.height-GROUND_HEIGHT-OFFSET_Y)
		set_pos(init_pos)
	