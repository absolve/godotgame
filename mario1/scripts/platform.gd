extends 'res://scripts/object.gd'

var status=constants.moveDown
onready var ani=$ani
onready var list=$len
var speed=300
var lens=2
var platformImg=preload("res://sprites/platform.png")
var winHeight

func _ready():
	winHeight=ProjectSettings.get_setting("display/window/size/height")
	type=constants.platform
	debug=true
	if status==constants.moveDown:
		yVel=-speed
	elif status==constants.moveUp:	
		yVel=speed
	rect=Rect2(Vector2(0,0),Vector2(32*lens,16))
		
	for i in range(lens):
		var temp=Sprite.new()
		temp.texture=platformImg
		temp.centered=false
		temp.position=Vector2(i*32,0)
		list.add_child(temp)
		pass
		
	pass

func _update(delta):
	if status==constants.moveDown || status==constants.moveUp:
		position.y+=yVel*delta
		if position.y>winHeight&&status==constants.moveDown:
			position.y=-16
	pass
