extends Node3D
class_name Drums

@export var player: Player


const _DRUMS_ATTACK_SCENE: PackedScene = preload("res://src/instruments/drums_attack.tscn")


func _on_attack_timer_timeout() -> void:
	var drums_attack: DrumsAttack = _DRUMS_ATTACK_SCENE.instantiate()
	player.add_sibling(drums_attack)
	drums_attack.global_position = player.global_position
	drums_attack.setup(player)
