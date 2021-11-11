extends Node2D
"""
地图显示砖块，箱子
"""
const blockSize=32
const minWidthNum=20  #一个屏幕20块
const heightNun=15

var brick=preload("res://scenes/brick.tscn")
var box=preload("res://scenes/box1.tscn")
var pipe=preload("res://scenes/pipe.tscn")

var map=[]
var debug=true
var mapWidthSize=40  #地图宽度 
var enemyList=[] #敌人列表
var currentLevel  #文件数据
var path="res://levels/1-1.json"
var currentMapWidth=0 #当前地图的宽度
var bg="overworld" #overworld   castle underwater
var allTiles=[]  #所有方块的集合
var marioPos={} #mario地图出生地
var selectItem='' #选择的item



var mode="edit"  #game正常游戏  edit编辑  test测试
onready var _brick=$brick
onready var _bg=$bg
onready var camera=$Camera2D
onready var _itemList=$layer/Control/tab/map/vbox/itemList
onready var _tab=$layer/Control/tab
onready var _itemAttr=$layer/Control/tab/map/vbox/attribute
onready var _toolBtn=$layer/Control/toolBtn
onready var _saveDialog=$layer/FileDialog
onready var _mapWidth=$layer/Control/tab/common/vbox/mapWidth
onready var _time=$layer/Control/tab/common/vbox/time
onready var _background=$layer/Control/tab/common/vbox/background
onready var _music=$layer/Control/tab/common/vbox/music
onready var _spriteSet=$layer/Control/tab/common/vbox/spriteset



func _ready():
	print(camera.get_camera_position())
	print(camera.get_camera_screen_center())
#	loadMapFile(path)
	_itemList.connect("itemSelect",self,'selectItem')

	if mode=='edit':
#		for i in constants.tilesType:
#			mapTiles[i]={}
#			pass
#		print(mapTiles)
#		loadIcon()
		pass
	elif mode=='game':
		_tab.hide()
		_toolBtn.hide()
		pass	
	elif mode=='test':
		
		pass
	pass

func nodeItem():

	pass

#载入方块的图片
#func loadIcon():
#	var dic=Directory.new()
#	dic.open("res://icon")
#	dic.list_dir_begin()
#	while true:
#		var file = dic.get_next()
#		if file == "":
#			break
##		print(file.get_extension())
##		print(dic.get_current_dir()+"/"+file)
#		print(file.get_file())
#		if file.get_extension()=='png':
#			var fileName=file.get_basename().split("#")
#			var type = fileName[0]
#			if fileName.size()>1:
#				var index=fileName[1]
#				if mapTiles.has(type): #载入文件
#					mapTiles[type][index]=load(dic.get_current_dir()+"/"+file)
#			else: #只有名字
#				mapTiles[type]["0"]=load(dic.get_current_dir()+"/"+file)
#			pass
#
#	dic.list_dir_end()
#
#	pass

func _update(delta):
	
	pass

func loadMapFile(fileName:String):
	var file = File.new()
	if file.file_exists(fileName):
		file.open(fileName, File.READ)
		currentLevel= parse_json(file.get_as_text())
		currentMapWidth=currentLevel['mapSize']*blockSize
		print(currentMapWidth)
		if currentLevel['bg']=="overworld":
			_bg.color=Color(Game.backgroundcolor[0])
		elif currentLevel['bg']=="castle":
			_bg.color=Color(Game.backgroundcolor[1])
		elif currentLevel['bg']=="underwater":	
			_bg.color=Color(Game.backgroundcolor[2])
			
		for i in currentLevel['data']:
			if i['type'] =='brick':
				var temp=brick.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				var obj={"x":i['x'],"y":i['y']}
#				print(obj)
				if checkTile(obj):
					print(obj,' has one brick')
				else:
					_brick.add_child(temp)
#				_brick.add_child(temp)
				pass
			elif i['type']=='box':
				var temp=box.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				temp.content=i['content']
				temp._visible=i['visible']
				var obj={"x":i['x'],"y":i['y']}
				if checkTile(obj):
					print(obj,' has one box')
				else:
					_brick.add_child(temp)
