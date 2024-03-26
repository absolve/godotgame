extends Node2D



onready var _indicator=$indicator
onready var _1p=$p1
onready var _2p=$p2
onready var _selectworld=$selectworld
onready var _treeui=$treeUI

var player=1	#默认选择1玩家  3地图编辑 4选择地图  5设置
var path="res://levels/show.json"
var timer=0
var tick=22
var status=constants.empty
var level='1-1' #当前的关卡
var title

func _ready():
	var scene=load("res://scenes/mapNew.tscn").instance()
	scene.isShow=true
	add_child(scene)
	scene.loadMapFile(path)
	scene.show_behind_parent=true
	scene.set_process_input(false)
	scene.z_index=-1
	title=scene.find_node('title')
	
	_treeui.connect("selectMap",self,"selectMap")
	_treeui.connect("cancel",self,"cancel")
	Game.connect("btnClose",self,"btnClose")
	

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
	for y in range(80):
		yield(get_tree(),"idle_frame")
	var scene=load("res://scenes/menu.tscn")
	var temp=scene.instance()
	Game.playerData['score']=0
	Game.playerData['level']=level
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


func _physics_process(delta):
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

		
func _input(event):
	if Input.is_action_just_pressed("ui_down"):
		if player==1:
			player=2
			_indicator.position.y=320
		elif player==2:	
			player=3
			_indicator.position.y=360
		elif player==3:	
			player=4
			_indicator.position.y=400
		elif player==4:		
			player=5
			_indicator.position.y=440
	elif Input.is_action_just_pressed("ui_up"):
		if player==2:
			player=1
			_indicator.position.y=280
		elif player==3:
			player=2
			_indicator.position.y=320	
		elif  player==4:
			player=3
			_indicator.position.y=360	
		elif player==5:	
			player=4
			_indicator.position.y=400	
	elif Input.is_action_just_pressed("ui_accept"):
		if player==1||player==2:
			startGame()
		elif player==3:
			editMap()	
		elif player==4:	
			_treeui.visible=true
		elif player==5:		
			if !MainSetting.visible:
				MainSetting.visible=true
				
func selectMap(level):
	print(level)
	if level!='':
		self.level=level
		title.setLevel(level)
		_treeui.visible=false
	
func cancel():
	_treeui.visible=false

func btnClose():
	MainSetting.visible=false
