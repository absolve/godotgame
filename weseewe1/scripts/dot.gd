extends RigidBody2D





func _ready():
	friction=0
	pass # Replace with function body.


#设置颜色
func setColor(color:String):
	$top.modulate=Color(color)
	pass
