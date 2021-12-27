extends HBoxContainer

export var key:String
export var list:Array
onready var option=$OptionButton
var value=''
#var selected=''

func _ready():
	$name.text=key
	for i in list:
		option.add_item(i)
	if list.size()>0:
		value=list[0]
	pass

func setValue(value:String):
	for i in range(len(list)):
		if list[i]==value:
			self.value=value
			option.text=value
			option.selected=i
			break
	
func getValue():
	return value

func _on_OptionButton_item_selected(index):
	value=option.get_item_text(index)
	pass # Replace with function body.
