extends Node2D



func _ready():
	$bird.setState(game.fly)


func _on_startBtn_pressed():
	game.changeScene(game.mainScene)
