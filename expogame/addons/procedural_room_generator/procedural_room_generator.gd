@tool
extends EditorPlugin

var dock # Global Dock Location
var delete_script
var seed_script



# Define the Room class
class Room:
	var zPlusSlotOccupied: bool = false
	var zMinusSlotOccupied: bool = false
	var xPlusSlotOccupied: bool = false
	var xMinusSlotOccupied: bool = false
	var xWidth: int
	var zDepth: int
	var name: String

	func _init(name: String, xWidth: int, zDepth: int):
		self.xWidth = xWidth
		self.zDepth = zDepth
		self.name = name

# List to hold all the Room objects
var roomsArray: Array = []


# Declare the grid as a dictionary
var grid: Dictionary = {}

# Function to set a value in the grid (indicating if the space is filled)
func set_value(x: int, y: int, value: bool):
	grid[Vector2(x, y)] = value

# Function to check if a value in the grid is filled
func is_filled(x: int, y: int) -> bool:
	return grid.get(Vector2(x, y), false)  # Default to false if the key doesn't exist

# Function to check a range of cells (returns true if any cell in the range is filled)
func check_range(x_min: int, x_max: int, y_min: int, y_max: int) -> bool:
	for x in range(x_min, x_max + 1):
		for y in range(y_min, y_max + 1):
			if is_filled(x, y):  # If any cell in the range is filled, return true
				return true
	return false  # No filled cells found




