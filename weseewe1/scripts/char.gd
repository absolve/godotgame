extends RigidBody2D


var size=Vector2(320,78)
var word_width=48

func _ready():
	friction=0

func setChar(word:String):
	if word=="w":
		$bg.region_rect=Rect2(10,0,48,78)
		$bg.flip_v=true
	elif word=='s':
		$bg.region_rect=Rect2(98,0,40,78)
	elif word=='e':
		$bg.region_rect=Rect2(55,0,42,78)
		$bg.flip_v=true
		$bg.flip_h=true
	
	

