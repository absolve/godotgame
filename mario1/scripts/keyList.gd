extends Control


onready var key=$MarginContainer/HBoxContainer2/HBoxContainer/key

func setKeyName(name):
	key.set_text(name)
