@tool
extends EditorPlugin

var dock # Global Dock Location
var delete_script



# Define the Room class
class Room:
	var zPlusSlotOccupied: bool = false
	var zMinusSlotOccupied: bool = false
	var xPlusSlotOccupied: bool = false
	var xMinusSlotOccupied: bool = false
	var xWidth: int
	var zDepth: int
	var name: String
	var location: Vector3
	var direction: int

	func _init(name: String, xWidth: int, zDepth: int):
		self.xWidth = xWidth
		self.zDepth = zDepth
		self.name = name
		

class Hallway:
	var dir: int #1 for north-south, 2 for east-west
	var location: Vector3
	
	func _init(dir: int, location: Vector3):
		self.location = location
		self.dir = dir


var hallwayArray: Array = []

# List to hold all the Room objects
var roomsArray: Array = []

# Int to hold the length of the hallways between rooms
const hallLength: int = 1

# Declare the grid as a dictionary
var grid: Dictionary = {}

# Function to set a value in the grid (indicating if the space is filled)
func set_value(x: int, y: int):
	# Add the coordinate to the dictionary with a null value (marks it as filled)
	grid[Vector2(x, y)] = null

# Function to check if a value in the grid is filled
func is_filled(x: int, y: int) -> bool:
	# Check if the coordinate exists in the dictionary
	return grid.has(Vector2(x, y))

# Function to check a range of cells (returns true if any cell in the range is filled)
func check_range(x_min: int, x_max: int, y_min: int, y_max: int) -> bool:
	for x in range(x_min, x_max + 1):
		for y in range(y_min, y_max + 1):
			if is_filled(x, y):  # If any cell in the range is filled, return true
				return true
	return false  # No filled cells found

