extends Node2D


var mode=1  #1单人 2双人  3编辑

var pos=Vector3(295,315,335)	#选择1p 2p 时的y坐标
var index=0
onready var _tankAni=$main/tankAni
onready var _ani=$ani

func _ready():
	pass 

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if (event as InputEventKey).scancode==KEY_DOWN:		
				if index<2:
					index+=1
					setMode(index)
			elif (event as InputEventKey).scancode==KEY_UP:
				if index>0:
					index-=1
					setMode(index)
			elif (event as InputEventKey).scancode==KEY_ENTER:	
				if _ani.get_current_animation()=="start" and \
					_ani.is_playing():
					_ani.play("end")
					return
				if mode in [1,2]:
					Game.mode=mode		
					Game.change2SceneLevel(Game._mainScene)
					queue_free()
				else:
					var scene = preload("res://scenes/map.tscn"	)
					var temp=scene.instance()
					temp.mode=1
					queue_free()
					set_process_input(false)
					get_tree().get_root().add_child(temp)
					set_process_input(true)
					#Game.changeSceneAni(Game._welcomeScene)
				
				
func setMode(index):
	print(index)
	if index==0:
		_tankAni.position.y=pos.x
		mode=1
	elif index==1:
		_tankAni.position.y=pos.y
		mode=2	
	elif index==2:
		_tankAni.position.y=pos.z
		mode=3
		
