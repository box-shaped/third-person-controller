extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func shoot(direction:Vector3):
	var bullet = preload("res://Scene/Player/bullet.tscn")
	bullet = bullet.instantiate()
	add_child(bullet)
	bullet.velocity = direction
	bullet.scale = Vector3(0.2,0.2,0.2)
