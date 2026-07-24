extends Node3D

signal damage_end


func notify_damage_end() -> void:
	damage_end.emit()
