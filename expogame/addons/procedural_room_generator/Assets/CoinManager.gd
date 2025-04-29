# CoinManager.gd (or attach to your main scene)
extends Node

var coin_count: int = 0
var starting_coin_total: int = 5
@onready var coin_label: Label = $"CanvasLayer/CoinLabel"

func add_coin():
	coin_count += 1
	var coins_remaining = starting_coin_total - coin_count
	coin_label.text = "Coins: %d" % coins_remaining
