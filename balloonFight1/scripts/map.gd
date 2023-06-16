extends Node2D

var cellSize=16	#每个格子的大小是16px
var height
var width
var debug=false

func _ready():
	var viewRect=get_viewport_rect()
	width=viewRect.size.x
	height=viewRect.size.y
	print(width,height)
	pass


func _draw():
	for i in range(width/cellSize):
		draw_line(Vector2(i*cellSize,0),Vector2(i*cellSize,width),Color.gray,0.5,true)
	for i in range(height/cellSize):
		draw_line(Vector2(0,i*cellSize),Vector2(width,i*cellSize),Color.gray,0.5,true)
	