# Function to add coordinates in the specified range to the grid (marking them as filled)
func add_range_to_grid(xmin: int, xmax: int, ymin: int, ymax: int):
	# Iterate through the range and add each coordinate to the dictionary (marking them as filled)
	for x in range(xmin, xmax + 1):
		for y in range(ymin, ymax + 1):
			grid[Vector2(x, y)] = null  # Simply add the coordinate to the dictionary (this marks it as filled)






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
	grid.clear()
	# Create a RandomNumberGenerator instance
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()  # Seed the generator (optional)
	
	# Generate random numbers
	var numOfRooms = rng.randi_range(10, 15)  # Random integer between 1 and 100

	print("Number of Rooms: ", numOfRooms)
	
	var positionedRoomsArray: Array = []
	# Create all of the room data
	# First clear the array
	roomsArray.clear()
	hallwayArray.clear()
	for i in range(numOfRooms):
		var x_width = rng.randi_range(1, 10)  # Random width between 1 and 10
		var z_depth = rng.randi_range(1, 10)  # Random depth between 1 and 10
		
		# Create a new room and add it to the list
		var new_room = Room.new("room" + str(i), x_width, z_depth)
		new_room.location = Vector3(0,0,0)
		roomsArray.append(new_room)
		#positionedRoomsArray.append(new_room)
	
	

	#---------------------------------------------------------------------------------------------
	# this is where we create the room relativity data (room positions relative to other rooms)
	# This accomplishes setting the room locations
	positionedRoomsArray.append(roomsArray[0])
	positionedRoomsArray[0].location = Vector3(0,0,0)
	addRoomToGrid(positionedRoomsArray[0])
	for i in range(1, roomsArray.size()):
		print("Room number: " , i , "is being checked in positioned loop")
		var currentRoom = roomsArray[i]
		for roomBefore in positionedRoomsArray:
			
			if not roomBefore.zPlusSlotOccupied:
				var coord: Vector3 = getSlotCoord(roomBefore, 1)
				currentRoom.location = getSpawnCoordFromSlotCoord(coord,1,currentRoom)
				if isSpaceForRoom(currentRoom):
					roomsArray[i].direction = 1
					roomBefore.zPlusSlotOccupied = true
					currentRoom.zMinusSlotOccupied = true
					addRoomToGrid(currentRoom)
					#make a new hallway and add it to the list
					hallwayArray.append(Hallway.new(1, coord + Vector3(0,0,-.5)))
					break
				else:
					currentRoom.location = Vector3(0,0,0)
					pass
			
			elif not roomBefore.xPlusSlotOccupied:
				var coord: Vector3 = getSlotCoord(roomBefore, 2)
				currentRoom.location = getSpawnCoordFromSlotCoord(coord,2,currentRoom)
				if isSpaceForRoom(currentRoom):
					roomsArray[i].direction = 2
					roomBefore.xPlusSlotOccupied = true
					currentRoom.xMinusSlotOccupied = true
					addRoomToGrid(currentRoom)
					#make a new hallway and add it to the list
					hallwayArray.append(Hallway.new(2, coord + Vector3(-.5,0,0)))
					break
				else:
					currentRoom.location = Vector3(0,0,0)
					pass
			
			elif not roomBefore.zMinusSlotOccupied:
				var coord: Vector3 = getSlotCoord(roomBefore,3)
				currentRoom.location = getSpawnCoordFromSlotCoord(coord,3,currentRoom)
				if isSpaceForRoom(currentRoom):
					roomsArray[i].direction = 3
					roomBefore.zMinusSlotOccupied = true
					currentRoom.zPlusSlotOccupied = true
					addRoomToGrid(currentRoom)
					#make a new hallway and add it to the list
					hallwayArray.append(Hallway.new(1, coord + Vector3(0,0,+.5)))
					break
				else:
					currentRoom.location = Vector3(0,0,0)
					pass
				
				
			elif not roomBefore.xMinusSlotOccupied:
				var coord: Vector3 = getSlotCoord(roomBefore,4)
				currentRoom.location = getSpawnCoordFromSlotCoord(coord,4,currentRoom)
				if isSpaceForRoom(currentRoom):
					roomsArray[i].direction = 4
					roomBefore.xMinusSlotOccupied = true
					currentRoom.xPlusSlotOccupied = true
					addRoomToGrid(currentRoom)
					#make a new hallway and add it to the list
					hallwayArray.append(Hallway.new(2, coord + Vector3(+.5,0,0)))
					break
				else:
					currentRoom.location = Vector3(0,0,0)
					pass
				
		positionedRoomsArray.append(currentRoom)
	
	
	for room in roomsArray:
		print("Name: ", room.name, ", xWidth: ", room.xWidth, ", zDepth: ", room.zDepth, ", Location: ", room.location, ", Bools: ", 
			room.zPlusSlotOccupied,room.xPlusSlotOccupied, room.zMinusSlotOccupied, room.xMinusSlotOccupied)
	
	# this is where we actually generate the rooms
	for currentRoom in positionedRoomsArray:
		generate_room2(currentRoom)# generateRoom2()
		
	for currentHall in hallwayArray:
		generate_hallway(currentHall)
		
	
	
	
	
	
	
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

	











	








	
func getSlotCoord(room: Room, dir: int) -> Vector3:
	# this returns the coord for the room spawnpoint off of a given direction of a room
	# so if you give room1 and 1 then it will give the coord in front of the north (z+) door of the room
	
	# first we get the transform of the room
	var center = room.location
	var slotCoord
	
	# Ensure proper float division
	var half_width = room.xWidth / 2.0
	var half_depth = room.zDepth / 2.0
	
	# if the direction is 1, add half the depth of the room + hallLength to center.z
	if dir == 1:
		slotCoord = Vector3(center.x, center.y, center.z + half_depth + hallLength)
	# if the direction is 2, add half the width of the room + hallLength to center.x
	elif dir == 2:
		slotCoord = Vector3(center.x + half_width + hallLength, center.y, center.z)
	# if the direction is 3, subtract half the depth of the room + hallLength from center.z
	elif dir == 3:
		slotCoord = Vector3(center.x, center.y, center.z - half_depth - hallLength)
	# if the direction is 4, subtract half the width of the room + hallLength from center.x
	elif dir == 4:
		slotCoord = Vector3(center.x - half_width - hallLength, center.y, center.z)
	else:
		print("Error: Invalid direction given")
		return center  # Return center as a fallback instead of an undefined variable
	
	return slotCoord
	

	
func getSpawnCoordFromSlotCoord(slotCoord: Vector3, dir: int, room: Room) -> Vector3:
	
	var spawnCoord: Vector3
	
	# Ensure proper float division
	var half_width = room.xWidth / 2.0
	var half_depth = room.zDepth / 2.0
	
	# if the direction is 1, add half the depth of the room to slotCoord.z
	if dir == 1:
		spawnCoord = Vector3(slotCoord.x, slotCoord.y, slotCoord.z + half_depth)
	# if the direction is 2, add half the width of the room to slotCoord.x
	elif dir == 2:
		spawnCoord = Vector3(slotCoord.x + half_width, slotCoord.y, slotCoord.z)
	# if the direction is 3, subtract half the depth of the room from slotCoord.z
	elif dir == 3:
		spawnCoord = Vector3(slotCoord.x, slotCoord.y, slotCoord.z - half_depth)
	# if the direction is 4, subtract half the width of the room from slotCoord.x
	elif dir == 4:
		spawnCoord = Vector3(slotCoord.x - half_width, slotCoord.y, slotCoord.z)
	
	return spawnCoord

func get_room_bounds(room) -> Array:
	var half_width = room.xWidth / 2
	var half_depth = room.zDepth / 2
	var xmin = int(room.location.x - half_width)
	var xmax = int(room.location.x + half_width)
	var zmin = int(room.location.z - half_depth)
	var zmax = int(room.location.z + half_depth)
	return [xmin, xmax, zmin, zmax]
	


func isSpaceForRoom(room: Room) -> bool:
	var gridRange = get_room_bounds(room)
	return !check_range(gridRange[0], gridRange[1], gridRange[2], gridRange[3])
	
	

