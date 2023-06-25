extends KinematicBody2D

var dir=Constants.right
var vec=Vector2.ZERO
var size=Vector2(10,24)
var isInvincible=false #无敌
var onFloor=false
var gravity=100
var type
var upAccelerate=200

func _ready():
	pass
