extends HBoxContainer

export var key:String
export var value:String
onready var valueObj=$value

func _ready():
	$name.text=key
	$value.text=value
	valueObj.connect("text_changed")
	pass

func setValue(values:String):
	$value.text=values

func getValue():
	return $value.text


