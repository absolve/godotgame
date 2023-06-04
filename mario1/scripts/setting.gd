extends Control

var gameResolution:Vector2
var windowResolution:Vector2
var screenResolution:Vector2
var maxScale
var scale=1
var fullscreen=false
var borderless=false
onready var _fullscreen=$HBoxContainer/Panel/VBoxContainer/VBoxContainer/fullscreen
onready var _borderless=$HBoxContainer/Panel/VBoxContainer/VBoxContainer/borderless
onready var _master=$HBoxContainer/Panel2/VBoxContainer/VBoxContainer4/master
onready var _bg=$HBoxContainer/Panel2/VBoxContainer/VBoxContainer4/bg
onready var _sfx=$HBoxContainer/Panel2/VBoxContainer/VBoxContainer4/sfx
var beep=preload("res://sounds/coin.ogg")

func _ready():
	setResolution()
	_master.setName('Master')
	_bg.setName('bg')
	_sfx.setName('sfx')
	
	_master.sound.stream=beep
	_bg.sound.stream=beep
	_sfx.sound.stream=beep
	_master.slider.value=Game.config.Volume.Master*100
	_bg.slider.value=Game.config.Volume.Bg*100
	_sfx.slider.value=Game.config.Volume.Sfx*100
	_master.setVolume(Game.config.Volume.Master)
	_bg.setVolume(Game.config.Volume.Bg)
	_sfx.setVolume(Game.config.Volume.Sfx)
	if Game.config.Resolution.Fullscreen:
		setFullscreen(Game.config.Resolution.Fullscreen)
	else:	
#	setFullscreen(Game.config.Resolution.Fullscreen)
		setScale(Game.config.Resolution.Scale)
		setBorderless(Game.config.Resolution.Borderless)
	
	_master.slider.connect("value_changed",self,"_on_master_value_changed")
	_bg.slider.connect("value_changed",self,"_on_bg_value_changed")
	_sfx.slider.connect("value_changed",self,"_on_sfx_value_changed")
	
	pass

func setFullscreen(value:bool):
	fullscreen=value
	OS.window_fullscreen = value
	if value:
		scale=maxScale
	else:
		OS.center_window()
		scale=OS.window_size.x/gameResolution.x

func setBorderless(value:bool):
	borderless=value
	OS.window_borderless  = value
	
func setResolution():
	var rect=get_viewport().get_visible_rect()
	gameResolution=rect.size
	screenResolution=OS.get_screen_size(OS.current_screen)
	windowResolution=OS.window_size
	print('GameResolution',gameResolution)
	print('WindowResolution',windowResolution)
	print('ScreenResolution',screenResolution)
	maxScale=ceil(screenResolution.y/ gameResolution.y)
	print('MaxScale',maxScale)


func setScale(value):
	scale = clamp(value, 1, maxScale)
	if scale>=maxScale:
		OS.window_fullscreen = true
	else:
		OS.window_fullscreen = false	
		OS.window_size = gameResolution * scale
		OS.center_window()
	setResolution()

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if (event as InputEventKey).scancode==KEY_F11:
				scale-=0.5
				setScale(scale)
			elif (event as InputEventKey).scancode==KEY_F12:	
				scale+=0.5
				setScale(scale)
	


func _on_scaleDown_pressed():
	scale-=0.5
	setScale(scale)
	pass # Replace with function body.


func _on_ScaleUp_pressed():
	scale+=0.5
	setScale(scale)
	pass # Replace with function body.



func _on_fullscreen_pressed():
	setFullscreen(_fullscreen.pressed)
	pass # Replace with function body.


func _on_borderless_pressed():
	setBorderless(_borderless.pressed)
	pass # Replace with function body.

func _on_master_value_changed(value):
#	print(value)
	_master.setVolume(value/100)
	_master.sound.play()
	pass
	
func _on_bg_value_changed(value):	
	_bg.setVolume(value/100)
	_bg.sound.play()
	pass
	
func _on_sfx_value_changed(value):
	_sfx.setVolume(value/100)
	_sfx.sound.play()
	pass


func _on_save_pressed():
	Game.config.Volume.Master=_master.slider.value/100
	Game.config.Volume.Bg=_bg.slider.value/100
	Game.config.Volume.Sfx=_sfx.slider.value/100
	
	Game.config.Resolution.Scale=scale
	Game.config.Resolution.Fullscreen=fullscreen
	Game.config.Resolution.Borderless=borderless
	
	Game.saveConfigFile()
	


func _on_close_pressed():
	Game.emit_signal("btnClose")
