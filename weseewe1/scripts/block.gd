extends StaticBody2D


#状态
export var state = Game.blockState.SLOW
export var speed=50
export var fastSpeed=172
#export var ypos=480
export var offsetX=21
var height=128	#高度128
var width=102
export var noCollision=false	#能否站立
var sendExit=false
var offsetY=22


func _ready():
	add_to_group("block")
	if noCollision:
		$shape.disabled=noCollision

func setColor(color:String):
	$bg.modulate=Color(color)

func setState(state):
	self.state=state
	if state==Game.blockState.SHAKE:
		var speedY=1
		var	flap=true
		var startY=position.y
		var index=0
		while true:
			speedY+=0.3
			if flap:
				position.y+=speedY
			else:
				position.y-=speedY
			yield(get_tree(), "idle_frame")
			if flap&& position.y>=startY+offsetY:
				flap=false
				speedY=1
				index+=1
			if !flap && position.y<=startY-offsetY+5:
				flap=true
				speedY=1
				index+=1
			if index>=2 && position.y>=startY:
				self.state=Game.blockState.SLOWMOVE
				break

func _physics_process(delta):
	if state==Game.blockState.SLOW:
		position.x-=speed*delta
	elif state==Game.blockState.FAST:
		position.x-=fastSpeed*delta
	elif state==Game.blockState.STOP:	
		pass
	elif state==Game.blockState.SLOWMOVE:
		position.x+=5*delta
		position.y+=8*delta
	elif state==Game.blockState.SHAKE:
		pass
	
		
	if position.x<=8 and !sendExit:	#消失在左边
		Game.emit_signal("blockExit",position.x)
		sendExit=true


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	 
