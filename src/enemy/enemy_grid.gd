extends Node3D
class_name EnemyGrid

@export var cell_size: float
@export var enemy_manager: EnemyManager

var _cells: Dictionary = {}  # Vector2i: Array[Enemy]


func _physics_process(_delta: float) -> void:
	clear()
	for enemy in enemy_manager.active:
		insert(enemy)


func _key(pos: Vector3) -> Vector2i:
	return Vector2i(
		floori(pos.x / cell_size),
		floori(pos.z / cell_size),
	)


func clear() -> void:
	_cells.clear()


func insert(enemy: Enemy) -> void:
	var k := _key(enemy.global_position)
	if not _cells.has(k):
		_cells[k] = []
	_cells[k].append(enemy)


func get_neighbors(pos: Vector3, out: Array, radius: int = 1) -> void:
	out.clear()
	var base := _key(pos)
	for dx in range(-radius, radius + 1):
		for dz in range(-radius, radius + 1):
			var k := base + Vector2i(dx, dz)
			if _cells.has(k):
				out.append_array(_cells[k])
