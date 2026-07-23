extends MeshInstance3D
class_name RhythmArrow

const HIT_WINDOW_BEATS: float = 0.2   # keep in sync with the controller (shared constant/autoload ideally)
var _direction: Vector3
var target_beat: float = 0.0      # the beat this arrow must be hit on
var lead_beats: float = 2.0       # how many beats it travels from spawn to ring
var travel_distance: float = 10.0

@export var enabled: bool = false

signal missed(arrow)

func recolor(color: Color) -> void:
	var new_material: Material = get_active_material(0).duplicate()
	new_material.set("albedo_color", color)
	set_surface_override_material(0, new_material)

func setup(angle, direction, color, _target_beat: float, _lead_beats: float) -> void:
	_direction = direction
	target_beat = _target_beat
	lead_beats = _lead_beats
	enabled = true
	rotate(Vector3.UP, deg_to_rad(angle))
	recolor(color)

func _process(_delta: float) -> void:
	if not enabled:
		return

	# progress: 0.0 at spawn (lead_beats before target), 1.0 exactly on the ring at target_beat
	var progress := float(1.0 - (target_beat - Conductor.current_beat) / lead_beats)
	position = _direction * travel_distance * progress

	# passed the hit window unhit → miss, remove so it can't shadow later arrows
	if Conductor.current_beat > target_beat + HIT_WINDOW_BEATS:
		enabled = false
		missed.emit()
		queue_free()
