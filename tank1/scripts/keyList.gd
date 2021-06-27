extends Control


onready var key=$HBoxContainer/key

func setKeyName(name):
	key.set_text(name)
