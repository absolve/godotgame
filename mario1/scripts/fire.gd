extends "res://scripts/object.gd"

onready var ani=$ani
onready var flySound=$fly

var speed=60
var dir=constants.left
var status=constants.flying


func _ready():
	debug=true
	type=constants.fire
	rect=Rect2(Vector2(-16,-8),Vector2(32,16))
	var flySound1=flySound.stream as AudioStreamOGGVorbis
	flySound1.set_loop(false)
	flySound.play()
	pass

func _update(delta):
	if status==constants.flying:
		if dir==constants.left:
			xVel=-speed
	pass
