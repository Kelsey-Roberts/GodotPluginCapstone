@tool
extends EditorPlugin

var dock

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	dock = preload("res://addons/texturegenerator/TextureGeneratorDoc.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_BL, dock)

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_control_from_docks(dock)
	dock.free()
