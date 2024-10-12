extends StaticBody3D
@export var health = 50:
	set(value):
		health = value
		if value<=0:
			startdie()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
signal castleGone
func startdie():
	castleGone.emit()

func die():
	self.queue_free()
func _on_area_3d_body_entered(body: Node3D) -> void:
	print("castle collided")
	if body.is_in_group("Enemy"): 
		if body.cooldown<=0: 
			body.attack()
			print("attempting attack")
			health -= body.damage
			print(health)
			
