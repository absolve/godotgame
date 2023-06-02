extends VBoxContainer

export var busName='Master'
export var volume:float=0.0 

onready var slider=$HSlider
onready var label=$Label
onready var sound=$AudioStreamPlayer

func _ready():
#	var Master:float	= db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
#	print(Master)
#	label.text=str(busName)
	pass

func setName(busName):
	self.busName=busName
	label.text=str(busName)
	sound.bus=self.busName

func setVolume(volume:float):
	self.volume=volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(busName), linear2db(self.volume))
