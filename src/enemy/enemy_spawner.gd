extends Node3D
class_name EnemySpawner

@export var player: Player

const _ENEMY_SCENE: PackedScene = preload("res://src/enemy/enemy.tscn")


func _ready() -> void:
	EnemyService.spawn_enemy.connect(_on_spawn_enemy)


func _on_spawn_enemy(pos: Vector3) -> void:
	var enemy: Enemy = _ENEMY_SCENE.instantiate()
	add_sibling(enemy)
	enemy.setup(player, pos)
