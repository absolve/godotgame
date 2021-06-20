extends Control


var controls =['p1_up','p1_down','p1_left','p1_right','p1_fire',
			'p2_up','p2_down','p2_left','p2_right','p2_fire','game_start']
onready var actionList=$tab/Control/control/actionList
onready var actions=$tab/Control/control/actionList/ScrollContainer/actions
var action=preload("res://scenes/action.tscn")
var keyList=preload("res://scenes/keyList.tscn")
onready var popup=$Popup
var ActionNodes:Dictionary = {}	#inputmap对应的action
var configFile="config.ini"
var ActionEvent:Dictionary = {} #事件

func _ready():
	
	loadConfig()
	for i in controls:
		
		var list=InputMap.get_action_list(i) #inputmap的按键类型
		ActionEvent[i]=[]
	#	print(list)
		var tempAction=action.instance() #imputmap
		actions.add_child(tempAction)
		tempAction.setAction(i)
		ActionNodes[i]=tempAction
		var button=tempAction.find_node("Button")
		button.connect("pressed",self,"addActionEvent",[i])
		
		for z in list:
			addEvent(i,z)
	saveConfig()		
	pass # Replace with function body.

#添加action新的事件
func addActionEvent(name):
	popup.visible=true
	popup.set_process_input(true)
	yield(popup, "finish")
	if popup.NewEvent == null:
		return
	print(popup.NewEvent)
	var event:InputEvent = popup.NewEvent
	InputMap.action_add_event(name, event)
	addEvent(name, event)
	pass

#添加event
func addEvent(name,event):
	ActionEvent[name].append(event)
	#print(event.scancode)
	var action=ActionNodes[name]  #获取action节点
	var tempkey =keyList.instance()
	var removeBtn=tempkey.find_node("Button")
	removeBtn.connect("pressed",self,"removeEvent",[name,event,tempkey])
	
	action.addKeyList(tempkey)
	if event is InputEventKey:
		tempkey.setKeyName("Keyboard: " + event.as_text())
	elif event is InputEventJoypadButton:
		tempkey.setKeyName("Gamepad: " + event.as_text())
	elif event is InputEventJoypadMotion:
		var text="Gamepad: "
		var stick: = ''
		if Input.is_joy_known(event.device):
			stick = str(Input.get_joy_axis_string(event.axis))
			text+= stick + " "
		else:
			text += "Axis: " + str(event.axis) + " "
		
		if !stick.empty():	#known
			var value:int = round(event.axis_value)
			if stick.ends_with('X'):
				if value > 0:
					text += 'Rigt'
				else:
					text += 'Left'
			else:
				if value > 0:
					text += 'Down'
				else:
					text += 'Up'
		else:
			text += str(round(event.axis_value))
		tempkey.setKeyName(text)
	pass

#移除inputmap中的事件
func removeEvent(action,event,node):
#	print(action,event,node)
	InputMap.action_erase_event(action, event)
	node.queue_free()
	pass

#保存配置
func saveConfig():
	var data:Dictionary = {'input':{}}
	for i in controls:
		data['input'][i]=[]
		var event=ActionEvent[i]
		print(event)
		for z in event:
			print(z)
			var button_data:Dictionary = {}
			if z is InputEventKey:
				button_data["eventtype"] = "InputEventKey"
				button_data["scancode"] = z.scancode
			elif z is InputEventJoypadButton:
				button_data["eventtype"] = "InputEventJoypadButton"
				button_data["device"] = z.device
				button_data["button_index"] = z.button_index	
			elif z is InputEventJoypadMotion:
				button_data["eventtype"] = "InputEventJoypadMotion"
				button_data["device"] = z.device
				button_data["axis"] = z.axis
				button_data["axis_value"] = z.axis_value
			data['input'][i].push_back(button_data)		
	print(data)
	var file=File.new()
	var baseDir=OS.get_executable_path().get_base_dir()
	file.open(baseDir+configFile, File.WRITE)
	file.store_string(to_json(data))
	file.close()
	pass

#载入配置
func loadConfig():
	var baseDir=OS.get_executable_path().get_base_dir()
	var file=File.new()
	if file.file_exists(baseDir+configFile):
		file.open(filename, File.READ)
		var data=parse_json(file.get_as_text())
		print('data ',data)
		if data:
			var input=data['input']
			for i in controls:
				var event=input[i]
				ActionEvent[i]=[]
				for z in event:
					var NewEvent:InputEvent
					if z.EventType == "InputEventKey":
						NewEvent = InputEventKey.new()
						NewEvent.scancode = z.scancode
					elif z.EventType == "InputEventJoypadButton":
						NewEvent = InputEventJoypadButton.new()
						NewEvent.device = z.device
						NewEvent.button_index = z.button_index
					elif z.EventType=='InputEventJoypadMotion':
						NewEvent = InputEventJoypadMotion.new()
						NewEvent.device = z.device
						NewEvent.axis = z.axis
						NewEvent.axis_value = z.axis_value
					ActionEvent[i].append()	
				
				pass
			pass
			
			
		pass
	else:
		print("file not exist")	
		file.open(baseDir+configFile, File.WRITE)
		file.close()
	pass

func _on_btn_back_pressed():
	queue_free()
	Game.changeScene(Game._welcomeScene)
	pass # Replace with function body.


func _on_btn_ok_pressed():
	pass # Replace with function body.
