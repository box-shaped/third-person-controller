extends Node3D
var coord = Vector3()
func _physics_process(delta: float) -> void:
	get_tree().call_group("Enemy","update_target_location",coord)
	if $CanvasLayer/HUD.getActive()=="Gun":
		if Input.is_mouse_button_pressed( 1 ):
			$Player.shoot()
		if Input.is_action_pressed("fire2"):
			$Player.ADS(delta)
		else:
			$Player.Hip(delta)
			
func _input(event):
	if event.is_action_pressed("Build"):
		if $CanvasLayer/HUD.getActive()=="Gun":
			return
		$NavigationRegion3D/Map.build()


func _on_map_castle_placed(centre) -> void:
	$MonsterSpawner.setCentre(centre)
	coord = centre
	
	
	
