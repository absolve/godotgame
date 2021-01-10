extends Node2D
#参考资料 https://developer.ibm.com/technologies/javascript/tutorials/wa-build2dphysicsengine/

var state=Game.game_state.START
var level



onready var _tank = $map/tanks
onready var _brick=$map/brick
onready var _bullet=$map/bullets
onready var _bonus=$map/bonus
onready var _map=$map
onready var _base=$map/base
onready var _ani=$ani

func _ready():
	Game.connect("baseDestroyed",self,"baseDestroy")
	Game.otherObj=$map/obj
	Game.mainScene=$map/bullets
	$map.loadMap(Game.mapDir+"/"+Game.mapNameList[Game.level])
	$map.addNewPlayer(1)
	var basePos=Vector2(_map.basePos.x*_map.cellSize,_map.basePos.y*_map.cellSize)
	#$map.addEnemy(basePos)	#添加敌人
	pass 


func _process(delta):
	if state==Game.game_state.LOAD:
		if Input.is_action_just_pressed("ui_accept"):
			#Splash.playOut()
			#state = Game.game_state.START
			setState(Game.game_state.START)
			pass
		pass
	elif state==Game.game_state.START:
		#return
		for i in _tank.get_children():	#检查坦克与砖块的碰撞
			var rect=i.getRect()
			for y in _brick.get_children():
				if y.get_class()=="brick":
					var rect1=y.getRect()
					if rect.intersects(rect1,false):  #碰撞
					
						var dx=(y.getPos().x-i.position.x)/(y.getXSize()/2)
						var dy=(y.getPos().y-i.position.y)/(y.getYSize()/2)
						var absDX = abs(dx)
						var absDY = abs(dy)

						if abs(absDX - absDY) < .1:
							if dx<0:
								i.position.x=y.getPos().x+y.getXSize()/2+i.getSize()/2			
							else:
								i.position.x=y.getPos().x-y.getXSize()/2-i.getSize()/2	

							if dy<0:
								i.position.y=y.getPos().y+y.getYSize()/2+i.getSize()/2			
							else:
								i.position.y=y.getPos().y-y.getYSize()/2-i.getSize()/2						
						elif absDX > absDY:
							print("absDX > absDY")
							if dx<0:
								i.position.x=y.getPos().x+y.getXSize()/2+i.getSize()/2					
							else:
								i.position.x=y.getPos().x-y.getXSize()/2-i.getSize()/2		
						else:
							if dy<0:
								i.position.y=y.getPos().y+y.getYSize()/2+i.getSize()/2	
							else:
								i.position.y=y.getPos().y-y.getYSize()/2-i.getSize()/2	
						var type=i.get_class()
						if type=="enemy":
							i.setStop(true)		
						pass
			
		
		for i in _bullet.get_children():	#子弹跟方块
			if i.get_class()=="bullet":
				var rect=i.getRect()
				for y in _brick.get_children():
					if y.get_class()=="brick":
						var rect1=y.getRect()
						if rect.intersects(rect1,false):  #碰撞
							i.addExplode(false)
							y.hit(i.getDir())
				
		for i in _bullet.get_children():	#同一个子弹
			if i.get_class()=="bullet":
				var typeA = i.getType()
				var rect=i.getRect()
				for y in _bullet.get_children():
					if i!=y && y.get_class()=="bullet": #排除同一个
						var rect1=y.getRect()
						if rect.intersects(rect1,false):
							var typeB=y.getType()
							if typeA==Game.bulletType.players and typeB==Game.bulletType.enemy:
								i.destroy()
								y.destroy()
							elif typeA==Game.bulletType.enemy and typeB==Game.bulletType.players:
								i.destroy()
								y.destroy()
					
		for i in _tank.get_children():	#坦克与坦克的碰撞
			for y in _tank.get_children():
				if i!=y:
					var rect=i.getRect()
					var rect1=y.getRect()
					
					pass
				pass
		
				
		for i in _bullet.get_children():
			if i.position.x<_map.offset.x or i.position.x>_map.mapRect.size.x+_map.mapRect.position.x:
				i.addExplode(false)
			if	i.position.y<_map.offset.y or i.position.y>_map.mapRect.size.y+_map.mapRect.position.y:
				i.addExplode(false)
			pass
		
		for i in _tank.get_children():
			var type=i.get_class()
			var rect=i.getRect()
			if i.position.x-i.getSize()/2 <_map.mapRect.position.x:
				i.position.x = _map.mapRect.position.x+i.getSize()/2
				if type=="enemy":
					i.setStop(true)		
			if i.position.x+i.getSize()/2>_map.mapRect.size.x+_map.mapRect.position.x:
				i.position.x = _map.mapRect.size.x+_map.mapRect.position.x-i.getSize()/2
			
				if type=="enemy":
					i.setStop(true)		
			if i.position.y-i.getSize()/2<_map.mapRect.position.y:
				i.position.y= _map.mapRect.position.y+i.getSize()/2
				if type=="enemy":
					i.setStop(true)		
			if i.position.y+i.getSize()/2>_map.mapRect.size.y+_map.mapRect.position.y:
				i.position.y = _map.mapRect.size.y+_map.mapRect.position.y-i.getSize()/2
				if type=="enemy":
					i.setStop(true)			
			pass
		
		
		for i in _bonus.get_children():
			var rect=i.getRect()
			for y in _tank.get_children():
				if y.get_class()=="player":
					var rect1=y.getRect()
					if rect.intersects(rect1,false):
						print("_bonus")
						pass
					pass
		
		for i in _base.get_children():
			if !i.destroy:
				var rect=i.getRect()
				for y in _bullet.get_children():
					var rect1=y.getRect()
					if rect.intersects(rect1,false):
						i.setBaseDestroyed()
						y.destroy()
		
		pass
	elif state==Game.game_state.NEXT_LEVEL:
		
		pass
	elif state==Game.game_state.OVER:
		pass
	pass



#设置状态
func setState(state):
	if state==Game.game_state.START:
		print('loadMap')
		
		pass
	elif state==Game.game_state.NEXT_LEVEL:
		
		pass	
	elif state==Game.game_state.OVER:
		
		pass
	self.state=state


#基地毁灭	
func baseDestroy():
	print('baseDestroy')
	$ani.play("gameover")
	#setState(Game.game_state.OVER)
	pass
