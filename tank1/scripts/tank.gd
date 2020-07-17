extends KinematicBody2D


var power=0	# 0 普通级别
var armor=1 #护甲  为0死亡
var dir=0 # 0上 1下 2左 3右
var bulletMax=1
var speed = 50
var vec=Vector2.ZERO
var state=Game.tank_state.START

var keymap={"up":0,"down":0,"left":0,"right":0,'fire':0}
var bullets=[]

func _ready():
	setKeyMap(1)
	pass
	
func _physics_process(delta):
	
	if state==Game.tank_state.STOP:
		return
	
	if Input.is_key_pressed(keymap["up"]):
		print("up")
		vec.y=-speed
		vec.x=0
		vec = move_and_slide(vec,Vector2.UP)
		$ani.flip_v=false
		$ani.rotation_degrees=0
		dir=0
		$ani.play("small_run")
	elif Input.is_key_pressed(keymap["down"]):
		vec.x=0
		vec.y=speed
		vec = move_and_slide(vec,Vector2.UP)
		print("down")
		$ani.flip_v=true
		$ani.rotation_degrees=0
		dir=1
		$ani.play("small_run")
	elif Input.is_key_pressed(keymap["left"]):
		vec.x=-speed
		vec.y=0
		vec = move_and_slide(vec,Vector2.UP)
		$ani.flip_v=false
		if $ani.rotation_degrees!=-90:
			$ani.rotation_degrees=-90
		dir=2	
		$ani.play("small_run")
	elif Input.is_key_pressed(keymap["right"]):	
		vec.y=0
		vec.x=speed
		vec = move_and_slide(vec,Vector2.UP)
		$ani.flip_v=false
		if $ani.rotation_degrees!=90:
			$ani.rotation_degrees=90
		dir=3
		$ani.play("small_run")
	else:
		vec=Vector2.ZERO
		
		$ani.play("small")
		
	
		
	if Input.is_key_pressed(keymap["fire"]):
		print("fire")
	
	pass


func animation(dir):
	if dir==0:
		pass
	elif dir==1:
		pass
	elif dir==2:
		pass
	elif dir==3:
		pass		
	
	pass


func fire():
	pass


func setKeyMap(playerId:int):
	if playerId==1:
		keymap["up"]=Game.player1["up"]
		keymap["down"]=Game.player1["down"]
		keymap["left"]=Game.player1["left"]
		keymap["right"]=Game.player1["right"]
		keymap["fire"]=Game.player1["fire"]
		
	pass
