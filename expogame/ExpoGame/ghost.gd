extends Node3D

@export var speed := 2.0
var player

func _ready():
	await get_tree().create_timer(3.0).timeout  # Wait for 1 secon
	player = get_node("../Player") # adjust path as needed
	$Area3D.body_entered.connect(_on_body_entered)

func _process(delta):
	if player:
		var direction = (player.global_transform.origin - global_transform.origin).normalized()
		global_translate(direction * speed * delta)
	

func _on_body_entered(body):
	if body.name == "Player":
		get_tree().change_scene_to_file("res://ExpoGame/GameOver.tscn")  # Or handle game over another way
		print("game over")
		
