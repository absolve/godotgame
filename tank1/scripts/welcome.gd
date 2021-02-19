extends Node2D


var mode=1  #1单人 2双人  3编辑

var pos=Vector3(295,315,335)	#选择1p 2p 时的y坐标
var index=0

func _ready():
	pass 


func _process(delta):
#	if Input.is_key_pressed(KEY_UP):
#		if index>0:
#			index-=1
#			setMode(index)
#		pass
#	elif Input.is_key_pressed(KEY_DOWN):
#		if index<2:
#			index+=1
#			setMode(index)
#			pass
#
#		pass
#	elif Input.is_key_pressed(KEY_ENTER):
#		print('start')
#		print('mode',mode)
##		Game.mode=mode
##		if Game.mapNameList.size()>0:
##			var name = Game.mapNameList[0].split('.')
##			Splash.setLevelName("stage "+name[0])
##		Game.changeScene(Game._mainScene)
#		pass
	pass

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if (event as InputEventKey).scancode==KEY_DOWN:
				print(11111111111)
				if index<2:
					index+=1
					setMode(index)
			elif (event as InputEventKey).scancode==KEY_UP:
				print(2222)
				if index>0:
					index-=1
					setMode(index)
			elif (event as InputEventKey).scancode==KEY_ENTER:	
				Game.mode=mode
				Game.changeSceneAni(Game._mainScene)
				#SoundsUtil.playMusic()
				print(12)
				
func setMode(index):
	print(index)
	if index==0:
		$ani.position.y=pos.x
		mode=1
	elif index==1:
		$ani.position.y=pos.y
		mode=2	
	elif index==2:
		$ani.position.y=pos.z
		mode=3
		
