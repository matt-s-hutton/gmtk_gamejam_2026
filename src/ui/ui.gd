extends Control
class_name UI

@onready var health_label: Label = %Health
@onready var game_over_ui: Control = %GameOver

func _ready() -> void:
	UiService.update_health_label.connect(_on_update_health_label)
	UiService.game_over.connect(_on_game_over)


func _on_update_health_label(text: String) -> void:
	health_label.text = text


func _on_game_over() -> void:
	game_over_ui.show()
	get_tree().paused = true


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	Conductor.stop()
	Conductor.reset_tracking()
	get_tree().reload_current_scene()
	Conductor.play()