#				_brick.add_child(temp)
				pass
			elif i['type']=='goomba':	
				
				pass
			elif i['type']=='koopa':
				
				pass
			elif i['type']=='pipe':
				var temp=pipe.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				var obj={"x":i['x'],"y":i['y']}
				if checkTile(obj):
					print(obj,' has one pipe')
				else:
					_brick.add_child(temp)
				_brick.add_child(temp)
		file.close()
	else:
		print('文件不存在')	
		pass
	pass

#保存到文件
func save2File(fileName):
	print(fileName)
	var data={
		"mapSize":mapWidthSize,
		"bg":_background.value,
		"music":_music.value,
		'time':_time.value,
		'marioPos':marioPos,
		'data':allTiles
	}
	var file = File.new()
	file.open(fileName, File.WRITE)
	file.store_string(to_json(data))
	file.close()
	pass

func checkTile(obj):
#	if allTiles.bsearch_custom(obj,self,"checkXY")!=0:
#		return true
#	else:
#		allTiles.append(obj)
#		return false
	var flag=false		
	for i in allTiles:
		if i["x"]==obj["x"]&&i["y"]==obj["y"]:	
			flag=true
			break
	return 	flag		
		
#func checkXY(a,b):
#	return a["x"]==b["x"]&&a["y"]==b["y"]

#检查点击的位置是否有这个方块
func checkHasItem(pos):
	print('checkHasItem',pos)
	var x = pos.x
	var y=pos.y
	var indexX = int(x)/(blockSize)
	var indexY=int(y)/(blockSize)
#	var temp = {"x":indexX,"y":indexY}
#	print(temp)
	var flag=false
	
	for i in allTiles:
		if i["x"]==indexX&&i["y"]==indexY:
			flag=true
			break
	print(flag)		
	return 	flag
	pass

#添加方块信息
func addItem(type,pos):
	if not constants.tilesAttribute.has(type):
		print('item type error ',type)
		return	
	print(type)
	var g=constants.tilesAttribute[type].duplicate()
	g.x=pos.x
	g.y=pos.y
	allTiles.append(g)
#	if type=='goomba':
#		var g=constants.tilesAttribute[type].duplicate()	
#		g.x=pos.x
#		g.y=pos.y
#		allTiles.append(g)
#	elif type=='koopa':
#		var k=constants.tilesAttribute[type].duplicate()	
#		k.x=pos.x
#		k.y=pos.y
#		allTiles.append(k)
#		pass
#	elif type=='box':
#		var b=constants.tilesAttribute[type].duplicate()	
#		b.x=pos.x
#		b.y=pos.y
#		print(b)
#		allTiles.append(b)
#		pass
#	elif type=='brick':
#		var b=constants.tilesAttribute[type].duplicate()	
#		b.x=pos.x
#		b.y=pos.y
#		allTiles.append(b)
#		pass
#	elif type=='pipe':	
#		var p=constants.tilesAttribute[type].duplicate()	
#		p.x=pos.x
#		p.y=pos.y
#		allTiles.append(p)
#		pass
#	elif type=='coin':
#		var c=constants.tilesAttribute[type].duplicate()	
#		c.x=pos.x
#		c.y=pos.y
#		allTiles.append(c)
#		pass
#	elif type=='bg':
#		var bg=constants.tilesAttribute[type].duplicate()	
#		bg.x=pos.x
#		bg.y=pos.y
#		allTiles.append(bg)
#		pass					
	pass

#删除一个方块
func delItem(pos:Vector2):
	var indexX = int(pos.x)/(blockSize)
	var indexY=int(pos.y)/(blockSize)
	var temp = {"x":indexX,"y":indexY}
	for i in range(allTiles.size()):
		if allTiles[i]["x"]==indexX&&allTiles[i]["y"]==indexY:
			allTiles.remove(i)
			break
#	var index = allTiles.bsearch_custom(temp,self,"checkXY")
#	print(index)
#	print(allTiles.size())
#	if index!=0:
#		allTiles.remove(index-1)
	pass

#选择方块
func selectItem(index,itemName):
	print(index,itemName)
	selectItem=itemName
	pass

func getItemPos(pos:Vector2):
	return {
		'x':int(pos.x)/blockSize,
		'y':int(pos.y)/blockSize
	}
	pass

