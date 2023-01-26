extends "res://scripts/object.gd"

var status=constants.rising
var speed=60

func _ready():
	rect=Rect2(Vector2(-4,-4),Vector2(8,8))
	maxYVel=constants.bubbleMaxVel #y轴最大速度
	yVel=-speed
	active=false
	type=constants.bubble
	pass


func _update(delta):
	if status==constants.rising:
		if abs(yVel)<maxYVel:
			yVel+=-randi()%20*delta
		if getTop()<constants.underwaterMaxHeight:
			destroy=true
		position.y+=yVel*delta
	pass

func pause():
	status=constants.stop


func resume():
	status=constants.rising
