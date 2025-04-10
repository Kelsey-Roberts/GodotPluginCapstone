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
		generate_room3(currentRoom)# generateRoom2()
		
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
	#delete_script.call_deferred("delete_node_by_name", get_tree())
	var delete_node = get_editor_interface().get_edited_scene_root().get_node_or_null("Delete")
		
	if delete_node:
		# Loop through all children of the "Delete" node and delete them
		for child in delete_node.get_children():
			child.queue_free()
		print("Deleted all children of 'Delete' node.")
	else:
		print("Error: 'Delete' node not found in scene.")
			
			
			
	
	
	











	








	
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
	


	
	
	
func generate_room3(currentRoom: Room) -> void:
	
	var room = Node3D.new()
	room.name = currentRoom.name
	
	var room_wall_mesh = MeshInstance3D.new()
	room_wall_mesh.mesh = create_custom_wall_mesh3(currentRoom)
	
	var room_floor_mesh = MeshInstance3D.new()
	room_floor_mesh.mesh = create_custom_floor_mesh(currentRoom)
	
	var floorTexture = load("res://assets/textures/stoneFloor.jpg")
	var wallTexture = load("res://assets/textures/stoneBrickWall.jpg")
	
	var floorMaterial = StandardMaterial3D.new()
	floorMaterial.albedo_texture = floorTexture
	
	var wallMaterial = StandardMaterial3D.new()
	wallMaterial.albedo_texture = wallTexture
	
	room_floor_mesh.material_override = floorMaterial
	room_wall_mesh.material_override = wallMaterial
	
	var current_scene = get_tree().edited_scene_root
	var delete_node = get_editor_interface().get_edited_scene_root().get_node_or_null("Delete")
	delete_node.add_child(room)
	room.add_child(room_floor_mesh)
	room.add_child(room_wall_mesh)
	
	room.owner = current_scene
	room_floor_mesh.owner = current_scene
	room_wall_mesh.owner = current_scene
	room_wall_mesh.create_trimesh_collision()
	room_floor_mesh.create_trimesh_collision()
	#room_wall_mesh.get_child(0).owner = current_scene
	#room_floor_mesh.get_child(0).owner = current_scene
	#==========================================================
	
	
	
#func generate_hallway(currentHall: Hallway) -> void:
	#var hall = Node3D.new()
	#var hall_mesh = MeshInstance3D.new()
	#var box_mesh = create_hall_mesh(currentHall)
	#hall_mesh.mesh = box_mesh
	#hall.add_child(hall_mesh)
	#
	##hall.owner = delete_node
	#
	#var hallTexture = load("res://assets/textures/hallTexture.jpg")
	#var hallMaterial = StandardMaterial3D.new()
	#hallMaterial.albedo_texture = hallTexture
	#
	#hall_mesh.material_override = hallMaterial
	#
	#var current_scene = get_tree().edited_scene_root
	#var delete_node = get_editor_interface().get_edited_scene_root().get_node_or_null("Delete")
	##current_scene.add_child(hall)
	#delete_node.add_child(hall)
	#hall.owner = current_scene
	#hall_mesh.owner = current_scene
	#hall_mesh.create_trimesh_collision()
	#
	#print("Hall generated")
	
	
	
func generate_hallway(currentHall: Hallway) -> void:
	var hall = Node3D.new()
	
	var hall_floor_mesh = MeshInstance3D.new()
	hall_floor_mesh.mesh = create_hall_floor_mesh(currentHall)
	
	var hall_wall_mesh = MeshInstance3D.new()
	hall_wall_mesh.mesh = create_hall_wall_mesh(currentHall)
	
	var hall_ceiling_mesh = MeshInstance3D.new()
	hall_ceiling_mesh.mesh = create_hall_ceiling_mesh(currentHall)
	
	
	hall.add_child(hall_floor_mesh)
	hall.add_child(hall_wall_mesh)
	hall.add_child(hall_ceiling_mesh)
	
	
	var hallTexture = load("res://assets/textures/hallTexture.jpg")
	var hallMaterial = StandardMaterial3D.new()
	hallMaterial.albedo_texture = hallTexture
	
	hall_floor_mesh.material_override = hallMaterial
	hall_wall_mesh.material_override = hallMaterial
	hall_ceiling_mesh.material_override = hallMaterial
	
	var current_scene = get_tree().edited_scene_root
	var delete_node = get_editor_interface().get_edited_scene_root().get_node_or_null("Delete")
	#current_scene.add_child(hall)
	delete_node.add_child(hall)
	hall.owner = current_scene
	
	hall_floor_mesh.owner = current_scene
	hall_floor_mesh.create_trimesh_collision()
	
	hall_wall_mesh.owner = current_scene
	hall_wall_mesh.create_trimesh_collision()
	
	hall_ceiling_mesh.owner = current_scene
	hall_wall_mesh.create_trimesh_collision()
	
	print("Hall generated")
	
	
	
	
