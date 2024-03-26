extends Node2D


onready var overworld=$overworld
onready var overworldFast=$overworld_fast
onready var lowTime=$lowtime
onready var star=$star
onready var starFast=$star_fast
onready var konami=$konami
onready var brick=$brick
onready var brickHit=$brickhit
onready var coin=$coin
onready var item=$item
onready var item1up=$item1up
onready var mushroom=$mushroom
onready var boom=$boom
onready var shoot=$shoot
onready var stomp=$stomp
onready var big2small=$big2small
onready var score=$score
onready var gameover=$gameover
onready var death=$death
onready var levelend=$levelend
onready var underground=$underground
onready var undergroundFast=$underground_fast
onready var pipe=$pipe
onready var castle=$castle
onready var castleFast=$castle_fast
onready var bridgebreak=$bridgebreak
onready var bowserfall=$bowserfall
onready var castleend=$castleend
onready var underwater=$underwater
onready var underwater_fast=$underwater_fast
onready var pause=$pause
onready var finish=$finish

var bgm="overworld"	#背景音
var lastBgm=''
var isLowTime=false
var sfx=''#特效


func _ready():
	var overworld1=overworld.stream as AudioStreamOGGVorbis
	overworld1.set_loop(true)
	var overworldFast1=overworldFast.stream as AudioStreamOGGVorbis
	overworldFast1.set_loop(true)
	var underground1=underground.stream as AudioStreamOGGVorbis
	underground1.set_loop(true)
	var undergroundFast1=undergroundFast.stream as AudioStreamOGGVorbis
	undergroundFast1.set_loop(true)
	var  castle1=castle.stream as AudioStreamOGGVorbis
	castle1.set_loop(true)
	var castleFast1=castleFast.stream as AudioStreamOGGVorbis
	castleFast1.set_loop(true)
	var underwater1=underwater.stream as AudioStreamOGGVorbis
	underwater1.set_loop(true)
	


func playBgm():
	if bgm=="overworld":
		if isLowTime:
			overworldFast.play()
		else:	
			overworld.play()
	elif  bgm=='underground':
		if isLowTime:
			undergroundFast.play()
		else:
			underground.play()
	elif bgm=='castle':
		if isLowTime:
			castleFast.play()
		else:
			castle.play()
	elif bgm=='star':
		if isLowTime:
			starFast.play()
		else:
			star.play()
	elif bgm=='underwater':
		if isLowTime:
			underwater_fast.play()
		else:
			underwater.play()
	elif bgm=='levelend':
		levelend.play()
	elif bgm=='lowTime':
		if lowTime.playing:
			lowTime.stream_paused=false
		else:	
			lowTime.play()
	
func stopBgm():
	if bgm=="overworld":
		overworldFast.stop()
		overworld.stop()
	elif bgm=='underground':
		undergroundFast.stop()
		underground.stop()
	elif bgm=='castle':
		castleFast.stop()
		castle.stop()
	elif bgm=='star':
		starFast.stop()
		star.stop()
	elif bgm=='underwater':
		underwater_fast.stop()
		underwater.stop()
	elif bgm=='levelend':
		levelend.stop()
	elif bgm=='lowTime':
		lowTime.stream_paused=true

	
func changeBgm(newBgm):
	stopBgm()
	lastBgm=bgm
	bgm=newBgm
	playBgm()

func playLastBgm():
	stopBgm()
	bgm=lastBgm
	playBgm()

#func stopSpecialBgm():
#	starFast.stop()
#	star.stop()
	
func playKonamiMusic():
	konami.play()

func playLowTime():
	changeBgm('lowTime')
#	stopBgm()
#	bgm='lowTime'
#	playBgm()
#	lowTime.play()
#	yield(lowTime,"finished")
	
	
func playBrickBreak():
	brick.play()

func playBrickHit():
	brickHit.play()

func playCoin():
	coin.play()

func playItem():
	item.play()

func playItem1up():
	item1up.play()

func playMushroom():
	mushroom.play()

func playBoom():
	boom.play()

func playShoot():
	shoot.play()

func playStomp():
	stomp.play()

func playBig2small():
	big2small.play()

func playScore():
	score.play()

func playGameover():
	gameover.play()

func playDeath():
	death.play()

func playLevelend():
	levelend.play()

func playPipe():
	pipe.play()

func playBridgeBreak():
	bridgebreak.play()
	
func playbowserFall():
	bowserfall.play()

func playCastleEnd():
	castleend.play()
	
func playPause():
	pause.play()

func playFinish():
	finish.play()
	

func _on_lowtime_finished():
	isLowTime=true
	playLastBgm()
