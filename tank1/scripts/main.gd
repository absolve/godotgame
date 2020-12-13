extends Node2D


var state=Game.game_state.LOAD
var level



func _ready():
	Game.connect("baseDestroyed",self,"baseDestroy")
	pass 


func _process(delta):
	if state==Game.game_state.LOAD:
		if Input.is_action_just_pressed("ui_accept"):
			#Splash.playOut()
			#state = Game.game_state.START
			setState(Game.game_state.START)
			pass
		pass
	elif state==Game.game_state.START:
		
		pass
	elif state==Game.game_state.NEXT_LEVEL:
		
		pass
	elif state==Game.game_state.OVER:
		pass
	pass



#设置状态
func setState(state):
	if state==Game.game_state.START:
		print('loadMap')
		$map.loadMap(Game.mapDir+"/"+Game.mapNameList[Game.level])
		$map.addNewPlayer(1)
		pass
	elif state==Game.game_state.NEXT_LEVEL:
		
		pass	
	elif state==Game.game_state.OVER:
		
		pass
	self.state=state


#基地毁灭	
func baseDestroy():
	print('baseDestroy')
	setState(Game.game_state.OVER)
	pass
