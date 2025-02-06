@tool
extends EditorPlugin

var dock # Global Dock Location
var delete_script


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	dock = preload("res://addons/procedural_room_generator/plugin_gui.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_BL, dock)
	
	delete_script = preload("res://addons/procedural_room_generator/delete_node.gd").new()
	# to grab controls from the dock simply right click the control and copy path
	var generate_button = dock.get_node("Controls_VContainer/Generate_Button_Panel/Generate_Button")
	generate_button.pressed.connect(_on_generate_button_pressed)
	
	var delete_button = dock.get_node("Controls_VContainer/Delete_Button_Panel/Delete_Button")
	delete_button.pressed.connect(_on_delete_button_pressed)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_control_from_docks(dock)
	dock.free()
	
func _on_generate_button_pressed() -> void:
	print("Generate button pressed!")
	var x_input = 0
	var y_input = 0
	var furniture = 0
	x_input = int((dock.get_node("Controls_VContainer/Room_Dimensions_Panel/Room_Dimensions/HBoxContainer/X_Input")).text)
	y_input = int((dock.get_node("Controls_VContainer/Room_Dimensions_Panel/Room_Dimensions/HBoxContainer/Y_Input")).text)
	var roof = bool((dock.get_node("Controls_VContainer/Roof_Panel/Roof/Roof_Toggle_Button")).button_pressed)
	print((x_input + y_input), y_input, roof)
	# now call the room generation script here with the above vars!
	generate_room(x_input,y_input)
	
func _on_delete_button_pressed() -> void:
	delete_script.call_deferred("delete_node_by_name", get_tree())

	













func generate_room(xWidth,zDepth) -> void:
	var room = Node3D.new()
	room.name = "Room_" + Time.get_time_string_from_system()

	var room_mesh = MeshInstance3D.new()
	var box_mesh = create_custom_room_mesh(xWidth, zDepth)
	
	room_mesh.mesh = box_mesh
	room.add_child(room_mesh)

	var current_scene = get_tree().edited_scene_root
	current_scene.add_child(room)
	room.owner = current_scene

	print("Room generated:", room.name)
	












func create_custom_room_mesh(xWidth, zDepth) -> ArrayMesh:
	# Create the ArrayMesh object
	var array_mesh = ArrayMesh.new()

	# Define the vertices for the square (using PackedVector3Array)
	var squareVerts = PackedVector3Array([
		Vector3(-.5, 0, -.5),  # back-left
		Vector3(.5, 0, -.5),   # back-right
		Vector3(.5, 0, .5),    # front-right

		Vector3(-.5, 0, -.5),  # back-left
		Vector3(.5, 0, .5),    # front-right
		Vector3(-.5, 0, .5)    # front-left
	])
	
	var doorWallVerts = PackedVector3Array([
		Vector3(-.5,0,0),
		Vector3(-.5,1,0),
		Vector3(-.5,3,0),
		Vector3(-.5,0,0),
		Vector3(-.5,3,0),
		Vector3(-.5,0,0),
		
		Vector3(-.5,2,0),
		Vector3(-.5,3,0),
		Vector3(.5,3,0),
		Vector3(-.5,2,0),
		Vector3(.5,3,0),
		Vector3(.5,2,0),
		
		Vector3(.5,0,0),
		Vector3(.5,3,0),
		Vector3(.5,1,0),
		Vector3(.5,0,0),
		Vector3(.5,1,0),
		Vector3(.5,0,0)
	])
	
	var vertices = PackedVector3Array([])
	
	for square_vert in squareVerts:  #bottomface
		vertices.append(square_vert)
	
	for square_vert in squareVerts:  #backface
		var rotation_matrix = Basis().rotated(Vector3(1, 0, 0), deg_to_rad(90))
		# Apply the rotation to the original vector
		var rotated_vector = rotation_matrix * square_vert
		vertices.append(Vector3(rotated_vector.x, rotated_vector.y + .5, rotated_vector.z-.5))
		
	for square_vert in squareVerts:  #leftface
		var rotation_matrix = Basis().rotated(Vector3(0, 0, 1), deg_to_rad(90))
		# Apply the rotation to the original vector
		var rotated_vector = rotation_matrix * square_vert
		vertices.append(Vector3(rotated_vector.x+.5, rotated_vector.y + .5, rotated_vector.z))
		
	for square_vert in squareVerts:  #rightface
		var rotation_matrix = Basis().rotated(Vector3(0, 0, 1), deg_to_rad(-90))
		# Apply the rotation to the original vector
		var rotated_vector = rotation_matrix * square_vert
		vertices.append(Vector3(rotated_vector.x-.5, rotated_vector.y + .5, rotated_vector.z))
		
	for doorWallVert in doorWallVerts: 
		var rotation_matrix = Basis().rotated(Vector3(0, 1, 0), deg_to_rad(180))
		var rotated_vector = rotation_matrix * doorWallVert
		vertices.append(Vector3(rotated_vector.x, rotated_vector.y, rotated_vector.z+.5))
	

	# Define normals for the square (using PackedVector3Array)
	var normals = PackedVector3Array([
		Vector3(0, 1, 0),  # Normal for all vertices (facing up)
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		
		Vector3(0, 0, 1),	# Normals for frontface
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		
		Vector3(1, 0, 0),	# Normals for frontface
		Vector3(1, 0, 0),
		Vector3(1, 0, 0),
		Vector3(1, 0, 0),
		Vector3(1, 0, 0),
		Vector3(1, 0, 0),
		
		Vector3(-1, 0, 0),	# Normals for frontface
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
		
		Vector3(0, 0, 1),   # Normals for doorWall
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),   
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),   
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		
		
	])

	# Define indices for the two triangles forming the square (using PackedInt32Array)
	var indices = PackedInt32Array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,      12,13,14,15,16,17,         18,19,20,21,22,23,                                              24,25,26,27,28,29,    30,31,32,33,34,35,    36,37,38,39,40,41])

	var xScale = xWidth
	var yScale = 3.0
	var zScale = zDepth

	for i in range(vertices.size()):  # Loop through each vertex in the array
		# Directly modify the elements in the vertices array
		vertices[i] = Vector3(vertices[i].x * xScale, vertices[i].y * yScale, vertices[i].z * zScale)
		
		
	#unscale the door (unscale the x for the door verts)
	for i in range(vertices.size()):  # Loop through each vertex in the array
		# Directly modify the elements in the vertices array
		if i == (3 + 23) or ((5 + 23) <= i and i <= (14 + 23)) or i == (16 + 23):
			vertices[i] = Vector3(vertices[i].x * 1.0/xScale, vertices[i].y* 1.0/yScale, vertices[i].z)
		


	# Create an array of arrays for the vertex attributes
	var arrays = Array()

	# Assign vertices, normals, and indices
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices

	# Commit the data to the ArrayMesh
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	return array_mesh

	

	
