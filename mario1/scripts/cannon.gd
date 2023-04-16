extends "res://scripts/object.gd"

var status=constants.cannonFire
var spriteIndex=0
var timer=0
var delay=120
var camera
var winWidth
onready var ani=$ani

var bullet=preload("res://scenes/bulletBill.tscn")

func _ready():
#	active=false
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	type=constants.cannon
	animation('cannon')
	camera=Game.getCamera()
	winWidth=get_viewport_rect().size.x
#	print(camera)
#	debug=true
#	status=constants.stop
	


func _update(delta):
	if status==constants.cannonFire:
		timer+=1
		if timer>delay:
			timer=0
			delay=120+randi()%290
			if position.x>camera.position.x && position.x<camera.position.x+winWidth:
				if Game.getMario().size()>0:
					var m= Game.getMario()[0]
					if is_instance_valid(m):
						var temp=bullet.instance()
						temp.position.x=position.x
						temp.position.y=position.y
						if m.position.x>position.x:
							temp.dir=constants.right
						else:
							temp.dir=constants.left
						Game.addObj(temp)
	pass

	
func pause():
	status=constants.stop
	

func resume():
	status=constants.cannonFire

func animation(type):
	if type=='cannon':
		if spriteIndex==0:
			ani.play("0")
		elif spriteIndex==1:
			ani.play("1")	
		elif spriteIndex==2:
			ani.play("2")	
		elif spriteIndex==3:
			ani.play("3")	
	pass

func getLeft()->float:
	return position.x-rect.size.x/2-1

func getRight()->float:
	return position.x+rect.size.x/2+1
