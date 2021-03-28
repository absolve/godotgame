extends StaticBody2D



var width=376	#地面的宽度
var state=game.slow	#状态
var fastSpeed=120	
var slowSpeed=40


func _ready():
	add_to_group(game.group_ground)
	 
func _physics_process(delta):
	if state==game.slow:
		if position.x<-width:
			position.x=width-3
		position.x-=slowSpeed*delta
	elif state==game.fast:
		if position.x<-width:
			position.x=width-3
		position.x-=fastSpeed*delta
	elif state==game.stop:
		pass
	

func setState(newState):
	state=newState
	
