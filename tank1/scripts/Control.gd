extends Control


var p1key=['p1_up','p1_down','p1_left','p1_right','p1_fire']
onready var actionList=$tab/control/actionList
onready var actions=$tab/control/actionList/ScrollContainer/actions
var action=preload("res://scenes/action.tscn")
var keyList=preload("res://scenes/keyList.tscn")


func _ready():
	for i in p1key:
		var list=InputMap.get_action_list(i)
		print(list)
		var tempAction=action.instance()
		actions.add_child(tempAction)
		tempAction.setAction(i)
		for z in list:
			var tempkey =keyList.instance()
			tempAction.addKeyList(tempkey)
			if z is InputEventKey:
				tempkey.setKeyName("Keyboard: " + z.as_text())
			elif z is InputEventJoypadButton:
				tempkey.setKeyName("Gamepad: " + z.as_text())
			elif z is InputEventJoypadMotion:
				var text="Gamepad: "
				var stick: = ''
				if Input.is_joy_known(z.device):
					stick = str(Input.get_joy_axis_string(z.axis))
					text+= stick + " "
				else:
					text += "Axis: " + str(z.axis) + " "
				
				if !stick.empty():	#known
					var value:int = round(z.axis_value)
					if stick.ends_with('X'):
						if value > 0:
							text += 'Rigt'
						else:
							text += 'Left'
					else:
						if value > 0:
							text += 'Down'
						else:
							text += 'Up'
				else:
					text += str(round(z.axis_value))
				tempkey.setKeyName(text)
		
			print(z.as_text(),' ',z.get_device())
	pass # Replace with function body.





# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_return_pressed():
	queue_free()
	Game.changeScene(Game._welcomeScene)
	pass # Replace with function body.


func _on_Button_pressed():
	
	pass # Replace with function body.
