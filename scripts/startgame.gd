extends TextureButton


func _ready():
	connect("pressed",self,"_pressed")
	
	pass

func _pressed():
	#还原结果
	#设置水管和地面不再移动get_main_node().get
	game.changeState(game.state_main)
	pass
	
