extends Building


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

signal get_closest(origin:Vector3)

func _shoot(target:Vector3):
	$Base/Gun/Barrel/ProjectileSpawner.shoot(($Base/Gun/Barrel.global_position.direction_to(target)).normalized()*50)
	$Targetingmarker.global_position = target
	print("Tower sending ", target, "To proj spawner")

func _track_target(target:Vector3):
	
	if _check_line_of_sight(target):
		$Targetingmarker.global_position = target
		$Base/Gun.look_at(target)
		print("valide LoS")
	
	else: print("invalide LoS")

func _check_line_of_sight(target:Vector3):
	$Base/Gun/RayCast3D.look_at(target)
	
	if $Base/Gun/RayCast3D.get_collider():
		
		if $Base/Gun/RayCast3D.get_collider().is_in_group("Enemy"):
			return true
	
	else:
		return false
