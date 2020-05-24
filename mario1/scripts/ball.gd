extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 200
var vel = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	vel = (get_global_mouse_position() - position).normalized() * speed
	pass # Replace with function body.


func _physics_process(delta):
	
	vel=move_and_slide(vel)
	
	
	
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass # Replace with function body.
