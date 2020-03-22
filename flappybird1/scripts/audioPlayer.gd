extends Node2D

#播放声音

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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

