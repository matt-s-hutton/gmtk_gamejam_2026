extends Node3D
class_name KeyboardAttack


@onready var _hit_warning_mesh: MeshInstance3D = %WarningMarkerMesh
@onready var _bomb_mesh: MeshInstance3D = %BombMesh

const _KEYBOARD_ATTACK_HIT_SCENE: PackedScene = preload("res://src/instruments/keyboard_attack_hit.tscn")

const _FADE_SPEED: float = 8.0
const _MAX_ALPHA: float = 0.5
const _DROP_SPEED: float = 48.0  # units per second

var _mat: StandardMaterial3D
var _time: float = 0.0
var _dropping: bool = false
var _target_y: float = 0.0


func _ready() -> void:
	_mat = _hit_warning_mesh.mesh.material
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_target_y = _hit_warning_mesh.position.y


func _process(delta: float) -> void:
	_time += delta * _FADE_SPEED
	var alpha: float = (sin(_time) * 0.5 + 0.5) * _MAX_ALPHA
	var c: Color = _mat.albedo_color
	c.a = alpha
	_mat.albedo_color = c

	if _dropping:
		var pos: Vector3 = _bomb_mesh.position
		pos.y = move_toward(pos.y, _target_y, _DROP_SPEED * delta)
		_bomb_mesh.position = pos
		if is_equal_approx(pos.y, _target_y):
			_dropping = false
			_spawn_hit_scene()
			queue_free()


func _spawn_hit_scene() -> void:
	var keyboard_attack_hit: Node3D = _KEYBOARD_ATTACK_HIT_SCENE.instantiate()
	add_sibling(keyboard_attack_hit)
	keyboard_attack_hit.global_position = global_position


func _on_drop_timer_timeout() -> void:
	_dropping = true