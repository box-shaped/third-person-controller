extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func explode():
	$GPUParticles3D.emit_particle()
	$GPUParticles3D2.emit_particle()
	$ExplosionSfx.play()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
