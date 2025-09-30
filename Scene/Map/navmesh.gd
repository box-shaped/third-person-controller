extends NavigationRegion3D

var geometry := NavigationMeshSourceGeometryData3D.new()
var added_positions := {} # Tracks tile positions to prevent duplicates
var needs_rebake := false # Flag for batching rebakes

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	# If we deferred a rebake, do it at the start of the frame
	if needs_rebake:
		_on_map_rebake()
		needs_rebake = false

# Rebakes geometry
func _on_map_rebake() -> void:
	NavigationServer3D.bake_from_source_geometry_data(self.navigation_mesh, geometry)
	bake_navigation_mesh(0)
	print("Navigation mesh rebaked.")

# Adds a tile's collision geometry to the navmesh safely
func _on_map_add_to_geometry(Tile: Node, coordinates: Vector3) -> void:
	# Convert coordinates to a key (rounded to avoid floating point issues)
	var key = Vector3(round(coordinates.x), round(coordinates.y), round(coordinates.z))
	if key in added_positions:
		print("Tile already added at this position:", key)
		return
	added_positions[key] = true

	var transform := Transform3D(Basis(), coordinates)

	# 1. Check for CollisionShape3D
	var collision_shape := Tile.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision_shape and collision_shape.shape:
		var cpu_mesh: Mesh = collision_shape.shape.get_debug_mesh()
		if cpu_mesh:
			geometry.add_mesh(cpu_mesh, transform)
			#print("Added CollisionShape3D at", coordinates)
			needs_rebake = true
			return

	# 2. Check for CollisionPolygon3D
	var collision_polygon := Tile.get_node_or_null("CollisionPolygon3D") as CollisionPolygon3D
	if collision_polygon:
		var polygon := collision_polygon.polygon
		if polygon.size() >= 3:
			var st := SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)

			# Build a flat polygon on XZ plane at y=0
			for i in range(1, polygon.size() - 1):
				st.add_vertex(Vector3(polygon[0].x, 0, polygon[0].y))
				st.add_vertex(Vector3(polygon[i].x, 0, polygon[i].y))
				st.add_vertex(Vector3(polygon[i + 1].x, 0, polygon[i + 1].y))

			var cpu_mesh := st.commit()
			if cpu_mesh:
				geometry.add_mesh(cpu_mesh, transform)
				#print("Added CollisionPolygon3D at", coordinates)
				needs_rebake = true
				return

	# 3. Fallback: use visual mesh (slow)
	var mesh_instance := Tile.get_child(0) as MeshInstance3D
	if mesh_instance and mesh_instance.mesh:
		geometry.add_mesh(mesh_instance.mesh, transform)
		#print("Added visual MeshInstance3D at", coordinates)
	else:
		print("Tile has no usable geometry:", Tile)

	# Defer rebake until next frame for batching
	needs_rebake = true
