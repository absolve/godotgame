extends Button

var drag=false
var temp=Vector2.ZERO

func _ready():
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and  event.pressed:
			if get_rect().has_point(get_viewport().get_mouse_position()):
				drag=true
				temp=get_viewport().get_mouse_position()
#			temp=get_viewport().get_mouse_position()
			pass
		else:
			drag=false
		pass
	elif event is InputEventMouseMotion:
		if drag:
			var pos=get_viewport().get_mouse_position()	
			self.rect_position+=pos-temp
			temp=pos
			pass
	pass

