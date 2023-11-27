extends CanvasLayer




func _on_resume_pressed():
	Game.emit_signal("resume")
	


func _on_return_pressed():
	Game.emit_signal("returnHome")
	
