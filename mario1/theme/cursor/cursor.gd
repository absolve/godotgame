extends Node



var couror=load("res://theme/cursor/cursor.png")
var beam=load("res://theme/cursor/cursor1.png")

func _ready():
	Input.set_custom_mouse_cursor(couror)
	Input.set_custom_mouse_cursor(beam,Input.CURSOR_IBEAM)

