extends Node3D
var coord = Vector3()
var removalqueue = []
var displaygameover = false
var gameoveropacity = 0
var timer = 0
var maxtimer = 0.2
var towers =[]
var enemies = []
var bulletTimer = 0
@export var fireDelay = 1
@export var enemyheight = 2
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
		lerpf(gameoveropacity,1,delta/5) 
		text.add_theme_color_override("theme_override_colors/default_color",Color(0,0,0,gameoveropacity))
	timer+=delta
	#print("shamameze",timer)
	if timer<maxtimer:
		return
	get_tree().call_group("Enemy","update_target_location",coord)
	#print("shazam")
	process_towers(delta)
	timer =0
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

func process_towers(delta):
	#print("Enemies:","Total: ",enemies.size())
	#print("Towers:","Total: ",towers.size())
	
	for tower in towers:
		var target = get_closest_enemy(tower.global_position).global_position+Vector3(0,enemyheight,0)
		tower._track_target(target)
	bulletTimer+=delta
	if bulletTimer>fireDelay:
		for tower in towers:
			var target = get_closest_enemy(tower.global_position).global_position+Vector3(0,enemyheight,0)
			tower._shoot(target)
			print("enemy position at: ",target)
			bulletTimer = 0
func get_closest_enemy(to: Vector3):
	var lowest: float = 100
	var current = null
	
	for enemy in enemies:
		if enemy == null: 
			#print("Null enemy found, removing from list")
			enemies.erase(enemy) 
			continue  # Use 'continue' instead of 'break' to continue checking other enemies

		var dist = to.distance_to(enemy.global_position)
		#print("Checking enemy at position:", enemy.global_position, "Distance to enemy:", dist)
		#print("Distance to enemy:", dist)
		
		if dist < lowest:
			lowest = dist
			current = enemy
	print("Closest enemy found:", current)
	return current

func _on_map_new_tower(tower) -> void:
	towers.append(tower)


func _on_monster_spawner_enemyspawn(enemy) -> void:
	enemies.append(enemy)
	
