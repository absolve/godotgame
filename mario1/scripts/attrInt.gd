extends HBoxContainer

export var key:String
export var value:String



func _ready():
	$name.text=key
	$value.value=int(value)
	pass


func setValue(_value:int):
	$value.value=_value
	
func getValue():
	return $value.value
