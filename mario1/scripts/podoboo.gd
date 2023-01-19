extends "res://scripts/enemy.gd"

onready var ani=$ani
var preStatus

func _ready():
	type=constants.podoboo
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	maxYVel=constants.enemyMaxVel #y轴最大速度
	gravity=constants.enemyGravity
	
	pass


func _update(delta):
	
	pass
	
func animation(type):
	
	pass	
