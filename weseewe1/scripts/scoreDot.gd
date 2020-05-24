extends RigidBody2D



func _ready():
	pass 

#设置颜色
func setColor(color:String):
	$ball.modulate=Color(color)
	

