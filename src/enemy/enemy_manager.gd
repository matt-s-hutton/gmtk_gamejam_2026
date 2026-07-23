extends Node3D
class_name EnemyManager

@export var player: Player
@export var enemy_grid: EnemyGrid

const _ENEMY_SCENE: PackedScene = preload("res://src/enemy/enemy.tscn")

var _inactive: Array[Enemy] = []
var active: Array[Enemy] = []


func _ready() -> void:
	EnemyService.spawn_enemy.connect(_on_spawn_enemy)
	EnemyService.activate_enemy.connect(_on_activate_enemy)
	EnemyService.deactivate_enemy.connect(_on_deactivate_enemy)


func _on_spawn_enemy() -> void:
	var enemy: Enemy = _ENEMY_SCENE.instantiate()
	add_child(enemy)
	enemy.tree_exiting.connect(_on_enemy_tree_exiting.bind(enemy))
	enemy.deactivate()
	_inactive.append(enemy)


func _on_activate_enemy(pos: Vector3) -> void:
	if _inactive.is_empty():
		push_warning("No inactive enemies to activate — pool exhausted")
		return
	var enemy: Enemy = _inactive.pop_back()
	active.append(enemy)
	enemy.setup(player, pos, enemy_grid)


func _on_deactivate_enemy(e: Enemy) -> void:
	active.erase(e)
	_inactive.append(e)


func _on_enemy_tree_exiting(enemy: Enemy) -> void:
	assert(false, "Enemy left tree unexpectedly: %s" % enemy.name)
	while _inactive.has(enemy):
		_inactive.erase(enemy)
	while active.has(enemy):
		active.erase(enemy)
