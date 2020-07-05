extends Node2D


func playJumpA():
	if not $jumpA.playing:
		$jumpA.play()
	
func playJumpB():
	if not $jumpB.playing:
		$jumpB.play()
	pass
