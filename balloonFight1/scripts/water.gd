extends Area2D

onready var ani=$ani
var aniIndex=0

func _ready():
	ani.play(str(aniIndex))
	pass
