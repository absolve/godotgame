extends HBoxContainer

export var key:String
export var value:String

func _ready():
	$name.text=key
	$value.text=value
	pass

func setValue(value:String):
	$value.text=value

func getValue():
	return $value.text
