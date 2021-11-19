extends "res://scripts/object.gd"

var status=constants.spin
onready var ani=$ani

func _ready():
	gravity=constants.boxGravity
	debug=true
	yVel=-600
	ani.play("default")
	pass

func _update(delta):
	if status==constants.spin:
		spinning(delta)
		pass
		
func spinning(delta):
	yVel+=gravity*delta
	position.y+=yVel*delta
	if yVel>400:
		queue_free()
		var score=Game.score.instance()
		score.rect_position=position
		score.score=200
		Game.addObj2Other(score)
	pass		
