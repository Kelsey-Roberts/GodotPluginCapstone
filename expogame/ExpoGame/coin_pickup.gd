extends Area3D

@export var rotation_speed : float = 1.0  # degrees per second

func _process(delta: float) -> void:
	var radians = deg_to_rad(rotation_speed) * delta
	$MeshInstance3D.rotate_y(radians)
