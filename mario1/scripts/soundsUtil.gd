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

var bgm="overworld"
var lastBgm=''
var isLowTime=false

func _ready():
	var lowTime1=lowTime.stream as AudioStreamOGGVorbis
	lowTime1.set_loop(false)
	
	var konami1=konami.stream as AudioStreamOGGVorbis
	konami1.set_loop(false)
	
	var brick1=brick.stream as AudioStreamOGGVorbis
	brick1.set_loop(false)
	
	var brickHit1=brickHit.stream as AudioStreamOGGVorbis
	brickHit1.set_loop(false)
	
	var coin1=coin.stream as AudioStreamOGGVorbis
	coin1.set_loop(false)
	
	var item1=item.stream as AudioStreamOGGVorbis
	item1.set_loop(false)
	
	var item1up1=item1up.stream as AudioStreamOGGVorbis
	item1up1.set_loop(false)
	
	var mushroom1=mushroom.stream as AudioStreamOGGVorbis
	mushroom1.set_loop(false)
	
	var boom1=boom.stream as AudioStreamOGGVorbis
	boom1.set_loop(false)
	
	var shoot1=shoot.stream as AudioStreamOGGVorbis
	shoot1.set_loop(false)
	
	var stomp1=stomp.stream as AudioStreamOGGVorbis
	stomp1.set_loop(false)
	
	var big2small1=big2small.stream as AudioStreamOGGVorbis
	big2small1.set_loop(false)
	
	var score1=score.stream as AudioStreamOGGVorbis
	score1.set_loop(false)
	
	var gameover1=gameover.stream as AudioStreamOGGVorbis
	gameover1.set_loop(false)
	
	var death1=death.stream as AudioStreamOGGVorbis
	death1.set_loop(false)
	
	var levelend1=levelend.stream as AudioStreamOGGVorbis
	levelend1.set_loop(false)
	
	var pipe1=pipe.stream as AudioStreamOGGVorbis
	pipe1.set_loop(false)
	
	var bridgebreak1=bridgebreak.stream as AudioStreamOGGVorbis
	bridgebreak1.set_loop(false)
	
	var bowserfall1 = bowserfall.stream as AudioStreamOGGVorbis
	bowserfall1.set_loop(false)
	
	var castleend1=castleend.stream as AudioStreamOGGVorbis
	castleend1.set_loop(false)
	
	var pause1=pause.stream as AudioStreamOGGVorbis
	pause1.set_loop(false)

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

#func playSpecialBgm():
#	if isLowTime:
#		starFast.play()
#	else:
#		star.play()

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
	stopBgm()
	lowTime.play()
	yield(lowTime,"finished")
	isLowTime=true
	playBgm()
	
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
