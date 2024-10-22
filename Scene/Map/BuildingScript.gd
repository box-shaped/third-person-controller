class_name Building
extends StaticBody3D

@export var player_destructible:bool = true

@export var enemy_destructible:bool = true
@export var highlight = false:
	set(newvalue):
		if newvalue==true:
			highlight = newvalue
			addhighlight()
		else:
			highlight = newvalue
			removehighlight()

func addhighlight():
	var meshes = find_children("","MeshInstance3D")
	for mesh in meshes:
		mesh.mesh.surface_get_material(0).albedo_color = Color(1,0.4,0.4,1)
func removehighlight():
	var meshes = find_children("","MeshInstance3D")
	for mesh in meshes:
		mesh.mesh.surface_get_material(0).albedo_color = Color(1,1,1,1)
