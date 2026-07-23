extends Node3D
class_name DrumsAttack

@export var attack_radius := 7.0
@export var radius_expansion_rate := 18.0
@export var knockback := 3.0
@export var damage: int = 8

@onready var _attack_mesh: MeshInstance3D = %MeshInstance3D
@onready var _attack_collision_shape: CollisionShape3D = %CollisionShape3D

var _origin_node: Node3D
var _expanding := false
var _radius := 0.0


func setup(o: Node3D) -> void:
	_origin_node = o
	_expanding = true


func _process(delta: float) -> void:
	if _origin_node != null:
		global_position = _origin_node.global_position
	if not _expanding or is_queued_for_deletion():
		return
	_radius = clampf(_radius + radius_expansion_rate * delta, 0.0, attack_radius)
	_attack_mesh.mesh.radius = _radius
	_attack_collision_shape.shape.radius = _radius
	if _radius == attack_radius:
		queue_free()


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is EnemyHurtBox:
		var enemy: Enemy = area.enemy
		enemy.hit(damage, global_position.direction_to(enemy.global_position), knockback)
