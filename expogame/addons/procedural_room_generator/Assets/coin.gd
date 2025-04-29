extends Area3D

@export var rotation_speed = 90.0  # degrees per second
@export var value = 1  # or whatever currency system you use

func _ready():
	print("coin ready")
	connect("body_entered", _on_body_entered)

func _process(delta):
	rotate_y(deg_to_rad(rotation_speed * delta))

func _on_body_entered(body):
	print("on body entered")
	if body.is_in_group("Player"):
		print("coin collision")
		body.add_coins(value)  # Replace with your actual method
		get_tree().get_root().get_node("Node3D").add_coin()
		queue_free()
