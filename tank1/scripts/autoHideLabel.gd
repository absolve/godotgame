extends Label

onready var timer=$Timer

func _ready():
	pass
	
func startHideTimer():
	self.visible=true
	timer.start()
	pass	

func _on_Timer_timeout():
	self.visible=false
	pass # Replace with function body.
