extends Node3D


# Called when the node enters the scene tree for the first time.

var mapDone = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if mapDone:
		#var raycast = $"../SpringArmPivot/SpringArm3D/Camera3D/Ray"
		#set_position(raycast.get_collision_point())
		pass


func _on_map_done() -> void:
	mapDone = true
	
