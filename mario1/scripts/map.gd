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
var background=preload("res://scenes/bg.tscn")

#var map=[]
var debug=true
var mapWidthSize=20  #地图宽度 
var enemyList=[] #敌人列表
var currentLevel  #文件数据
var path="res://levels/1-1.json"
var currentMapWidth=0 #当前地图的宽度
var bg="overworld" #overworld   castle underwater
var time=400 #时间
var allTiles=[]  #所有方块的集合
var marioPos={} #mario地图出生地
var selectItem='' #选择的item
var state=constants.startState


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
onready var _marioList=$mario
onready var _brickList=$brick
onready var _bulletList=$bullet
onready var _itemsList=$item
onready var _otherobjList=$otherObj
onready var _enemyList=$enemy
onready var _loadDiaglog=$layer/loadDialog
onready var _title = $title

func _ready():
	print(camera.get_camera_position())
	print(camera.get_camera_screen_center())
#	loadMapFile("res://levels/test.json")
	_itemList.connect("itemSelect",self,'selectItem')
	Game.setMap(self)
	Game.connect("stateChange",self,'stateChange')
	Game.connect("stateFinish",self,'stateFinish')
	
	if mode=='edit':
		_title.hide()
		pass
	elif mode=='game':
		_tab.hide()
		_toolBtn.hide()	
		loadMapFile("res://levels/test.json")
		pass	
	elif mode=='test':
		
		pass
	print(camera.get_camera_position())	
	pass

#func nodeItem():
#
#	pass

#载入文件
func loadMapFile(fileName:String):
	var file = File.new()
	if file.file_exists(fileName):
		file.open(fileName, File.READ)
		currentLevel= parse_json(file.get_as_text())
		mapWidthSize=currentLevel['mapSize']
		print(currentLevel['time'])
		time =int(currentLevel['time'])
		if currentLevel['bg']=="overworld":
			_bg.color=Color(Game.backgroundcolor[0])
		elif currentLevel['bg']=="castle":
			_bg.color=Color(Game.backgroundcolor[1])
		elif currentLevel['bg']=="underwater":	
			_bg.color=Color(Game.backgroundcolor[2])
			
		for i in currentLevel['data']:
			if i['type'] =='brick':
				if mode=='edit':
					allTiles.append(i)
				elif mode=='game':	
					var temp=brick.instance()
					temp.spriteIndex=i['spriteIndex']
					temp.position.x=i['x']*blockSize+blockSize/2
					temp.position.y=i['y']*blockSize+blockSize/2
					var obj={"x":i['x'],"y":i['y']}
					if checkTile(obj):
						print(obj,' has one brick')
					else:
						_brick.add_child(temp)
				pass
			elif i['type']=='box':
				if mode=='edit':
					allTiles.append(i)
				else:	
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
				pass
			elif i['type']=='goomba':	
				
				pass
			elif i['type']=='koopa':
				
				pass
			elif i['type']=='pipe':
				if mode=='edit':
					allTiles.append(i)
				else:	
					var temp=pipe.instance()
					temp.spriteIndex=i['spriteIndex']
					temp.position.x=i['x']*blockSize+blockSize/2
					temp.position.y=i['y']*blockSize+blockSize/2
					var obj={"x":i['x'],"y":i['y']}
					if checkTile(obj):
						print(obj,' has one pipe')
					else:
						_brick.add_child(temp)
#					_brick.add_child(temp)
			elif i['type']=='bg':	
				if mode=='edit':
					allTiles.append(i)
				else:
					var temp=background.instance()	
					temp.spriteIndex=i['spriteIndex']
					temp.position.x=i['x']*blockSize+blockSize/2
					temp.position.y=i['y']*blockSize+blockSize/2
					var obj={"x":i['x'],"y":i['y']}
					if checkTile(obj):
						print(obj,' has one ng')
					else:	
						_background.add_child(temp)
					
					
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
#	print('checkHasItem',pos)
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
#	print(flag)		
	return 	flag


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


#删除一个方块
func delItem(pos:Vector2):
	var indexX = int(pos.x)/(blockSize)
	var indexY=int(pos.y)/(blockSize)
	var temp = {"x":indexX,"y":indexY}
	for i in range(allTiles.size()):
		if allTiles[i]["x"]==indexX&&allTiles[i]["y"]==indexY:
			allTiles.remove(i)
			break


#选择方块
func selectItem(index,itemName):
#	print(index,itemName)
	selectItem=itemName


func getItemPos(pos:Vector2):
	return {
		'x':int(pos.x)/blockSize,
		'y':int(pos.y)/blockSize
	}


#获取属性
func getItemAttr(pos:Vector2):
	var indexX = int(pos.x)/(blockSize)
	var indexY=int(pos.y)/(blockSize)
