extends "res://scripts/object.gd"

onready var ani=$ani
onready var flySound=$fly

var speed=120
var dir=constants.left
var status=constants.flying
var target=0

func _ready():
#	debug=true
	type=constants.fire
	rect=Rect2(Vector2(-16,-8),Vector2(32,16))
	var flySound1=flySound.stream as AudioStreamOGGVorbis
	flySound1.set_loop(false)
	flySound.play()
	ani.play("default")
	if dir==constants.right:
		ani.flip_h=true
	pass

func _update(delta):
	if status==constants.flying:
		if dir==constants.left:
			xVel=-speed
		else:
			xVel=speed	
		if position.y<target:
			yVel=50
		else:
			yVel=0			
	pass

func pause():
	status=constants.stop
	active=false
	ani.stop()

func resume():
	status=constants.flying
	active=true
	ani.play()
