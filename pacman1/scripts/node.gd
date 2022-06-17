extends Node2D

var debug=true
var neighbors={Constants.up:null,Constants.down:null,
				Constants.left:null,Constants.right:null}
var type
var rect=Rect2(Vector2(-15,-15),Vector2(30,30))	

func _ready():
#	update()
	pass


func _draw():
	print("a")
	if debug:
		draw_rect(rect,Color.red,false)
#		for i in neighbors.keys():
#			if neighbors[i]:
#				draw_line(position,neighbors[i].position,Color.white,5)
	pass
