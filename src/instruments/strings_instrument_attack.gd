extends Node3D
class_name StringsInstrumentAttack

@export var knockback := 2.0
@export var damage: int = 9

## Radius around the player for the outward throw target.
@export var throw_radius := 6.0
## Initial outward throw speed (units/sec).
@export var throw_speed := 16.0
## Pull toward the player once returning (units/sec^2).
@export var return_accel := 40.0
## Optional cap on how fast the disc can travel (units/sec). 0 = uncapped.
@export var max_speed := 24.0
## Distance-squared to the outward point that flips OUT -> RETURN.
@export var reach_threshold_sq := 0.4
## Distance-squared to the player that counts as caught and despawns.
@export var catch_threshold_sq := 0.6
## Spin speed (radians/sec) for visual flair.
@export var spin_speed := 20.0

@onready var _skin: Node3D = %StringsInstrumentAttackSkin

enum Phase { OUT, RETURN }

var _player: Player
var _phase: int = Phase.OUT
var _out_target: Vector3
var _velocity: Vector3
var _launched: bool = false


func setup(p: Player) -> void:
	_player = p
	var angle := randf() * TAU
	var dir := Vector3(cos(angle), 0.0, sin(angle))
	_out_target = _player.attack_emission_point.global_position + dir * throw_radius
	_velocity = dir * throw_speed
	_launched = true


func _physics_process(delta: float) -> void:
	if _skin:
		_skin.rotate_y(spin_speed * delta)

	if not _launched:
		return

	match _phase:
		Phase.OUT:
			# Coast outward at the throw velocity, no acceleration yet.
			if global_position.distance_squared_to(_out_target) <= reach_threshold_sq:
				_phase = Phase.RETURN
		Phase.RETURN:
			# Every tick, pull velocity toward the player's live position.
			# This decelerates the outward drift, reverses it, then accelerates home.
			var to_player := _player.attack_emission_point.global_position - global_position
			_velocity += to_player.normalized() * return_accel * delta

	if max_speed > 0.0:
		_velocity = _velocity.limit_length(max_speed)

	global_position += _velocity * delta

	if _phase == Phase.RETURN:
		var player_pos := _player.attack_emission_point.global_position
		if global_position.distance_squared_to(player_pos) <= catch_threshold_sq:
			queue_free()