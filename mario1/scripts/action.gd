extends Control

onready var  action=$hbox/PanelContainer/action
onready var keyList=$keyList

func _ready():
	pass


func setAction(name):
	action.set_text(name)

func addKeyList(obj):
	keyList.add_child(obj)
	pass
