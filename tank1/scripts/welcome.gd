extends Node2D


var mode=1  #1单人 2双人  

var pos=Vector2(295,315)	#选择1p 2p 时的y坐标

func _ready():
	pass 


func _process(delta):
	
	if Input.is_key_pressed(KEY_UP):
		$ani.position.y=pos.x
		mode=1
		pass
	elif Input.is_key_pressed(KEY_DOWN):
		$ani.position.y=pos.y
		mode=2
		pass
	elif Input.is_key_pressed(KEY_ENTER):
		print('start')
		print('mode',mode)
		Game.mode=mode
		if Game.mapNameList.size()>0:
			var name = Game.mapNameList[0].split('.')
			Splash.setLevelName("stage "+name[0])
		Game.changeScene(Game._mainScene)
		pass
	pass
