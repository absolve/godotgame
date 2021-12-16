extends "res://scripts/object.gd"

onready var flag=$flag
onready var lens=$len
var poleLen=10
var poleImg=preload("res://sprites/flag1.png")
var status=constants.empty
var speed=130

func _ready():
	addPoleLen()
	
	pass


#添加旗杆长度
func addPoleLen():
	for i in range(poleLen):
		var temp=Sprite.new()
		temp.texture=poleImg
		temp.position=Vector2(0,33+i*32)
		lens.add_child(temp)
	pass

func _process(delta):
	_update(delta)
	pass

func _update(delta):
	if status==constants.flagLanding:
		flag.position.y+=speed*delta
		if flag.position.y>=poleLen*32:
			status=constants.empty
			Game.emit_signal("flagEnd")
		pass
	pass

