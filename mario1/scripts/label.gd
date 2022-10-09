extends "res://scripts/object.gd"

onready var _label=$Label
var _name

func _ready():
	active=false
	_label.text=str(_name)
	pass

func setLabel(s):
	_name=s
