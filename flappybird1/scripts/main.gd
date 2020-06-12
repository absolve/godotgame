extends Node2D

#分数图片
const sprite_numbers = [
	preload("res://sprites/number_large_0.png"),
	preload("res://sprites/number_large_1.png"),
	preload("res://sprites/number_large_2.png"),
	preload("res://sprites/number_large_3.png"),
	preload("res://sprites/number_large_4.png"),
	preload("res://sprites/number_large_5.png"),
	preload("res://sprites/number_large_6.png"),
	preload("res://sprites/number_large_7.png"),
	preload("res://sprites/number_large_8.png"),
	preload("res://sprites/number_large_9.png")
]

#最后得分
const sprite_mid_numbers = [
	preload("res://sprites/number_middle_0.png"),
	preload("res://sprites/number_middle_1.png"),
	preload("res://sprites/number_middle_2.png"),
	preload("res://sprites/number_middle_3.png"),
	preload("res://sprites/number_middle_4.png"),
	preload("res://sprites/number_middle_5.png"),
	preload("res://sprites/number_middle_6.png"),
	preload("res://sprites/number_middle_7.png"),
	preload("res://sprites/number_middle_8.png"),
	preload("res://sprites/number_middle_9.png")
]

#奖牌的图片
const spr_medal_bronze   = preload("res://sprites/medal_bronze.png")
const spr_medal_silver   = preload("res://sprites/medal_silver.png")
const spr_medal_gold     = preload("res://sprites/medal_gold.png")
const spr_medal_platinum = preload("res://sprites/medal_platinum.png")

var state=game.startGame	#默认游戏开始状态

var offsetNum=16	#摄像机偏移次数
var magnitude = 2  #偏移
var num=0

func _ready():
	randomize()
	
	game.connect("scoreChange",self,"_on_score_changed")
	
	$game/pipe.setRandomYpos()
	$game/pipe2.setRandomYpos()
	$game/pipe3.setRandomYpos()

	game.score=0
	$game/bird.connect("birdStateChange",self,"_on_bird_state_change")
	$game/Timer.connect("timeout",self,"_on_timeout") 
	$game/bird.setState(game.fly)


#游戏开始
func startGame()->void:
	$game/pipe.state=game.move
	$game/pipe2.state=game.move
	$game/pipe3.state=game.move
	$game/ground.state=game.fast
	$game/ground1.state=game.fast
#	$bird.setState(game.play)
	

#游戏结束
func gameOver()->void:
	#游戏结束
	if $game/ready.visible:
		$game/ready.hide()
	$game/score.visible=false
	$game/btnPause.visible=false
	state=game.endGame
	$game/pipe.setState(game.stop)
	$game/pipe2.setState(game.stop)
	$game/pipe3.setState(game.stop)
	$game/ground.setState(game.stop)
	$game/ground1.setState(game.stop)
	$game/bird.setState(game.dead)
	
	while num<offsetNum:		
		$game/camera.offset.x += rand_range(-magnitude,magnitude)
		$game/camera.offset.y+=rand_range(-magnitude,magnitude)
		num+=1
		magnitude-=0.07
		yield(get_tree(), "idle_frame")
	num=0
	magnitude=3
	$game/camera.offset.x=72
	$game/camera.offset.y=128
	showGameOverPanel()
	setFinalScore()


#碰到地面和水管
func _on_bird_state_change()->void:
	print('_on_bird_state_change')
	gameOver()
	

#分数变化
func _on_score_changed():
	game.score+=1
	#播放声音
	if AudioPlayer:
		AudioPlayer.playSfxPoint()
	
	#设置分数
	for child in $game/score.get_children():
		child.queue_free()
	
	for i in game.get_digits(game.score):
		var rect = TextureRect.new()
		rect.texture=sprite_numbers[i]
		$game/score.add_child(rect)

	
#设置最后的分数
func setFinalScore():
	for child in $game/gameOverPanel/panel/scoreContainer.get_children():
		child.queue_free()
	for i in game.get_digits(game.score):
		var rect = TextureRect.new()
		rect.texture=sprite_mid_numbers[i]
		$game/gameOverPanel/panel/scoreContainer.add_child(rect)
	#设置最高分
	if game.score>game.highScore:
		game.highScore=game.score
		$game/gameOverPanel/panel/newHighScore.show()
	
	for child in $game/gameOverPanel/panel/bestContainer.get_children():
		child.queue_free()
	for i in game.get_digits(game.highScore):
		var rect = TextureRect.new()
		rect.texture=sprite_mid_numbers[i]
		$game/gameOverPanel/panel/bestContainer.add_child(rect)
		
	#设置奖牌
	var texture
	if game.score>=game.MEDAL_BRONZE:
		texture = spr_medal_bronze
	if game.score>=game.MEDAL_SILVER:
		texture = spr_medal_silver
	if game.score>=game.MEDAL_GOLD:
		texture=spr_medal_gold
	if game.score>=game.MEDAL_PLATINUM:
		texture=spr_medal_platinum
	if texture:
		$game/gameOverPanel/panel/medal.texture=texture
		$game/gameOverPanel/panel/medal/spark.show()
	
#定时器时间到
func _on_timeout()->void:
	if state==game.startGame:
		$game/ready/ani.play("fade_out")
		startGame()
	
	

#继续游戏
func _on_btnResume_pressed():
	get_tree().paused=false
	$game/pausePanel.hide()


#返回开始界面
func _on_btnMenu_pressed():
	get_tree().paused=false
	game.changeScene(game.welcomeScene)


#暂停按钮
func _on_btnPause_pressed():
	#print("_on_btnPause_pressed")
	get_tree().paused=true
	$game/pausePanel.show()
	#showGameOverPanel()
	pass
	
#显示游戏结束界面
func showGameOverPanel():
	$game/gameOverPanel.show()
	$game/gameOverPanel/ani.play("idle")

#重新开始
func _on_btnRestart_pressed():
	game.changeScene(game.mainScene)


#游戏开始
func _on_tipBtn_pressed():
	$game/tipBtn.hide()
#	startGame()
	#$ready/ani.play("fade_in")
	$game/bird.setState(game.play)
	$game/Timer.start()
	
