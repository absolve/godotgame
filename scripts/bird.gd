extends RigidBody2D
#小鸟脚本的语法

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	pass

func _fixed_process(delta):
#	print("11")
	if rad2deg(get_rot())>30:
		set_rot(deg2rad(30))
	if get_linear_velocity().y>0:
		set_angular_velocity(1.5)
	
	
func _input(event):
	if event.type==InputEvent.KEY and event.is_pressed() and event.scancode==KEY_SPACE and not event.is_echo():
		flap()
	pass	
	
func flap():
	set_linear_velocity(Vector2(0,-150))	
	set_angular_velocity(-3)
	