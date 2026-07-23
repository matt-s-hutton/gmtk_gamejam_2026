extends Node3D

@export var spawn_count: int = 1000
@export var area_size: float = 40.0


func _ready() -> void:
	for i in spawn_count:
		var pos := Vector3(
			randf_range(-area_size, area_size),
			0.0,
			randf_range(-area_size, area_size),
		)
		EnemyService.request_spawn_enemy(pos)