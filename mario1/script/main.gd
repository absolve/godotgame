extends Node2D


var player=1	#默认选择1玩家

func _ready():
	pass 

func _process(delta):
	if Input.is_action_just_pressed("ui_down"):
		if player==1:
			player=2
			$indicator.position = Vector2(140,292)
	elif Input.is_action_just_pressed("ui_up"):
		if player==2:
			player=1
			$indicator.position = Vector2(140,263)
	elif Input.is_action_just_pressed("ui_accept"):
		print("开始游戏")
		
		