extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
signal get_closest(origin:Vector3)
func _shoot(target:Vector3):
	$Base/Gun/Barrel/ProjectileSpawner.shoot(($Base/Gun/Barrel.global_position.direction_to(target)).normalized()*50)
	$Targetingmarker.global_position = target
	print("Tower sending ", target, "To proj spawner")
	
