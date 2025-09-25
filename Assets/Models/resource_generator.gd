extends Building
@export_category("Generator Stats")
@export var resourcetype :="unassigned"
@export var generation_interval = 5
@export var generation_amount = 1
var timer = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resourcetype=get_child(3).name
signal resource_update(resource:String,change:int)
func give_resource():
	if resourcetype == "unassigned":
		print("No resourcetype assigned")
		return
	else:
		resource_update.emit(resourcetype,generation_amount)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer+=delta
	if timer>generation_interval:
		give_resource()
		timer = 0
