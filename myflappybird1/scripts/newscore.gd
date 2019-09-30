extends TextureFrame
#显示新的分数

func _ready():
	hide()
	
	game.connect("new_score",self,"show")
	pass
