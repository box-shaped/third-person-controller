extends Control
@onready var GRID = $GridContainer
@export var healthfontsize = 40
var targetscale =Vector2(1.0,1.0)
@export_group("Hotbar")
@export var hotbarlength = 3
@export var slotSize = Vector2(64,64)
@export var margin = 10
@export var seperator = 10
@export var hotbarItems={
	1:"House1",
	2:"Tower",
	3:"Gun"
}
var active = 1
signal Hud
func getActive():
	return hotbarItems[active]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RichTextLabel.add_theme_font_size_override("theme_override_font_sizes/normal_font_size",healthfontsize)
	_on_castle_health(50,50)
	#$GridContainer.size = Vector2(slotSize.y+margin,(slotSize.x+seperator)*hotbarlength+2*margin)
	for i in hotbarlength:
		$GridContainer.get_child(i).size = slotSize
func _on_castle_health(current:int,max:int):
	current = current
	max=max
	targetscale = Vector2(current/(max*1.0),1.0)
	print("attempting to set to ", current/(max*1.0)," ",current,max)
	$RichTextLabel.text = str(current," / ",max)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Container2/HealthMeasure.value = 100*lerp($Container2/HealthMeasure.value/100,targetscale.x,delta*15)
	#print($Container2/HealthMeasure.value)
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


func _on_player_crosshair(visibility: bool) -> void:
	$Container.visible = visibility
