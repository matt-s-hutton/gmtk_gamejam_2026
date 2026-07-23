extends Node3D
class_name EnemyGrid

@export var cell_size: float

var _cells: Dictionary = {}  # Vector2i: Array[Enemy]


func _physics_process(_delta: float) -> void:
	clear()
	for node in get_tree().get_nodes_in_group('enemies'): # Needs to change if we start pooling enemies
		assert(node is Enemy, "Non-Enemy node in 'enemies' group: %s" % node.name)
		if not node is Enemy:
			continue
		insert(node)


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


func get_neighbors(pos: Vector3, out: Array) -> void:
	out.clear()
	var base := _key(pos)
	for dx in range(-1, 2):
		for dz in range(-1, 2):
			var k := base + Vector2i(dx, dz)
			if _cells.has(k):
				out.append_array(_cells[k])
