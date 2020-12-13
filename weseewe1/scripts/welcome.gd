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

onready var _spawnblock=$block/spawnblock
onready var _btnSound=$ui/btnSound2
onready var _colorTimer=$colorTimer
onready var _gamePassTimer=$gamePassTimer
onready var _player=$player/player
onready var _scoreDotutil=$dot/scoreDotutil
onready var _ani=$ani
onready var _word=$ui/word
onready var _particleUtil=$bg/particleUtil
onready var _camera=$camera
onready var _gameOverTimer=$gameOverTimer
onready var _colorDotUtil=$dot/colorDotUtil
var _scoreBoard
var _helpInfo
onready var _bg= $bg
onready var _btnPause=$ui/btnPause2
onready var _btnMain=$ui/btnMain
onready var _btnRank=$ui/btnRank
onready var _author=$ui/author


func _ready():
	print(Game.data['sound'])
	if  Game.data['sound']:
		_btnSound.pressed=false
		SoundUtil.playWelcomMusic()
	else:
		_btnSound.pressed=true
	
	_spawnblock.init()
	height=OS.get_window_size().y
	_gameOverTimer.connect("timeout",self,"_gameOver")
	_colorTimer.connect("timeout",self,"_addNewColor")
	_gamePassTimer.connect("timeout",self,"_gamePass")
	
	if Game.nextState!=Game.state.STATE_IDLE:
		if Game.nextState==Game.state.STATE_START:
			setState(Game.state.STATE_START)
		elif Game.nextState==Game.state.STATE_NEWSCORE:
			_ani.current_animation="newScore"
			_scoreDotutil.clear()
			_word.clear()
			_player.playMewScoreAni()
			var delay=0
			while delay<300:
				delay+=1
				if delay%20==0&&delay<100:
					_particleUtil.addRandomPosParticle(Vector2(randi()%80+120,460),true)
				yield(get_tree(), "idle_frame")
			_ani.play("newScoreBack")
			_scoreDotutil.init(Game.data['best_round'])
			_particleUtil.startRandomParticle()
			_word.init()		
		Game.nextState=Game.state.STATE_IDLE
	else:
		_scoreDotutil.init(Game.data['best_round'])
		_particleUtil.startRandomParticle()
		_word.init()

