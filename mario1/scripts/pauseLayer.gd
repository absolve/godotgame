extends CanvasLayer




func _on_resume_pressed():
#	Game.emit_signal("resume")
	get_tree().paused=false
	visible=false

func _on_return_pressed():
	get_tree().paused=false
	Game.emit_signal("returnHome")
#	set_process_input(false)
#	var scene=load("res://scenes/welcome.tscn")
#	var temp=scene.instance()
#	queue_free()
#	get_tree().get_root().add_child(temp)
#	set_process_input(true)
	
