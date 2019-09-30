extends StaticBody2D

# 1 移动 2 缓慢移动 3 停止
var flag = 1
const bg_width = 168

#地面自动设置位置
func _ready():
	set_process(true)
	add_to_group(game.GROUP_GROUNDS)
	pass

func set_state(s):
	flag=s

#设置背景的模式
func setFlag(mode):
	if mode==1:
		flag=1
	elif mode==2:
		flag=2
	elif mode==3:
		flag=3

func _process(delta):
	if flag<3:
		if flag==1:
			if get_pos().x<-bg_width:
				set_pos(Vector2(bg_width-1,get_pos().y))
			set_pos(get_pos()-Vector2(1,0))
		elif flag==2:
			if get_pos().x<-bg_width:
				set_pos(Vector2(bg_width-1,get_pos().y))
			set_pos(get_pos()-Vector2(0.2,0))	
			


