extends Node

#保存所有的常量
var resting="resting"  #静止
var bumped="bumped"	#突起
var opened="opened"	#已打开


#mario的状态
var idle="idle"
var stand="stand"
var walk="walk"
var jump ="jump"
var fall="fall"
var small2big="small2big"
var big2fire="big2fire"
var big2small="big2small"
var crouch="crouch"



#mario 数据
var mario_speed=180
var mario_max_speed=300		#跑的时候最大速度
var acceleration=8	#加速度
var runAccel=8 #奔跑加速度
var friction=9	#摩檫力
var animation_speed=120	#动画速度
var gravity=1100	#重力
var gravityJump=600	#跳跃的时候重力

var dropSpeed=400 #下落最大速度
var jumpSpeed=400	#跳跃高度



func _ready():
	pass 


