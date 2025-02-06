# delete_node.gd
extends Node

func delete_node_by_name(scene_tree, node_name: String = "") -> void:
	if scene_tree == null or scene_tree.edited_scene_root == null:
		push_error("No active scene found or scene tree is not ready.")
		return
	
	var node_to_delete
	
	if node_name != "":
		# Attempt to find the node by name if a name is provided
		node_to_delete = scene_tree.edited_scene_root.get_node_or_null(node_name)
	else:
		# If no name is provided, get the last child of the edited scene root
		var child_count = scene_tree.edited_scene_root.get_child_count()
		if child_count > 0:
			node_to_delete = scene_tree.edited_scene_root.get_child(child_count - 1)

	if node_to_delete:
		node_to_delete.queue_free()
		print("Deleted node:", node_to_delete.name)
	else:
		print("No node found to delete.")
