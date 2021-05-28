extends Control


var p1key=['p1_up','p1_down','p1_left','p1_right']


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in p1key:
		var list=InputMap.get_action_list(i)
		print(list)
		for z in list:
			print(z.as_text(),' ',z.get_device())
	pass # Replace with function body.





# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
