extends Control


onready var list=$ScrollContainer/PanelContainer/list
var attr=preload("res://scenes/attr.tscn")

func _ready():
	pass

func addAttr(name,value):
	var temp=attr.instance()
	temp.key=str(name)
	temp.value=str(value)
	
	list.add_child(temp)
	pass

func clearAttr():
	for child in list.get_children():
		child.queue_free()
	pass

func _on_Button_pressed():
	addAttr("1","2")
	pass # Replace with function body.
