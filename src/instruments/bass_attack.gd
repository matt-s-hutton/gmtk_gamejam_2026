@tool
extends Node3D
class_name BassAttack

@export var preview_in_editor: bool = false:
	set(value):
		preview_in_editor = value
		if value and Engine.is_editor_hint():
			_timer = 0.0
			_playing = true
@export var effect_speed: float = 3.0
@export var lifetime: float = 1.0
@export var width_scale: float = 1.6
@export_exp_easing("inout") var progress_easing: float = 0.25
@export_exp_easing("inout") var width_in_easing: float = 1.5
@export_exp_easing("inout") var width_out_easing: float = 0.25
@export_range(0.0, 1.0) var width_center_time: float = 0.3

@export var knockback := 3.0
@export var damage: int = 8

@onready var _mesh: MeshInstance3D = %MeshInstance3D

var _emitter: Node3D
var _dir: Vector3

var _mat: ShaderMaterial
var _timer: float = 0.0
var _playing: bool = false


func _ready() -> void:
	_mat = _mesh.material_override


func setup(e: Node3D, dir: Vector3) -> void:
	assert(dir.is_normalized(), "Direction passed to bass attack setup was not normalised: %s" % dir)
	_emitter = e
	_dir = dir
	global_position = _emitter.global_position
	global_rotation.y = atan2(_dir.x, _dir.z)
	_timer = 0.0
	_playing = true


func _process(delta: float) -> void:
	if not _playing:
		return

	_timer += delta * effect_speed

	_mat.set_shader_parameter("progress", clamp(ease(_timer, progress_easing), 0.0, 1.0))

	var width := 0.0
	if _timer < width_center_time:
		width = ease(_timer / width_center_time, width_in_easing) * width_scale
	else:
		width = (1.0- ease((_timer - width_center_time) / (lifetime - width_center_time),width_out_easing)) * width_scale
	_mat.set_shader_parameter("width", clamp(width, 0.0, 1.0))

	if _timer >= lifetime:
		if Engine.is_editor_hint():
			_playing = false
			_mat.set_shader_parameter("progress", 0.0)
		else:
			queue_free()


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is EnemyHurtBox:
		var enemy: Enemy = area.enemy
		enemy.hit(damage, global_position.direction_to(enemy.global_position), knockback)
