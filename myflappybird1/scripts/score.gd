extends HBoxContainer

const sprite_numbers = [
	preload("res://sprites/number_large_0.png"),
	preload("res://sprites/number_large_1.png"),
	preload("res://sprites/number_large_2.png"),
	preload("res://sprites/number_large_3.png"),
	preload("res://sprites/number_large_4.png"),
	preload("res://sprites/number_large_5.png"),
	preload("res://sprites/number_large_6.png"),
	preload("res://sprites/number_large_7.png"),
	preload("res://sprites/number_large_8.png"),
	preload("res://sprites/number_large_9.png")
]



func _ready():
	game.connect("score_current_changed", self, "_on_score_current_changed")
	
	var bird = game.get_main_node().get_node("bird")
	if bird:
		bird.connect("state_changed", self, "_on_bird_state_changed")

func _on_bird_state_changed(bird):
	if bird.get_state()==2:
		hide()


func _on_score_current_changed():
	set_number(game.score_current)
	
	
func set_number(number):
	for child in get_children():
		child.queue_free()
	
	for digit in game.get_digits(number):
		var texture_frame = TextureFrame.new()
		texture_frame.set_texture(sprite_numbers[digit])
		add_child(texture_frame)
	pass	

