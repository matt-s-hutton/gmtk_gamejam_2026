extends MeshInstance3D
class_name EnemySkin

@export var rotation_speed: float = 1.0
@export var spin_speed: float = 2.0
@export var flash_decay: float = 5.0

var _flash_material: ShaderMaterial
var _flash := 0.0

var colours: Array[Color] = [
	Color('#19647E'),
	Color('#9E829C'),
	Color('#9F2042'),
	Color('#5CAB7D'),
	Color('#F2E86D'),
]


func _ready() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = colours[randi() % colours.size()]

	_flash_material = ShaderMaterial.new()
	_flash_material.shader = load("res://src/enemy/enemy_damage.gdshader")
	material.next_pass = _flash_material

	material_override = material


func _process(delta: float) -> void:
	var rand_offset = randf()
	rotate_x((1 + rand_offset) * delta)
	rotate_z((1 + rand_offset) * delta)
	rotate_y((2 + rand_offset) * delta)

	if _flash > 0.0:
		_flash = max(_flash - flash_decay * delta, 0.0)
		_flash_material.set_shader_parameter("flash", _flash)


func flash() -> void:
	_flash = 1.0
	_flash_material.set_shader_parameter("flash", _flash)


func _on_orthnormalise_timer_timeout() -> void:
	basis = basis.orthonormalized()