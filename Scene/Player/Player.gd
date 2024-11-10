extends CharacterBody3D

const LERP_VALUE : float = 0.15

var snap_vector : Vector3 = Vector3.DOWN
var speed : float

@export_group("Movement variables")
@export var walk_speed : float = 3.0
@export var run_speed : float = 6.0
@export var jump_strength : float = 15.0
@export var gravity : float = 30.0
@export var hipfire_pos:Vector3 = Vector3(0.5,0,-0.7)
@export var hipfire_angle:Vector3 = Vector3(0.03,0.05,0)
@export var ADS_pos:Vector3 = Vector3(0,-0.17,-0.4)
@export var ADS_LERP = 20
@export var fovs = {"Hipfire":70,"ADS":40}
@export var MAX_STEP_UP = 5
@export var MAX_STEP_DOWN = 5
@export var CAMERA_SMOOTHING = 1
@export var shotPower = 80
var senseratio = 0.4
#fovs["ADS"]/fovs["Hipfire"]

const ANIMATION_BLEND : float = 7.0

@onready var player_mesh : Node3D = $Mesh
@onready var spring_arm_pivot : Node3D = $Pivot
@onready var animator : AnimationTree = $AnimationTree
@onready var marker = $"../Buildmarker"
@onready var ray = find_child("Ray")
@onready var gun = $Pivot/Camera3D/GunParent
@onready var camera = $Pivot/Camera3D
@onready var CAMERA_HEAD = $Pivot/Camera3D
@onready var CAMERA_NECK = $Pivot


var is_grounded := true					# If player is grounded this frame
var was_grounded := true		
var wish_dir := Vector3.ZERO	
var vertical = Vector3(0,1,0)
var horizontal = Vector3(1,0,1)

func _ready():
	ray.add_exception($".")
#input_event(find_node("Camera3D"), event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int)
func _physics_process(delta):
	if ray.is_colliding():
		marker.position = ray.get_collision_point()
	wish_dir = velocity
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
	move_laser()
	apply_floor_snap()
	stair_step_up()#w
	#stair_step_down()
	smooth_camera_jitter(delta)
	move_and_slide()
	#animate(delta)
func move_laser():
	if $Pivot/Camera3D/GunParent/Gun/RayCast3D.get_collider()!=null:
		
		$Pivot/Camera3D/GunParent/Gun/light.global_position = $Pivot/Camera3D/GunParent/Gun/RayCast3D.get_collision_point()
		$Pivot/Camera3D/GunParent/Gun/light.position.z+=1
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
	gun.rotation = gun.rotation.lerp(Vector3(0,0,0), ADS_LERP * delta)

	#print(gun.transform.origin)
	camera.fov=lerpf(camera.fov,fovs["ADS"],ADS_LERP*delta*0.75)
	$Pivot.sensitivity=$Pivot.defaultsensitivity*senseratio
	crosshair.emit(0)
func Hip(delta):
	gun.transform.origin = gun.transform.origin.lerp(hipfire_pos, ADS_LERP * delta)
	gun.rotation =gun.rotation.lerp(hipfire_angle, ADS_LERP * delta)
	#print(gun.transform.origin)
	camera.fov=lerpf(camera.fov,fovs["Hipfire"],ADS_LERP*delta*0.75)
	$Pivot.sensitivity=$Pivot.defaultsensitivity
	crosshair.emit(1)
func shoot():
	var shot_at
	if $AnimationPlayer.is_playing() and $AnimationPlayer.current_animation == "assaultFire":
		return
	$Pivot/Camera3D/GunParent/Gun/ProjectileSpawner.shoot(-$Pivot/Camera3D/GunParent.global_transform.basis.z*shotPower)
	#if ray.get_collider(): 
		#shot_at = ray.get_collider()
		#if shot_at.is_in_group("Enemy"):
			#shot_at.health -= 25
	$Pivot/Camera3D/GunParent/Gun/muzzleFlash.muzzleFlash()
	$AnimationPlayer.play("assaultFire")
	$Gunshot.play()
	
	##### CODE FROM: https://github.com/JheKWall/Godot-Stair-Step-Demo/blob/main/Scripts/player_character.gd by JKWall #####
