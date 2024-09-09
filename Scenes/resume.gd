extends Control
func _ready():
	$".".hide()
func _input(event):
	if event.is_action_pressed("pauseGame"):
		pauseunpause()
func pause():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$".".show()



func pauseunpause():
	if get_tree().paused:
		unpause()
	else:
		pause()

func unpause():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$".".hide()
	get_tree().paused = false
func _on_resume_pressed():
	unpause()

func _on_quit_pressed() -> void:
	get_tree().quit()
