extends Node2D

func _ready():
	pass

func playIn():
	$ani.play("in")
	
func playOut():
	$ani.play_backwards("in")

func setLevelName(name):
	$name.text=name
