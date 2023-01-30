extends "res://scripts/object.gd"

var status=constants.cannonFire
var spriteIndex=0
var timer=0
var delay=120
var camera
onready var ani=$ani

var bullet=preload("res://scenes/bulletBill.tscn")

func _ready():
#	active=false
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	type=constants.cannon
	animation('cannon')
	camera=Game.getCamera()
	print(camera)
	debug=true
	pass


func _update(delta):
	if status==constants.cannonFire:
		timer+=1
		if timer>delay:
			timer=0
			delay=120+randi()%290
			if position.x>camera.position.x && position.x<camera.get_camera_screen_center().x*2:
				if Game.getMario().size()>0:
					var m= Game.getMario()[0]
					var temp=bullet.instance()
					temp.position.x=position.x
					temp.position.y=position.y
					if m.position.x>position.x:
						temp.dir=constants.right
					else:
						temp.dir=constants.left
					Game.addObj(temp)
				print('fire')	
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

#func floorCollide(obj):
#	return false
#
#func ceilcollide(obj):
#	return false	
