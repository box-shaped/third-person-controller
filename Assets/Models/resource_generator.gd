extends Building
@export_category("Generator Stats")
@export var resourcetype :="unassigned"
@export var generation_interval = 5
@export var generation_amount = 1
var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func give_resource():
	
	if resourcetype == "unassigned":
		print("No resourcetype assigned")
		return
	
	else:
		pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer+=delta
	
	if timer>generation_interval:
		give_resource()
		timer = 0
