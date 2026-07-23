extends Control
class_name UI

@onready var health_label: Label = %Health

func _ready() -> void:
	UiService.update_health_label.connect(_on_update_health_label)


func _on_update_health_label(text: String) -> void:
	health_label.text = text


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	