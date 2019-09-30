extends Area2D
#每个水管的分数

func _ready():
	connect("body_enter", self, "_on_body_enter")
	pass

func _on_body_enter(other_body):
	if other_body.is_in_group(game.GROUP_BIRDS):
		game.addScore()
	#		audio_player.play("sfx_point")
