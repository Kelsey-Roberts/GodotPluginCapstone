extends CanvasLayer

func _ready():
	visible = false
	$VBoxContainer/Resume.pressed.connect(_on_resume_pressed)
	$VBoxContainer/Restart.pressed.connect(_on_restart_pressed)
	$VBoxContainer/Exit.pressed.connect(_on_quit_pressed)

func _on_resume_pressed():
	get_tree().paused = false
	visible = false

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()
