extends Node2D


func playJumpA():
	if not Game.data['sound']:
		return
	
	if not $jumpA.playing:
		$jumpA.play()
	
func playJumpB():
	if not Game.data['sound']:
		return
	if not $jumpB.playing:
		$jumpB.play()
	pass

func playColor():
	if not Game.data['sound']:
		return
	if not $color.playing:
		$color.play()
	pass

func startPop():
	$pop.autoplay=true
	$pop.play()
	pass

func stopPop():
	$pop.autoplay=false
	$pop.stop()
	pass

func startTrack():
	$track.autoplay=true
	$track.play()
	pass

func stopTrack():
	$track.autoplay=false
	$track.stop()
	

