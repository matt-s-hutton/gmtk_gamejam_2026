extends Node3D
class_name Enemy

@export var move_speed: float = 2.0
@export var stop_distance: float = 1.0
@export var turn_speed: float = 5.0
@export var max_knockback: float = 8.0
@export var initial_health: int = 20
@export var separation_radius: float = 1.5
@export var separation_strength: float = 4.0
@export var separation_update_interval: int = 4

@onready var _enemy_skin: EnemySkin = %EnemySkin
@onready var _hit_stream_player: AudioStreamPlayer3D = %HitStreamPlayer

const _GRAVEYARD := Vector3(0, -1000, 0)

var _player: Player
var _health: int
var _pathing := false
var _knockback_velocity := Vector3.ZERO
var _enemy_grid: EnemyGrid
var _neighbor_buffer: Array = []
var _cached_push := Vector3.ZERO
var _separation_frame_offset: int = 0


func setup(p: Player, pos: Vector3, enemy_grid: EnemyGrid) -> void:
	set_physics_process(true)
	_player = p
	global_position = pos
	_enemy_grid = enemy_grid
	_health = initial_health
	_knockback_velocity = Vector3.ZERO
	_cached_push = Vector3.ZERO
	_separation_frame_offset = get_instance_id() % separation_update_interval
	_pathing = true


func deactivate() -> void:
	_pathing = false
	set_physics_process(false)
	global_position = _GRAVEYARD


func _die() -> void:
	if not _pathing:
		return
	deactivate()
	EnemyService.request_deactivate_enemy(self)


func _physics_process(delta: float) -> void:
	if not _pathing or _player == null or _enemy_grid == null:
		return

	_knockback_velocity = _knockback_velocity.move_toward(Vector3.ZERO, move_speed * delta)

	var to_target := _player.global_position - global_position
	to_target.y = 0.0

	var move := Vector3.ZERO
	if to_target.length() > stop_distance:
		move = to_target.normalized() * move_speed

	move += _separation_force()

	if move.length() > 0.01:
		var target_yaw := atan2(move.x, move.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, turn_speed * delta)

	global_position += (move + _knockback_velocity) * delta
	global_position.y = 0.0


func _separation_force() -> Vector3:
	if (Engine.get_physics_frames() + _separation_frame_offset) % separation_update_interval == 0:
		_cached_push = _compute_separation()
	return _cached_push


func _compute_separation() -> Vector3:
	_enemy_grid.get_neighbors(global_position, _neighbor_buffer)
	var push := Vector3.ZERO
	var r_sq := separation_radius * separation_radius
	for other in _neighbor_buffer:
		if other == self:
			continue
		var away: Vector3 = global_position - other.global_position
		away.y = 0.0
		var d_sq := away.length_squared()
		if d_sq < r_sq:
			if d_sq > 0.0001:
				push += away * ((1.0 - d_sq / r_sq) / d_sq)
			else:
				var angle := float(get_instance_id() % 628) * 0.01
				push += Vector3(cos(angle), 0.0, sin(angle))
	return push * separation_strength


func hit(dmg_amount: int, knockback_dir: Vector3, knockback_amount: float) -> void:
	_hit_stream_player.play()
	_damage(dmg_amount)
	_knockback(knockback_dir, knockback_amount)


func _damage(amount: int) -> void:
	assert(amount >= 0, "Damage must be non-negative, got %d" % amount)
	if amount <= 0 or _health <= 0:
		return
	_health = maxi(_health - amount, 0)
	if _health == 0:
		_die()
	else:
		_enemy_skin.flash()


func _knockback(dir: Vector3, amount: float) -> void:
	_knockback_velocity = (_knockback_velocity + dir * amount).limit_length(max_knockback)