func create_hall_floor_mesh(currentHall: Hallway) -> ArrayMesh:
	var array_mesh = ArrayMesh.new()
	
	var uvs = PackedVector2Array([#adding the uvs for the bottom square:
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(1, 1),
		Vector2(0, 0),
		Vector2(1, 1),
		Vector2(0, 1)
	])
	
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
	arrays[Mesh.ARRAY_TEX_UV] = uvs  # Assign the UVs array to the mesh

	# Commit the data to the ArrayMesh
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	return array_mesh





func create_hall_ceiling_mesh(currentHall: Hallway) -> ArrayMesh:
	var array_mesh = ArrayMesh.new()
	
	var uvs = PackedVector2Array([#adding the uvs for the bottom square:
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(1, 1),
		Vector2(0, 0),
		Vector2(1, 1),
		Vector2(0, 1)
	])
	
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
		var rotation_matrix = Basis().rotated(Vector3(1, 0, 0), deg_to_rad(180))
		square_vert = rotation_matrix * square_vert
		square_vert.y += 2
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
	arrays[Mesh.ARRAY_TEX_UV] = uvs  # Assign the UVs array to the mesh

	# Commit the data to the ArrayMesh
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	return array_mesh








func create_hall_wall_mesh(currentHall: Hallway) -> ArrayMesh:
	
	var array_mesh = ArrayMesh.new()
	
	var uvs = PackedVector2Array([#adding the uvs for the bottom square:
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(1, 2),
		Vector2(0, 0),
		Vector2(1, 2),
		Vector2(0, 2),
		
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(1, 2),
		Vector2(0, 0),
		Vector2(1, 2),
		Vector2(0, 2)
	])
	
	
	
	
	var squareVerts = PackedVector3Array([
		Vector3(-.5, 0, -.5),  # back-left
		Vector3(.5, 0, -.5),   # back-right
		Vector3(.5, 0, .5),    # front-right
	
		Vector3(-.5, 0, -.5),  # back-left
		Vector3(.5, 0, .5),    # front-right
		Vector3(-.5, 0, .5)    # front-left
	])
	
	var vertices = PackedVector3Array([])
	
	var normals = PackedVector3Array([
		
		Vector3(0, 0, 1),  # Normals for first wall (wall is to +x but tex faces -x)
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		
		Vector3(0, 0, 1),  # Normals for second wall (wall is to -x but tex faces +x)
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1)
	])
	
	#make two 1x2 walls across from each other (1 unit apart) in the x axis (a wall to x+ and a wall to x-)
	#if the direction is 2 then rotate the model 90 degrees
	
	#this is the right face
	for square_vert in squareVerts:
		var rotation_matrix = Basis().rotated(Vector3(1, 0, 0), deg_to_rad(-90))
		square_vert = rotation_matrix * square_vert
		square_vert.y *= 2
		square_vert.y += 1
		rotation_matrix = Basis().rotated(Vector3(0,1,0), deg_to_rad(-90))
		square_vert = rotation_matrix * square_vert
		square_vert.x -= .5
		vertices.append(square_vert)
	
	#this is the left face
	for square_vert in squareVerts:
		var rotation_matrix = Basis().rotated(Vector3(1, 0, 0), deg_to_rad(-90))
		square_vert = rotation_matrix * square_vert
		square_vert.y *= 2
		square_vert.y += 1
		rotation_matrix = Basis().rotated(Vector3(0,1,0), deg_to_rad(90))
		square_vert = rotation_matrix * square_vert
		square_vert.x += .5
		vertices.append(square_vert)
	
	
	var dir2_rotation_matrix = Basis().rotated(Vector3(0, 1, 0), deg_to_rad(90))
	for i in range(vertices.size()):  # Loop through each vertex in the array
		if(currentHall.dir == 2):
			vertices[i]= vertices[i] * dir2_rotation_matrix
		vertices[i] = vertices[i] + currentHall.location
	
	var indices = PackedInt32Array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
	
	# Create an array of arrays for the vertex attributes
	var arrays = Array()

	# Assign vertices, normals, and indices
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	arrays[Mesh.ARRAY_TEX_UV] = uvs  # Assign the UVs array to the mesh

	# Commit the data to the ArrayMesh
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	return array_mesh
	#=======================================================================

