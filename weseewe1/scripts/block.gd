extends StaticBody2D


#状态
export var state = Game.blockState.SLOW
export var speed=30
export var fastSpeed=140
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

func _physics_process(delta):
	if state==Game.blockState.SLOW:
		position.x-=round(speed*delta)
	elif state==Game.blockState.FAST:
		position.x-=round(fastSpeed*delta)
	elif state==Game.blockState.STOP:	
		pass

	if position.x<51 and !sendExit:	#消失在左边
		#position.x=width*4+width/2-30
		print(position.x)
		Game.emit_signal("blockExit")
		sendExit=true
		
		


func _on_VisibilityNotifier2D_screen_exited():
	#Game.emit_signal("blockExit")
	queue_free()
	pass