#获取属性
func getItemAttr(pos:Vector2):
	var indexX = int(pos.x)/(blockSize)
	var indexY=int(pos.y)/(blockSize)
	var temp = {"x":indexX,"y":indexY}
#	var index = allTiles.bsearch_custom(temp,self,"checkXY")
#	print('getItemAttr',index)
	for i in allTiles:
		if i["x"]==indexX&&i["y"]==indexY:
			var attr=constants.tilesAttribute[i.type]
			_itemAttr.clearAttr()
			for y in attr.keys():
				print(y)
				_itemAttr.addAttr(y,i[y])
			break	
#	if index!=0:
#		var type=allTiles[index-1].type
#		print(allTiles[index-1])
#		var attr=constants.tilesAttribute[type]
#		print(attr)
#		_itemAttr.clearAttr()
#		for i in attr.keys():
#			print(i)
#			_itemAttr.addAttr(i,allTiles[index-1][i])
			
	pass

func _process(delta):
	update()
	pass

func _input(event):
	if mode=='edit':
		if _saveDialog.visible:
			return
		if event is InputEventKey:
			if event.is_pressed():
				if (event as InputEventKey).scancode==KEY_LEFT:	
					if camera.position.x>-minWidthNum/2*blockSize:  #前后一半屏幕
						camera.position.x-=10
					pass
				elif (event as InputEventKey).scancode==KEY_RIGHT:	
					if camera.position.x<mapWidthSize*blockSize-minWidthNum/2*blockSize:
						camera.position.x+=10
					pass	
		elif event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and  event.pressed:
				if _tab.is_visible_in_tree()&& _tab.get_rect().has_point(get_local_mouse_position()):
					return
				if _toolBtn.is_visible_in_tree()&&_toolBtn.get_rect().has_point(get_local_mouse_position()):
					return
				if checkHasItem(get_global_mouse_position()):
					if selectItem=='del':
						delItem(get_global_mouse_position())
					else:  #显示属性
						getItemAttr(get_global_mouse_position())
						pass
					pass
				else:	
					var pos=getItemPos(get_global_mouse_position())	
					print(pos)
					addItem(selectItem,pos)
				pass
			elif !event.pressed:	
				
				pass	
			pass
		elif event is InputEventMouseMotion:	#移动
			
			pass	
		pass
	pass

func _draw():
	if debug:
		for i in range(mapWidthSize+1):
			if i%20==0:
				draw_line(Vector2(i*blockSize,0),Vector2(i*blockSize,blockSize*heightNun)
			,Color.red,1.2,true)
			else:
				draw_line(Vector2(i*blockSize,0),Vector2(i*blockSize,blockSize*heightNun)
			,Color.gray,0.5,true)
		for i in range(mapWidthSize):
			draw_line(Vector2(0,i*blockSize),Vector2(blockSize*mapWidthSize,i*blockSize),
			Color.gray,0.5,true)	
		for i in allTiles:
			if i.type=='goomba':
				if constants.mapTiles.has(i.type):
					draw_texture(constants.mapTiles[i.type]['0'],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))
				pass
			elif i.type=='koopa':
				if constants.mapTiles.has(i.type):
					draw_texture(constants.mapTiles[i.type]['0'],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))
#				draw_texture(koopaImg,Vector2(i.x*blockSize,i.y*blockSize-12),Color(1,1,1,0.5))	
			elif i.type=='box':
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))	
			elif i.type=='brick':	
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))	
#				draw_texture(brickImg,Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))	
			elif i.type=='coin':
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type]['0'],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))	
			pass
	pass
	
	


func _on_hide_pressed():
	_toolBtn.show()
	_tab.hide()
	pass # Replace with function body.


func _on_save_pressed():
	var baseDir=OS.get_executable_path().get_base_dir()
	_saveDialog.current_dir=baseDir
	_saveDialog.current_file="1-1.json"
	_saveDialog.popup_centered()
	pass # Replace with function body.


func _on_toolBtn_pressed():
	_toolBtn.hide()
	_tab.show()
	pass # Replace with function body.


func _on_Button_pressed():
	
	pass # Replace with function body.


func _on_FileDialog_confirmed():
	if _saveDialog.current_file:
		save2File(_saveDialog.current_path)
	pass # Replace with function body.
