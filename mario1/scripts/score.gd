extends Label


var yVel=-80 #y轴速度
var maxHeight
var score=0 #显示分号

func _ready():
	maxHeight=rect_position.y-90
	text=str(score)
	pass

func setPos(pos:Vector2):
	rect_position=pos

func setScore(_score):
	score=_score

func _update(delta):
	rect_position.y+=yVel*delta
	if rect_position.y<=maxHeight:
		queue_free()
	pass