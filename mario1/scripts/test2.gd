extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var ball = preload("res://scenes/ball.tscn")

func _ready():
	pass # Replace with function body.


func _input(event):
	if event  is InputEventMouseButton:
		var b = ball.instance()
		b.position.x=50
		b.position.y=50
		add_child(b)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
