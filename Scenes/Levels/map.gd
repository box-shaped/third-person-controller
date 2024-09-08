extends Node3D

#For 2D games this will be the hight/width of your hexagon sprite
@export var _cellSize : Vector2 = Vector2(1,1)
@export var _mapSize : Vector2 = Vector2(5,10)

func _ready():
	_generateHexTileMap()
	
			
func _generateHexTileMap():
	for x in range(-10,_mapSize.x):
		for y in range(-_mapSize.y,5):
			var TileLibrary = preload("res://Library.tscn").instantiate()
			var hexTile = TileLibrary.get_child(0)
			var cell = Vector2(x,y)
			var tilePosition =  _cellToPixel(cell)
			#For 2D games use hexTile.position = tilePosition
			var offset: float = (randf()/4)
			hexTile.position = Vector3(tilePosition.x,offset, tilePosition.y)
			hexTile.scale = (Vector3(1,1+offset,1))
			hexTile.get_parent().remove_child(hexTile)
			add_child(hexTile)
			
func _cellToPixel(cell : Vector2) -> Vector2:
	var x = (sqrt(3.0) * cell.x + sqrt(3.0) / 2.0 * cell.y) * _cellSize.x
	var y = (0.0 * cell.x + 3.0 / 2.0 * cell.y) * _cellSize.y
	return Vector2(x, y)