func create_custom_floor_mesh(currentRoom: Room) -> ArrayMesh:
	var textureOption = 2
	var array_mesh = ArrayMesh.new()
	var uvs = PackedVector2Array() 
	var vertices = PackedVector3Array([])
	
	# Define the vertices for the square (using PackedVector3Array)
	var squareVerts = PackedVector3Array([
		Vector3(-.5, 0, -.5),  # back-left
		Vector3(.5, 0, -.5),   # back-right
		Vector3(.5, 0, .5),    # front-right
	
		Vector3(-.5, 0, -.5),  # back-left
		Vector3(.5, 0, .5),    # front-right
		Vector3(-.5, 0, .5)    # front-left
	])
	
	#VERTICES:
	#this is the bottom face
	for square_vert in squareVerts:  #bottomface
		vertices.append(square_vert)
		# no rotation needed
		
		
	#UVS:
	#first find out what is longer the width or height of the room
	var widthIsLarger = (currentRoom.xWidth>currentRoom.zDepth)
	var largerSide
	var smallerSide
	if(widthIsLarger):
		largerSide = float(currentRoom.xWidth)
		smallerSide = float(currentRoom.zDepth)
	else:
		largerSide = float(currentRoom.zDepth)
		smallerSide = float(currentRoom.xWidth)
	#if that amount is 1 then get the other ratio - get biggerside/smaller side.
	var ratio = float(smallerSide)/float(largerSide)
	var space = (1-ratio)/2
	
	#----------------------------------------------------------Here we will have two texture options
	#------------------------------------------------------1 is one texture and 2 is tiled
	match textureOption:
		1:
			#if depth is bigger:
			# use these UVs: 
			if(!widthIsLarger):
				var left = space
				var right = 1-space
				uvs.append(Vector2(left,0))#0
				uvs.append(Vector2(right,0))#1
				uvs.append(Vector2(right,1))#2
				uvs.append(Vector2(left,0))#3
				uvs.append(Vector2(right,1))#4
				uvs.append(Vector2(left,1))#5
			else:
				var lowerSpace = space
				var upperSpace = 1-space
				uvs.append(Vector2(0,lowerSpace))#0
				uvs.append(Vector2(1,lowerSpace))#1
				uvs.append(Vector2(1,upperSpace))#2
				uvs.append(Vector2(0,lowerSpace))#3
				uvs.append(Vector2(1,upperSpace))#4
				uvs.append(Vector2(0,upperSpace))#5
		2:
			uvs.append(Vector2(0,0))#0
			uvs.append(Vector2(currentRoom.xWidth,0))#1
			uvs.append(Vector2(currentRoom.xWidth,currentRoom.zDepth))#2
			uvs.append(Vector2(0,0))#3
			uvs.append(Vector2(currentRoom.xWidth,currentRoom.zDepth))#4
			uvs.append(Vector2(0,currentRoom.zDepth))#5
			
		3:
			pass
		_:
			pass
	#------------------------------------------------------------------------------------------
	var normals = PackedVector3Array([
		
		Vector3(0, 1, 0),  # Normal for bottomface
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 0)
	])
	
	
	var xScale = currentRoom.xWidth
	var zScale = currentRoom.zDepth
	
	for i in range(vertices.size()):  # Loop through each vertex in the array
		# Directly modify the elements in the vertices array
		vertices[i] = Vector3(vertices[i].x * xScale, vertices[i].y, vertices[i].z * zScale)
		vertices[i] = vertices[i] + currentRoom.location
		
	var indices = PackedInt32Array([0, 1, 2, 3, 4, 5])
	
	# Create an array of arrays for the vertex attributes
	var arrays = Array()

	# Assign vertices, normals, and indices
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	arrays[Mesh.ARRAY_TEX_UV] = uvs  # Assign the UVs array to the mesh
	
	# Commit the data to the ArrayMesh
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	return array_mesh   























