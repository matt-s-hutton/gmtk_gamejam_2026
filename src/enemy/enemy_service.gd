extends Node

signal spawn_enemy(pos: Vector3)


func request_spawn_enemy(pos: Vector3) -> void:
	spawn_enemy.emit(pos)
