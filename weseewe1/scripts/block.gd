extends StaticBody2D


#状态
export var state = Game.blockState.SLOW
export var speed=50
export var fastSpeed=160
export var ypos=480
export var offsetX=21
var height=128	#高度128
var width=102
export var noCollision=false
var sendExit=false

func _ready():
	position.y=ypos
	add_to_group("block")
	if noCollision:
		$shape.disabled=noCollision

func setColor(color:String):
	$bg.modulate=Color(color)

func setState(state):
	self.state=state

func _physics_process(delta):
	if state==Game.blockState.SLOW:
		position.x-=speed*delta
	elif state==Game.blockState.FAST:
		position.x-=fastSpeed*delta
	elif state==Game.blockState.STOP:	
		pass
	
	if position.x<=8 and !sendExit:	#消失在左边
		print(position.x)
		Game.emit_signal("blockExit",position.x)
		print(5665)
		sendExit=true
		
		


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	 
