extends Node3D

@export var player: Player
@export var _enemy_grid: EnemyGrid
@export var search_radius: int = 6

const _LEAD_ATTACK_SCENE: PackedScene = preload("res://src/instruments/lead_attack.tscn")

func _ready() -> void:
	_enemy_grid = get_tree().get_first_node_in_group("enemy_grid") as EnemyGrid

func _on_atack_timer_timeout() -> void:
	var target = get_nearest_enemy_from_grid(player.global_position, search_radius)
	if not is_instance_valid(target):
		return
	var lead_attack: LeadAttack = _LEAD_ATTACK_SCENE.instantiate()
	player.add_sibling(lead_attack)
	lead_attack.global_position = player.attack_emission_point.global_position
	lead_attack.setup(player.attack_emission_point.global_position, _enemy_grid, target)

func get_nearest_enemy_from_grid(
	pos: Vector3,
	radius: int
) -> Node3D:
	if not is_instance_valid(_enemy_grid):
		return null

	var nearby_enemies: Array = []
	_enemy_grid.get_neighbors(pos, nearby_enemies, radius)

	var nearest_enemy: Node3D = null
	var min_dist_sq: float = INF

	for enemy in nearby_enemies:
		if not is_instance_valid(enemy):
			continue

		var dist_sq := pos.distance_squared_to(enemy.global_position)

		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			nearest_enemy = enemy

	return nearest_enemy
