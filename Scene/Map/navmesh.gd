extends NavigationRegion3D
var  geometry := NavigationMeshSourceGeometryData3D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_map_rebake() -> void:
	NavigationServer3D.bake_from_source_geometry_data(self.navigation_mesh,geometry)


func _on_map_add_to_geometry(Tile: Variant, coordinates: Variant) -> void:
	geometry.add_mesh(Tile.get_child(0),Transform3D(Basis(),coordinates))
	print("added to geometry",Tile.get_child(0),Transform3D(Basis(),coordinates))
