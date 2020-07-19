extends KinematicBody2D


var dir=0 # 0上 1下 2左 3右
var speed=80
var type=Game.bulletType.player

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
	

func setFastSpeed():
	speed=110
	pass

func _physics_process(delta):
	
	var collisions= move_and_collide(vec*delta)
	if collisions:
		print(collisions)
		print(collisions.get_class())
		print(collisions.collider.get_class())
		if collisions.collider.get_class()=='player':
			queue_free()
			var ex =Game.explode.instance()
			ex.position=position
			Game.mainRoot.add_child(ex)
			pass
		else:
			pass
		
		
	pass


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass # Replace with function body.
