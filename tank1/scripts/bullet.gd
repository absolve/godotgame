extends KinematicBody2D


export var dir=0 # 0上 1下 2左 3右
var speed=80
var type=Game.bulletType.players
var playerID  #玩家id
var power=1  #1是基本火力 2是最强火力
#var winSize=Vector2(480,416)	#屏幕大小
var size=Vector2(6,8)	#图片大小
var vec= Vector2.ZERO


func _ready():
	add_to_group(Game.groups['bullet'])
	if dir==0:
		$Sprite.flip_v=true
		vec.x=0
		vec.y=-speed
	elif dir==1:
		vec.x=0
		vec.y=speed
	elif dir==2:
		$shape.rotation_degrees=90
		$shape.rotation_degrees=90
		vec.x=-speed
		vec.y=0
	elif dir==3:
		$shape.rotation_degrees=-90
		$shape.rotation_degrees=-90
		vec.x=speed
		vec.y=0
	if type==Game.bulletType.players:
		#layers = 2+4+8
		collision_mask=2+4+32
		
	elif type==Game.bulletType.enemy:
		#layers = 1+4+8
		collision_mask=1+4+32
		
	print(collision_mask)	

func setFastSpeed():
	speed=110
	pass

func _physics_process(delta):
	var collisions= move_and_collide(vec*delta)
	if collisions:
		if collisions.collider.get_class()=='player':		
			if type==Game.bulletType.enemy:
				pass
			elif type==	Game.bulletType.players:
				queue_free()
				pass
		elif collisions.collider.get_class()=='enemy':
			if type==Game.bulletType.enemy:
				add_collision_exception_with(collisions.collider)
			elif type==Game.bulletType.players:
				
				pass
			pass
		elif collisions.collider.get_class()=='bullet':
			if collisions.collider.has_method("getType"):
				if collisions.collider.getType()!=type:
					print("type")
					destroy()
				else:
					add_collision_exception_with(collisions.collider)
			else:
				add_collision_exception_with(collisions.collider)
			pass
		elif collisions.collider.get_class()=='base':
			if collisions.collider.has_method('setBaseDestroyed'):
				addExplode(false)
				destroy()
				collisions.collider.setBaseDestroyed()
				
			
	if dir==0:
		if position.y-size.y/2<=0:
			addExplode(false)
			destroy()
	elif dir ==1:
		if position.y-size.y/2>=Game.winSize.y:
			addExplode(false)
			destroy()
	elif dir==2:
		if position.x-size.x/2<=0:
			addExplode(false)
			destroy()
	elif dir==3:
		if position.x-size.x/2>=Game.winSize.y:
			addExplode(false)
			destroy()
		
	

func get_class():
	return 'bullet'

func getType():
	return type

func setType(type:String):
	if type=="player":
		self.type=Game.bulletType.players
	elif type=="enemy":
		self.type=Game.bulletType.enemy

func setDir(dir):
	self.dir=dir

func destroy():
	queue_free()

func addExplode(big):
	var temp=Game.explode.instance()
	if big:
		temp.big=true
	temp.position=position
	Game.mainScene.add_child(temp)
	
	