func create_custom_wall_mesh3(currentRoom: Room) -> ArrayMesh:
	#-------------------------------------------------------------
	var array_mesh = ArrayMesh.new()
	var uvs = PackedVector2Array()#these are the coordinates of the texture image - one vector2 for each vertex
	var vertices = PackedVector3Array([])
	var indices = PackedInt32Array([])#These are the triangles - numbers represent vertices (the index of the vert in vertices array) every three numbers is a triangle
	var normals = PackedVector3Array([])
	var index_count = 0
	var uv_count = 0
	#-------------------------------------------------------------
	var squareVerts = PackedVector3Array([
		Vector3(-.5, 0, -.5),  # back-left
		Vector3(.5, 0, -.5),   # back-right
		Vector3(.5, 0, .5),    # front-right
	
		Vector3(-.5, 0, -.5),  # back-left
		Vector3(.5, 0, .5),    # front-right
		Vector3(-.5, 0, .5)    # front-left
	])
	var squareIndices: Array[int] = [0,1,2, 3,4,5]
	var squareUvs: Array[Vector2] = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1),     Vector2(0, 0), Vector2(1, 1), Vector2(0, 1)]
	var doorWallVerts = PackedVector3Array([
		Vector3(-.5,0,0),#0
		Vector3(-.5,2,0),#1
		Vector3(-.5,0,0),#2
		Vector3(-.5,0,0),#3
		Vector3(-.5,2,0),#4
		Vector3(-.5,2,0),#5
		
		Vector3(.5,0,0),#6
		Vector3(.5,2,0),#7
		Vector3(.5,0,0),#8
		Vector3(.5,0,0),#9
		Vector3(.5,2,0),#10
		Vector3(.5,2,0),#11
		
		Vector3(-.5,2,0),#12
		Vector3(-.5,3,0),#13
		Vector3(.5,2,0),#14
		Vector3(.5,2,0),#15
		Vector3(-.5,3,0),#16
		Vector3(.5,3,0)#17
	])#the verts used for the door (ones to not scale): 2,3,5,6,7,10
	var doorWallIndices: Array[int] = [0,1,2, 3,5,4, 6,7,8, 9,11,10, 12,13,14, 15,16,17]
	var doorIndices: Array[int] = [2,3,5,6,7,10]
	#--------------------------------------------------------------
	
	
	#-----Wall 1--Z Pos-----------------------------------------------------------------------------------------------
	# this is the front face
	if currentRoom.zPlusSlotOccupied:
	
		for i in range(doorWallVerts.size()):
			
			var currentVert = doorWallVerts[i]
			#this part does the math for the UVs:
			currentVert.x += .5 #makes the model's lower left start at origin
			if i in [2, 3, 4, 6, 7, 11]: #if it is a door vert
				currentVert.x += (currentRoom.xWidth/2.0) - .5
			if i in [8,9,10,14,15,17]:
				currentVert.x += (currentRoom.xWidth) - 1
			uvs.append(Vector2(currentVert.x/3.0,currentVert.y/3.0))#sets the UVs
			#now we rotate the model
			#now we move the wall model so its center is at room center
			currentVert.x -= currentRoom.xWidth/2.0
			#its at the room center now so we rotate it to face the right way
			var rotation_matrix = Basis().rotated(Vector3(0, 1, 0), deg_to_rad(180))#front face
			currentVert = rotation_matrix * currentVert
			#now we move the wall into place
			currentVert.z += currentRoom.zDepth/2.0
			vertices.append(currentVert)
			normals.append(Vector3(0,0,-1))
			indices.append(doorWallIndices[i]+index_count)
		index_count += doorWallIndices.size()
			
			
			
	else:
		for j in range(squareVerts.size()):
			var rotation_matrix = Basis().rotated(Vector3(1, 0, 0), deg_to_rad(-90))#back face
			var rotated_vert = rotation_matrix * squareVerts[j]
			var w = currentRoom.xWidth/3.0
			rotated_vert = Vector3(rotated_vert.x * currentRoom.xWidth, rotated_vert.y* 3.0, rotated_vert.z)
			rotated_vert = Vector3(rotated_vert.x, rotated_vert.y + (3.0/2.0), rotated_vert.z)
			rotated_vert = Vector3(rotated_vert.x, rotated_vert.y, rotated_vert.z + currentRoom.zDepth/2.0)
			vertices.append(rotated_vert)
			normals.append(Vector3(0, 0, -1))
			uvs.append(Vector2(squareUvs[j].x * w,squareUvs[j].y))
			indices.append(index_count+squareIndices[j])
		index_count+=squareVerts.size()
		
		
	#---------End of Wall 1---------------------------------------------------------------------------------------
	
	
	#-------------Wall 2------X Pos-------------------------------------------------------------------------------
	if currentRoom.xPlusSlotOccupied:
		
		for i in range(doorWallVerts.size()):
			
			var currentVert = doorWallVerts[i]
			#this part does the math for the UVs:
			currentVert.x += .5 #makes the model's lower left start at origin
			if i in [2, 3, 4, 6, 7, 11]: #if it is a door vert
				currentVert.x += (currentRoom.zDepth/2.0) - .5
			if i in [8,9,10,14,15,17]:
				currentVert.x += (currentRoom.zDepth) - 1
			uvs.append(Vector2(currentVert.x/3.0,currentVert.y/3.0))#sets the UVs
			#now we rotate the model
			#now we move the wall model so its center is at room center
			currentVert.x -= currentRoom.zDepth/2.0
			#its at the room center now so we rotate it to face the right way
			var rotation_matrix = Basis().rotated(Vector3(0, 1, 0), deg_to_rad(-90))
			currentVert = rotation_matrix * currentVert
			#now we move the wall into place
			currentVert.x += currentRoom.xWidth/2.0
			vertices.append(currentVert)
			normals.append(Vector3(0,0,-1))
			indices.append(doorWallIndices[i]+index_count)
		index_count += doorWallIndices.size()
		
		
		
		
		
	else:
		for j in range(squareVerts.size()):
			var rotation_matrix = Basis().rotated(Vector3(1, 0, 0), deg_to_rad(-90))#right face
			var rotated_vert = rotation_matrix * squareVerts[j]
			rotation_matrix = Basis().rotated(Vector3(0, 1, 0), deg_to_rad(-90))
			rotated_vert = rotated_vert * rotation_matrix
			var d = currentRoom.zDepth/3.0
			rotated_vert = Vector3(rotated_vert.x, rotated_vert.y* 3.0, rotated_vert.z * currentRoom.zDepth)
			rotated_vert = Vector3(rotated_vert.x, rotated_vert.y + (3.0/2.0), rotated_vert.z)
			rotated_vert = Vector3(rotated_vert.x + currentRoom.xWidth/2.0, rotated_vert.y, rotated_vert.z)
			vertices.append(rotated_vert)
			normals.append(Vector3(0, 0, -1))
			uvs.append(Vector2(squareUvs[j].x * d,squareUvs[j].y))
			indices.append(index_count+squareIndices[j])
		index_count+=squareVerts.size()
	#----------End of Wall 2--------------------------------------------------------------------------------------
	
	
	#-------------Wall 3------Z Min-------------------------------------------------------------------------------
	if currentRoom.zMinusSlotOccupied:
		
		for i in range(doorWallVerts.size()):
			
			var currentVert = doorWallVerts[i]
			#this part does the math for the UVs:
			currentVert.x += .5 #makes the model's lower left start at origin
			if i in [2, 3, 4, 6, 7, 11]: #if it is a door vert
				currentVert.x += (currentRoom.xWidth/2.0) - .5
			if i in [8,9,10,14,15,17]:
				currentVert.x += (currentRoom.xWidth) - 1
			uvs.append(Vector2(currentVert.x/3.0,currentVert.y/3.0))#sets the UVs
			#now we move the wall model so its center is at room center
			currentVert.x -= currentRoom.xWidth/2.0
			#its at the room center now so we rotate it to face the right way
			#this is the only wall that does not need rotation
			#var rotation_matrix = Basis().rotated(Vector3(0, 1, 0), deg_to_rad(180))#front face
			#currentVert = rotation_matrix * currentVert
			#now we move the wall into place
			currentVert.z -= currentRoom.zDepth/2.0
			vertices.append(currentVert)
			normals.append(Vector3(0,0,-1))
			indices.append(doorWallIndices[i]+index_count)
		index_count += doorWallIndices.size()
		
		
		
		
		
		
	else:
		for j in range(squareVerts.size()):
			var rotation_matrix = Basis().rotated(Vector3(1, 0, 0), deg_to_rad(-90))#back face
			var rotated_vert = rotation_matrix * squareVerts[j]
			rotation_matrix = Basis().rotated(Vector3(0, 1, 0), deg_to_rad(180))
			rotated_vert = rotated_vert * rotation_matrix
			var w = currentRoom.xWidth/3.0
			rotated_vert = Vector3(rotated_vert.x * currentRoom.xWidth, rotated_vert.y* 3.0, rotated_vert.z)
			rotated_vert = Vector3(rotated_vert.x, rotated_vert.y + (3.0/2.0), rotated_vert.z)
			rotated_vert = Vector3(rotated_vert.x, rotated_vert.y, rotated_vert.z - currentRoom.zDepth/2.0)
			vertices.append(rotated_vert)
			normals.append(Vector3(0, 0, -1))
			uvs.append(Vector2(squareUvs[j].x * w,squareUvs[j].y))
			indices.append(index_count+squareIndices[j])
		index_count+=squareVerts.size()
	#----------End of Wall 3--------------------------------------------------------------------------------------
	
	#-------------Wall 4------X Min-------------------------------------------------------------------------------
	if currentRoom.xMinusSlotOccupied:
		
		for i in range(doorWallVerts.size()):
			
			var currentVert = doorWallVerts[i]
			#this part does the math for the UVs:
			currentVert.x += .5 #makes the model's lower left start at origin
			if i in [2, 3, 4, 6, 7, 11]: #if it is a door vert
				currentVert.x += (currentRoom.zDepth/2.0) - .5
			if i in [8,9,10,14,15,17]:
				currentVert.x += (currentRoom.zDepth) - 1
			uvs.append(Vector2(currentVert.x/3.0,currentVert.y/3.0))#sets the UVs
			#now we rotate the model
			#now we move the wall model so its center is at room center
			currentVert.x -= currentRoom.zDepth/2.0
			#its at the room center now so we rotate it to face the right way
			var rotation_matrix = Basis().rotated(Vector3(0, 1, 0), deg_to_rad(90))
			currentVert = rotation_matrix * currentVert
			#now we move the wall into place
			currentVert.x -= currentRoom.xWidth/2.0
			vertices.append(currentVert)
			normals.append(Vector3(0,0,-1))
			indices.append(doorWallIndices[i]+index_count)
		index_count += doorWallIndices.size()
		
		
	else:
		for j in range(squareVerts.size()):
			var rotation_matrix = Basis().rotated(Vector3(1, 0, 0), deg_to_rad(-90))#right face
			var rotated_vert = rotation_matrix * squareVerts[j]
			rotation_matrix = Basis().rotated(Vector3(0, 1, 0), deg_to_rad(90))
			rotated_vert = rotated_vert * rotation_matrix
			var d = currentRoom.zDepth/3.0
			rotated_vert = Vector3(rotated_vert.x, rotated_vert.y* 3.0, rotated_vert.z * currentRoom.zDepth)
			rotated_vert = Vector3(rotated_vert.x, rotated_vert.y + (3.0/2.0), rotated_vert.z)
			rotated_vert = Vector3(rotated_vert.x - currentRoom.xWidth/2.0, rotated_vert.y, rotated_vert.z)
			vertices.append(rotated_vert)
			normals.append(Vector3(1, 0, 0))
			uvs.append(Vector2(squareUvs[j].x * d,squareUvs[j].y))
			indices.append(index_count+squareIndices[j])
		index_count+=squareVerts.size()
		
		
	#----------End of Wall 4--------------------------------------------------------------------------------------
	
	
	#------------------------------------------------------------
	#move the model to the room location:
	for i in range(vertices.size()):
		vertices[i] = vertices[i] + currentRoom.location
	#-------------------------------------------------------------
	#assign the arrays created above to the variables of the mesh
	var arrays = Array()
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	#-------------------------------------------------------------
	return array_mesh
	
