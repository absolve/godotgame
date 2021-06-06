extends Control

onready var  action=$hbox/PanelContainer/action
onready var keyList=$keyList

func _ready():
	print(action)
	pass

func _on_Button_pressed():
	
	pass # Replace with function body.

func setAction(name):
	print(action)
	action.set_text(name)

func addKeyList(obj):
	keyList.add_child(obj)
	pass
