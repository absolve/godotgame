extends TextureButton

#主界面上面继续按钮

func _ready():
	connect("pressed", self, "_on_pressed")
	
	pass

func _on_pressed():
	get_tree().set_pause(false)
	var panel = game.get_main_node().get_node("hub").get_node("pause_panel")
	panel.hide()
	print("12")
	

