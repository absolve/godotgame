extends TextureButton

#点击开始的按钮

func _ready():
	connect("pressed",self,"on_pressed")
	pass
	
#点击事件
func on_pressed():
	var bird=game.get_main_node().get_node("bird")
	bird.set_state(bird.state_play)
	var bg = game.get_main_node().get_node("movebg")
	bg.set_start()
	var pipe = game.get_main_node().get_node("movepipe")
	pipe.set_start()
	hide()
	pass
	
