extends Node2D


var player=1	#默认选择1玩家
onready var _indicator=$indicator

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
		var scene=load("res://scenes/map.tscn")
		var temp=scene.instance()
		temp.mode="game"
		queue_free()
		set_process_input(false)
		get_tree().get_root().add_child(temp)
		set_process_input(true)
		