func stair_step_down():
	if is_grounded:
		return

	# If we're falling from a step
	if velocity.y <= 0 and was_grounded:

		# Initialize body test variables
		var body_test_result = PhysicsTestMotionResult3D.new()
		var body_test_params = PhysicsTestMotionParameters3D.new()

		body_test_params.from = self.global_transform			## We get the player's current global_transform
		body_test_params.motion = Vector3(0, MAX_STEP_DOWN, 0)	## We project the player downward

		if PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
			# Enters if a collision is detected by body_test_motion
			# Get distance to step and move player downward by that much
			position.y += body_test_result.get_travel().y
			apply_floor_snap()
			is_grounded = true

# Function: Handle walking up stairs
func stair_step_up():
	if wish_dir == Vector3.ZERO:
		return


	# 0. Initialize testing variables
	var body_test_params = PhysicsTestMotionParameters3D.new()
	var body_test_result = PhysicsTestMotionResult3D.new()

	var test_transform = global_transform				## Storing current global_transform for testing
	var distance = wish_dir * 0.1						## Distance forward we want to check
	body_test_params.from = self.global_transform		## Self as origin point
	body_test_params.motion = distance					## Go forward by current distance


	# Pre-check: Are we colliding?
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):

		## If we don't collide, return
		return

	# 1. Move test_transform to collision location
	var remainder = body_test_result.get_remainder()							## Get remainder from collision
	test_transform = test_transform.translated(body_test_result.get_travel())	## Move test_transform by distance traveled before collision

	# 2. Move test_transform up to ceiling (if any)
	var step_up = MAX_STEP_UP * vertical
	body_test_params.from = test_transform
	body_test_params.motion = step_up
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())
										## DEBUG

	# 3. Move test_transform forward by remaining distance
	body_test_params.from = test_transform
	body_test_params.motion = remainder
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())
										## DEBUG

	# 3.5 Project remaining along wall normal (if any)
	## So you can walk into wall and up a step
	if body_test_result.get_collision_count() != 0:
		remainder = body_test_result.get_remainder().length()

		### Uh, there may be a better way to calculate this in Godot.
		var wall_normal = body_test_result.get_collision_normal()
		var dot_div_mag = wish_dir.dot(wall_normal) / (wall_normal * wall_normal).length()
		var projected_vector = (wish_dir - dot_div_mag * wall_normal).normalized()

		body_test_params.from = test_transform
		body_test_params.motion = remainder * projected_vector
		PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
		test_transform = test_transform.translated(body_test_result.get_travel())


	# 4. Move test_transform down onto step
	body_test_params.from = test_transform
	body_test_params.motion = MAX_STEP_UP * -vertical

	# Return if no collision
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):

		return

	test_transform = test_transform.translated(body_test_result.get_travel())

	# 5. Check floor normal for un-walkable slope
	var surface_normal = body_test_result.get_collision_normal()
	print("SSU: Surface check: ", snappedf(surface_normal.angle_to(vertical), 0.001), " vs ", floor_max_angle)#!
	if (snappedf(surface_normal.angle_to(vertical), 0.001) > floor_max_angle):

		return
	print("SSU: Walkable")#!

	# 6. Move player up
	var global_pos = global_position
	var step_up_dist = test_transform.origin.y - global_pos.y

	velocity.y = 0
	global_pos.y = test_transform.origin.y
	global_position = global_pos

# Function: Smooth camera jitter
func smooth_camera_jitter(delta):
	CAMERA_HEAD.global_position.x = CAMERA_NECK.global_position.x
	CAMERA_HEAD.global_position.y = lerpf(CAMERA_HEAD.global_position.y, CAMERA_NECK.global_position.y, CAMERA_SMOOTHING * delta)
	CAMERA_HEAD.global_position.z = CAMERA_NECK.global_position.z
#
	## Limit how far camera can lag behind its desired position
	CAMERA_HEAD.global_position.y = clampf(CAMERA_HEAD.global_position.y,
										-CAMERA_NECK.global_position.y - 1,
										CAMERA_NECK.global_position.y + 1)
