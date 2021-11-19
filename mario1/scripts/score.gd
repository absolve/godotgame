extends Label


var yVel=-50 #y轴速度
var maxHeight
var score=0 #显示分号

func _ready():
	maxHeight=rect_position.y-50
	text=str(score)
	pass


func _update(delta):
	rect_position.y+=yVel*delta
	if rect_position.y<=maxHeight:
		queue_free()
	pass
