extends Node3D
class_name Enemy

@export var move_speed: float = 2.0
@export var stop_distance: float = 1.0
@export var turn_speed: float = 5.0
@export var max_knockback: float = 8.0
@export var initial_health: int = 20

@onready var _enemy_skin: EnemySkin = %EnemySkin

var _player: Player
var _health: int
var _pathing := false
var _knockback_velocity := Vector3.ZERO


func _ready() -> void:
	_health = initial_health


func setup(p: Player, pos: Vector3) -> void:
	_player = p
	global_position = pos
	_pathing = true


func _process(delta: float) -> void:
	if not _pathing or _player == null or is_queued_for_deletion():
		return

	# Decay knockback toward zero.
	_knockback_velocity = _knockback_velocity.move_toward(Vector3.ZERO, move_speed * delta)

	var target := _player.global_position
	var to_target := target - global_position
	to_target.y = 0.0

	var move := Vector3.ZERO
	if to_target.length() > stop_distance:
		var dir := to_target.normalized()
		move = dir * move_speed

		var target_yaw := atan2(dir.x, dir.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, turn_speed * delta)

	global_position += (move + _knockback_velocity) * delta


func hit(dmg_amount: int, knockback_dir: Vector3, knockback_amount: float) -> void:
	_damage(dmg_amount)
	_knockback(knockback_dir, knockback_amount)


func _damage(amount: int) -> void:
	assert(amount > 0)
	if amount <= 0 or _health <= 0:
		return
	_health = maxi(_health - amount, 0)
	if _health == 0:
		queue_free()
	else:
		_enemy_skin.flash()


func _knockback(dir: Vector3, amount: float) -> void:
	_knockback_velocity = (_knockback_velocity + dir * amount).limit_length(max_knockback)
