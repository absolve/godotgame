extends Node

#玩家按键
var player1={"up":KEY_W,"down":KEY_S,"left":KEY_A,"right":KEY_D,'accelerate':KEY_J}
var player2={"up":KEY_UP,"down":KEY_DOWN,"left":KEY_LEFT,"right":KEY_RIGHT,'accelerate':KEY_KP_0 }

''' 地图相关 '''
var mapNum	#地图数量
var playerData={'p1':{'score':0,'lives':3,'balloonNum':2},
				'p2':{'score':0,'lives':3,'balloonNum':2}}
var gameData={'width':0,'height':0,'level':0}


#切换场景
func changeScene(stagePath):
	set_process_input(false)
	get_tree().change_scene(stagePath)
	set_process_input(true)
