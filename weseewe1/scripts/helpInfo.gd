extends Node2D


onready var tip1=$tip1
onready var tip2=$tip2

var time=0
var change=false
func _ready():
	
	pass # Replace with function body.


func _physics_process(delta):
#	time+=1
#	if time>120:
#		if change:
#			$tip1.add_force(Vector2.ZERO,Vector2(rand_range(0,10),0))
#			$tip2.add_force(Vector2.ZERO,Vector2(rand_range(0,10),0))
#		else:
#			$tip1.add_force(Vector2.ZERO,Vector2(-rand_range(0,10),0))
#			$tip2.add_force(Vector2.ZERO,Vector2(-rand_range(0,10),0))
#		change=!change
#		time=0
	update()
	pass


func _draw():
#	for i in range(len(joints)):
#		draw_line(joints[i].position,dots[i].position,Game.lineColor[0],0.5,true)
	
	var v1 = tip1.position
	draw_line(Vector2(v1.x-100,0),Vector2(v1.x-100,v1.y)
				,Game.lineColor[0],0.5,true)	
	draw_line(Vector2(v1.x,0),Vector2(v1.x,v1.y)
				,Game.lineColor[0],0.5,true)
	
	var v2 = tip2.position
	draw_line(Vector2(v2.x-100,0),Vector2(v2.x-100,v2.y)
				,Game.lineColor[0],0.5,true)	
	draw_line(Vector2(v2.x,0),Vector2(v2.x,v2.y)
				,Game.lineColor[0],0.5,true)
	
	
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
