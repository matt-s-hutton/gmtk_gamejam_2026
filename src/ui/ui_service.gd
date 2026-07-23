extends Node

signal update_health_label(text: String)
signal game_over


func request_update_health_label(text: String) -> void:
	update_health_label.emit(text)


func request_game_over() -> void:
	game_over.emit()
