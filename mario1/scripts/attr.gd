extends HBoxContainer

export var key:String
export var value:String

func _ready():
	$name.text=key
	$value.text=value
	pass

func setValue(values:String):
	$value.text=values

func getValue():
	return $value.text
