extends Node2D


export var angle=0 # 0是左转 1是右转
export var speed=20
export var xSpeed=-10
var width=64
var deg=0

func _ready():
	pass
	
func _process(delta):
	deg+=delta*speed
	if angle==0:
		rotation_degrees = -round(deg)
	else:
		rotation_degrees = round(deg)
	
	if deg>360:
		deg=0
	position.x+= xSpeed*delta
	if position.x<-width:
		position.x=OS.get_window_size().x+width

