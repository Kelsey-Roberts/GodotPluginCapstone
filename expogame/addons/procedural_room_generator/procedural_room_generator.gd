@tool
extends EditorPlugin

var dock # Global Dock Location


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	dock = preload("res://addons/procedural_room_generator/plugin_gui.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_BL, dock)



func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_control_from_docks(dock)
	dock.free()
