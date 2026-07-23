extends Node

signal spawn_enemy
signal activate_enemy(pos: Vector3)
signal deactivate_enemy(e: Enemy)


func request_spawn_enemy() -> void:
	spawn_enemy.emit()


func request_activate_enemy(pos: Vector3) -> void:
	activate_enemy.emit(pos)


func request_deactivate_enemy(e: Enemy) -> void:
	deactivate_enemy.emit(e)
