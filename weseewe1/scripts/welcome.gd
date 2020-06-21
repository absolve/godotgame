extends Node2D


var offsety=80 #摄像机的y偏移
var pos=543
var cameray=400
var gravity=1000

var state=Game.state.STATE_IDLE

var helpInfo =preload("res://scenes/helpInfo.tscn")


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
	if state==Game.state.STATE_HELP:
		$player/player.setState(Game.playerState.STAND)
		$block/spawnblock.setState(Game.blockState.FAST)	
		$ani.play("help")
		var helpinfo=helpInfo.instance()
		$ui.add_child(helpinfo)
		$ui/scoreDotutil.clear()
		$ui/colorDotUtil.add3Dot($block/spawnblock.allColor.slice(0,2))
#		yield($ani,"animation_finished")
		$block/spawnblock.setGameState(Game.state.STATE_HELP)
	elif state==Game.state.STATE_IDLE:
		if self.state==Game.state.STATE_PAUSE: #从游戏开始返回
			Game.changeScene(Game.mainScene)
		else:	
			$block/spawnblock.setGameState(Game.state.STATE_IDLE)
			$ui/helpInfo.queue_free()
			$ui/scoreDotutil.init()
			$player/player.setState(Game.playerState.IDLE)
			$ui/colorDotUtil.clearColor()
			$ani.play_backwards("help")
			yield($ani,"animation_finished")
			$block/spawnblock.setState(Game.blockState.SLOW)	
	elif state==Game.state.STATE_START:
		#$ui/btnPause.visible=true
		$ani.play("start")
		$ui/scoreDotutil.clear()
		$player/player.setState(Game.playerState.STAND)
		$block/spawnblock.setGameState(Game.state.STATE_START)
		#$block/spawnblock.setState(Game.blockState.FAST)	
		
		pass
	elif state==Game.state.STATE_OVER:#游戏结束
		
		pass
	elif state==Game.state.STATE_NEWSCORE:
		
		pass
	elif state==Game.state.STATE_PAUSE:
		$ani.play("pause")
		pass
	self.state=state
	
	
#游戏开始
func _on_btnStart_pressed():
#	$block/particleUtil.pos=Vector2(240,400)
#	$block/particleUtil.addParticle()
	setState(Game.state.STATE_START)
	pass

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
	$ui/btnSound.modulate=Color(1,1,1)
	


func _on_btnSound_button_down():
	$ui/btnSound.rect_position.x-=5
	$ui/btnSound.rect_position.y+=5
	$ui/btnSound.modulate=Color(0.8,0.8,0.8)
	
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
	

#游戏暂停按钮
func _on_btnPause_pressed():
	setState(Game.state.STATE_PAUSE)
	pass # Replace with function body.

#游戏继续
func _on_btnResume_pressed():
	$ani.play_backwards("pause")
	pass # Replace with function body.


func _on_btnResume_button_down():
	$ui/btnResume.rect_position.x-=5
	$ui/btnResume.rect_position.y+=5
	$ui/btnResume.modulate=Color(0.8,0.8,0.8)

	pass # Replace with function body.


func _on_btnResume_button_up():
	$ui/btnResume.rect_position.x+=5
	$ui/btnResume.rect_position.y-=5
	$ui/btnResume.modulate=Color(1,1,1)
	pass # Replace with function body.

#重新开始
func _on_btnRestart_pressed():
	pass # Replace with function body.


func _on_btnRestart_button_up():
	$ui/btnRestart.rect_position.x+=5
	$ui/btnRestart.rect_position.y-=5
	$ui/btnRestart.modulate=Color(1,1,1)
	pass # Replace with function body.


func _on_btnRestart_button_down():
	$ui/btnRestart.rect_position.x-=5
	$ui/btnRestart.rect_position.y+=5
	$ui/btnRestart.modulate=Color(0.8,0.8,0.8)

	
