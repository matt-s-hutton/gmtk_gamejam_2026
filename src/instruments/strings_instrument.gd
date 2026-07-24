extends Node3D
class_name StringsInstrument

@export var player: Player

const _STRINGS_INSTRUMENT_ATTACK_SCENE: PackedScene = preload("res://src/instruments/strings_instrument_attack.tscn")


func _on_attack_timer_timeout() -> void:
	var strings_attack: StringsInstrumentAttack = _STRINGS_INSTRUMENT_ATTACK_SCENE.instantiate()
	player.add_sibling(strings_attack)
	strings_attack.setup(player)
	strings_attack.global_position = player.attack_emission_point.global_position
