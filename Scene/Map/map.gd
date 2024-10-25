extends Node3D

# For 2D games this will be the height/width of your hexagon sprite
@export var _cellSize: Vector2 = Vector2(1.17, 1.17)
@export var mapDiameter: int = 31
@export var mapRadius = (mapDiameter-1)/2
@export var BUMP: float = 0.02
@export var mapHeight: int = 5
@export var centerHillRadius: int = 6
@export var centerHillHeight:float = 1
var centerPixel
var centerTile
var worldmap: Dictionary = {}
var noisegen
func toggle(input:bool):
	if input:return false
	else: return true
func _ready():
	await get_tree().create_timer(0.4).timeout
	
	noisegen = FastNoiseLite.new()
	noisegen.frequency = BUMP
	noisegen.seed = randi()
	centerTile  = Vector2i(mapRadius,mapRadius)
	centerPixel = _cellToPixel(centerTile)[0]
	worldmap = initmap(mapDiameter)
	translate(Vector3(-centerPixel.x, 0, -centerPixel.y))

	# Set player position using get_tile_height
	var player = get_node("../../Player")
	var center_cell = Vector2i((mapDiameter - 1) / 2, (mapDiameter - 1) / 2)
	player.position = Vector3(0, get_tile_height(center_cell)+4, 0)

	generateMap()
	#generateAltMap()
	placeCentralCastle()

	var endTime = Time.get_unix_time_from_system()
	print(endTime - Time.get_unix_time_from_system())
	done.emit()
	$"..".bake_navigation_mesh(0)
	enemy.emit(mapRadius,_cellSize,Vector3(centerPixel.x-mapRadius*_cellSize.x,get_tile_height(centerTile),centerPixel.y-mapRadius*_cellSize.y))
	

signal done
signal enemy
signal castlePlaced
func placeCentralCastle():
	var coord = Vector3(centerPixel.x, get_tile_height(centerTile), centerPixel.y)
	var castle = placeBlock("Castle", coord)
	castlePlaced.emit(castle.global_transform.origin)
	print(castle.position, "centre", coord)
	

	# Now adjust the neighbors
	var neighbors = get_neighbors(centerTile)
	for neighbor in neighbors:
		# Make sure the neighbor is valid in the world map
		if worldmap.has(str(neighbor)):
			# Set the neighbor's height to match the castle's height
			
			var neighbor_pixel = _cellToPixel(neighbor)[0]
			var tileCoords = Vector3(neighbor_pixel.x, get_tile_height(centerTile), neighbor_pixel.y)
			var grass = placeBlock("defaultGrass", tileCoords,true,true,true)
			grass.scale *= Vector3(1.001,1,1.001)
			worldmap[str("built",Vector2i(neighbor.x,neighbor.y))]=true
	worldmap[str("built",Vector2i(centerTile.x,centerTile.y))]=true
	castle.updateHealth.connect($"../../CanvasLayer/HUD"._on_castle_health)


func _cellToPixel(cell: Vector2) -> Array:
	# Hex grid to pixel conversion
	var x = (sqrt(3.0) * cell.x + sqrt(3.0) / 2.0 * cell.y) * _cellSize.x
	var y = (3.0 / 2.0 * cell.y) * _cellSize.y
	
	# Get noise-based offset and apply falloff
	var offset = noisegen.get_noise_2dv(cell) * mapHeight
	if offset < 0:
		offset = -offset  # Ensure positive offset
	
	# Return pixel coordinates and clamped offset
	return [Vector2(x, y), clamp(offset, 0, INF)]

func get_tile_height(cell: Vector2i) -> float:
	# Convert the cell coordinates to pixel coordinates
	var pixel_position = _cellToPixel(cell)
	var height_offset: float = pixel_position[1]

	# Calculate the distance from the center of the map
	var map_radius = (mapDiameter - 1) / 2
	var center = Vector2(map_radius, map_radius)
	var distance = cell.distance_to(center)

	# Apply the falloff based on the distance from the center
	var falloff_value = falloff(distance, centerHillRadius)
	height_offset *= falloff_value

	# Return the final height including any translation offset due to the map's center
	return height_offset

# Initializes the world map
func initmap(diameter):
	var radius: int = (diameter - 1) / 2
	var world_map = {}
	for y in range(diameter):
		for x in range(diameter):
			if (x + y) < radius or (x + y) > radius * 3:
				world_map[str(Vector2i(x, y))] = null
			else:
				world_map[str(Vector2i(x, y))] = true
				world_map[str("built",Vector2i(x,y))] = false
	return world_map

