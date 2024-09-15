extends Node3D

#For 2D games this will be the hight/width of your hexagon sprite
@export var _cellSize : Vector2 = Vector2(1.15,1.15)
@export var mapDiameter:int=101
@export var BUMP:float=0.03
@export var mapHeight = 10
var worldmap:Dictionary = {}
var noisegen = FastNoiseLite.new()

func _ready():
	await get_tree().create_timer(0.4).timeout
	var startTime = Time.get_unix_time_from_system()
	seed(7237)
	noisegen.frequency = BUMP
	#_generateHexTileMap()
	var center = _cellToPixel(Vector2((mapDiameter-1)/2,(mapDiameter-1)/2))
	worldmap = initmap(mapDiameter)
	translate(Vector3(-center[0].x, 0 ,-center[0].y))
	var player = get_node("../Player")
	
	player.position = Vector3(0, clamp(1*center[1],0,INF) ,0)
	generateMap()
	var endTime = Time.get_unix_time_from_system()
	print(endTime-startTime)
	done.emit()
signal done
func _cellToPixel(cell : Vector2) -> Array:
	var x = (sqrt(3.0) * cell.x + sqrt(3.0) / 2.0 * cell.y) * _cellSize.x
	var y = (0.0 * cell.x + 3.0 / 2.0 * cell.y) * _cellSize.y
	return [Vector2(x, y),noisegen.get_noise_2dv(cell)*mapHeight]
#I am so proud of how elegant this is
func initmap(diameter):
	var radius:int = (diameter-1)/2
	var world_map = {}
	for y in range(diameter):
		for x in range(diameter):
			if (x+y)<radius or (x+y)>radius*3:
				world_map[str(Vector2i(x,y))]=null
			else:
				world_map[str(Vector2i(x,y))]=true
	return(world_map)
func generateMap():
	var TileLibrary = preload("res://Library.tscn")
	for x in range(mapDiameter):
		for y in range(mapDiameter):
			var cell = Vector2i(x,y)
			if worldmap[str(cell)]:
				var tilePosition = _cellToPixel(cell)
				var offset: float = tilePosition[1]
				var coord:Vector2 = tilePosition[0]
				#print(offset)
				var hexTile
				if offset>50:
					hexTile = TileLibrary.instantiate().find_child("defaultGrass")
				else:
					hexTile = TileLibrary.instantiate().find_child("defaultGrass")
				var tileCoords = Vector3(coord.x,offset, coord.y)
				hexTile.position = tileCoords
				hexTile.scale = (Vector3(1,1+offset,1))
				hexTile.get_parent().remove_child(hexTile)
				hexTile.set_owner(null)
				add_child(hexTile)
func placeBlock(blockID:String, coordinates:Vector3):
	var co0ordinates = Vector2(coordinates.x, coordinates.z)
	var TileLibrary = preload("res://Library.tscn")
	var hexTile = TileLibrary.instantiate().find_child(str(blockID))
	var pixelCoords = pixel_to_pointy_hex(co0ordinates)
	var center = _cellToPixel(Vector2((mapDiameter-1)/2,(mapDiameter-1)/2))
	#translate(Vector3(-center[0].x, 0 ,-center[0].y))
	pixelCoords = _cellToPixel(pixelCoords)
	print(pixelCoords[1]+1)
	var tileCoords = Vector3(pixelCoords[0].x+center[0].x,coordinates.y, pixelCoords[0].y+center[0].y)
	hexTile.position = tileCoords
	print(tileCoords," SHOULD BE EQUAL TO VALUE BELOW")
	hexTile.get_parent().remove_child(hexTile)
	hexTile.set_owner(null)
	add_child(hexTile)
	print("BlockPlaced")
	print(hexTile.position)
	
func pixel_to_pointy_hex(point: Vector2) -> Vector2i:
	# Reverse the calculation done in cellToPixel
	var x = (point.x * sqrt(3) / 3 - point.y / 3) / _cellSize.x
	var y = (2 * point.y / 3) / _cellSize.y
	print("BlockPlaced")
	return Vector2i(round(x), round(y))
	
@onready var ray = $"../Player/SpringArmPivot/SpringArm3D/Camera3D/Ray"
func _input(event):
	if event.is_action_pressed("Build"):
		if ray.is_colliding():
			print(ray.get_collision_normal())
			if ray.get_collision_normal().y==1:
				var blocktype= $"../CanvasLayer/Control".getActive()
				print(blocktype)
				placeBlock(blocktype,ray.get_collision_point())
				print("raycollision",ray.get_collision_point())
				print("playerpos: ",$"../Player".position)

#code from https://www.redblobgames.com/grids/hexagons/
#var axial_direction_vectors = [
#    Hex(+1, 0), Hex(+1, -1), Hex(0, -1), 
#    Hex(-1, 0), Hex(-1, +1), Hex(0, +1), 
#]
#
#func axial_direction(direction):
#	return axial_direction_vectors[direction]
#
#func axial_add(hex, vec):
#	return Hex(hex.q + vec.q, hex.r + vec.r)
#
#func axial_neighbor(hex, direction):
#	return axial_add(hex, axial_direction(direction))
