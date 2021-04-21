extends Node2D

var select=false

func _ready():
	pass

func playIn():
	$ani.play("in")
	
func playOut():
	$ani.play("out")

func setLevel(name:String):
	$name.set_text("stage %s"%name)
	pass

func setLevelName(name):
	$name.text=name

func _input(event):	
	if !select:
		return
	if !Game.canSelectLevel:
		return
	if event is InputEventKey:
		if event.is_pressed():
			if (event as InputEventKey).scancode==KEY_ENTER:	
				Game.canSelectLevel=false
				get_tree().change_scene(Game._mainScene)
				playOut()
				SoundsUtil.playMusic()
				yield($ani,"animation_finished")
				select=false	
				pass
			elif (event as InputEventKey).scancode==KEY_DOWN:	
				if Game.level <Game.mapNum-1:
					Game.level+=1
					setLevel(str(Game.level+1))
				pass
			elif (event as InputEventKey).scancode==KEY_UP:	
				if Game.level >0:
					Game.level-=1	
					setLevel(str(Game.level+1))
				pass
	pass
