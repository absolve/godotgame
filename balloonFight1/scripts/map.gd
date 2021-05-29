extends Node2D

var cellSize=16	#每个格子的大小是16px

func _ready():
	pass






func _draw():
	for i in range(27):
		draw_line(Vector2(i*cellSize,0),Vector2(i*cellSize,cellSize*26),Color.gray,0.5,true)
		pass
	for i in range(27):
		draw_line(Vector2(0,i*cellSize),Vector2(cellSize*26,i*cellSize),Color.gray,0.5,true)
	
