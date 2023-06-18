extends Node2D


var spriteIndex=0
onready var ani=$ani


func _ready():
	ani.play(str(spriteIndex))
	pass
