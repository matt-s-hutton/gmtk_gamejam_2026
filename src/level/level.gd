extends Node3D

@export var spawn_count: int = 5000
@export var spawn_radius: float = 35.0
@export var spawn_interval: float = 0.5

@export var player: Player

var _timer := Timer.new()


func _ready() -> void:
	for i in spawn_count:
		EnemyService.request_spawn_enemy()

	add_child(_timer)
	_timer.wait_time = spawn_interval
	_timer.timeout.connect(_on_spawn_tick)
	_timer.start()


func _on_spawn_tick() -> void:
	var angle := randf() * TAU
	var offset := Vector3(cos(angle), 0.0, sin(angle)) * spawn_radius
	EnemyService.request_activate_enemy(player.global_position + offset)
