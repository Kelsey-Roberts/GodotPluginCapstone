# CoinManager.gd (or attach to your main scene)
extends Node

var coin_count: int = 0
var starting_coin_total: int = 5
@onready var coin_label: Label = $"CanvasLayer/CoinLabel"

func add_coin():
	coin_count += 1
	var coins_remaining = starting_coin_total - coin_count
	coin_label.text = "Coins left to collect: %d" % coins_remaining
	if coins_remaining == 0:
		game_win()

func game_win():
	get_tree().change_scene_to_file("res://ExpoGame/GameWin.tscn") 


# Pause Menu
var is_paused := false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	$PauseMenu.visible = is_paused

	if is_paused:
		$PauseMenu/VBoxContainer/Resume.grab_focus()
