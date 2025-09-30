extends Node

# Preload enemy scene once
@onready var enemy_scene: PackedScene = preload("res://Scene/Mobs/Enemy.tscn")

var timer: float = 0.0            # Accumulated time
var mapRadius
var active: bool = false
var maxmobs: int = 10
var currentmobs: int = 0
var centre

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$defaultMonsterPath.position.y = $"../NavigationRegion3D/Map".mapHeight

signal enemyspawn

# Called every frame. Uses delta for frame-independent spawning
func _process(delta: float) -> void:
	if active and currentmobs < maxmobs:
		timer += delta
		if timer >= 0.5:  # spawn interval in seconds
			spawn_enemy()
			timer = 0.0

# Extracted enemy spawn logic
func spawn_enemy() -> void:
	var skeleton = enemy_scene.instantiate()
	var spawnLoc = $defaultMonsterPath/PathFollow3D
	spawnLoc.progress_ratio = randf()
	skeleton.position = spawnLoc.position
	skeleton.selfDie.connect(on_enemy_death)
	$EnemyParent.add_child(skeleton)
	print("spawned", skeleton.position.y)
	enemyspawn.emit(skeleton)
	currentmobs += 1

# Sets the centre tile as the destination for pathfinding
func setCentre(c: Vector3):
	centre = c
	print(centre, "pathdestination")

# Decreases the mob count
func on_enemy_death():
	currentmobs -= 1

# Finds the corners of the map
func get_map_corners(mapRadius: int, _cellSize: Vector2) -> Array:
	var directions = [
		Vector2i(1, 0),
		Vector2i(0, 1),
		Vector2i(-1, 1),
		Vector2i(-1, 0),
		Vector2i(0, -1),
		Vector2i(1, -1)
	]
	var corners = []
	for direction in directions:
		var corner_cell = direction * (mapRadius - 5)
		var corner_world_position = $"../NavigationRegion3D/Map"._cellToPixel(Vector2(corner_cell.x, corner_cell.y))[0]
		corners.append(Vector3(corner_world_position.x, 0, corner_world_position.y))
	return corners

# Creates the monster spawn curve
func _on_map_enemy(mapRadius: int, _cellSize: Vector2, centrepixel) -> void:
	var curvee = Curve3D.new()
	print("making monster spawn curve")
	var pointArray = get_map_corners(mapRadius, _cellSize)
	for d in range(6):
		print("adding at height", pointArray[d].y)
		curvee.add_point(pointArray[d] + Vector3(0, 100, 0))
	$defaultMonsterPath.curve = curvee
	centre = centrepixel
	active = true
