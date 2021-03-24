extends Node2D


func _ready():
#	$Timer.connect("timeout",self,"end")
	$Timer.start()
	pass

func setNum(num:int):
	$num.set_text("%d"%num)
	pass


func _on_Timer_timeout():
	queue_free()
	pass # Replace with function body.