func addRoomToGrid(room: Room) -> void:
	var gridRange = get_room_bounds(room)
	# func add_range_to_grid(xmin: int, xmax: int, ymin: int, ymax: int):
	add_range_to_grid(gridRange[0], gridRange[1], gridRange[2], gridRange[3])
	


func generate_room2(currentRoom: Room) -> void:
	var room = Node3D.new()
	room.name = currentRoom.name
	var room_mesh = MeshInstance3D.new()
	var box_mesh = create_custom_room_mesh2(currentRoom.location, currentRoom.direction, currentRoom.xWidth, currentRoom.zDepth, currentRoom.zPlusSlotOccupied, currentRoom.zMinusSlotOccupied, currentRoom.xMinusSlotOccupied, currentRoom.xPlusSlotOccupied)
	room_mesh.mesh = box_mesh
	room.add_child(room_mesh)
	var current_scene = get_tree().edited_scene_root
	current_scene.add_child(room)
	room.owner = current_scene
	
	print("Room generated:", room.name)
	
	
	
func generate_hallway(currentHall: Hallway) -> void:
	var hall = Node3D.new()
	var hall_mesh = MeshInstance3D.new()
	var box_mesh = create_hall_mesh(currentHall)
	hall_mesh.mesh = box_mesh
	hall.add_child(hall_mesh)
	var current_scene = get_tree().edited_scene_root
	current_scene.add_child(hall)
	hall.owner = current_scene
	
	print("Hall generated")
	
	
	
func create_hall_mesh(currentHall: Hallway) -> ArrayMesh:
	var array_mesh = ArrayMesh.new()
	
	var squareVerts = PackedVector3Array([
		Vector3(-.5, 0, -.5),  # back-left
		Vector3(.5, 0, -.5),   # back-right
		Vector3(.5, 0, .5),    # front-right
	
		Vector3(-.5, 0, -.5),  # back-left
		Vector3(.5, 0, .5),    # front-right
		Vector3(-.5, 0, .5)    # front-left
	])
	
	var vertices = PackedVector3Array([])
	
	#this is the bottom face
	for square_vert in squareVerts:  #bottomface
		vertices.append(square_vert)
	
	var normals = PackedVector3Array([
		
		Vector3(0, 1, 0),  # Normal for bottomface
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 0)
	])
	
	for i in range(vertices.size()):  # Loop through each vertex in the array
		vertices[i] = vertices[i] + currentHall.location
		
		
	var indices = PackedInt32Array([0, 1, 2, 3, 4, 5])
	
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
		#remove this code in between lines when doors are implemented
		#--------------------------------------------------------------
		for square_vert in squareVerts:
			var rotation_matrix = Basis().rotated(Vector3(1, 0, 0), deg_to_rad(-90))#front face
			var rotated_vector = rotation_matrix * square_vert
			vertices.append(Vector3(rotated_vector.x, rotated_vector.y + .5, rotated_vector.z+.5))
		#--------------------------------------------------------------
		
		#add door verts
		for doorWallVert in doorWallVerts:
			pass
			
	else:
		#add square verts
		for square_vert in squareVerts:
			var rotation_matrix = Basis().rotated(Vector3(1, 0, 0), deg_to_rad(-90))#front face
			var rotated_vector = rotation_matrix * square_vert
			vertices.append(Vector3(rotated_vector.x, rotated_vector.y + .5, rotated_vector.z+.5))
	
	
	
	
	# this is the back face
	if hasZMinusDoor:
		#remove this code in between lines when doors are implemented
		#--------------------------------------------------------------
		for square_vert in squareVerts:
			var rotation_matrix = Basis().rotated(Vector3(1, 0, 0), deg_to_rad(90))
			var rotated_vector = rotation_matrix * square_vert
			vertices.append(Vector3(rotated_vector.x, rotated_vector.y + .5, rotated_vector.z-.5))
		#--------------------------------------------------------------
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
		#remove this code in between lines when doors are implemented
		#--------------------------------------------------------------
		for square_vert in squareVerts:
			var rotation_matrix = Basis().rotated(Vector3(0, 0, 1), deg_to_rad(-90))
			# Apply the rotation to the original vector
			var rotated_vector = rotation_matrix * square_vert
			vertices.append(Vector3(rotated_vector.x-.5, rotated_vector.y + .5, rotated_vector.z))
		#--------------------------------------------------------------
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
		#remove this code in between lines when doors are implemented
		#--------------------------------------------------------------
		for square_vert in squareVerts:
			var rotation_matrix = Basis().rotated(Vector3(0, 0, 1), deg_to_rad(90))
			# Apply the rotation to the original vector
			var rotated_vector = rotation_matrix * square_vert
			vertices.append(Vector3(rotated_vector.x+.5, rotated_vector.y + .5, rotated_vector.z))
		#--------------------------------------------------------------
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
		vertices[i] = vertices[i] + spawnPos
		
		
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
