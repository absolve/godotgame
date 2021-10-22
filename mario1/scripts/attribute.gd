extends Control


onready var list=$PanelContainer/list
var attr=preload("res://scenes/attr.tscn")

func _ready():
	pass

func addttr(name,value):
	var temp=attr.instance()
	temp.get_node("name").text=str(name)
	temp.get_node("value").text=str(value)
	
	list.add_child(temp)
	pass



func _on_Button_pressed():
	addttr("1","2")
	pass # Replace with function body.