func _physics_process(delta):
	if state==Game.state.STATE_IDLE:
		pass
	elif state==Game.state.STATE_HELP:
		if  _player.position.y>cameraStartPos.y:
			_camera.offset.y-=(_player.position.y-cameraStartPos.y)*0.09
		else:
			_camera.offset.y+=(cameraStartPos.y-_player.position.y)*0.09

		cameraStartPos=_player.position	
		if _camera.offset.y<280:
			_camera.offset.y=280
		elif _camera.offset.y>320:
			_camera.offset.y=320
	elif state==Game.state.STATE_START:
		if  _player.position.y>cameraStartPos.y:
			_camera.offset.y-=(_player.position.y-cameraStartPos.y)*0.09
		else:
			_camera.offset.y+=(cameraStartPos.y-_player.position.y)*0.09

		cameraStartPos=_player.position	
	
		if _camera.offset.y<280:
			_camera.offset.y=280
		elif _camera.offset.y>320:
			_camera.offset.y=320
		#如果玩家位置超出屏幕就游戏结束	
		if _player.position.x<-_player.size/2:
			setState(Game.state.STATE_OVER)
		if _player.position.y>height+offsety+_player.size/2+30:
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
		_ani.play("help")
		_player.setState(Game.playerState.STAND)
		_spawnblock.setState(Game.blockState.FAST)	
		_helpInfo=helpInfo.instance()
		_bg.add_child(_helpInfo)
		_scoreDotutil.clear()
		_word.clear()
		_colorDotUtil.add3Dot(_spawnblock.allColor.slice(0,2))
		_spawnblock.setGameState(Game.state.STATE_HELP)
		self.state=state
	elif state==Game.state.STATE_IDLE:
		if self.state==Game.state.STATE_PAUSE: #从游戏开始返回
			get_tree().paused=false
			Game.changeScene(Game.mainScene)
		elif self.state==Game.state.STATE_PASS:	#已经通关
			Game.changeScene(Game.mainScene)
		elif self.state==Game.state.STATE_SCORE:	#分数
			_ani.play_backwards("score")
			_scoreDotutil.init(Game.data['best_round'])
			_word.init()
			_scoreBoard.queue_free()
		else:
			_player.setState(Game.playerState.IDLE)
			_spawnblock.setGameState(Game.state.STATE_IDLE)
			_helpInfo.queue_free()
			_scoreDotutil.init(Game.data['best_round'])
			_word.init()
			_colorDotUtil.clearColor()
			_ani.play_backwards("help")
			yield(_ani,"animation_finished")
			_spawnblock.setState(Game.blockState.SLOW)
		self.state=state
	elif state==Game.state.STATE_START:
		self.state=state
		if Game.data['sound']:
			SoundUtil.playGameStartMusic()
		_particleUtil.stopRandomParticle()
		_ani.play("start")
		_scoreDotutil.clear()
		_word.clear()
		_player.setState(Game.playerState.STAND)
		_player.playAni()
		_spawnblock.setState(Game.blockState.FAST)
		yield(_player.get_node("ani"),"animation_finished")
		_spawnblock.setGameState(Game.state.STATE_START)
		_colorDotUtil.addAllJoint()	#添加关节
		_colorTimer.start(1)	#游戏开始	
	elif state==Game.state.STATE_OVER:#游戏结束
		_player.setState(Game.playerState.DEAD)
		_spawnblock.setState(Game.blockState.SHAKE)
		if _player.position.x<-_player.size/2:
			_particleUtil.addEdgeParticle(Vector2(0,_player.position.y),false)
		else:
			_particleUtil.addRandomPosParticle(Vector2(_player.position.x,400),false)
		
		SoundUtil.playPop()
		SoundUtil.stopTrack()
		saveData()	#保存数据
		
		_btnPause.visible=false
		_gameOverTimer.start()
		self.state=state
	elif state==Game.state.STATE_NEWSCORE:
		self.state=state
	elif state==Game.state.STATE_PAUSE:
		get_tree().paused=true
		if Game.data['sound']:
			SoundUtil.stopTrack()
		_ani.play("pause")
		_player.setState(Game.playerState.IDLE)
		_spawnblock.setState(Game.blockState.STOP)
		self.state=state
	elif state==Game.state.STATE_RESUME:
		get_tree().paused=false
		if Game.data['sound']:
			SoundUtil.playWelcomMusic()
		_ani.play_backwards("pause")
		_player.setState(Game.playerState.STAND)
		_spawnblock.setState(Game.blockState.FAST)
		_spawnblock.setGameState(Game.state.STATE_START)
		_colorTimer.start()
		self.state=Game.state.STATE_START
	elif state==Game.state.STATE_PASS:
		_btnMain.set_position(Vector2(3,394))
		_spawnblock.setState(Game.blockState.SLOW)
		_spawnblock.setGameState(Game.state.STATE_PASS)
		_btnRank.visible=false
		_author.visible=true
		saveData()	#保存数据
		var delay=0
		while delay<300:
			delay+=1
			if delay%30==0:
				_particleUtil.addRandomPosParticle(Vector2(randi()%80+120,460),false)
			yield(get_tree(), "idle_frame")	
		self.state=state
	elif state==Game.state.STATE_SCORE:	#分数显示
		self.state=state
		_scoreDotutil.clear()
		_word.clear()
		_scoreBoard = scoreInfo.instance()
		$ui.add_child(_scoreBoard)
		_ani.play("score")
			

#游戏结束后定时器	
func _gameOver():
	Game.changeScene(Game.mainScene)
	
#添加新颜色
func _addNewColor():
	SoundUtil.playColor()	#新颜色声音
	if firstStart:
		_colorTimer.stop()
		_colorTimer.wait_time=getNewColordelay
		_colorTimer.start()
		firstStart=false
	var block =_spawnblock
	block.addNewColor()
	if block.useColor.size()>=10:	#如果已经是1个
		_gamePassTimer.start()#通关定时器
		_colorTimer.stop()
		_colorDotUtil.addDot(block.useColor[block.useColor.size()-1])
	else:
		_colorDotUtil.addDot(block.useColor[block.useColor.size()-1])

#游戏通关		
func _gamePass():
	setState(Game.state.STATE_PASS)

#保存数据
func saveData():
	var colorsNum=_spawnblock.useColor.size()
	if colorsNum>Game.data['best_round']:
		Game.nextState=Game.state.STATE_NEWSCORE
	Game.recordGameData(colorsNum)#记录数据


func _on_btnHelp2__pressed():
	setState(Game.state.STATE_HELP)
	

func _on_btnStart2__pressed():
	setState(Game.state.STATE_START)


func _on_btnSound2__pressed():
	if Game.data['sound']:
		Game.data['sound']=false
		SoundUtil.stopTrack()
	else:
		Game.data['sound']=true
		SoundUtil.playWelcomMusic()
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
