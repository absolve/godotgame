extends Node2D


#var nodes
#var obj=[]
#var pacman=preload("res://scenes/pacman.tscn")
#var ghost=preload("res://scenes/ghost.tscn")
var pos=Vector3(312,367,0)	#选择1p 2p 时的y坐标
var index=0

onready var indicator=$indicator


func _ready():

	pass


func _process(delta):
#	update()
#	for i in obj:
#
#		i._update(delta)
#
	pass


func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if (event as InputEventKey).scancode==KEY_DOWN:
				if index<3:
					index+=1
					setMode(index)
				pass
			elif (event as InputEventKey).scancode==KEY_UP:
				if index>0:
					index-=1
					setMode(index)
				pass
			elif (event as InputEventKey).scancode==KEY_ENTER:
				
				pass		
	pass



func setMode(index):
	if index==0:
		indicator.position.y=pos.x
	elif index==1:
		indicator.position.y=pos.y
	elif index==2:
		indicator.position.y=pos.z
	pass
	
	
func _draw():

	pass
