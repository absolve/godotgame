extends Node2D


var player=1	#默认选择1玩家
onready var _indicator=$indicator
onready var _title=$title

func _ready():
	
	pass 

func _process(delta):
	if Input.is_action_just_pressed("ui_down"):
		if player==1:
			player=2
			_indicator.position.y=320
	elif Input.is_action_just_pressed("ui_up"):
		if player==2:
			player=1
			_indicator.position.y=280
	elif Input.is_action_just_pressed("ui_accept"):
		print("开始游戏")
		var scene=load("res://scenes/menu.tscn")
		var temp=scene.instance()
		Game.playerData['score']=0
		Game.playerData['level']="1-1"
		Game.playerData['lives']=3
		Game.playerData['coin']=0
		Game.playerData['mario']['big']=false
		Game.playerData['mario']['fire']=false
		
		queue_free()
		set_process_input(false)
		get_tree().get_root().add_child(temp)
		set_process_input(true)
		
