extends TextureButton

#暂停按钮
func _ready():
	connect("pressed", self, "_pressed")
	var bird = game.get_main_node().get_node("bird")
	if bird:
		bird.connect("state_changed",self,"_on_bird_state_changed")
	
func _pressed():
	get_tree().set_pause(true)
	var panel = game.get_main_node().get_node("hub").get_node("pause_panel")
	panel.show()

func _on_bird_state_changed(bird):
	if bird.get_state()==2:
		hide()

