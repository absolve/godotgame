extends Node2D



var list=[]
# Called when the node enters the scene tree for the first time.
func _ready():
#	Game.mainRoot=self
	Game.mainScene=self
#	list.append($bullet)
#	list.append($bullet2)
	pass # Replace with function body.




func _on_Button_pressed():
	print(list)
#	for i in range(len(list)):
#		print(is_instance_valid(list[i]))
#		list.remove(i)
	var del=[]
	for i in list:
		print(is_instance_valid(i))
		del.append(i)
	for i in del:
		list.remove(list.find(i))
		
	pass # Replace with function body.
