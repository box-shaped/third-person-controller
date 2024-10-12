extends Node3D

@export_group("FOV")
@export var change_fov_on_run : bool
@export var normal_fov : float = 75.0
@export var run_fov : float = 90.0
@export var defaultsensitivity:float = 0.003
var sensitivity:float = defaultsensitivity
const CAMERA_BLEND : float = 0.05

@onready var pivot : Node3D = $"."
@onready var camera : Camera3D = $Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		$"..".rotate_y(-event.relative.x * sensitivity)
		pivot.rotate_x(-event.relative.y * sensitivity)
		pivot.rotation.x = clamp(pivot.rotation.x, -PI/2.3, PI/2.3)
		print("work i pray")

func _physics_process(_delta):
	if change_fov_on_run:
		if owner.is_on_floor():
			if Input.is_action_pressed("run"):
				camera.fov = lerp(camera.fov, run_fov, CAMERA_BLEND)
			else:
				camera.fov = lerp(camera.fov, normal_fov, CAMERA_BLEND)
		else:
			camera.fov = lerp(camera.fov, normal_fov, CAMERA_BLEND)
	var event = Input
	if event is InputEventMouseMotion:
		$"..".rotate_y(-event.relative.x * sensitivity)
		pivot.rotate_x(-event.relative.y * sensitivity)
		pivot.rotation.x = clamp(pivot.rotation.x, -PI/2.3, PI/2.3)
