extends Node2D

#图片
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
const spr_medal_bronze   = preload("res://sprites/medal_bronze.png"  )
const spr_medal_silver   = preload("res://sprites/medal_silver.png"  )
const spr_medal_gold     = preload("res://sprites/medal_gold.png"    )
const spr_medal_platinum = preload("res://sprites/medal_platinum.png")



# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	#$pipe.position.x=game.winWidth+$pipe.PIPE_WIDTH
	#$ground1.position.x=game.winWidth
	$pipe.connect("scoreChange",self,"_on_score_changed")
	
	$pipe.setRandomYpos()
	$pipe2.setRandomYpos()
	$pipe3.setRandomYpos()

	game.score=0
	$bird.connect("birdStateChange",self,"_on_bird_state_change")

#游戏开始
func startGame()->void:
	$pipe.state=game.move
	$pipe2.state=game.move
	$pipe3.state=game.move
	$ground.state=game.fast
	$ground1.state=game.fast
	$bird.setState(game.play)
	

#游戏结束
func gameOver()->void:
	#游戏结束
	$pipe.setState(game.stop)
	$pipe2.setState(game.stop)
	$pipe3.setState(game.stop)
	$ground.setState(game.stop)
	$ground1.setState(game.stop)
	$bird.setState(game.dead)
	showGameOverPanel()
	setFinalSorce()	


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
	for child in $score.get_children():
		child.queue_free()
	
	for i in game.get_digits(game.score):
		var rect = TextureRect.new()
		rect.texture=sprite_numbers[i]
		$score.add_child(rect)

	
#设置最后的分数
func setFinalSorce():	
	for child in $gameOverPanel/panel/scoreContainer.get_children():
		child.queue_free()
	for i in game.get_digits(game.score):
		var rect = TextureRect.new()
		rect.texture=sprite_mid_numbers[i]
		$gameOverPanel/panel/scoreContainer.add_child(rect)
	#设置最高分
	if game.score>game.highScore:
		game.highScore=game.score
		$gameOverPanel/panel/newHighScore.show()
	
	for child in $gameOverPanel/panel/bestContainer.get_children():
		child.queue_free()
	for i in game.get_digits(game.highScore):
		var rect = TextureRect.new()
		rect.texture=sprite_mid_numbers[i]
		$gameOverPanel/panel/bestContainer.add_child(rect)
		
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
		$gameOverPanel/panel/medal.texture=texture
	
	


#继续游戏
func _on_btnResume_pressed():
	get_tree().paused=false
	$pausePanel.hide()
	pass # Replace with function body.

#返回开始界面
func _on_btnMenu_pressed():
	get_tree().paused=false
	game.changeScene(game.welcomeScene)


#暂停按钮
func _on_btnPause_pressed():
	print("_on_btnPause_pressed")
	get_tree().paused=true
	$pausePanel.show()
	#showGameOverPanel()
	pass
	
#显示游戏结束界面
func showGameOverPanel():
	$gameOverPanel.show()
	$gameOverPanel/ani.play("idle")

#重新开始
func _on_btnRestart_pressed():
	game.changeScene(game.mainScene)
	pass # Replace with function body.


#游戏开始
func _on_tipBtn_pressed():
	$tipBtn.hide()
	startGame()
	pass # Replace with function body.
