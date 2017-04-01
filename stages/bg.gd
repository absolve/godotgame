extends StaticBody2D

#地面自动设置位置
func _ready():
	set_process(true)
	pass

func _process(delta):
	if get_pos().x<-168:
		set_pos(Vector2(168,get_pos().y))
	set_pos(get_pos()-Vector2(1,0))
