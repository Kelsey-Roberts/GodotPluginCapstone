extends CanvasLayer

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		get_tree().change_scene_to_file("res://addons/procedural_room_generator/world.tscn")
