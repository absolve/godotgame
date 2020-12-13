extends Node2D


onready var tip1=$tip1
onready var tip2=$tip2
var time=0
var change=false

func _ready():
	
	pass # Replace with function body.


func _process(delta):

	update()
	pass


func _draw():
	var v1 = tip1.position
	draw_line(Vector2(v1.x-50,0),Vector2(v1.x-50,v1.y)
				,Game.lineColor[0],0.5,true)	
	draw_line(Vector2(v1.x+50,0),Vector2(v1.x+50,v1.y)
				,Game.lineColor[0],0.5,true)
	
	var v2 = tip2.position
	draw_line(Vector2(v2.x-50,0),Vector2(v2.x-50,v2.y)
				,Game.lineColor[0],0.5,true)	
	draw_line(Vector2(v2.x+50,0),Vector2(v2.x+50,v2.y)
				,Game.lineColor[0],0.5,true)


