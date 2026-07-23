extends Node

signal update_health_label(text: String)


func request_update_health_label(text: String) -> void:
	update_health_label.emit(text)
