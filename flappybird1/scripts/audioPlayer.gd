extends Node2D

#播放声音

# 
func _ready():
	pass 


func playSfxDie()->void:
	$sfxDie.play()

func playSfxHit()->void:
	$sfxHit.play()
		
func playSfxPoint()->void:
	$sfxPoint.play()

func playSfxSwooshing()->void:
	$sfxSwooshing.play()

func playSfxWing()->void:
	$sfxWing.play()

