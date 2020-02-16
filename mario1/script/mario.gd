extends KinematicBody2D


var speed = 120  #移动速度
var jump_speed = 800 #跳跃
var gravity=1500
var velocity = Vector2.ZERO
var friction = 0.1
var acceleration = 0.5
var faceRight=true
var maxSpeed=180	#最大速度
var shapeSize=Vector2(30,32)
var shapeSizelvup=Vector2(30,64)

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	var input_dir = 0
	if Input.is_action_pressed("ui_right"):
		input_dir += 1
		faceRight=true
	if Input.is_action_pressed("ui_left"):
		input_dir -= 1
		faceRight=false

	$ani.flip_h=!faceRight
	
	if input_dir != 0:
		velocity.x = lerp(velocity.x, input_dir * speed, acceleration)
		$ani.play("run_small")
	else:
		velocity.x = lerp(velocity.x, 0, friction)
		$ani.play("idle_small")
		
	velocity = move_and_slide(velocity, Vector2.UP)


