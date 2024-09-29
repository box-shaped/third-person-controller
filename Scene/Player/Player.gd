extends CharacterBody3D

const LERP_VALUE : float = 0.15

var snap_vector : Vector3 = Vector3.DOWN
var speed : float

@export_group("Movement variables")
@export var walk_speed : float = 3.0
@export var run_speed : float = 6.0
@export var jump_strength : float = 15.0
@export var gravity : float = 30.0
@export var hipfire_pos:Vector3 = Vector3(0.97,-0.66,-0.66)
@export var ADS_pos:Vector3 = Vector3(0.,-0.265,-0.5)
@export var ADS_LERP = 20
@export var fovs = {"Hipfire":70,"ADS":40}
var senseratio = 0.5
#fovs["ADS"]/fovs["Hipfire"]

const ANIMATION_BLEND : float = 7.0

@onready var player_mesh : Node3D = $Mesh
@onready var spring_arm_pivot : Node3D = $Pivot
@onready var animator : AnimationTree = $AnimationTree
@onready var marker = $"../Buildmarker"
@onready var ray = find_child("Ray")
@onready var gun = $Pivot/Camera3D/Gun
@onready var camera = $Pivot/Camera3D

func _ready():
	ray.add_exception($".")
#input_event(find_node("Camera3D"), event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int)
func _physics_process(delta):
	if ray.is_colliding():
		marker.position = ray.get_collision_point()
	
	var move_direction : Vector3 = Vector3.ZERO
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_direction.z = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")
	move_direction = move_direction.rotated(Vector3.UP, rotation.y)
	
	velocity.y -= gravity * delta
	
	if Input.is_action_pressed("run"):
		speed = run_speed
	else:
		speed = walk_speed
	
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	
	if move_direction:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)
	
	var just_landed := is_on_floor() and snap_vector == Vector3.ZERO
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("jump")
	if is_jumping:
		velocity.y = jump_strength
		snap_vector = Vector3.ZERO
	elif just_landed:
		snap_vector = Vector3.DOWN
	
	apply_floor_snap()
	move_and_slide()
	#animate(delta)
signal crosshair(visible:bool)
func animate(delta):
	if is_on_floor():
		animator.set("parameters/ground_air_transition/transition_request", "grounded")
		
		if velocity.length() > 0:
			if speed == run_speed:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 1.0, delta * ANIMATION_BLEND))
			else:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 0.0, delta * ANIMATION_BLEND))
		else:
			animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), -1.0, delta * ANIMATION_BLEND))
	else:
		animator.set("parameters/ground_air_transition/transition_request", "air")

#func _input(event):
	#if event.is_action_pressed("Build"):
		#if ray.is_colliding():
			#if ray.get_collider().is_in_group("Enemy"):
				#shoot()
func ADS(delta):
	gun.transform.origin = gun.transform.origin.lerp(ADS_pos, ADS_LERP * delta)
	camera.fov=lerpf(camera.fov,fovs["ADS"],ADS_LERP*delta*0.75)
	$Pivot.sensitivity=$Pivot.defaultsensitivity*senseratio
	crosshair.emit(0)
func Hip(delta):
	gun.transform.origin = gun.transform.origin.lerp(hipfire_pos, ADS_LERP * delta)
	camera.fov=lerpf(camera.fov,fovs["Hipfire"],ADS_LERP*delta*0.75)
	$Pivot.sensitivity=$Pivot.defaultsensitivity
	crosshair.emit(1)
func shoot():
	var shot_at
	if $AnimationPlayer.is_playing() and $AnimationPlayer.current_animation == "assaultFire":
		return
	if ray.get_collider(): 
		shot_at = ray.get_collider()
		if shot_at.is_in_group("Enemy"):
			shot_at.health -= 25
	$Pivot/Camera3D/Gun/muzzleFlash.muzzleFlash()
	$AnimationPlayer.play("assaultFire")
	$"Single-gunshot-52-80191".play()
