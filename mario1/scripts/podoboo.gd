extends "res://scripts/enemy.gd"

onready var ani=$ani
var preStatus
var ySpeed=600
var timer=0
var delay=120  #调出屏幕外的延迟
var height

func _ready():
	type=constants.podoboo
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	maxYVel=constants.enemyMaxVel #y轴最大速度
	gravity=constants.podobooGravity
	status=constants.upward
	height=get_viewport_rect().size.y
	print(height)
	position.y=height+getSizeY()/2
	pass


func _update(delta):
	if status==constants.upward:
		
		if yVel>0:
			animation('down')
		
		if yVel>0 && getTop()>height:
			status=constants.podobooIdle
			yVel=0
			timer=0
		pass
	elif status==constants.podobooIdle:
		timer+=1
		if timer>delay:
			status=constants.upward
			yVel=-ySpeed
			position.y=height+getSizeY()/2
			animation('up')
	
	
func pause():
	preStatus=status
	status=constants.stop

func resume():
	status=preStatus
	
func animation(type):
	if type=='up':
		ani.play("fly")
		ani.flip_v=false
	elif type=='down':
		ani.play("fly")
		ani.flip_v=true	
	pass	
