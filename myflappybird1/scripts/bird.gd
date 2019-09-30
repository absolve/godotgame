extends RigidBody2D
#小鸟脚本的语法

const state_idle=0 #初始化的状态
const state_play=1 #飞行的状态
const state_hit=2  #击中的状态

#信号
signal state_changed
#当前状态
var prev_state=0 

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	connect("body_enter",self,"_on_body_enter")
	#添加到一个组里面
	add_to_group(game.GROUP_BIRDS)
	#print("22222")
	#设置状态
	set_state(state_idle)
	
	pass

func _fixed_process(delta):
#	print("11")
	if prev_state==state_play:
		if rad2deg(get_rot())>30:
			set_rot(deg2rad(30))
			set_angular_velocity(0)
		if get_linear_velocity().y>0:
			set_angular_velocity(1.5)
	elif prev_state==state_idle:
		
		pass
	elif prev_state==state_hit:
		
		pass		
	
#获取当前状态
func get_state():
	return prev_state
		
#设置状态
func set_state(new_state):
	prev_state = new_state
	if prev_state==state_idle:
		get_node("anim").play("idle")
		set_gravity_scale(0)
	elif prev_state==state_play:
		get_node("anim").play("fly")
		set_gravity_scale(5)
		#set_linear_velocity(Vector2(0,-150))
		flap()
	elif prev_state==state_hit:
		get_node("anim").play("empty")
		set_linear_velocity(Vector2(0, 0))
		set_angular_velocity(0.5)
	
#输入事件
func _input(event):
	if prev_state==state_play:
		if event.type==InputEvent.KEY and event.is_pressed() and event.scancode==KEY_SPACE and not event.is_echo():
			flap()
	else:
		pass	
	
	
func flap():
	audio_player.play("sfx_wing")
	set_linear_velocity(Vector2(0,-150))	
	set_angular_velocity(-3)
	
func _on_body_enter(other_body):
	if other_body.is_in_group(game.GROUP_PIPES):
		if prev_state==state_play:
			audio_player.play("sfx_hit")
			audio_player.play("sfx_die")
			prev_state = state_hit
			var other_body = get_colliding_bodies()[0]
			add_collision_exception_with(other_body)
			set_state(state_hit)
			emit_signal("state_changed",self)
		#print("水管")
	elif other_body.is_in_group(game.GROUP_GROUNDS):
		if prev_state==state_play:
			prev_state = state_hit
			audio_player.play("sfx_hit")
			set_state(state_hit)
			emit_signal("state_changed",self)
		print("地面")
	pass
