extends Node2D


var offsety=60 #摄像机的y偏移
var pos=543
var cameray=400
var gravity=1000

var state=Game.state.STATE_IDLE
var helpInfo =preload("res://scenes/helpInfo.tscn")
var height #高度
#var cameraOffset=20
var firstStart=true	#新增颜色定时器第一次启动
var getNewColordelay=20 #下一个新颜色的间隔

func _ready():
	$block/spawnblock.init()
	height=OS.get_window_size().y
	$gameOverTimer.connect("timeout",self,"_gameOver")
	$colorTimer.connect("timeout",self,"_addNewColor")
	$colorTimer.start(2)
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
		
		if $camera.offset.y>300:
			$camera.offset.y=300
		pass
	elif state==Game.state.STATE_START:
		var velocity = $player/player.velocity
		if velocity.y>0:
			$camera.offset.y+=abs(velocity.y/100*0.2)
		elif velocity.y<0:
			$camera.offset.y-=abs(velocity.y/100*0.2)
		
		if $camera.offset.y>300:
			$camera.offset.y=300
		#如果玩家位置超出屏幕就游戏结束	
		if $player/player.position.x<-$player/player.size/2:
			print("x 超出")
			setState(Game.state.STATE_OVER)
			pass
		if $player/player.position.y>height+offsety+$player/player.size/2:
			print("y 超出")
			setState(Game.state.STATE_OVER)
		pass
	elif state==Game.state.STATE_OVER:#游戏结束
		
		pass
	elif state==Game.state.STATE_PAUSE:
		pass

#设置状态	
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
		self.state=state
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
		self.state=state
	elif state==Game.state.STATE_START:
		#$ui/btnPause.visible=true
		$ani.play("start")
		$ui/scoreDotutil.clear()
		$player/player.setState(Game.playerState.STAND)
		$block/spawnblock.setGameState(Game.state.STATE_START)
		#$block/spawnblock.setState(Game.blockState.FAST)	
		self.state=state
		pass
	elif state==Game.state.STATE_OVER:#游戏结束
		$player/player.setState(Game.playerState.DEAD)
		$block/spawnblock.setState(Game.blockState.SHAKE)
		$block/particleUtil.setPos($player/player.position)
		$block/particleUtil.addParticle()
		$ui/btnPause.visible=false
		$gameOverTimer.start()
		self.state=state	
	elif state==Game.state.STATE_NEWSCORE:
		self.state=state
	elif state==Game.state.STATE_PAUSE:
		$ani.play("pause")
		$player/player.setState(Game.playerState.IDLE)
		$block/spawnblock.setState(Game.blockState.STOP)
		self.state=state
	elif state==Game.state.STATE_RESUME:
		$ani.play_backwards("pause")
		$player/player.setState(Game.playerState.STAND)
		$block/spawnblock.setState(Game.blockState.SLOW)
		$block/spawnblock.setGameState(Game.state.STATE_START)	
		self.state=Game.state.STATE_START

#游戏结束后定时器	
func _gameOver():
	Game.changeScene(Game.mainScene)
	pass	
	
#添加新颜色
func _addNewColor():
	print("_addNewColor")
	if firstStart:
		$colorTimer.stop()
		$colorTimer.wait_time=getNewColordelay
		$colorTimer.start()
		firstStart=false
	
	
	
	pass	

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
	setState(Game.state.STATE_RESUME)
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

	
