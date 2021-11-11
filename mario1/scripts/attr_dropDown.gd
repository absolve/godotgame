extends HBoxContainer

export var key:String
export var list:Array
onready var option=$OptionButton
var value=''

func _ready():
	$name.text=key
	for i in list:
		option.add_item(i)
	if list.size()>0:
		value=list[0]
	pass


func _on_OptionButton_item_selected(index):
	value=option.get_item_text(index)
	pass # Replace with function body.
