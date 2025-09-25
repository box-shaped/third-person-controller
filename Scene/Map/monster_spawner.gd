extends Node
var timer = 0
var skel
var mapRadius
var active = 0
var maxmobs= 10
var currentmobs = 0
var centre 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$defaultMonsterPath.position.y = $"../NavigationRegion3D/Map".mapHeight

signal enemyspawn

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if active:
		timer+=1
		if timer>20 and active and currentmobs<maxmobs:
			skel = preload("res://Scene/Mobs/Enemy.tscn")
			var skeleton = skel.instantiate()
			var spawnLoc = $defaultMonsterPath/PathFollow3D
			spawnLoc.progress_ratio = randf()
			skeleton.selfDie.connect(on_enemy_death)
			skeleton.position = spawnLoc.position
			#skeleton.position.y = $"../NavigationRegion3D/Map".get_tile_height($"../NavigationRegion3D/Map".pixel_to_pointy_hex(Vector2(spawnLoc.position.x,spawnLoc.position.y)))+2
			$EnemyParent.add_child(skeleton)
			print("spawned",skeleton.position.y)
			enemyspawn.emit(skeleton)
			timer=0
			currentmobs+=1

# Sets the centre of the map for monster pathfinding
func setCentre(centrre):
	centre = centrre
	print(centre,"pathdestination")

# Directions to the 6 hex corners in axial coordinates
func get_map_corners(mapRadius: int, _cellSize: Vector2) -> Array:
	var directions = [
		Vector2i(1, 0),   # 0° (right)
		Vector2i(0, 1),   # 60° (top-right)
		Vector2i(-1, 1),  # 120° (top-left)
		Vector2i(-1, 0),  # 180° (left)
		Vector2i(0, -1),  # 240° (bottom-left)
		Vector2i(1, -1)   # 300° (bottom-right)
	]
	
	var corners = []
	
	# Iterate through the 6 directions and calculate the corner positions
	for direction in directions:
		
		# Scale the direction by map radius to get the outermost cell
		var corner_cell = direction * (mapRadius-5)
		
		# Convert the hex grid coordinate (corner_cell) to world coordinates
		var corner_world_position = $"../NavigationRegion3D/Map"._cellToPixel(Vector2(corner_cell.x, corner_cell.y))[0]  # Get the world position (x, y)
		
		# Store the corner's world coordinates
		corners.append(Vector3(corner_world_position.x, 0, corner_world_position.y))
		
	return corners

# Removes monsters from the monster count on their death
func on_enemy_death():
	currentmobs-=1

# Creates the monster spawn curve around the edge of the map
func _on_map_enemy(mapRadius:int,_cellSize:Vector2,centrepixel) -> void:
	var curvee = Curve3D.new()
	print("making monster spawn curve")
	var pointArray = get_map_corners(mapRadius,_cellSize)
	for d in range(6):
		print("adding at height", pointArray[d].y)
		curvee.add_point(pointArray[d]+Vector3(0,100,0))
	$defaultMonsterPath.curve = curvee
	centre = centrepixel
	active = 1
