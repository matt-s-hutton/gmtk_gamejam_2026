extends MeshInstance3D
class_name RhythmArrow

var _direction: Vector3
var _speed: float

@export var enabled: bool = false
@export var total_beats: int = 0
@export var beat_delta: float = 0.0

# A little jank right now
func recolor(color: Color) -> void:
	var new_material: Material = get_active_material(0).duplicate()
	new_material.set("albedo_color", color)
	set_surface_override_material(0, new_material)

func setup(angle, direction, color, speed) -> void:
	_direction = direction
	_speed = speed
	
	enabled = true
	
	rotate(Vector3.UP, deg_to_rad(angle))
	recolor(color)

func _process(delta: float) -> void:
	if enabled: position = position.move_toward(_direction * 10, delta * _speed)
	beat_delta += delta
