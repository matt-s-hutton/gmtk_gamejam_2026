extends Node3D

@export var player: Player

const _BASS_ATTACK_SCENE: PackedScene = preload("res://src/instruments/bass_attack.tscn")


func _on_attack_timer_timeout() -> void:
	var player_dir: Vector3 = player.facing_dir
	if player_dir == Vector3.ZERO:
		player_dir = Vector3(0, 0, -1)
	var bass_attack: BassAttack = _BASS_ATTACK_SCENE.instantiate()
	add_child(bass_attack)
	bass_attack.global_position = player.attack_emission_point.global_position
	bass_attack.setup(player.attack_emission_point, player_dir)
