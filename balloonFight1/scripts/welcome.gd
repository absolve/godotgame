extends Node2D


var mode=0 #0单人模式  1双人模式 
var pos=Vector3(295,324,354)
var index=0
onready var _ani=$ani

func _ready():
	pass # Replace with function body.


func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if (event as InputEventKey).scancode==KEY_DOWN:		
				if index<2:
					index+=1
					setMode(index)
			elif (event as InputEventKey).scancode==KEY_UP:
				if index>0:
					index-=1
					setMode(index)
			elif (event as InputEventKey).scancode==KEY_ENTER:	
				pass

func setMode(index):
	print(index)
	if index==0:
		_ani.position.y=pos.x
		mode=1
	elif index==1:
		_ani.position.y=pos.y
		mode=2	
	elif index==2:
		_ani.position.y=pos.z
		mode=3
