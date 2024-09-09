extends Node3D

#For 2D games this will be the hight/width of your hexagon sprite
@export var _cellSize : Vector2 = Vector2(1,1)
@export var _mapSize : Vector2 = Vector2(5,10)
@export var mapDiameter:int=101
@export var BUMP:float=0.1
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
	player.translate(Vector3(0, 1+center[1] ,0))
	generateMap()
	var endTime = Time.get_unix_time_from_system()
	print(endTime-startTime)

func _cellToPixel(cell : Vector2) -> Array:
	var x = (sqrt(3.0) * cell.x + sqrt(3.0) / 2.0 * cell.y) * _cellSize.x
	var y = (0.0 * cell.x + 3.0 / 2.0 * cell.y) * _cellSize.y
	return [Vector2(x, y),noisegen.get_noise_2dv(cell)]
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
	
	for x in range(mapDiameter):
		for y in range(mapDiameter):
			var cell = Vector2i(x,y)
			if worldmap[str(cell)]:
				var TileLibrary = preload("res://Library.tscn")
				var hexTile = TileLibrary.instantiate().get_child(0)
				var tilePosition =  _cellToPixel(cell)
				#For 2D games use hexTile.position = tilePosition
				var offset: float = tilePosition[1]
				var coord:Vector2 = tilePosition[0]
				hexTile.position = Vector3(coord.x,offset, coord.y)
				hexTile.scale = (Vector3(1,1+offset,1))
				hexTile.get_parent().remove_child(hexTile)
				hexTile.set_owner(null)
				add_child(hexTile)
				
	

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
