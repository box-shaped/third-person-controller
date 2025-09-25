extends Control

# Called when node enters the scene tree
func _ready():
	$".".hide()

# Detects pressing the pause button
func _input(event):
	if event.is_action_pressed("pauseGame"):
		pauseunpause()

# Pauses the game
func pause():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$".".show()

# Controls whether the game is paused or unpaused
func pauseunpause():
	if get_tree().paused:
		unpause()
	else:
		pause()

# Unpauses the game
func unpause():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$".".hide()
	get_tree().paused = false

# Detects when resume is pressed
func _on_resume_pressed():
	unpause()

# Exits the game
func _on_quit_pressed() -> void:
	get_tree().quit()
