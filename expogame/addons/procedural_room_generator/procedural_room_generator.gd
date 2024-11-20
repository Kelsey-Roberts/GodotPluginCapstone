@tool
extends EditorPlugin

var dock # Global Dock Location


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	dock = preload("res://addons/procedural_room_generator/plugin_gui.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_BL, dock)
	# to grab controls from the dock simply right click the control and copy path
	var generate_button = dock.get_node("Controls_VContainer/Generate_Button_Panel/Generate_Button")
	generate_button.pressed.connect(_on_generate_button_pressed)
	
	
	 


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
	furniture = int((dock.get_node("Controls_VContainer/Furniture_Panel/Furniture/Furniture_Input")).text)
	var roof = bool((dock.get_node("Controls_VContainer/Roof_Panel/Roof/Roof_Toggle_Button")).button_pressed)
	print((x_input + y_input), y_input, furniture, roof)
	# now call the room generation script here with the above vars!
	

	
