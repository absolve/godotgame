extends RigidBody2D




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


#设置颜色
func setColor(color:String):
	$top.modulate=Color(color)
	pass
