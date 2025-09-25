extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Controlls muzzle flash
func muzzleFlash():
	$DirectionalLight3D.visible = true
	$GPUParticles3D.emitting = true
	await get_tree().create_timer(0.05).timeout
	$DirectionalLight3D.visible = false
