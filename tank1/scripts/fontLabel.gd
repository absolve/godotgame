extends Node2D

export var string:String

func _ready():
	$Label.text=string
	$Timer.start()
	pass


func _on_Timer_timeout():
	queue_free()
	pass # Replace with function body.
