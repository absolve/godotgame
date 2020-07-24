extends KinematicBody2D


export var dir=0 # 0上 1下 2左 3右
var speed=80
var type=Game.bulletType.players
var power=1  #1是基本火力 2是最强火力

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
		pass
	elif type==Game.bulletType.enemy:
		#layers = 1+4+8
		pass
	print(collision_mask)	

func setFastSpeed():
	speed=110
	pass

func _physics_process(delta):
	
	var collisions= move_and_collide(vec*delta)
	if collisions:
	#	print(collisions)
		print(collisions.get_class())
		print(collisions.collider.get_class())
		if collisions.collider.get_class()=='player':
			queue_free()
			var ex =Game.explode.instance()
			ex.position=position
			Game.mainScene.add_child(ex)
			pass
		elif collisions.collider.get_class()=='enemy':
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
		
	pass

func get_class():
	return 'bullet'

func getType():
	return type

func destroy():
	queue_free()

func addExplode():
	pass

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass # Replace with function body.
