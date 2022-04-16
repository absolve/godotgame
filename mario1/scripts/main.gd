extends Node2D



onready var _indicator=$indicator
onready var _1p=$p1
onready var _2p=$p2

var player=1	#默认选择1玩家  3地图编辑
var path="res://levels/show.json"
var timer=0
var tick=22
var status=constants.empty

func _ready():
	var scene=load("res://scenes/map.tscn").instance()
	scene.mode='show'
	add_child(scene)
	scene.loadMapFile(path)
	scene.show_behind_parent=true
	scene.set_process_input(false)
	scene.z_index=-1
	pass 

func startGame():
	print("开始游戏")
	status=constants.startState
	if player==1:
		_1p.visible=false		
	elif player==2:
		_2p.visible=false
			
	set_process_input(false)
	SoundsUtil.playKonamiMusic()
	yield(SoundsUtil.konami,"finished")
	var scene=load("res://scenes/menu.tscn")
	var temp=scene.instance()
	Game.playerData['score']=0
	Game.playerData['level']="1-1"
	Game.playerData['lives']=3
	Game.playerData['coin']=0
	Game.playerData['mario']['big']=false
	Game.playerData['mario']['fire']=false
	queue_free()
	get_tree().get_root().add_child(temp)
	set_process_input(true)
	pass

func editMap():
	set_process_input(false)
	var scene=load("res://scenes/editMap.tscn")
	var temp=scene.instance()
	queue_free()
	get_tree().get_root().add_child(temp)
	set_process_input(true)
	pass

func _process(delta):
	if status==constants.startState:
		timer+=1
		if timer>tick:
			timer=0
			if player==1:
				if _1p.visible:
					_1p.visible=false
				else:
					_1p.visible=true	
			elif player==2:
				if _2p.visible:
					_2p.visible=false
				else:
					_2p.visible=true	
	pass
		
func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("ui_down"):
			if player==1:
				player=2
				_indicator.position.y=320
			elif player==2:	
				player=3
				_indicator.position.y=360
		elif Input.is_action_just_pressed("ui_up"):
			if player==2:
				player=1
				_indicator.position.y=280
			elif player==3:
				player=2
				_indicator.position.y=320	
		elif Input.is_action_just_pressed("ui_accept"):
		
			if player==1||player==2:
				startGame()
			else:
				editMap()	
#			status=constants.startState
#			if player==1:
#				_1p.visible=false		
#			elif player==2:
#				_2p.visible=false
#
#			set_process_input(false)
#			SoundsUtil.playKonamiMusic()
#			yield(SoundsUtil.konami,"finished")
#			var scene=load("res://scenes/menu.tscn")
#			var temp=scene.instance()
#			Game.playerData['score']=0
#			Game.playerData['level']="1-1"
#			Game.playerData['lives']=3
#			Game.playerData['coin']=0
#			Game.playerData['mario']['big']=false
#			Game.playerData['mario']['fire']=false
#
#			queue_free()
#
#			get_tree().get_root().add_child(temp)
#			set_process_input(true)
	
