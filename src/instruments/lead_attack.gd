extends CharacterBody3D
class_name LeadAttack
@export var cell_size: float = 150
var player: Player
var _enemy_grid: EnemyGrid
var vector_attack: Vector3
var max_speed: float = 50.0
@export var knockback := 3.0
@export var damage: int = 8

var _target: Node3D

func _ready() -> void:
	set_physics_process(false)

func setup(pos: Vector3, enemy_grid: EnemyGrid, target: Node3D) -> void:
	global_position = pos
	_enemy_grid = enemy_grid
	_target = target
	set_physics_process(true)


func _key(pos: Vector3) -> Vector2i:
	return Vector2i(
		floori(pos.x / cell_size),
		floori(pos.z / cell_size),
	)

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(_target):
		self.queue_free()

	if not is_instance_valid(_target):
		velocity = Vector3.ZERO
		return

	var desired_direction := global_position.direction_to(
		_target.global_position
	)

	velocity = desired_direction * max_speed
	move_and_slide()


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is EnemyHurtBox:
		var enemy: Enemy = area.enemy
		enemy.hit(damage, global_position.direction_to(enemy.global_position), knockback)
		self.queue_free()
