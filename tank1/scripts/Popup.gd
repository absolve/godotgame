extends Popup

var NewEvent:InputEvent
signal finish


func _ready():
#	get_tree().set_input_as_handled()
	popup_exclusive = true
	set_process_input(false)
	connect("about_to_show", self, "receive_input")
	
	pass


func receive_input()->void:
	print("receive_input")
	set_process_input(true)
	get_focus_owner().release_focus()
#	popup_centered()

func _input(event)->void:
	if event is InputEventMouse:
		pass	
	elif event is InputEventKey || event is InputEventJoypadButton || event is InputEventJoypadMotion:
		if !event.is_pressed():
			return	
		NewEvent = event
		emit_signal("finish")
		set_process_input(false)
		visible = false

#func _unhandled_input(event):
#   print("There was an unhandled event!!!")

func _on_cancel_pressed():
	print('_on_cancel_pressed')
	NewEvent = null
	emit_signal("finish")
	set_process_input(false)
	visible = false
	
