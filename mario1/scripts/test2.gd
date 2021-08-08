extends Node2D


onready var mario=$mario1
onready var brick=$brick

func _ready():
	pass # Replace with function body.


func _process(delta):
	mario._update(delta)
	
	for i in brick.get_children():
		var rect1 = mario.getRect()
		var rect2=i.getRect()
		if rect1.intersects(rect2):
			if mario.position.y<i.position.y:
				mario.yVel=0
				mario.position.y=i.position.y-i.getSize()/2-mario.getSize()/2
				pass
			else:
				
				pass
			
			
			pass
		
		pass	
	
	pass
