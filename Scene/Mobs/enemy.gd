extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@export var speed = 2
@export var health = 50:
	set(value):
		health = value
		if value<=0:
			die()
@export var attackcooldown:float = 5
@export var damage = 3
var cooldown = 0
# Called when the node enters the scene tree for the first time.
# Variables declared outside the function for caching and optimization
var next_location: Vector3 = Vector3() # Cache next path position
var next_path_update_time: float = 0.0 # Timer to control path updates
var threshold: float = 0.1 # Distance threshold to next position
const PATH_UPDATE_INTERVAL: float = 0.1 # How often to update the path in seconds
var veelocity: Vector3 = Vector3() # Store velocity for movement
var player_destructible = false


func _physics_process(delta: float) -> void:
	cooldown-=delta
	var current_location = global_transform.origin
	
	# Update path only at intervals or when agent is close to the next location
	next_path_update_time -= delta
	if next_path_update_time <= 0 or current_location.distance_to(next_location) < threshold:
		next_location = nav_agent.get_next_path_position()
		next_path_update_time = PATH_UPDATE_INTERVAL
		update_animation()
		
	# Calculate velocity if there's a valid path to follow
	var direction = next_location - current_location
	if direction.length() > threshold:  # Only move if there's meaningful distance
		velocity = direction.normalized() * speed
	else:
		velocity = Vector3()  # Stop moving if at destination
	
	# Move only if velocity is non-zero to avoid unnecessary calculations
	if velocity != Vector3(0,0,0):
		look_at(position+(velocity*Vector3(1,0,1)))
		move_and_slide()
signal selfDie
func die():
	self.queue_free()
	selfDie.emit()
signal attackSignal
func attack():
	cooldown = attackcooldown
	$Skeleton_Warrior/AnimationPlayer.play("Unarmed_Melee_Attack_Punch_A")
	print("he atacceth")
	attackSignal.emit(damage)
func update_animation():
	if !$Skeleton_Warrior/AnimationPlayer.is_playing():
		if cooldown>0:
			$Skeleton_Warrior/AnimationPlayer.play("Unarmed_Idle")
		else:
			$Skeleton_Warrior/AnimationPlayer.play("Walking_B")

func _ready():
	#nav_agent.target_location = $"..".centre
	#selfDie.connect($".."._on_enemy_death())
	$HeightGetterRay.add_exception($".")
	$HeightGetterRay.force_raycast_update()
	var pos = $HeightGetterRay.get_collision_point()
	#print("enemyspawnat",pos)
	if pos.y>0: position = pos
	
func update_target_location(target_location):
	nav_agent.target_location = target_location
	var dir = Vector3(nav_agent.target_location.x,position.y,nav_agent.target_location.z)
	if !dir==position: look_at(dir)
	pass
