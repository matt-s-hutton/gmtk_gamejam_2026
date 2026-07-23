extends Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func _on_pressed() -> void:
	print('restart')
	get_tree().paused = false
	get_tree().reload_current_scene()