func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	dock = preload("res://addons/procedural_room_generator/plugin_gui.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_BL, dock)
	
	seed_script = preload("res://addons/procedural_room_generator/seed_generator.gd").new()
	# fetch seeding script
	
	delete_script = preload("res://addons/procedural_room_generator/delete_node.gd").new()
	# fetch delete button script
	
	# to grab controls from the dock simply right click the control and copy path
	var generate_button = dock.get_node("ControlsVContainer/GenerateButtonPanel/Generate_Button")
	generate_button.pressed.connect(_on_generate_button_pressed)
	
	var delete_button = dock.get_node("Controls_VContainer/Delete_Button_Panel/Delete_Button")
	delete_button.pressed.connect(_on_delete_button_pressed)
	
	
	


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_control_from_docks(dock)
	dock.free()
	
func _on_generate_button_pressed() -> void:
	
		#now make the first room
	#choose a direction randomly and make a second room of random length and width
	#repeat that process for another 
	
	# Create a RandomNumberGenerator instance
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()  # Seed the generator (optional)
	
	# Generate random numbers
	var numOfRooms = dock.get_node("ControlsVContainer/RoomCountPanel/HBoxContainer/Ratio_Input")  # Random integer between 1 and 100
	#var random_float = rng.randf()           # Random float between 0 and 1
	#var random_float_range = rng.randf_range(-5.0, 5.0)  # Random float in range [-5.0, 5.0]

	print("Number of Rooms: ", numOfRooms)
	
	
	
	# Create room array
	# First clear the array
	roomsArray.clear()
	for i in range(numOfRooms):
		var x_width = rng.randi_range(1, 10)  # Random width between 1 and 10
		var z_depth = rng.randi_range(1, 10)  # Random depth between 1 and 10
		
		# Create a new room and add it to the list
		var new_room = Room.new("room" + str(i), x_width, z_depth)
		roomsArray.append(new_room)
		
		
		
	for room in roomsArray:
		print("Name: ", room.name, ", xWidth: ", room.xWidth, ", zDepth: ", room.zDepth, ", Bools: ", 
			room.xPlusSlotOccupied, room.xMinusSlotOccupied, room.zPlusSlotOccupied, room.zMinusSlotOccupied)
	
	# now that the list of rooms was created 
	# for each room in the list (starting at the second)
	# go through each room in the list looking for an open slot.
	# when you find one update the slot and the location and the 
	
	
	# for the first room: set the xPlusSlot to true
	# for each room in the list: get the 
	
	# need to make spawnpoint member variables for the rooms. one for each direction
	
	# for each room in the list except the last: get the north spawn point
	# create the next room (dir is 1)
	var nextSpawnPoint = Vector3(0,0,0)
	# Loop through every room except the last
	for i in range(roomsArray.size() - 1):
		# Access the current room
		var current_room = roomsArray[i]
		
		# Access the next room
		var next_room = roomsArray[i + 1]
		
		current_room.zPlusSlotOccupied = true
		nextSpawnPoint = Vector3(nextSpawnPoint.x, nextSpawnPoint.y, nextSpawnPoint.z + current_room.zDepth/2)
		if i==0:
			nextSpawnPoint=Vector3(0,0,0)
			generate_room2(current_room.name, nextSpawnPoint, 0, current_room.xWidth, current_room.zDepth, false, false, false, false)
		else:
			generate_room2(current_room.name, nextSpawnPoint, 0, current_room.xWidth, current_room.zDepth, false, false, false, false)
		nextSpawnPoint = Vector3(nextSpawnPoint.x, nextSpawnPoint.y, nextSpawnPoint.z + current_room.zDepth/2 + 1)
		
		
	#var r = roomsArray[1]
	#generate_room2(r.name, Vector3(0,0,0), 0, r.xWidth, r.zDepth, false, false, false, false)
	
	
	
	
	
	
	print("Generate button pressed!")
	var x_input = 0
	var y_input = 0
	var furniture = 0
	x_input = int((dock.get_node("Controls_VContainer/Room_Dimensions_Panel/Room_Dimensions/HBoxContainer/X_Input")).text)
	y_input = int((dock.get_node("Controls_VContainer/Room_Dimensions_Panel/Room_Dimensions/HBoxContainer/Y_Input")).text)
	var roof = bool((dock.get_node("Controls_VContainer/Roof_Panel/Roof/Roof_Toggle_Button")).button_pressed)
	print((x_input + y_input), y_input, roof)
	# now call the room generation script here with the above vars!
	#generate_room(x_input,y_input)
	#var spawnDir = 0
	#generate_room2("room1", Vector3(0, 0, 0), spawnDir, x_input, y_input, false, false, false, false)
	
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
	


func generate_room2(name, spawnPos, spawnDir, xWidth, zDepth, hasZPlusDoor, hasZMinusDoor, hasXMinusDoor, hasXPlusDoor) -> void:
	var room = Node3D.new()
	room.name = name
	var room_mesh = MeshInstance3D.new()
	var box_mesh = create_custom_room_mesh2(spawnPos, spawnDir, xWidth, zDepth, hasZPlusDoor, hasZMinusDoor, hasXMinusDoor, hasXPlusDoor)
	
	room_mesh.mesh = box_mesh
	room.add_child(room_mesh)
	#room.position = Vector3(10, 5, -3) #where did this line come from?
	
	var finalPosition
	
	
	match spawnDir:
		0:#this is no direction; centered
			finalPosition = spawnPos
		1:#this is ZPlus
			finalPosition = Vector3(spawnPos.x, spawnPos.y, spawnPos.z + zDepth/2)#x,y,z
		2:#this is ZMinus
			finalPosition = Vector3(spawnPos.x, spawnPos.y, spawnPos.z - zDepth/2)
		3:#this is XPlus
			finalPosition = Vector3(spawnPos.x + xWidth, spawnPos.y, spawnPos.z)
		4:#this is XMinus
			finalPosition = Vector3(spawnPos.x - xWidth, spawnPos.y, spawnPos.z)
		_:
			print("Invalid spawn direction")
	
	
	
	room.position = finalPosition
	
	var current_scene = get_tree().edited_scene_root
	current_scene.add_child(room)
	room.owner = current_scene
	
	print("Room generated:", room.name)
	


func create_custom_room_mesh2(spawnPos, spawnDir, xWidth, zDepth, hasZPlusDoor, hasZMinusDoor, hasXMinusDoor, hasXPlusDoor) -> ArrayMesh:
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
	
	#this is the bottom face
	for square_vert in squareVerts:  #bottomface
		vertices.append(square_vert)
		# no rotation needed
	
	
	
	
	# this is the front face
	if hasZPlusDoor:
		#add door verts
		for doorWallVert in doorWallVerts:
			pass
			
	else:
		#add square verts
		for square_vert in squareVerts:
			var rotation_matrix = Basis().rotated(Vector3(1, 0, 0), deg_to_rad(-90))#front face
			var rotated_vector = rotation_matrix * square_vert
			vertices.append(Vector3(rotated_vector.x, rotated_vector.y + .4, rotated_vector.z+.5))
	
	
	
	
	# this is the back face
	if hasZMinusDoor:
		#add door verts
		for doorWallVert in doorWallVerts:
			pass
			
	else:
		#add square verts
		for square_vert in squareVerts:
			var rotation_matrix = Basis().rotated(Vector3(1, 0, 0), deg_to_rad(90))
			var rotated_vector = rotation_matrix * square_vert
			vertices.append(Vector3(rotated_vector.x, rotated_vector.y + .5, rotated_vector.z-.5))
	
	
	
	
	# this is the right face
	if hasXPlusDoor:
		#add door verts
		for doorWallVert in doorWallVerts:
			pass
			
	else:
		#add square verts
		for square_vert in squareVerts:
			var rotation_matrix = Basis().rotated(Vector3(0, 0, 1), deg_to_rad(-90))
			# Apply the rotation to the original vector
			var rotated_vector = rotation_matrix * square_vert
			vertices.append(Vector3(rotated_vector.x-.5, rotated_vector.y + .5, rotated_vector.z))
	
	
	
	
	
	# this is the left face
	if hasXMinusDoor:
		#add door verts
		for doorWallVert in doorWallVerts:
			pass
			
	else:
		#add square verts
		for square_vert in squareVerts:
			var rotation_matrix = Basis().rotated(Vector3(0, 0, 1), deg_to_rad(90))
			# Apply the rotation to the original vector
			var rotated_vector = rotation_matrix * square_vert
			vertices.append(Vector3(rotated_vector.x+.5, rotated_vector.y + .5, rotated_vector.z))
		
	
	
	var normals = PackedVector3Array([
		
		Vector3(0, 1, 0),  # Normal for bottomface
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		
		Vector3(0, 0, -1),   # Normals for frontface
		Vector3(0, 0, -1),
		Vector3(0, 0, -1),
		Vector3(0, 0, -1),
		Vector3(0, 0, -1),
		Vector3(0, 0, -1),
		
		Vector3(0, 0, 1),	# Normals for backface
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		
		Vector3(-1, 0, 0),	# Normals for rightface
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
		
		Vector3(1, 0, 0),	# Normals for leftface
		Vector3(1, 0, 0),
		Vector3(1, 0, 0),
		Vector3(1, 0, 0),
		Vector3(1, 0, 0),
		Vector3(1, 0, 0),
		
	])
	
	var xScale = xWidth
	var yScale = 3.0
	var zScale = zDepth
	
	for i in range(vertices.size()):  # Loop through each vertex in the array
		# Directly modify the elements in the vertices array
		vertices[i] = Vector3(vertices[i].x * xScale, vertices[i].y * yScale, vertices[i].z * zScale)
		
		
	var indices = PackedInt32Array([0, 1, 2, 3, 4, 5,      6, 7, 8, 9, 10, 11,      12,13,14,15,16,17,         18,19,20,21,22,23,        24,25,26,27,28,29])
	
	
	
	
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

	

	
