extends TextureButton
#游戏开始


func _ready():
	connect("pressed", self, "_on_pressed")
	pass

func _on_pressed():
	game.changeState(game.state_main)
	pass
