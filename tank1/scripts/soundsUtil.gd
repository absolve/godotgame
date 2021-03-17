extends Node2D

onready var gameover=$gameover

func _ready():
	var point = $point.stream as AudioStreamOGGVorbis
	point.set_loop(false)
	var power1= $power1.stream as AudioStreamOGGVorbis
	power1.set_loop(false)
	var power2 = $power2.stream as AudioStreamOGGVorbis
	power2.set_loop(false)
	var explosion1=$explosion1.stream as AudioStreamOGGVorbis
	explosion1.set_loop(false)
	var explosion2=$explosion2.stream as AudioStreamOGGVorbis
	explosion2.set_loop(false)
	var gameover=$gameover.stream as AudioStreamOGGVorbis
	gameover.set_loop(false)
	var bomb = $bomb.stream as AudioStreamOGGVorbis
	bomb.set_loop(false)
	var bonus=$bonus.stream as AudioStreamOGGVorbis
	bonus.set_loop(false)
	var pause=$pause.stream as AudioStreamOGGVorbis
	pause.set_loop(false)
	var music=$music.stream as AudioStreamOGGVorbis
	music.set_loop(false)
	var life=$life.stream as AudioStreamOGGVorbis
	life.set_loop(false)
	var eat =$eat.stream as AudioStreamOGGVorbis
	eat.set_loop(false)
	var bullet=$bullet.stream as AudioStreamOGGVorbis
	bullet.set_loop(false)
	var award=$award.stream as AudioStreamOGGVorbis
	award.set_loop(false)
	pass

#统计的时候
func playPoint():
	#$point.autoplay=false
	#$point.stream.loop=false
	if !$point.playing:
		$point.play()
	pass

func playGameOver():
	gameover.play()
	pass

func playPause():
	$pause.play()

func playMusic():
	$music.play()

func playBouns():
	$bonus.play()

func playLife():
	$life.play()

func playEat():
	$eat.play()

func playBomb():
	$bomb.play()

func playBullet():
	$bullet.play()

func playBaseDestroy():
	$explosion2.play()

func playaward():
	$award.play()

#敌人被摧毁
func playEnemyDestroy():
	$explosion1.play()

func _on_Button_pressed():
	playPoint()
	pass # Replace with function body.
