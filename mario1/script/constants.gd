extends Node

#保存所有的常量
var resting="resting"  #静止
var bumped="bumped"	#突起
var opened="opened"	#已打开


#mario的状态
var idle="idle"
var walk="walk"
var jump ="jump"
var fall="fall"
var small2big="small2big"
var big2fire="big2fire"
var big2small="big2small"


#mario 速度
var mario_speed=180
var mario_max_speed=300
var acceleration=5	#加速度
var friction=8	#摩檫力
var animation_speed=120

func _ready():
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
