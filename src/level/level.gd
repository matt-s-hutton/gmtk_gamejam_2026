extends Node3D


func _ready() -> void:
	EnemyService.request_spawn_enemy(Vector3(9, 0, 10))
