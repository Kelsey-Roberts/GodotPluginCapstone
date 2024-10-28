@tool
extends EditorPlugin

var dock
var input_fields = {}
var scene_path = "res://addons/texturegenerator/My3DScene.tscn"  # Path to your 3D scene

func _enter_tree() -> void:
	# Instantiate the dock from the .tscn file
	dock = preload("res://addons/texturegenerator/TextureGeneratorDoc.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_BL, dock)

	# Connect button and input fields
	var generate_button = dock.get_node("generate_button")  # Make sure these names match your dock
	var x_input = dock.get_node("x_input")
	var y_input = dock.get_node("y_input")

	# Store the input fields in a dictionary
	input_fields["x_input"] = x_input
	input_fields["y_input"] = y_input

	# Connect the button's pressed signal to the method
	generate_button.pressed.connect(self._on_generate_button_pressed)

func _exit_tree() -> void:
	# Clean up the dock when exiting
	remove_control_from_docks(dock)
	dock.free()

func _on_generate_button_pressed() -> void:
	# Load the 3D scene
	var scene_path = "res://addons/texturegenerator/My3DScene.tscn"
	var my_scene = load(scene_path).instantiate()

	# Get the root node of the 3D scene (which is named "wow")
	var root = my_scene.get_node("wow")
	
	# Check if the root node exists and call the method
	if root:
		print("Root node found. Attempting to add cylinder.")
		root.nope()  # Call the cylinder method instead of cube
	else:
		print("Error: Could not find the root node.")
