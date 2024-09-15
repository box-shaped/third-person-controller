extends Control
@onready var GRID = $GridContainer
var hotbarlength = 3
var active = 1
var hotbarItems={
	1:"House1",
	2:"House2",
	3:"defaultGrass"
}
func getActive():
	return hotbarItems[active]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GRID.get_child(0).button_pressed = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("Action1"):
		_on_button_1_pressed()
	elif event.is_action_pressed("Action2"):
		_on_button_2_pressed()
	elif event.is_action_pressed("Action3"):
		_on_button_3_pressed()
func _on_button_1_pressed() -> void:
	active = 1
	print(1)

func _on_button_2_pressed() -> void:
	active = 2
	print(2)

func _on_button_3_pressed() -> void:
	active = 3
	print(3)
