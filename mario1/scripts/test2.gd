extends Node2D


onready var mario=$mario1
onready var brick=$brick
onready var box1=$brick/box1
onready var item=$brick/item
onready var obj=$obj

func _ready():
	box1.mainScene=obj
	pass # Replace with function body.


func _process(delta):
	mario._update(delta)
	box1._update(delta)
	item._update(delta)
	
	for i in obj.get_children():
		i._update(delta)
	
	var onFloor=false
	for i in brick.get_children():
		var rect1 = mario.getRect()
		var rect2=i.getRect()
		if rect1.intersects(rect2):
			if mario.position.y<i.position.y:
				mario.yVel=0
				mario.position.y=i.position.y-i.getSize()/2-mario.getSize()/2
				onFloor=true
				pass
			else:
				mario.yVel=8
				if !onFloor:
					onFloor=false
				pass
			
			
			pass
		
		pass	
	mario.isOnFloor=onFloor
	
	for i in brick.get_children():
		var rect1 = item.getRect()
		var rect2=i.getRect()
		if item.status==constants.growing:
			continue
		elif rect1.intersects(rect2):
			if item.position.y<i.position.y:
				item.yVel=0
				item.position.y=i.position.y-i.getSize()/2-item.getSize()/2
				pass
			elif item.position.y>i.position.y:
				item.yVel=0
				pass
		
	pass


func _on_Button_pressed():
	mario.small2Big()
	pass # Replace with function body.


func _on_Button2_pressed():
	box1.startBumped()
	pass # Replace with function body.


func _on_Button3_pressed():
	
	pass # Replace with function body.
