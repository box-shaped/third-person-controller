extends Node3D
var coord = Vector3()
var removalqueue = []
signal get_active_slot
func _physics_process(delta: float) -> void:
	get_tree().call_group("Enemy","update_target_location",coord)
	get_active_slot.emit()
	if $CanvasLayer/HUD.getActive()=="Gun":
		if Input.is_mouse_button_pressed( 1 ):
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
	$NavigationRegion3D._on_map_rebake()
