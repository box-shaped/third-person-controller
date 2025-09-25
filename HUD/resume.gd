extends Control

# Called when the node enters the scene tree
func _ready():
	$".".hide()

# Recieves input (pause / unpause)
func _input(event):

	if event.is_action_pressed("pauseGame"):
		pauseunpause()

# Identifies when the game is paused / unpaused
func pauseunpause():

	if get_tree().paused:
		unpause()
		
	else:
		pause()

#Controls pausing
func pause():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$".".show()

# Controls unpausing
func unpause():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$".".hide()
	get_tree().paused = false

# Identifies when the game is resumed (unpaused)
func _on_resume_pressed():
	unpause()

# Identifies when the game is quit
func _on_quit_pressed() -> void:
	get_tree().quit()
