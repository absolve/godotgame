extends KinematicBody2D

#class_name player

var power=0	#子弹级别  0普通级别 1快速  2最大火力
var armor=1 #护甲  为0死亡
var dir=0 # 0上 1下 2左 3右
var bulletMax=1	#发射最大子弹数
var speed = 50
var vec=Vector2.ZERO
var state=Game.tank_state.START
var shootTime=0	
var shootDelay=0.5
var id=0	#0 就是玩家1p  1 2p
var level=0 #坦克的级别	0最小 1中等 2是大  3是最大

var keymap={"up":0,"down":0,"left":0,"right":0,'fire':0}
var bullets=[]
var size=28  	#大小
var bullet=preload("res://scenes/bullet.tscn")


func _ready():
	name='player'
	setKeyMap(1)
	add_to_group(Game.groups['player'])
	pass
	
func _physics_process(delta):
	#print("player _physics_process")
	if state==Game.tank_state.STOP:
		return
	
	if Input.is_key_pressed(keymap["up"]):
#		print("up")
		vec.y=-speed
		vec.x=0
		dir=0
		animation(dir,vec)	
	elif Input.is_key_pressed(keymap["down"]):
		vec.x=0
		vec.y=speed
		#vec = move_and_slide(vec,Vector2.UP)
		dir=1
		animation(dir,vec)	
	elif Input.is_key_pressed(keymap["left"]):
		vec.x=-speed
		vec.y=0
		#print("left")
		#vec = move_and_slide(vec,Vector2.UP)
	
		dir=2	
		animation(dir,vec)	
	elif Input.is_key_pressed(keymap["right"]):	
		vec.y=0
		vec.x=speed
		#vec = move_and_slide(vec,Vector2.UP)
		
		dir=3
		animation(dir,vec)	
	else:
		vec=Vector2.ZERO	
		dir=-1
		animation(dir,vec)	
	
	
	if vec!=Vector2.ZERO:
		vec = move_and_slide(vec,Vector2.UP)
		
	if Input.is_key_pressed(keymap["fire"]):
		print("fire")
		fire()
	pass


func animation(dir,vec):
	if dir==0:
		$ani.flip_v=false
		$ani.rotation_degrees=0
		pass
	elif dir==1:
		$ani.flip_v=true
		$ani.rotation_degrees=0
		pass
	elif dir==2:
		$ani.flip_v=false
		if $ani.rotation_degrees!=-90:
			$ani.rotation_degrees=-90
		pass
	elif dir==3:
		$ani.flip_v=false
		if $ani.rotation_degrees!=90:
			$ani.rotation_degrees=90
		pass	
	if level==0:
		if vec!=Vector2.ZERO:
			$ani.play("small_run")
		else:	
			$ani.play("small")
	elif level==1:
		if vec!=Vector2.ZERO:
			$ani.play("middle_run")
		else:
			$ani.play("middle")
	elif level==2:
		if vec!=Vector2.ZERO:
			$ani.play("big_run")
		else:
			$ani.play("big")
	elif level==3:
		if vec!=Vector2.ZERO:
			$ani.play("super_run")
		else:
			$ani.play("super")

#提升级别
func powerUp(isAddArmor:bool=false):
	if level<=3:
		if level==0:
			speed=80
		elif level==1:
			bulletMax=2
		level+=1
	if isAddArmor:
		if armor<=2:
			armor+=1
	
			
#被击中	
func hit():
	armor-=1
	if armor>=0:
		queue_free()
		Game.emit_signal("tankDestroy",id)
	if level==3:
		level-=1
		power-=1
	pass	

#开火
func fire():
	if OS.get_unix_time()-shootTime<shootDelay:
		return
	else:
		shootTime=OS.get_unix_time()
		
	var del=[]
	for i in bullets: #清理无效对象
		print(is_instance_valid(i))
		if not is_instance_valid(i):
			del.append(i)
	for i in del:
		bullets.remove(bullets.find(i))
	#print("-----",bullets)
	if bullets.size()<bulletMax:
		var temp=bullet.instance()
		temp.setType("player")
		temp.position=position
		#temp.power=2
		temp.setDir(dir)
		temp.playerID=id
		bullets.append(temp)
		Game.mainScene.add_child(temp)



func setKeyMap(playerId:int):
	if playerId==1:
		keymap["up"]=Game.player1["up"]
		keymap["down"]=Game.player1["down"]
		keymap["left"]=Game.player1["left"]
		keymap["right"]=Game.player1["right"]
		keymap["fire"]=Game.player1["fire"]
		
	pass
	
	
func get_class():
	return 'player'
