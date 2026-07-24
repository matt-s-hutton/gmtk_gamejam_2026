extends Node3D
class_name Keyboard

@export var player: Player
@export var min_attack_radius: float = 6
@export var max_attack_radius: float = 14

const _KEYBOARD_ATTACK_SCENE: PackedScene = preload("res://src/instruments/keyboard_attack.tscn")


func _on_attack_timer_timeout() -> void:
	var keyboard_attack: KeyboardAttack = _KEYBOARD_ATTACK_SCENE.instantiate()
	player.add_sibling(keyboard_attack)

	var origin: Vector3 = player.attack_emission_point.global_position
	var angle: float = randf() * TAU
	var dist: float = sqrt(lerp(min_attack_radius * min_attack_radius, max_attack_radius * max_attack_radius, randf()))
	keyboard_attack.global_position = origin + Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)