#	var temp = {"x":indexX,"y":indexY}
#	var index = allTiles.bsearch_custom(temp,self,"checkXY")
#	print('getItemAttr',index)
	for i in allTiles:
		if i["x"]==indexX&&i["y"]==indexY:
			var attr=constants.tilesAttribute[i.type]
			_itemAttr.clearAttr()
			for y in attr.keys():
#				print(y)
				_itemAttr.addAttr(y,i[y])
			break			
	pass

func addObj2Brick(obj):
	_brickList.add_child(obj)

func addObj2Item(obj):
	_itemsList.add_child(obj)

func addObj2Other(obj):
	_otherobjList.add_child(obj)

func addObj2Bullet(obj):
	_bulletList.add_child(obj)

func getBulletCount(id):
	var num=0
	for i in _bulletList.get_children():
		if i.type==constants.fireball&&i.status==constants.fly:
			num+=1
	return num

func stateChange():
	print('stateChange')
	state=constants.stateChange
	for i in _itemsList.get_children():
		i.pause()
	pass

func stateFinish():
	state=constants.startState
	for i in _itemsList.get_children():
		i.resume()
	pass	
	
func _update(delta):
	if mode=='edit':
		pass
	elif mode=='game':
		if state==constants.startState:
			#清除超过屏幕的敌人
			for i in _enemyList.get_children():
				var pos=camera.get_camera_position()
				if i.position.x+i.getSize()/2<=pos.x-camera.offset.x:
					i.queue_free()
				elif i.position.x-i.getSize()/2>=pos.x+camera.offset.x*3:
					i.queue_free()
				if i.position.y+i.getSizeY()/2>=camera.offset.y*2:
					i.queue_free()		
				pass
			for i in _bulletList.get_children():
				var pos=camera.get_camera_position()
				if i.position.x+i.getSize()/2<=pos.x-camera.offset.x:
					i.queue_free()
				elif i.position.x-i.getSize()/2>=pos.x+camera.offset.x*3:
					i.queue_free()
				if i.position.y+i.getSizeY()/2>=camera.offset.y*2:
					i.queue_free()	
			
			for i in _marioList.get_children():
				i._update(delta)
			for i in _brickList.get_children():
				i._update(delta)
			for i in _bulletList.get_children():
				i._update(delta)
			for i in _itemsList.get_children():
				i._update(delta)
			for i in _otherobjList.get_children():
				i._update(delta)
			for i in _enemyList.get_children():
				i._update(delta)
			
			for i in _marioList.get_children():  #mario跟方块
				var onFloor=false
				for y in _brickList.get_children():
					var rect1 = i.getRect()
					var rect2=y.getRect()
					if rect1.encloses(rect2):#完全叠一起
						continue
					if rect1.intersects(rect2):		
						var dx=(y.position.x-i.position.x)/y.getSize()/2
						var dy=(y.position.y-i.position.y)/y.getSize()/2
						if abs(abs(dx)-abs(dy))<.1:  #两边重叠
#							print('abs(abs(dx)-abs(dy))')
							if dx<0:
#								if i.dir==constants.left:
#									i.xVel=0
								i.position.x=y.position.x+y.getSize()/2+i.getSize()/2
							else:
#								if i.dir==constants.right:
#									i.xVel=0	
								i.position.x=y.position.x-y.getSize()/2-i.getSize()/2
							if dy<0:
								i.yVel=abs(i.yVel)-abs(i.yVel)/4
#								i.position.y=y.position.y+y.getSize()/2+i.getSizeY()/2
								if !onFloor:
									onFloor=false
							else:
#								if i.yVel>0:
#									i.yVel=0
#								i.position.y=y.position.y-y.getSize()/2-i.getSizeY()/2
#								onFloor=true
								pass	
							pass
						elif abs(dx)>abs(dy): #左右的碰撞
							if dx<0:
								if i.dir==constants.left:
									i.xVel=0
								i.position.x=y.position.x+y.getSize()/2+i.getSize()/2
							else:
								if i.dir==constants.right:
									i.xVel=0	
								i.position.x=y.position.x-y.getSize()/2-i.getSize()/2
						else: #上下的碰撞
							if dy<0:  #下方							
