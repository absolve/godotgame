extends TextureButton

signal _button_down
signal _button_up
signal _pressed


func _ready():
	pass


func _on_TextureButton_button_down():
	rect_position.x -= 5
	rect_position.y += 5
	modulate = Color(0.8, 0.8, 0.8)
	emit_signal("_button_down")


func _on_TextureButton_button_up():
	rect_position.x += 5
	rect_position.y -= 5
	modulate = Color(1, 1, 1)
	emit_signal("_button_up")


func _on_TextureButton_pressed():
	emit_signal("_pressed")