func falloff(distance: float, radius: float) -> float:
	if distance < radius:
		return 1 + centerHillHeight * pow(1 - (distance / radius), 2)
	else:
		return 1  # No change to tiles outside the radius

func generateMap():
	var TileLibrary = preload("res://Scene/Map/Library.tscn")
	for x in range(mapDiameter):
		for y in range(mapDiameter):
			var cell = Vector2i(x, y)
			if worldmap[str(cell)]:
				var tilePosition = _cellToPixel(cell)
				var coord: Vector2 = tilePosition[0]
				# Set the height of the tile using the new get_tile_height function
				var offset: float = get_tile_height(cell)
				var tileCoords = Vector3(coord.x, offset, coord.y)
				placeBlock("defaultGrass",tileCoords, 0,1)


func pixel_to_pointy_hex(point: Vector2) -> Vector2i:
	# Reverse the calculation done in _cellToPixel
	var x = (point.x * sqrt(3) / 3 - point.y / 3) / _cellSize.x
	var y = (2 * point.y / 3) / _cellSize.y
	return Vector2i(round(x), round(y))

@onready var ray = $"../../Player/Pivot/Camera3D/Ray"
signal rebake
signal add_to_geometry(Tile, coordinates)
func placeBlock(blockID: String, coordinates: Vector3, debug: bool = true, basemap: bool = false,centergrass:bool=false):
	# Convert world coordinates (ray collision) to grid coordinates
	
	var cellCoords = pixel_to_pointy_hex(Vector2(coordinates.x, coordinates.z))
	if worldmap[str("built",Vector2i(cellCoords.x,cellCoords.y))]==true:
		return
	# Get the tile's correct height based on grid coordinates
	var tile_height = get_tile_height(cellCoords)
	
	if debug:
		print(tile_height, "from get_tile_height")
		#print("raycast collision coordinates", coordinates)
		#print("difference in height", tile_height - coordinates.y)

	# Calculate the pixel position of the grid cell
	var pixel_position = _cellToPixel(cellCoords)[0]
	var center_offset = _cellToPixel(Vector2((mapDiameter - 1) / 2, (mapDiameter - 1) / 2))[0]
	if centergrass:
		tile_height = coordinates.y
	# Adjust the final position by taking the center offset into account
	var tileCoords = Vector3(pixel_position.x , tile_height, pixel_position.y )
	
	# Instantiate and position the tile
	var TileLibrary = preload("res://Scene/Map/Library.tscn")
	var hexTile = TileLibrary.instantiate().find_child(blockID)
	hexTile.position = tileCoords
	add_to_geometry.emit(hexTile, tileCoords)
	# Optionally scale the tile if scalee is true
	if basemap:
		hexTile.scale = Vector3(1, 1 + tile_height, 1)

	# Clean up and add the tile to the scene
	hexTile.get_parent().remove_child(hexTile)
	hexTile.set_owner(null)
	add_child(hexTile)
	if not basemap: 
		worldmap[str("built",Vector2i(cellCoords.x,cellCoords.y))]=true
		rebake.emit()
	return hexTile


	
func get_neighbors(cell: Vector2i) -> Array:
	# These are the six neighbors for a pointy-topped hexagonal grid
	var directions = [
		Vector2i(1, 0),  # Right
		Vector2i(1, -1), # Top-right
		Vector2i(0, -1), # Top-left
		Vector2i(-1, 0), # Left
		Vector2i(-1, 1), # Bottom-left
		Vector2i(0, 1)   # Bottom-right
	]
	
	var neighbors = []
	for dir in directions:
		neighbors.append(cell + dir)
	return neighbors

func build():
	if ray.get_collision_normal().y == 1:
			# Get the block type from UI
			var blocktype = $"../../CanvasLayer/HUD".getActive()
			
			# Get the collision point from the raycast
			var collision_point = ray.get_collision_point()
			collision_point.x +=centerPixel.x
			collision_point.z +=centerPixel.y
			# Place the block at the raycast hit location
			placeBlock(blocktype, collision_point)
signal removalqueue(action:bool,object:Variant)
func remove_building():
	var building = ray.get_collider()
	print(building)
	if !building.player_destructible:
		
		return
	if building.highlight:
		building.highlight = false
		removalqueue.emit(false,building)
		print("attempting to remove highlight to building")

	else:
		building.highlight = true
		removalqueue.emit(true,building)
		print("attempting to add highlight to building")
