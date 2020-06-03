extends Node2D


var offsety=80 #摄像机的y偏移
var pos=543
var cameray=400
var gravity=1000

var state=Game.state.STATE_IDLE

func _ready():
	$block/spawnblock.init()
	pass 



func _physics_process(delta):
	if state==Game.state.STATE_IDLE:
		
		pass		
	elif state==Game.state.STATE_HELP:
		var velocity = $player/player.velocity
		if velocity.y>0:
			$camera.offset.y+=abs(velocity.y/100*0.2)
		elif velocity.y<0:
			$camera.offset.y-=abs(velocity.y/100*0.2)
		
		if $camera.offset.y>310:
			$camera.offset.y=310
		pass
	elif state==Game.state.STATE_START:
		var velocity = $player/player.velocity
		if velocity.y>0:
			$camera.offset.y+=abs(velocity.y/100*0.2)
		elif velocity.y<0:
			$camera.offset.y-=abs(velocity.y/100*0.2)
		
		if $camera.offset.y>310:
			$camera.offset.y=310
		pass
	

func setState(state):
	self.state=state
	if state==Game.state.STATE_HELP:
		$player/player.setState(Game.playerState.STAND)
		$block/spawnblock.setState(Game.blockState.FAST)	
		$ani.play("help")
#		yield($ani,"animation_finished")
		
	elif state==Game.state.STATE_IDLE:
		$player/player.setState(Game.playerState.IDLE)
		$ani.play_backwards("help")
		yield($ani,"animation_finished")
		$block/spawnblock.setState(Game.blockState.SLOW)
	elif state==Game.state.STATE_START:
		pass
	elif state==Game.state.STATE_OVER:
		
		pass
		
	


func _on_btnStart_pressed():
	$block/particleUtil.pos=Vector2(240,400)
	$block/particleUtil.addParticle()
	

#帮助按钮	
func _on_btnHelp_pressed():
	setState(Game.state.STATE_HELP)
	pass # Replace with function body.




func _on_btnStart_button_up():
	$ui/btnStart.rect_position.x+=5
	$ui/btnStart.rect_position.y-=5
	$ui/btnStart.modulate=Color(1,1,1)
	pass # Replace with function body.


func _on_btnStart_button_down():
	$ui/btnStart.rect_position.x-=5
	$ui/btnStart.rect_position.y+=5
	$ui/btnStart.modulate=Color(0.8,0.8,0.8)
	

func _on_btnScore_pressed():
	
	pass # Replace with function body.


func _on_btnScore_button_up():
	$ui/btnScore.rect_position.x+=5
	$ui/btnScore.rect_position.y-=5
	$ui/btnScore.modulate=Color(1,1,1)
	

func _on_btnScore_button_down():
	$ui/btnScore.rect_position.x-=5
	$ui/btnScore.rect_position.y+=5
	$ui/btnScore.modulate=Color(0.8,0.8,0.8)
	
	


func _on_btnSound_button_up():
	$ui/btnSound.rect_position.x+=5
	$ui/btnSound.rect_position.y-=5
	$ui/btnSound.modulate=Color(0.8,0.8,0.8)
	



func _on_btnSound_button_down():
	$ui/btnSound.rect_position.x-=5
	$ui/btnSound.rect_position.y+=5
	$ui/btnSound.modulate=Color(1,1,1)
	
func _on_btnSound_pressed():
	if Game.sound:
		Game.sound=false
	else:
		Game.sound=true
	



func _on_btnHelp_button_up():
	$ui/btnHelp.rect_position.x+=5
	$ui/btnHelp.rect_position.y-=5
	$ui/btnHelp.modulate=Color(1,1,1)



func _on_btnHelp_button_down():
	$ui/btnHelp.rect_position.x-=5
	$ui/btnHelp.rect_position.y+=5
	$ui/btnHelp.modulate=Color(0.8,0.8,0.8)


func _on_btnMain_button_down():
	$ui/btnMain.rect_position.x-=5
	$ui/btnMain.rect_position.y+=5
	$ui/btnMain.modulate=Color(0.8,0.8,0.8)



func _on_btnMain_button_up():
	$ui/btnMain.rect_position.x+=5
	$ui/btnMain.rect_position.y-=5
	$ui/btnMain.modulate=Color(1,1,1)


func _on_btnMain_pressed():
	setState(Game.state.STATE_IDLE)


func _on_btnRank_button_down():
	$ui/btnRank.rect_position.x-=5
	$ui/btnRank.rect_position.y+=5
	$ui/btnRank.modulate=Color(0.8,0.8,0.8)




func _on_btnRank_button_up():
	$ui/btnRank.rect_position.x+=5
	$ui/btnRank.rect_position.y-=5
	$ui/btnRank.modulate=Color(1,1,1)
	pass # Replace with function body.


func _on_btnNet_button_down():
	$ui/btnHelp.rect_position.x-=5
	$ui/btnHelp.rect_position.y+=5
	$ui/btnHelp.modulate=Color(0.8,0.8,0.8)



func _on_btnNet_button_up():
	$ui/btnHelp.rect_position.x+=5
	$ui/btnHelp.rect_position.y-=5
	$ui/btnHelp.modulate=Color(1,1,1)
	
