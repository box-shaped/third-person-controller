extends Node3D
@export var velocity = Vector3(0,0,0)
@export var gravity = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_as_top_level(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position+=velocity*delta
	look_at(position+velocity)
	velocity.y-=gravity*delta

func _on_area_3d_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
