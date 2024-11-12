extends Node3D
var coord = Vector3()
var removalqueue = []
var displaygameover = false
var gameoveropacity = 0
var timer = 0
var maxtimer = 0.5
var towers =[]
@onready var overlay = $"CanvasLayer/HUD/Game Over/Overlay"
@onready var text = $"CanvasLayer/HUD/Game Over/Text"
signal get_active_slot
func _physics_process(delta: float) -> void:
	get_active_slot.emit()
	if $CanvasLayer/HUD.getActive()=="Gun":
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			$Player.shoot()
		if Input.is_action_pressed("fire2"):
			$Player.ADS(delta)
		else:
			$Player.Hip(delta)

func _input(event):
	if $CanvasLayer/HUD.getActive()=="Gun":
			return
	if event.is_action_pressed("Build"):
		$NavigationRegion3D/Map.build()
	elif event.is_action_pressed("fire2"):
		$NavigationRegion3D/Map.remove_building()
		print("testett")
	if event.is_action_pressed("NUKE THE QUEUE"):
		delete_queued_objects()
func _process(delta) -> void:
	if displaygameover:
		lerpf(gameoveropacity,1,delta) 
		text.add_theme_color_override("theme_override_colors/default_color",Color(0,0,0,gameoveropacity))
	timer+=delta
	if timer<maxtimer:
		return
	get_tree().call_group("Enemy","update_target_location",coord)
	process_towers()
func _on_map_castle_placed(centre) -> void:
	$MonsterSpawner.setCentre(centre)
	coord = centre

func _on_map_removalqueue(action: bool, object: Variant) -> void:
	if action:
		removalqueue.append(object)
	else:
		removalqueue.erase(object)
func delete_queued_objects():
	for object in removalqueue:
		object.queue_free()
		removalqueue.erase(object)
	$NavigationRegion3D._on_map_rebake()

func _on_map_castle_gone() -> void:
	$"CanvasLayer/HUD/Game Over".visible = true
	displaygameover = true
	print("balls")

func process_towers():
	for tower in towers:
		tower._shoot(Vector3.ZERO)

func _on_map_new_tower(tower) -> void:
	towers.append(tower)
