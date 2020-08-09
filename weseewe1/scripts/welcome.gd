extends Node2D


var offsety=60 #摄像机的y偏移
var state=Game.state.STATE_IDLE
var helpInfo =preload("res://scenes/helpInfo.tscn")
var height #高度
var firstStart=true	#新增颜色定时器第一次启动
var getNewColordelay=18 #下一个新颜色的间隔
var scoreInfo = preload("res://scenes/scoreBoard.tscn")	#分数信息

#onready var playPos=$player/player.position
onready var cameraStartPos=$player/player.position


func _ready():
	#print('cameraStartPos===',cameraStartPos)
	print(Game.data['sound'])
	if  Game.data['sound']:
		$ui/btnSound2.pressed=false
		SoundUtil.playWelcomMusic()
	else:
		$ui/btnSound2.pressed=true
	
	$block/spawnblock.init()
	height=OS.get_window_size().y
	$gameOverTimer.connect("timeout",self,"_gameOver")
	$colorTimer.connect("timeout",self,"_addNewColor")
#	$colorTimer.start(2)
	$gamePassTimer.connect("timeout",self,"_gamePass")
	
	if Game.nextState!=Game.state.STATE_IDLE:
		if Game.nextState==Game.state.STATE_START:
			setState(Game.state.STATE_START)
			pass
		elif Game.nextState==Game.state.STATE_NEWSCORE:
			$ani.current_animation="newScore"
			$dot/scoreDotutil.clear()
			$ui/word.clear()
			$player/player.playMewScoreAni()
			var delay=0
			#$block/particleUtil.setPos(Vector2(160,480))
			while delay<300:
				delay+=1
				if delay%20==0&&delay<100:
					$block/particleUtil.addRandomPosParticle(Vector2(randi()%80+120,460),true)
				yield(get_tree(), "idle_frame")
			$ani.play("newScoreBack")
			$dot/scoreDotutil.init(Game.data['best_round'])
			$block/particleUtil.startRandomParticle()
			$ui/word.init()
			
		Game.nextState=Game.state.STATE_IDLE
	else:
		$dot/scoreDotutil.init(Game.data['best_round'])
		$block/particleUtil.startRandomParticle()
		$ui/word.init()

func _physics_process(delta):
	if state==Game.state.STATE_IDLE:
		pass
	elif state==Game.state.STATE_HELP:
		if  $player/player.position.y>cameraStartPos.y:
			$camera.offset.y-=($player/player.position.y-cameraStartPos.y)*0.09
		else:
			$camera.offset.y+=(cameraStartPos.y-$player/player.position.y)*0.09

		cameraStartPos=$player/player.position	
	
		if $camera.offset.y<280:
			$camera.offset.y=280
		elif $camera.offset.y>320:
			$camera.offset.y=320
	elif state==Game.state.STATE_START:
		if  $player/player.position.y>cameraStartPos.y:
			$camera.offset.y-=($player/player.position.y-cameraStartPos.y)*0.09
		else:
			$camera.offset.y+=(cameraStartPos.y-$player/player.position.y)*0.09

		cameraStartPos=$player/player.position	
	
		if $camera.offset.y<280:
			$camera.offset.y=280
		elif $camera.offset.y>320:
			$camera.offset.y=320
		#如果玩家位置超出屏幕就游戏结束	
		if $player/player.position.x<-$player/player.size/2:
			setState(Game.state.STATE_OVER)
		if $player/player.position.y>height+offsety+$player/player.size/2+30:
			setState(Game.state.STATE_OVER)
	elif state==Game.state.STATE_OVER:#游戏结束
		pass
	elif state==Game.state.STATE_PAUSE:
		pass
	elif state==Game.state.STATE_PASS:
		pass
	elif state==Game.state.STATE_SCORE:
		pass
	
	
	
#设置状态	
func setState(state):
	if state==Game.state.STATE_HELP:
		$ani.play("help")
		$player/player.setState(Game.playerState.STAND)
		$block/spawnblock.setState(Game.blockState.FAST)	
		var helpinfo=helpInfo.instance()
		$bg.add_child(helpinfo)
		$dot/scoreDotutil.clear()
		$ui/word.clear()
		$dot/colorDotUtil.add3Dot($block/spawnblock.allColor.slice(0,2))