#								i.position.y=y.position.y+y.getSize()/2+i.getSizeY()/2-1
								if !onFloor:
									onFloor=false
								if y.type==constants.box && i.yVel<0:
									if y.status==constants.resting:
										if y.isDestructible():
											y.add4Brick()
											y.destroy()
										else:	
											y.startBumped()
								i.yVel=abs(i.yVel)-abs(i.yVel)/4			
							else:
								if i.yVel>0:  #掉落的情况
									i.yVel=0
								i.position.y=y.position.y-y.getSize()/2-i.getSizeY()/2
								onFloor=true	
							pass
				i.isOnFloor=onFloor
		
			
			for i in _itemsList.get_children():  #物品的判断
				for y in _brickList.get_children():
					if i.status==constants.growing: #排除在增长的状态
						continue
					var rect1 = i.getRect()
					var rect2=y.getRect()
					if rect1.encloses(rect2):#完全叠一起
						continue
					if rect1.intersects(rect2):
						var dx=(y.position.x-i.position.x)/y.getSize()/2
						var dy=(y.position.y-i.position.y)/y.getSize()/2
						if abs(abs(dx)-abs(dy))<.1:  #两边重叠
	#						if dx<0:
	#							i.position.x=y.position.x+y.getSize()/2+i.getSize()/2
	#						else:
	#							i.position.x=y.position.x-y.getSize()/2-i.getSize()/2
							if dy<0:
								i.yVel=8
							else:
								if i.yVel>0:
									i.yVel=0
								i.position.y=y.position.y-y.getSize()/2-i.getSizeY()/2
						elif abs(dx)>abs(dy): #左右的碰撞
							i.xVel=0
							if dx<0:
								i.position.x=y.position.x+y.getSize()/2+i.getSize()/2
								i.turnRight()
							else:
								i.position.x=y.position.x-y.getSize()/2-i.getSize()/2
								i.turnLeft()
						else: #上下的碰撞
							if dy<0:  #下方
								i.yVel=8
							else:
								if i.yVel>0:  #掉落的情况
									i.yVel=0
								i.position.y=y.position.y-y.getSize()/2-i.getSizeY()/2
								if i.status==constants.jumping:
									i.yVel=-i.jumpSpeed
				pass
				
			
			for i in _enemyList.get_children():  #敌人跟方块
				if i.status==constants.dead||i.status==constants.deadJump:
					continue
				for y in _brickList.get_children():
					var rect1 = i.getRect()
					var rect2=y.getRect()
					if rect1.intersects(rect2):
	#					print(rect1,rect2)
						if rect1.encloses(rect2):#完全叠一起
								continue
						var dx=(y.position.x-i.position.x)/y.getSize()/2
						var dy=(y.position.y-i.position.y)/y.getSize()/2
						if abs(abs(dx)-abs(dy))<.1:  #两边重叠
	#						if dx<0:
	#							i.position.x=y.position.x+y.getSize()/2+i.getSize()/2
	#						else:
	#							i.position.x=y.position.x-y.getSize()/2-i.getSize()/2
								
							if dy<0:
								i.yVel=8
							else:
								if i.yVel>0:
									i.yVel=0
								i.position.y=y.position.y-y.getSize()/2-i.getSizeY()/2
						elif abs(dx)>abs(dy): #左右的碰撞
							if dx<0:
								i.position.x=y.position.x+y.getSize()/2+i.getSize()/2
								i.turnRight()
							else:
								i.turnLeft()
								i.position.x=y.position.x-y.getSize()/2-i.getSize()/2
						else: #上下的碰撞
							if dy<0:  #下方
								i.yVel=8
	#							i.position.y=y.position.y+y.getSize()/2+i.getSizeY()/2+1
							else:
								if i.yVel>0:  #掉落的情况
									i.yVel=0
								if y.type==constants.box&& y.status==constants.bumped:
									i.startDeathJump()
								else:		
									i.position.y=y.position.y-y.getSize()/2-i.getSizeY()/2
								
			for i in _marioList.get_children():
				for y in _enemyList.get_children():
					if y.status==constants.dead||y.status==constants.deadJump:
						continue
					var rect1 = i.getRect()
					var rect2=y.getRect()
					if rect1.encloses(rect2):#完全叠一起
						continue
					if rect1.intersects(rect2):
						var dx=(y.position.x-i.position.x)/y.getSize()/2
						var dy=(y.position.y-i.position.y)/y.getSize()/2
						if abs(abs(dx)-abs(dy))<.1:  #两边重叠
							if dx<0:
								if y.type==constants.koopa && y.status==constants.shell:
									y.status=constants.sliding
									y.dir=constants.left
							else:
								if y.type==constants.koopa && y.status==constants.shell:
									y.status=constants.sliding
									y.dir=constants.right
							if dy<0:
	#							i.yVel=8
								pass
							else:
								if i.yVel>0:
									i.yVel=0
								i.position.y=y.position.y-y.getSize()/2-i.getSizeY()/2
							pass
						elif abs(dx)>abs(dy): #左右的碰撞
							if dx<0:
	#							i.position.x=y.position.x+y.getSize()/2+i.getSize()/2
								if y.type==constants.koopa && y.status==constants.shell:
									y.status=constants.sliding
									y.dir=constants.left
							else:
								if y.type==constants.koopa && y.status==constants.shell:
									y.status=constants.sliding
									y.dir=constants.right
	#							i.position.x=y.position.x-y.getSize()/2-i.getSize()/2
							pass	
						else: #上下的碰撞
							if dy<0:  #下方
	#							i.yVel=8
								pass
							else:
								i.yVel=-300
								i.position.y=y.position.y-y.getSize()/2-i.getSizeY()/2+1#位置调整
								if y.type==constants.koopa:
									if dx<0:
										y.dir=constants.right
									else:
										y.dir=constants.left
									pass		
								y.jumpedOn()	
				pass
			
			
			for i in _bulletList.get_children():
				for y in _brickList.get_children():
					if i.status==constants.boom: #排除在增长的状态
						continue
					var rect1 = i.getRect()
					var rect2=y.getRect()
					if rect1.encloses(rect2):#完全叠一起
						continue
					if rect1.intersects(rect2):
						var dx=(y.position.x-i.position.x)/y.getSize()/2
						var dy=(y.position.y-i.position.y)/y.getSize()/2
						if abs(abs(dx)-abs(dy))<.1:  #两边重叠
							if dx<0:
								if dy>=0:
									i.position.y=y.position.y-y.getSize()/2-i.getSizeY()/2
									if i.status==constants.fly:
										i.yVel=-i.speed	
								else:
									if i.type==constants.fireball &&i.status==constants.fly:
										i.boom()		
							else:
								if dy>=0:
									i.position.y=y.position.y-y.getSize()/2-i.getSizeY()/2
									if i.status==constants.fly:
										i.yVel=-i.speed	
								else:
									if i.type==constants.fireball&&i.status==constants.fly:
										i.boom()		
								pass
	#						if dy<0:
	#							i.yVel=8
	#						else:
	#							i.position.y=y.position.y-y.getSize()/2-i.getSizeY()/2
	#							if i.status==constants.fly:
	#								i.yVel=-i.speed
						elif abs(dx)>abs(dy): #左右的碰撞
							i.xVel=0
							if dx<0:
								#i.position.x=y.position.x+y.getSize()/2+i.getSize()/2
								if i.type==constants.fireball:
									i.boom()
							else:
								#i.position.x=y.position.x-y.getSize()/2-i.getSize()/2
	#							i.turnLeft()
								if i.type==constants.fireball:
									i.boom()
						else: #上下的碰撞
							if dy<0:  #下方
								if i.status==constants.fly:
									i.yVel=i.speed
							else:
	#							if i.yVel>0:  #掉落的情况
	#								i.yVel=0
								i.position.y=y.position.y-y.getSize()/2-i.getSizeY()/2
								if i.status==constants.fly:
									i.yVel=-i.speed
				pass
			
			
			for i in _marioList.get_children():
				for y in _itemsList.get_children():
					var rect1 = i.getRect()
					var rect2=y.getRect()
					if rect1.intersects(rect2):
						if y.type==constants.mushroom:
							y.queue_free()
							i.small2Big()
						elif y.type==constants.fireflower:
							y.queue_free()
							i.big2Fire()
							pass
						elif y.type==constants.star:
							y.queue_free()
							i.setInvincible()
						pass
					pass
				
			pass
		elif state==constants.stateChange:
			for i in _marioList.get_children():
				i._update(delta)
				if i.dead:
					if i.position.y-i.getSizeY()/2>=camera.offset.y*2:
						print(i.position.y)
						i.queue_free()
			pass
	pass


