extends "res://scripts/object.gd"


var maxXVel=constants.marioWalkMaxSpeed
var maxYVel=0
var big = false #是否变大
var faceRight=true
var fire = false #是否能发射子弹
var status=constants.stand
var acceleration =constants.acceleration #加速度

var stand_small_animation=['stand_small','stand_small_green',
						'stand_small_red','stand_small_black']
var slide_small_animation=['slide_small','slide_small_green',
						'slide_small_red','slide_small_black']
var walk_small_animation=['walk_small','walk_small_green',
						'walk_small_red','walk_small_black']
var jump_small_animation=['jump_small','jump_small_green',
						'jump_small_red','jump_small_black']
var stand_big_animation=['stand_big','stand_big_green',
						'stand_big_red','stand_big_black']
var walk_big_animation=['walk_big','walk_big_green',
						'walk_big_red','walk_big_black']
var slide_big_animation=['slide_big','slide_big_green',
						'slide_big_red','slide_big_black']
var jump_big_animation=['jump_big','jump_big_green',
						'jump_big_red','jump_big_black']	
							
var aniIndex=0						
onready var ani=$ani

func _ready():
	debug=true
	self.rect=Rect2(Vector2(-13,-16),Vector2(26,32))	
	pass 


func _update(delta):
	if status==constants.stand:
		stand(delta)
		pass
	elif status==constants.walk:
		walk(delta)
		pass
	pass

func stand(delta):
	self.xVel=0
	self.yVel=0
	animation("stand")
	if Input.is_action_pressed("ui_left"):
		faceRight=false
		status = constants.walk
	elif Input.is_action_pressed("ui_right"):
		faceRight=true
		status = constants.walk
		
	pass

func walk(delta):
	if xVel>0:
		ani.speed_scale=1+xVel/constants.marioAniSpeed
	elif xVel<0:
		ani.speed_scale=1+xVel/constants.marioAniSpeed*-1
	
	if Input.is_action_pressed("ui_action"):
		acceleration=constants.runAcceleration
		maxXVel=constants.marioRunMaxSpeed
	else:
		acceleration=constants.acceleration
		maxXVel=constants.marioWalkMaxSpeed	
	
	if Input.is_action_pressed("ui_left"):
		if xVel>0: #反方向
			animation("slide")
			acceleration=constants.slideFriction
		else:
			acceleration=constants.acceleration
			faceRight=false
			animation('walk')
			
		if xVel>-maxXVel:
			xVel-=acceleration
		elif xVel<-maxXVel:
			xVel+=acceleration
	elif Input.is_action_pressed("ui_right"):
		faceRight=true
		if xVel<0:
			animation("slide")
			acceleration=constants.slideFriction
		else:
			faceRight=true
			acceleration=constants.acceleration
			animation('walk')
			
		if xVel<maxXVel:
			xVel+=acceleration
		elif xVel>maxXVel:
			xVel-=acceleration
	else:
		if faceRight:
			if	self.xVel>0:
				self.xVel-=acceleration
			else:
				self.xVel=0
				status=constants.stand	
		else:
			if self.xVel<0:
				self.xVel+=acceleration
			else:
				self.xVel=0
				status=constants.stand	
					
	position.x+=self.xVel*delta
	pass

func jump(delta):
	
	pass

func fall(delta):
	
	pass

func animation(type):
	if type=='stand':
		if big:
			ani.play(stand_big_animation[aniIndex])
		else:	
			ani.play(stand_small_animation[aniIndex])
	elif type=='slide':
		if big:
			ani.play(slide_big_animation[aniIndex])
		else:	
			ani.play(slide_small_animation[aniIndex])
	elif type=='walk':
		if big:
			ani.play(walk_big_animation[aniIndex])
		else:	
			ani.play(walk_small_animation[aniIndex])
	elif type=='jump':
		if big:
			ani.play(jump_small_animation[aniIndex])
		else:	
			ani.play(jump_small_animation[aniIndex])
	if faceRight && ani.flip_h:
		ani.flip_h=false
	elif !faceRight && !ani.flip_h:
		ani.flip_h=true	
	pass
