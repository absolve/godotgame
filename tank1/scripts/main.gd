extends Node2D


var state=Game.game_state.LOAD

func _ready():

	pass 

func _process(delta):
	if state==Game.game_state.LOAD:
		if Input.is_action_just_pressed("ui_accept"):
			Splash.playOut()
			#state = Game.game_state.START
			setState(Game.game_state.START)
			pass
		pass
	elif state==Game.game_state.START:
		
		pass
	elif state==Game.game_state.NEXT_LEVEL:
		
		pass
	
	pass

#设置状态
func setState(state):
	if state==Game.game_state.START:
		print('loadMap')
		$map.loadMap(Game.mapDir+"/"+Game.mapNameList[Game.level])
		pass
	elif state==Game.game_state.NEXT_LEVEL:
		
		pass	
	self.state=state

func _input(event):
	
	pass
