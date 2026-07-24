extends Node3D
class_name StringsInstrumentAttack

@export var knockback := 2.0
@export var damage: int = 9

## Minimum distance the disc flies out. The out target never lands closer than this.
@export var min_throw_radius := 4.0
## Maximum distance the disc flies out.
@export var max_throw_radius := 6.0
## Initial outward speed. The return pull is derived from this.
@export var throw_speed := 16.0
## Distance to the player that counts as "reached" on the return leg.
@export var catch_radius := 1.5
## Seconds to keep flying past the player before despawning.
@export var flyoff_time := 0.6

@onready var _skin: Node3D = %StringsInstrumentAttackSkin

enum Phase { OUT, RETURN, FLYOFF }

var _player: Player
var _phase: int = Phase.OUT
var _out_target: Vector3
var _velocity: Vector3
var _launched: bool = false
var _flyoff_elapsed: float = 0.0


func setup(p: Player) -> void:
	_player = p
	var angle := randf() * TAU
	var dir := Vector3(cos(angle), 0.0, sin(angle))
	var radius := randf_range(min_throw_radius, max_throw_radius)
	_out_target = _player.attack_emission_point.global_position + dir * radius
	_velocity = dir * throw_speed
	_launched = true


func _physics_process(delta: float) -> void:
	if _skin:
		_skin.rotate_y(throw_speed * delta)

	if not _launched:
		return

	var player_pos := _player.attack_emission_point.global_position

	match _phase:
		Phase.OUT:
			if global_position.distance_squared_to(_out_target) <= 0.4:
				_phase = Phase.RETURN
		Phase.RETURN:
			# Pull toward the player; derived from throw so it always comes home.
			var pull := throw_speed * throw_speed / max_throw_radius
			_velocity += (player_pos - global_position).normalized() * pull * delta
			_velocity = _velocity.limit_length(throw_speed * 1.5)
			# Reached the player: commit to current heading and fly off.
			if global_position.distance_squared_to(player_pos) <= catch_radius * catch_radius:
				_phase = Phase.FLYOFF
		Phase.FLYOFF:
			# No more pull — coast straight on the velocity we had, then despawn.
			_flyoff_elapsed += delta
			if _flyoff_elapsed >= flyoff_time:
				queue_free()

	global_position += _velocity * delta

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is EnemyHurtBox:
		var enemy: Enemy = area.enemy
		enemy.hit(damage, global_position.direction_to(enemy.global_position), knockback)