#		yield($ani,"animation_finished")
		$block/spawnblock.setGameState(Game.state.STATE_HELP)
		self.state=state
	elif state==Game.state.STATE_IDLE:
		if self.state==Game.state.STATE_PAUSE: #从游戏开始返回
			get_tree().paused=false
			Game.changeScene(Game.mainScene)
		elif self.state==Game.state.STATE_PASS:	#已经通关
			Game.changeScene(Game.mainScene)
		elif self.state==Game.state.STATE_SCORE:	#分数
			$ani.play_backwards("score")
			$dot/scoreDotutil.init(Game.data['best_round'])
			$ui/word.init()
			$ui/scoreBoard.queue_free()
		else:
			$player/player.setState(Game.playerState.IDLE)
			$block/spawnblock.setGameState(Game.state.STATE_IDLE)
			$bg/helpInfo.queue_free()
			$dot/scoreDotutil.init(Game.data['best_round'])
			$ui/word.init()
			$dot/colorDotUtil.clearColor()
			$ani.play_backwards("help")
			yield($ani,"animation_finished")
			$block/spawnblock.setState(Game.blockState.SLOW)
		self.state=state
	elif state==Game.state.STATE_START:
		self.state=state
		if Game.data['sound']:
			SoundUtil.playGameStartMusic()
		#$ui/btnPause.visible=true
		$block/particleUtil.stopRandomParticle()
		$ani.play("start")
		$dot/scoreDotutil.clear()
		$ui/word.clear()
		$player/player.setState(Game.playerState.STAND)
		$player/player.playAni()
		$block/spawnblock.setState(Game.blockState.FAST)
		yield($player/player/ani,"animation_finished")
		$block/spawnblock.setGameState(Game.state.STATE_START)
		$dot/colorDotUtil.addAllJoint()	#添加关节
		$colorTimer.start(1)	#游戏开始	
	elif state==Game.state.STATE_OVER:#游戏结束
		$player/player.setState(Game.playerState.DEAD)
		$block/spawnblock.setState(Game.blockState.SHAKE)
		if $player/player.position.x<-$player/player.size/2:
			#$block/particleUtil.setPos(Vector2(0,$player/player.position.y))
			$block/particleUtil.addEdgeParticle(Vector2(0,$player/player.position.y),false)
		else:
			#$block/particleUtil.setPos($player/player.position)
			$block/particleUtil.addRandomPosParticle(Vector2($player/player.position.x,400),false)
		
		SoundUtil.playPop()
		SoundUtil.stopTrack()
		saveData()	#保存数据
		
		$ui/btnPause2.visible=false
		$gameOverTimer.start()
		self.state=state
	elif state==Game.state.STATE_NEWSCORE:
		self.state=state
	elif state==Game.state.STATE_PAUSE:
		get_tree().paused=true
		if Game.data['sound']:
			SoundUtil.stopTrack()
		$ani.play("pause")
		$player/player.setState(Game.playerState.IDLE)
		$block/spawnblock.setState(Game.blockState.STOP)
		self.state=state
	elif state==Game.state.STATE_RESUME:
		get_tree().paused=false
		if Game.data['sound']:
			SoundUtil.playWelcomMusic()
		$ani.play_backwards("pause")
		$player/player.setState(Game.playerState.STAND)
		$block/spawnblock.setState(Game.blockState.FAST)
		$block/spawnblock.setGameState(Game.state.STATE_START)
		$colorTimer.start()
		self.state=Game.state.STATE_START
	elif state==Game.state.STATE_PASS:
		print('STATE_PASS')
		$ui/btnMain.set_position(Vector2(3,394))
		$block/spawnblock.setState(Game.blockState.SLOW)
		$block/spawnblock.setGameState(Game.state.STATE_PASS)
		$ui/btnRank.visible=false
		$ui/author.visible=true
		saveData()	#保存数据
		var delay=0
		#$block/particleUtil.setPos(Vector2(160,480))
		while delay<300:
			delay+=1
			if delay%30==0:
				$block/particleUtil.addRandomPosParticle(Vector2(randi()%80+120,460),false)
			yield(get_tree(), "idle_frame")
			
		self.state=state
	elif state==Game.state.STATE_SCORE:	#分数显示
		self.state=state
		$dot/scoreDotutil.clear()
		$ui/word.clear()
		var scoreinfo = scoreInfo.instance()
		$ui.add_child(scoreinfo)
		$ani.play("score")
			

#游戏结束后定时器	
func _gameOver():
	Game.changeScene(Game.mainScene)
	pass
	
#添加新颜色
func _addNewColor():
	print("_addNewColor")
	SoundUtil.playColor()	#新颜色声音
	if firstStart:
		$colorTimer.stop()
		$colorTimer.wait_time=getNewColordelay
		$colorTimer.start()
		firstStart=false
	var block =$block/spawnblock
	block.addNewColor()
	if block.useColor.size()>=10:	#如果已经是1个
		$gamePassTimer.start()#通关定时器
		$colorTimer.stop()
		$dot/colorDotUtil.addDot(block.useColor[block.useColor.size()-1])
		print('block.useColor.size()>=10')
	else:
		$dot/colorDotUtil.addDot(block.useColor[block.useColor.size()-1])

#游戏通关		
func _gamePass():
	print("_gamePass")
	setState(Game.state.STATE_PASS)

#保存数据
func saveData():
	var colorsNum=$block/spawnblock.useColor.size()
	if colorsNum>Game.data['best_round']:
		Game.nextState=Game.state.STATE_NEWSCORE
	Game.recordGameData(colorsNum)#记录数据


func _on_btnHelp2__pressed():
	setState(Game.state.STATE_HELP)
	

func _on_btnStart2__pressed():
	setState(Game.state.STATE_START)


func _on_btnSound2__pressed():
	print( Game.data['sound'])
	if Game.data['sound']:
		Game.data['sound']=false
		SoundUtil.stopTrack()
	else:
		Game.data['sound']=true
		SoundUtil.playWelcomMusic()
	print(Game.data)
	Game.save(Game.data)

func _on_btnScore2__pressed():
	setState(Game.state.STATE_SCORE)


func _on_btnMain2__pressed():
	setState(Game.state.STATE_IDLE)


func _on_btnPause2__pressed():
	setState(Game.state.STATE_PAUSE)


func _on_btnResume2__pressed():
	setState(Game.state.STATE_RESUME)


func _on_btnRestart2__pressed():
	get_tree().paused=false
	Game.nextState=Game.state.STATE_START
	Game.changeScene(Game.mainScene)
