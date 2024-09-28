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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active:
		timer+=1
		if timer>20 and active and currentmobs<maxmobs:
			skel = preload("res://Scenes/Enemy.tscn")
			var skeleton = skel.instantiate()
			var spawnLoc = $defaultMonsterPath/PathFollow3D
			spawnLoc.progress_ratio = randf()
			skeleton.selfDie.connect(on_enemy_death)
			skeleton.position = spawnLoc.position
			skeleton.position.y = 10
			add_child(skeleton)
			print("spawned")
			timer=0
			currentmobs+=1
func setCentre(centrre):
	centre = centrre
	print(centre,"pathdestination")
	
func get_map_corners(mapRadius: int, cellSize: Vector2) -> Array:
	# Directions to the 6 hex corners in axial coordinates
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
func on_enemy_death():
	currentmobs-=1

func _on_map_enemy(mapRadius:int,_cellSize:Vector2,centrepixel) -> void:
	var curvee = Curve3D.new()
	var pointArray = get_map_corners(mapRadius,_cellSize)
	for d in range(6):
		curvee.add_point(pointArray[d])
	$defaultMonsterPath.curve = curvee
	centre = centrepixel
	active = 1