func _process(delta):
	if debug:
		update()
	_update(delta)
	pass

func _input(event):
	if mode=='edit':
		if _saveDialog.visible||_loadDiaglog.visible:
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
				print(camera.get_local_mouse_position())
				if _tab.is_visible_in_tree()&& _tab.get_rect().has_point(camera.get_local_mouse_position()):
					return
				if _toolBtn.is_visible_in_tree()&&_toolBtn.get_rect().has_point(camera.get_local_mouse_position()):
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
			elif i.type=='pipe':
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))	
			elif i.type=='bg':
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))
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
#	for i in _marioList.get_children():
#		i.startDeathJump()
	var baseDir=OS.get_executable_path().get_base_dir()
	print(baseDir)
	_loadDiaglog.current_dir=baseDir
	_loadDiaglog.popup_centered()	
	pass # Replace with function body.


func _on_FileDialog_confirmed():
	if _saveDialog.current_file:
		save2File(_saveDialog.current_path)
	pass # Replace with function body.


func _on_apply_pressed():
	
	pass # Replace with function body.


func _on_loadDialog_confirmed():
	var dir=_loadDiaglog.current_dir
	var file=_loadDiaglog.current_file
	print(dir,' ',file)
	print(_loadDiaglog.current_path)
	if file:
		loadMapFile(dir+"/"+file)
	pass # Replace with function body.
