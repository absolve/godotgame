extends Node2D

func _ready():
	$Timer.connect("timeout",self,"doing")
	$Timer.start()
	pass


func doing():
	pass
	print("=========")
	SoundsUtil.playGameOver()
	yield(SoundsUtil.gameover,"finished")
	Game.changeScene(Game._welcomeScene)
	print("====end=====")
